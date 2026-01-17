export PATH="/opt/homebrew/bin:$PATH"
export PATH="$PATH:$HOME/tools"

# Anyenv
# export PATH="$HOME/.anyenv/bin:$PATH"
# eval "$(/opt/homebrew/bin/brew shellenv)"
# eval "$(anyenv init -  --no-rehash)"
# eval "$(rbenv init -  --no-rehash)"

# Deno
export PATH="$HOME/.deno/bin:$PATH"

# Android
export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"

# Bun
export PATH="$PATH:$HOME/.bun/bin"

export ENABLE_TOOL_SEARCH=true
export ENABLE_EXPERIMENTAL_MCP_CLI=false

# ~/.local/bin をPATHに追加（スクリプト用）
export PATH="$HOME/.local/bin:$PATH"

# Zellij alias
alias z='zellij'

# gwq (git worktree manager)
eval "$(gwq completion zsh)"
