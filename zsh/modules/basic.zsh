# ビープ音を鳴らさない
setopt nolistbeep
# コマンドのスペルミスを指摘する
#setopt correct
# 諸々のパスを通す
export PATH="/usr/local/bin:$PATH"

# 履歴ファイルを明示
HISTFILE=~/.zsh_history

# タブ補完などを有効にする
autoload -Uz compinit && compinit
