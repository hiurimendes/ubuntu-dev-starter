#!/usr/bin/env bash

SCRIPT_NAME="Ubuntu Dev Installer V2.2"
LOG_FILE="${PWD}/ubuntu-dev-installer.log"

TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(eval echo "~$TARGET_USER")"

export DEBIAN_FRONTEND=noninteractive

APT_UPDATED=0
MODE="interactive"
DRY_RUN=0
SELECT_ALL=0
SHOW_HELP=0
NODE_CHANNEL="lts"
SELECTED_MODULES=()

# Cores opcionais para whiptail/newt
# Pode ajustar depois se quiser outro tema.
export NEWT_COLORS='
root=,black
window=white,black
border=white,black
title=yellow,black
textbox=white,black
button=black,cyan
actbutton=white,blue
compactbutton=white,black
actsellistbox=white,blue
sellistbox=white,black
checkbox=white,black
actcheckbox=yellow,blue
entry=white,black
label=white,black
shadow=black,black
'

log() {
  echo "[INFO] $*" >>"$LOG_FILE"
}

warn() {
  echo "[WARN] $*" >>"$LOG_FILE"
}

error() {
  echo "[ERROR] $*" >>"$LOG_FILE"
}

die() {
  error "$*"
  echo "[ERROR] $*" >&2
  exit 1
}

init_runtime() {
  if [[ -e "$LOG_FILE" && ! -w "$LOG_FILE" ]]; then
    rm -f "$LOG_FILE"
  fi

  rm -f "$LOG_FILE"
  touch "$LOG_FILE"
  chmod 600 "$LOG_FILE"
}

on_error() {
  local exit_code=$?
  local line_no=$1
  error "Falha na linha ${line_no}. Consulte: $LOG_FILE"
  echo "[ERROR] Falha na linha ${line_no}. Consulte: $LOG_FILE" >&2
  exit "$exit_code"
}
trap 'on_error $LINENO' ERR

require_root() {
  [[ "$EUID" -eq 0 ]] || die "Execute com sudo: sudo ./install.sh"
}

require_ubuntu() {
  command -v apt >/dev/null 2>&1 || die "Este script requer Ubuntu/Debian com apt."
}

run_cmd() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[dry-run] $*"
    return 0
  fi

  log "Executando: $*"
  eval "$@" >>"$LOG_FILE" 2>&1
}

run_as_target_user() {
  local cmd="$1"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[dry-run][$TARGET_USER] $cmd"
    return 0
  fi

  log "Executando como $TARGET_USER: $cmd"
  sudo -H -u "$TARGET_USER" bash -lc "$cmd" >>"$LOG_FILE" 2>&1
}

apt_update_once() {
  if [[ "$APT_UPDATED" -eq 0 ]]; then
    run_cmd "apt update -y"
    APT_UPDATED=1
  fi
}

reset_apt_cache_flag() {
  APT_UPDATED=0
}

install_apt_packages() {
  apt_update_once
  run_cmd "apt install -y $*"
}

ensure_line_in_file() {
  local file="$1"
  local marker="$2"
  local content="$3"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[dry-run] garantir bloco em $file"
    return 0
  fi

  touch "$file"
  chown "$TARGET_USER:$TARGET_USER" "$file"

  if ! grep -Fq "$marker" "$file"; then
    {
      echo ""
      echo "$content"
    } >>"$file"
    chown "$TARGET_USER:$TARGET_USER" "$file"
  fi
}

append_shell_init_block() {
  local marker="$1"
  local content="$2"

  ensure_line_in_file "$TARGET_HOME/.bashrc" "$marker" "$content"
  ensure_line_in_file "$TARGET_HOME/.zshrc" "$marker" "$content"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --interactive)
        MODE="interactive"
        shift
        ;;
      --non-interactive)
        MODE="non-interactive"
        shift
        ;;
      --all)
        MODE="non-interactive"
        SELECT_ALL=1
        shift
        ;;
      --only)
        MODE="non-interactive"
        shift
        [[ $# -gt 0 ]] || die "Use --only modulo1,modulo2"
        IFS=',' read -r -a SELECTED_MODULES <<<"$1"
        shift
        ;;
      --node-channel)
        shift
        [[ $# -gt 0 ]] || die "Use --node-channel lts|current"
        NODE_CHANNEL="$1"
        shift
        ;;
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      --help|-h)
        SHOW_HELP=1
        shift
        ;;
      *)
        die "Argumento desconhecido: $1"
        ;;
    esac
  done
}

print_help() {
  cat <<EOF
$SCRIPT_NAME

Uso:
  sudo ./install.sh
  sudo ./install.sh --all
  sudo ./install.sh --only zsh,git,nvm,pnpm
  sudo ./install.sh --only bun,yarn --node-channel current
  sudo ./install.sh --all --dry-run

Opções:
  --interactive
  --non-interactive
  --all
  --only LISTA
  --node-channel lts|current
  --dry-run
  --help|-h
EOF
}

print_summary_console() {
  cat <<EOF
Instalação finalizada.

Usuário alvo: $TARGET_USER
Node channel: $NODE_CHANNEL
Log: $LOG_FILE
EOF
}

install_base_dependencies() {
  install_apt_packages \
    ca-certificates \
    curl \
    wget \
    gnupg \
    lsb-release \
    apt-transport-https \
    software-properties-common \
    whiptail
}