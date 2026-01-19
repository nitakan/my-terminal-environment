# ssh-agentに鍵が登録されていなければバックグラウンドで追加
ssh-add -l &> /dev/null || (ssh-add -A &> /dev/null &)
# gwq (git worktree manager)
eval "$(gwq completion zsh)"

