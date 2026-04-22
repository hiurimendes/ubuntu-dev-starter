#!/usr/bin/env bash

setup_github_cli_repo() {
  run_cmd "mkdir -p -m 755 /etc/apt/keyrings"

  if [[ ! -f /etc/apt/keyrings/githubcli-archive-keyring.gpg ]] || [[ "$DRY_RUN" -eq 1 ]]; then
    run_cmd "curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/etc/apt/keyrings/githubcli-archive-keyring.gpg 2>/dev/null"
    run_cmd "chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg"
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[dry-run] configurar repo GitHub CLI"
  else
    cat > /etc/apt/sources.list.d/github-cli.list <<EOG
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main
EOG
  fi

  reset_apt_cache_flag
}

install_github_cli() {
  setup_github_cli_repo
  install_apt_packages gh
}
