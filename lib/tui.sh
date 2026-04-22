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

show_category_menu() {
  local args=()
  local category
  local total
  local selected
  local selected_count

  while IFS= read -r category; do
    total="$(count_modules_in_category "$category")"
    selected="$(count_selected_in_category "$category")"
    args+=("$category" "$(printf '%s/%s selecionados' "$selected" "$total")")
  done < <(get_categories)

  selected_count="$(count_selected_modules)"

  args+=("__actions__" "──────── Ações ────────")
  args+=("Instalar selecionados" "$(printf '%s item(ns) selecionado(s)' "$selected_count")")
  args+=("Selecionar todos" "Marcar todos os módulos")
  args+=("Limpar seleção" "Desmarcar todos os módulos")
  args+=("Sair" "Fechar o instalador")

  whiptail \
    --title "$SCRIPT_NAME" \
    --menu "Escolha uma categoria para selecionar os módulos.\nDepois use \"Instalar selecionados\" para continuar." \
    24 88 14 \
    "${args[@]}" \
    3>&1 1>&2 2>&3
}

show_category_checklist() {
  local category="$1"
  local args=()
  local module
  local desc
  local status
  local default_state

  while IFS= read -r module; do
    [[ -z "$module" ]] && continue

    desc="${MODULE_DESCRIPTIONS[$module]}"
    status="$(module_status "$module")"

    if module_is_selected "$module"; then
      default_state="ON"
    else
      default_state="OFF"
    fi

    args+=("$module" "$(printf '%-28s [%s]' "$desc" "$status")" "$default_state")
  done < <(get_modules_by_category "$category")

  whiptail \
    --title "$SCRIPT_NAME - $category" \
    --checklist "Selecione os módulos da categoria \"$category\":" \
    22 96 12 \
    "${args[@]}" \
    3>&1 1>&2 2>&3
}

update_category_selection() {
  local category="$1"
  local raw="$2"
  local module

  while IFS= read -r module; do
    [[ -n "$module" ]] && remove_selected_module "$module"
  done < <(get_modules_by_category "$category")

  while IFS= read -r module; do
    [[ -n "$module" ]] && add_selected_module "$module"
  done < <(normalize_whiptail_selection "$raw")
}

show_selected_summary() {
  local summary=""
  local module

  if [[ "${#SELECTED_MODULES[@]}" -eq 0 ]]; then
    summary="Nenhum módulo foi selecionado."
  else
    summary="Módulos selecionados:\n\n"
    for module in "${SELECTED_MODULES[@]}"; do
      summary+="- ${MODULE_DESCRIPTIONS[$module]} [$module]\n"
    done
  fi

  whiptail --title "$SCRIPT_NAME" --msgbox "$summary" 20 80
}

run_category_selection_flow() {
  local choice
  local selected

  while true; do
    choice="$(show_category_menu)" || return 1

    case "$choice" in
      "__actions__")
        continue
        ;;
      "Instalar selecionados")
        if [[ "${#SELECTED_MODULES[@]}" -eq 0 ]]; then
          show_msg "Nenhum módulo selecionado."
          continue
        fi

        show_selected_summary
        return 0
        ;;
      "Selecionar todos")
        select_all_modules
        show_msg "Todos os módulos foram selecionados."
        ;;
      "Limpar seleção")
        clear_all_modules
        show_msg "Todas as seleções foram removidas."
        ;;
      "Sair")
        return 1
        ;;
      *)
        selected="$(show_category_checklist "$choice")" || continue
        update_category_selection "$choice" "$selected"
        ;;
    esac
  done
}

show_summary() {
  local summary=""
  summary+="Instalação finalizada.\n\n"
  summary+="Usuário alvo: $TARGET_USER\n"
  summary+="Canal do Node: $NODE_CHANNEL\n"
  summary+="Selecionados: $(count_selected_modules)\n"
  summary+="Log: $LOG_FILE\n\n"
  summary+="Observações:\n"
  summary+="- Abra um novo terminal para recarregar shell e PATH.\n"
  summary+="- Docker pode exigir logout/login para uso sem sudo.\n"

  whiptail --title "$SCRIPT_NAME" --msgbox "$summary" 18 80
}