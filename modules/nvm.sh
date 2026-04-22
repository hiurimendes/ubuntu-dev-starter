#!/usr/bin/env bash

get_latest_nvm_tag() {
  curl -fsSL "https://api.github.com/repos/nvm-sh/nvm/releases/latest" \
    | grep '"tag_name":' \
    | sed -E 's/.*"([^"]+)".*/\1/' \
    | head -n1
}

install_nvm() {
  local latest_nvm
  latest_nvm="$(get_latest_nvm_tag || true)"

  if [[ -n "$latest_nvm" ]]; then
    run_as_target_user "curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/${latest_nvm}/install.sh | bash"
  else
    run_as_target_user "curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash"
  fi

  local nvm_block='# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'

  append_shell_init_block 'export NVM_DIR="$HOME/.nvm"' "$nvm_block"
}

install_nvm_if_needed() {
  [[ -s "$TARGET_HOME/.nvm/nvm.sh" ]] || install_nvm
}

install_node_if_needed() {
  if sudo -H -u "$TARGET_USER" bash -lc 'command -v node >/dev/null 2>&1'; then
    log "Node já está disponível para $TARGET_USER"
    return 0
  fi

  local install_target="--lts"
  [[ "$NODE_CHANNEL" == "current" ]] && install_target="node"

  run_as_target_user "
    export NVM_DIR=\"\$HOME/.nvm\"
    [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"
    nvm install ${install_target}
    if [[ \"$NODE_CHANNEL\" == \"lts\" ]]; then
      nvm alias default 'lts/*'
    else
      nvm alias default node
    fi
    nvm use default
  "
}

install_corepack_if_needed() {
  install_nvm_if_needed
  install_node_if_needed

  run_as_target_user '
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    corepack enable
  '
}
