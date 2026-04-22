#!/usr/bin/env bash

setup_docker_repo() {
  run_cmd "install -m 0755 -d /etc/apt/keyrings"

  if [[ ! -f /etc/apt/keyrings/docker.gpg ]] || [[ "$DRY_RUN" -eq 1 ]]; then
    run_cmd "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg"
    run_cmd "chmod a+r /etc/apt/keyrings/docker.gpg"
  fi

  . /etc/os-release

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[dry-run] configurar repo Docker para ${VERSION_CODENAME}"
  else
    cat > /etc/apt/sources.list.d/docker.list <<EOD
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable
EOD
  fi

  reset_apt_cache_flag
}

install_docker() {
  setup_docker_repo
  install_apt_packages docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[dry-run] groupadd -f docker"
    log "[dry-run] usermod -aG docker $TARGET_USER"
    log "[dry-run] systemctl enable docker"
    log "[dry-run] systemctl restart docker"
  else
    groupadd -f docker
    usermod -aG docker "$TARGET_USER" || warn "Falha ao adicionar usuário ao grupo docker."
    systemctl enable docker | tee -a "$LOG_FILE"
    systemctl restart docker | tee -a "$LOG_FILE"
  fi
}

install_docker_compose() {
  setup_docker_repo
  install_apt_packages docker-compose-plugin
}
