#!/usr/bin/env bash

show_msg() {
  whiptail --title "$SCRIPT_NAME" --msgbox "$1" 12 78
}

confirm_yesno() {
  whiptail --title "$SCRIPT_NAME" --yesno "$1" 12 78
}

choose_node_channel_if_needed() {
  NODE_CHANNEL="$(
    whiptail \
      --title "$SCRIPT_NAME" \
      --menu "Escolha o canal do Node.js para instalações via nvm/corepack:" \
      15 72 5 \
      "lts" "Node LTS (recomendado)" \
      "current" "Node Current (mais recente)" \
      3>&1 1>&2 2>&3
  )" || NODE_CHANNEL="lts"
}

show_main_checklist() {
  local args=()
  local key
  local desc
  local status
  local label

  for key in "${MODULE_KEYS[@]}"; do
    desc="${MODULE_DESCRIPTIONS[$key]}"
    status="$(module_status "$key")"
    label="[$(printf '%-16s' "${MODULE_CATEGORIES[$key]}")] ${desc} (${status})"
    args+=("$key" "$label" "${MODULE_DEFAULTS[$key]}")
  done

  whiptail \
    --title "$SCRIPT_NAME" \
    --checklist "Selecione os módulos para instalar ou atualizar:" \
    26 100 16 \
    "${args[@]}" \
    3>&1 1>&2 2>&3
}

show_summary() {
  local summary=""
  summary+="Instalação finalizada.\n\n"
  summary+="Usuário alvo: $TARGET_USER\n"
  summary+="Canal do Node: $NODE_CHANNEL\n"
  summary+="Log: $LOG_FILE\n\n"
  summary+="Observações:\n"
  summary+="- Abra um novo terminal para recarregar shell e PATH.\n"
  summary+="- Docker pode exigir logout/login para uso sem sudo.\n"

  whiptail --title "$SCRIPT_NAME" --msgbox "$summary" 18 80
}