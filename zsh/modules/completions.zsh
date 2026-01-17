# Git completion
autoload -Uz compinit && compinit
fpath=(~/.zsh/git $fpath)
zstyle ':completion:*:*:git:*' script ~/.zsh/git/git-completion.bash

# Additional completions directory
fpath=(~/.zsh/completions $fpath)
