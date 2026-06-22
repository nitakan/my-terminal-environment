---
name: team-workflow
description: >
  This skill should be used when the user asks to "implement a plan with a team",
  "create a team for implementation", "execute implementation plan", "use the team
  workflow", "delegate to architect and members", "チームで実装して",
  "実装計画を実行", "アーキテクトとメンバーに委任", or when an implementation plan
  specifies a team structure. Only invoke on explicit user request — do NOT
  auto-trigger based on task complexity or the number of files changed.
---

# Team Implementation Workflow

Structured workflow for executing implementation plans with a team of specialized agents.
The core value is the **design-review layer**: an architect reads actual code, creates precise
instructions, and reviews output—preventing interpretation errors that occur when directly
delegating plans to implementation agents.

## Decision Criteria

Use this workflow when:
- Target files exceed 5, or changes span multiple architectural layers
- Refactoring or structural changes require understanding existing code before modifying it
- The implementation plan explicitly specifies a team structure

Do NOT use when:
- Design review overhead exceeds benefit (typo fixes, constant changes)
- A single-file modification requires no design judgment

## Team Composition

| Role | Responsibility |
|------|---------------|
| **team-lead** | User communication, team management, final review against the plan. Always the parent agent. |
| **architect** | Read target files, create design instructions for members, code review after implementation. |
| **member-\*** | Execute implementation per architect's instructions. Named by scope (member-server, member-app, member-web, etc.). |

## Subagent Delegation (Context Efficiency)

Architect and members MUST delegate actual work (file reading, implementation, investigation)
to subagents via the Agent tool. This preserves context window capacity for coordination,
preventing context exhaustion in long-running team sessions.

### Model Selection

The architect specifies the recommended model in design instructions.
Members use the specified model when spawning subagents.

| Complexity | Model | Examples |
|-----------|-------|---------|
| High | (omit `model`) | Multi-file refactoring, design decisions, type-safety verification |
| Low–Medium | `model: "sonnet"` | Single-file edits, mechanical changes, grep-based investigation |

**Important:** High complexity tasks must NOT specify `model: "opus"` — instead omit the `model`
parameter entirely so the subagent inherits the parent's model (Opus with 1M context).
Explicitly setting `model: "opus"` may downgrade to the default context window.

## Workflow

### 1. Setup

Create the team, tasks, and dependencies:

```
TeamCreate → TaskCreate (all tasks) → TaskUpdate (set blockedBy/addBlocks)
```

Spawn architect first, then members. All as `subagent_type: "general-purpose"` with
`team_name` set to the team name.

### 2. Architect → Team-Lead → User → Members: Design Instructions

The architect dispatches a subagent to read all target files (never instruct based on
assumptions), then sends the **team-lead** a `SendMessage` with design instructions.

**CRITICAL — User Approval Gate:**
The architect MUST send design instructions to the **team-lead**, NOT directly to members.
The team-lead then:
1. Shares the design instructions with the user
2. Asks for user approval (via AskUserQuestion)
3. Only after approval, forwards the instructions to the member

This prevents members from starting implementation before the user has reviewed
and approved the design. Sending instructions directly to members removes the user's
ability to catch design issues before code is written.

See `examples/architect-to-member-message.md` for a concrete message format.

**Who designs — Architect vs Member:**
- **Architect must design** when changes span multiple members (e.g., server + app),
  since cross-layer contract alignment (API schema, field names, behavior) requires
  a single source of truth to prevent drift.
- **A single member may design** when the change is fully contained within that member's
  scope (no cross-layer impact) and no architectural judgment is needed.
  - The member still dispatches subagents for code reading and implementation.
  - The member **must report the design decision and completion to the architect**
    so the architect maintains overall awareness and can challenge the approach if needed.
  - If the member discovers cross-layer impact mid-task, they escalate back to the architect.

**Known failure mode — Plan vs Code Reality:**
Implementation plans may contain inaccurate type information (e.g., "String typedef"
when the actual code uses a freezed class). The architect's subagent must verify types
and API signatures in the actual code before issuing instructions. Always trust code
over plan descriptions.

### 3. Members: Implementation

Each member:

1. Claims tasks via `TaskUpdate` (set owner, status: in_progress)
2. Dispatches a subagent (Opus or Sonnet as specified by architect) to implement
3. Reports completion to architect via `SendMessage`
4. Marks tasks completed via `TaskUpdate`

### 4. Architect: Code Review

The architect dispatches a subagent to read all changed files and verifies changes
match design instructions.

- Issues found → send feedback to member → member fixes → re-review
- Approved → report to team-lead

### 5. Team-Lead: Final Review

The team-lead verifies against the **original plan**:

- No deviations in naming, behavior, or scope
- Files marked "do not modify" are untouched
- Grep confirms zero remaining references to removed classes/methods
- Behavioral backward compatibility preserved (e.g., default/fallback cases)

**Known failure mode — Scope Discipline:**
Members may modify files outside the plan's scope. The team-lead must catch scope
violations and revert them before approval.

If deviations found → send correction to architect → architect delegates to member.

**Known failure mode — Context Compression Resilience:**
The architect may lose prior answers due to context compression. When the architect
re-asks a previously answered question, the team-lead resends the decision with
full reasoning.

### 6. Shutdown

**CRITICAL — User Approval Required:**
Do NOT shut down the team automatically after all tasks complete.
The team-lead must ask the user for permission before shutting down (via AskUserQuestion).
The user may need the team for follow-up work (commits, PRs, additional fixes).

After receiving user approval, send `SendMessage` with shutdown request to each agent:

```json
{"type": "shutdown_request", "reason": "All tasks completed and reviewed."}
```

## Additional Resources

### Examples
- **`examples/architect-to-member-message.md`** — Concrete SendMessage payload showing the Why/What/Constraints/Order format
