#!/bin/bash

# Claude Code Status Line Script
# Displays project info and cost information from ccusage

# Read JSON input from stdin
input=$(cat)

# Extract basic information
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
project_dir=$(git rev-parse --show-toplevel 2>/dev/null || echo "$current_dir")
model=$(echo "$input" | jq -r '.model.display_name')

# Calculate relative path from project root
if [ "$current_dir" = "$project_dir" ]; then
    folder="$(basename "$project_dir")"
else
    # Remove project_dir prefix and leading slash
    rel_path="${current_dir#$project_dir}"
    rel_path="${rel_path#/}"
    folder="$(basename "$project_dir")/$rel_path"
fi

# Detect project type and language info
lang_info=""

# Check for Python project (venv exists or Python files present)
if [ -n "$VIRTUAL_ENV" ]; then
    # Python project with virtual environment
    venv_raw=$(echo "${VIRTUAL_ENV##*/}" | sed 's/-[0-9].*//')
    if [ "$venv_raw" = ".venv" ] || [ "$venv_raw" = "venv" ]; then
        venv="($folder)"
    else
        venv="($venv_raw)"
    fi
    pyver=$(python3 --version 2>/dev/null | cut -d' ' -f2 || echo 'N/A')
    lang_info=" | 💼 $venv | 🐍 $pyver"
elif [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ] || [ -f "Pipfile" ]; then
    # Python project without venv
    pyver=$(python3 --version 2>/dev/null | cut -d' ' -f2 || echo 'N/A')
    lang_info=" | 🐍 $pyver"
elif [ -f "go.mod" ] || [ -f "go.sum" ] || ls *.go >/dev/null 2>&1; then
    # Go project
    gover=$(go version 2>/dev/null | grep -oE 'go[0-9]+\.[0-9]+(\.[0-9]+)?' | sed 's/go//' || echo 'N/A')
    if [ "$gover" != "N/A" ]; then
        lang_info=" | 🦫 $gover"
    fi
fi

# Git branch
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'N/A')

# Context window remaining percentage
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
context_info=""
if [ -n "$remaining" ]; then
    # Format with one decimal place
    context_info=" | 🧠 $(printf "%.1f" "$remaining")%"
fi

# 5-hour session usage from OAuth API
usage_info=""
credentials=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
if [ -z "$credentials" ]; then
    usage_info=" | ⚠️ Auth:NoCredentials"
else
    access_token=$(echo "$credentials" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
    if [ -z "$access_token" ]; then
        usage_info=" | ⚠️ Auth:NoToken"
    else
        claude_version=$(claude --version 2>/dev/null | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+' || echo "2.1.19")
        usage_response=$(curl -s "https://api.anthropic.com/api/oauth/usage" \
            -H "Authorization: Bearer $access_token" \
            -H "anthropic-beta: oauth-2025-04-20" \
            -H "User-Agent: claude-code/${claude_version}" 2>/dev/null)
        if [ -z "$usage_response" ]; then
            # API failed - show cost from ccusage instead
            if command -v bun >/dev/null 2>&1; then
                blocks_json=$(bun x ccusage blocks --active --json 2>/dev/null)
                if [ -n "$blocks_json" ]; then
                    json_session_cost=$(echo "$blocks_json" | jq -r '.blocks[0].costUSD // empty' 2>/dev/null)
                    if [ -n "$json_session_cost" ] && [ "$json_session_cost" != "null" ]; then
                        usage_info=" | 💸 \$$(printf "%.2f" "$json_session_cost")"
                    fi
                fi
            fi
        elif echo "$usage_response" | jq -e '.error' >/dev/null 2>&1; then
            # API error (likely not Max Plan) - show cost from ccusage instead
            if command -v bun >/dev/null 2>&1; then
                blocks_json=$(bun x ccusage blocks --active --json 2>/dev/null)
                if [ -n "$blocks_json" ]; then
                    json_session_cost=$(echo "$blocks_json" | jq -r '.blocks[0].costUSD // empty' 2>/dev/null)
                    if [ -n "$json_session_cost" ] && [ "$json_session_cost" != "null" ]; then
                        usage_info=" | 💸 \$$(printf "%.2f" "$json_session_cost")"
                    fi
                fi
            fi
        else
            # Function to create progress bar
            make_bar() {
                local pct=$1
                local width=10
                local filled=$(echo "$pct * $width / 100" | bc 2>/dev/null || echo 0)
                local empty=$((width - filled))
                local bar=""
                for ((i=0; i<filled; i++)); do bar+="█"; done
                for ((i=0; i<empty; i++)); do bar+="░"; done
                echo "$bar"
            }

            # Function to get color based on percentage
            get_color() {
                local pct=$1
                if [ "$pct" -ge 90 ]; then
                    echo "🔴"
                elif [ "$pct" -ge 70 ]; then
                    echo "🟡"
                else
                    echo "🟢"
                fi
            }

            # Function to format time remaining
            format_time() {
                local reset_at=$1
                local now=$(date +%s)
                # Remove timezone info and parse as UTC
                local clean_time=$(echo "$reset_at" | sed 's/\.[0-9]*+.*//; s/\.[0-9]*-.*//')
                local reset_ts=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$clean_time" +%s 2>/dev/null || echo 0)
                if [ "$reset_ts" -gt 0 ] && [ "$reset_ts" -gt "$now" ]; then
                    local diff=$((reset_ts - now))
                    local hours=$((diff / 3600))
                    local mins=$(((diff % 3600) / 60))
                    echo "${hours}h${mins}m"
                fi
            }

            usage_parts=()

            # 5-hour limit
            five_hour_util=$(echo "$usage_response" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
            five_hour_reset=$(echo "$usage_response" | jq -r '.five_hour.resets_at // empty' 2>/dev/null)
            if [ -n "$five_hour_util" ] && [ "$five_hour_util" != "null" ]; then
                pct=$(printf "%.0f" "$five_hour_util")
                bar=$(make_bar "$pct")
                color=$(get_color "$pct")
                time_left=""
                if [ -n "$five_hour_reset" ]; then
                    time_left=$(format_time "$five_hour_reset")
                    if [ -n "$time_left" ]; then
                        time_left=" ($time_left)"
                    fi
                fi
                usage_parts+=("${color}5h:${bar}${pct}%${time_left}")
            fi

            # 7-day all models limit
            seven_day_util=$(echo "$usage_response" | jq -r '.seven_day.utilization // empty' 2>/dev/null)
            if [ -n "$seven_day_util" ] && [ "$seven_day_util" != "null" ]; then
                pct=$(printf "%.0f" "$seven_day_util")
                color=$(get_color "$pct")
                usage_parts+=("${color}7d:${pct}%")
            fi

            # Build usage info string
            if [ ${#usage_parts[@]} -gt 0 ]; then
                usage_info=" | "
                for i in "${!usage_parts[@]}"; do
                    if [ $i -gt 0 ]; then
                        usage_info="${usage_info} "
                    fi
                    usage_info="${usage_info}${usage_parts[$i]}"
                done
            fi
        fi
    fi
fi

# Output the complete status line
echo "📁 $folder${lang_info} | 🌿 $branch | 🤖 $model${context_info}${usage_info}"
