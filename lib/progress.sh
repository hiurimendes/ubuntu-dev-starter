#!/usr/bin/env bash

execute_selected_modules_with_progress() {
  local total="${#SELECTED_MODULES[@]}"
  local current=0
  local module
  local percent

  {
    for module in "${SELECTED_MODULES[@]}"; do
      current=$((current + 1))
      percent=$(( current * 100 / total ))

      echo "$percent"
      echo "XXX"
      echo "Instalando módulo: $module ($current/$total)"
      echo "XXX"

      execute_module "$module"
    done

    echo "100"
    echo "XXX"
    echo "Concluído."
    echo "XXX"
  } | whiptail --title "$SCRIPT_NAME" --gauge "Iniciando..." 10 78 0
}

execute_selected_modules_console() {
  local module
  for module in "${SELECTED_MODULES[@]}"; do
    log "==== Executando módulo: $module ===="
    execute_module "$module"
  done
}
