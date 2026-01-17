# ビープ音を鳴らさない
setopt nolistbeep

# 履歴ファイルを明示
HISTFILE=~/.zsh_history

# タブ補完などを有効にする
autoload -Uz compinit && compinit
