# Ubuntu Dev Installer V2.2

Instalador modular com TUI para Ubuntu.

## Recursos

- TUI com `whiptail`
- módulos separados em `modules/`
- categorias
- status visual de instalado/não instalado
- barra de progresso
- modo não interativo
- `--all`
- `--only`
- `--dry-run`
- seleção de `Node LTS` ou `Current`
- `Oh My Zsh` opcional

## Módulos

- zsh
- oh-my-zsh
- git
- nvm
- docker
- docker-compose
- github-cli
- pnpm
- bun
- yarn

## Uso

### Interativo

```bash
chmod +x install.sh
chmod +x lib/*.sh
chmod +x modules/*.sh
sudo ./install.sh
