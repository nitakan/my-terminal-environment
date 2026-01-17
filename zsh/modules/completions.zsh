# fpath設定（compinit より先に設定する必要がある）
fpath=(~/.zsh/git ~/.zsh/completions $fpath)

# Git completion
zstyle ':completion:*:*:git:*' script ~/.zsh/git/git-completion.bash

# 補完システム初期化（1回だけ、キャッシュ活用）
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh-24) ]]; then
  # キャッシュが24時間以内なら再利用
  compinit -C
else
  # キャッシュがないか古い場合は再生成
  compinit
fi
