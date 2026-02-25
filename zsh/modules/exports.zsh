export PATH="/opt/homebrew/bin:$PATH"
export PATH="$PATH:$HOME/tools"
export PATH="/usr/local/bin:$PATH"

# Android
export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"

# Bun
export PATH="$PATH:$HOME/.bun/bin"

# リポジトリの bin/ を PATH に追加（~/.zsh symlink からリポジトリルートを解決）
if [ -L "$HOME/.zsh" ]; then
    export PATH="$(dirname "$(readlink "$HOME/.zsh")")/bin:$PATH"
fi

# Claude Code
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS="true"

