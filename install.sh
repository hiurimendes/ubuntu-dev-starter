#!/usr/bin/env bash

set -Eeuo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BASE_DIR/lib/common.sh"
source "$BASE_DIR/lib/registry.sh"
source "$BASE_DIR/lib/tui.sh"
source "$BASE_DIR/lib/progress.sh"
source "$BASE_DIR/lib/dispatcher.sh"

source "$BASE_DIR/modules/zsh.sh"
source "$BASE_DIR/modules/git.sh"
source "$BASE_DIR/modules/nvm.sh"
source "$BASE_DIR/modules/docker.sh"
source "$BASE_DIR/modules/github_cli.sh"
source "$BASE_DIR/modules/pnpm.sh"
source "$BASE_DIR/modules/yarn.sh"
source "$BASE_DIR/modules/bun.sh"
source "$BASE_DIR/modules/oh_my_zsh.sh"

main() {
  init_runtime "$@"
  parse_args "$@"

  if [[ "$SHOW_HELP" -eq 1 ]]; then
    print_help
    exit 0
  fi

  require_root
  require_ubuntu
  install_base_dependencies

  if [[ "$MODE" == "interactive" ]]; then
    run_interactive_mode
  else
    run_non_interactive_mode
  fi
}

run_interactive_mode() {
  choose_node_channel_if_needed

  if ! run_category_selection_flow; then
    warn "Operação cancelada."
    exit 0
  fi

  if [[ "${#SELECTED_MODULES[@]}" -eq 0 ]]; then
    show_msg "Nenhum item foi selecionado."
    exit 0
  fi

  if ! confirm_yesno "Deseja iniciar a instalação/atualização dos módulos selecionados?"; then
    warn "Instalação cancelada."
    exit 0
  fi

  execute_selected_modules_with_progress
  show_summary
}

run_non_interactive_mode() {
  if [[ "$SELECT_ALL" -eq 1 ]]; then
    select_all_modules
  fi

  if [[ "${#SELECTED_MODULES[@]}" -eq 0 ]]; then
    die "Nenhum módulo selecionado. Use --all ou --only."
  fi

  execute_selected_modules_console
  print_summary_console
}

main "$@"
