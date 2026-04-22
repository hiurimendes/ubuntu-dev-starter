#!/usr/bin/env bash

install_bun() {
  run_as_target_user 'curl -fsSL https://bun.sh/install | bash'

  local bun_block='# BUN
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"'

  append_shell_init_block 'export BUN_INSTALL="$HOME/.bun"' "$bun_block"
}
