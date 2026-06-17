# Repository-scoped GitHub CLI account switching (generic engine; no identifiers).
#
# Resolves a gh account from the current repo's `origin` remote and exports
# GH_TOKEN for it. The token is read from gh's keyring on demand and cached in
# memory only — it is never written to disk. Define the mapping in
# ~/.zsh/local.zsh (Git-ignored); see zsh/local.zsh.example.
autoload -U add-zsh-hook
typeset -gA _GH_TOKEN_CACHE

gh_account_sync() {
  local url="" account="" tok="" pat=""
  url=$(git config --get remote.origin.url 2>/dev/null)
  if [[ -n "$url" ]] && (( ${+GH_ACCOUNT_RULES} )); then
    for pat in ${(k)GH_ACCOUNT_RULES}; do
      [[ "$url" == *"$pat"* ]] && { account=${GH_ACCOUNT_RULES[$pat]}; break }
    done
  fi
  : ${account:=${GH_ACCOUNT_DEFAULT:-}}
  [[ -z "$account" ]] && { unset GH_TOKEN; return }
  [[ -z "${_GH_TOKEN_CACHE[$account]:-}" ]] && \
    _GH_TOKEN_CACHE[$account]=$(gh auth token -u "$account" 2>/dev/null)
  tok=${_GH_TOKEN_CACHE[$account]:-}
  [[ -n "$tok" ]] && export GH_TOKEN="$tok" || unset GH_TOKEN
}

# Re-resolve GH_TOKEN for the current repo and report (runs in the current shell).
# Drop any pre-existing `ghs` alias so re-sourcing this file does not error.
unalias ghs 2>/dev/null
ghs() {
  gh_account_sync
  local url="" who=""
  url=$(git config --get remote.origin.url 2>/dev/null)
  who=$(gh api user --jq .login 2>/dev/null)
  print -r -- "remote : ${url:-(none)}"
  print -r -- "account: ${who:-(unknown)}"
}

add-zsh-hook chpwd gh_account_sync
