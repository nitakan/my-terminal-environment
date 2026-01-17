# Core modules
source ~/.zsh/modules/basic.zsh
source ~/.zsh/modules/exports.zsh
source ~/.zsh/modules/alias.zsh
source ~/.zsh/modules/environment.zsh
source ~/.zsh/modules/prompts.zsh
source ~/.zsh/modules/git.zsh
source ~/.zsh/modules/completions.zsh

# Optional modules
[[ -f ~/.zsh/modules/optional/flutter.zsh ]] && source ~/.zsh/modules/optional/flutter.zsh
[[ -f ~/.zsh/modules/optional/bun.zsh ]] && source ~/.zsh/modules/optional/bun.zsh
[[ -f ~/.zsh/modules/optional/deno.zsh ]] && source ~/.zsh/modules/optional/deno.zsh
[[ -f ~/.zsh/modules/optional/gcloud.zsh ]] && source ~/.zsh/modules/optional/gcloud.zsh

# Secrets (Git管理外)
[[ -f ~/.zsh/secrets ]] && source ~/.zsh/secrets

# Local machine-specific settings (Git管理外)
[[ -f ~/.zsh/local.zsh ]] && source ~/.zsh/local.zsh
