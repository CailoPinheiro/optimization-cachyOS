# Autologin do Hyprland no tty1 com Lockscreen Quickshell

**Data:** 2026-09-26  
**Status:** **Aplicado e consolidado** (atualizado em 2026-10-25)

## Motivo

Inicializar o sistema de forma instantânea e limpa (1 a 2 segundos), eliminando gerenciadores de exibição intermediários (display managers como GDM, SDDM ou greetd/tuigreet) e telas pretas. O login no console `tty1` ocorre automaticamente e silenciosamente, subindo o Hyprland de imediato. A segurança e autenticação do notebook ficam a cargo da tela de bloqueio gráfica moderna do Quickshell (`launchOnStartup: true`), garantindo uma interface visual estilizada com Material You e exigindo apenas uma senha ao ligar.

## Arquitetura da Solução

O fluxo completo de inicialização é composto por 4 etapas coordenadas:

1. **Autologin silencioso no console (`agetty`)**:
   O systemd executa o `getty@tty1.service` com drop-in de autologin configurado para o usuário `cailoop` sem limpar a tela (`--noclear`).
2. **Disparo automático do ambiente gráfico (`fish`)**:
   Ao iniciar a sessão no tty1, o shell carrega `~/.config/fish/config.fish`, que faz o `source` explícito de `~/.config/fish/auto-Hypr.fish`.
3. **Execução do compositor (`start-hyprland`)**:
   O `auto-Hypr.fish` valida que a variável `$DISPLAY` está vazia e `$XDG_VTNR` é igual a 1, chamando `exec start-hyprland > ~/.cache/hyprland.log 2>&1`.
4. **Bloqueio gráfico no boot (`Quickshell`)**:
   O compositor carrega o Quickshell. Com a chave `"launchOnStartup": true` em `~/.config/illogical-impulse/config.json`, o painel tranca a sessão imediatamente, apresentando o relógio, controles de mídia e campo de senha integrado ao tema do sistema.

## Histórico e Evolução

- **2026-09-26 (Original)**: O script `auto-Hypr.fish` ficava na raiz de `~/.config/fish/`, onde o fish não carrega nada automaticamente. Foi adicionado o `source` explícito no topo de `~/dots-hyprland/dots/.config/fish/config.fish`.
- **2026-09-26 (Experimento Greetd/Tuigreet)**: Foi testado o uso de `greetd` + `tuigreet` para oferecer uma tela de login no console. Detalhes arquivados em [2026-09-26-greeter-tuigreet.md](2026-09-26-greeter-tuigreet.md).
- **2026-10-25 (Consolidação Definitiva)**: O `greetd` foi desativado devido a problemas de concorrência com o DBus, limitação de cores do TTY e ocorrência de tela de bloqueio dupla (greetd + quickshell). O sistema retornou ao autologin direto via `agetty` com proteção por Quickshell on launch, absorvendo a configuração e consolidando a tweak em fonte única.

## Como realizar (Passo a passo)

### 1. Configurar o autologin no systemd (agetty tty1)

Criar o diretório de override e o arquivo de drop-in para o `getty@tty1`:

```bash
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf << 'EOF'
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty -o '-p -f -- \\u' --noclear --autologin cailoop %I $TERM
Type=idle
EOF
```

### 2. Desativar daemons conflitantes e ativar o getty@tty1

```bash
sudo systemctl daemon-reload
sudo systemctl disable --now greetd.service 2>/dev/null || true
sudo systemctl enable getty@tty1.service
```

### 3. Garantir o disparo no fish (`auto-Hypr.fish`)

No arquivo `~/dots-hyprland/dots/.config/fish/config.fish`, certificar-se de que o bloco de source está no topo, antes de `status is-interactive`:

```fish
# Auto start Hyprland on tty1.
if test -f ~/.config/fish/auto-Hypr.fish
    source ~/.config/fish/auto-Hypr.fish
end
```

E conferir o conteúdo de `~/.config/fish/auto-Hypr.fish`:

```fish
# Auto start Hyprland on tty1
if test -z "$DISPLAY" ;and test "$XDG_VTNR" -eq 1
    mkdir -p ~/.cache
    exec start-hyprland > ~/.cache/hyprland.log 2>&1
end
```

Se alterado o arquivo de dotfiles, sincronizar:
```bash
cd ~/dots-hyprland
./setup install-files -f --skip-backup --skip-allgreeting
```

### 4. Ativar o Lockscreen on Launch no Quickshell

Em `~/.config/illogical-impulse/config.json`, na seção de lockscreen, definir:

```json
"launchOnStartup": true,
```

## Arquivos tocados

- `/etc/systemd/system/getty@tty1.service.d/autologin.conf` (override do systemd para login sem senha no tty1)
- `~/dots-hyprland/dots/.config/fish/config.fish` (repositório de dotfiles)
- `~/.config/fish/config.fish` (configuração ativa do shell)
- `~/.config/fish/auto-Hypr.fish` (rotina de verificação de VT e inicialização do Hyprland)
- `~/.config/illogical-impulse/config.json` (configuração do lockscreen gráfico da Quickshell)

## Como verificar

1. Reiniciar a máquina:
   ```bash
   sudo reboot
   ```
2. Observar o boot:
   - Nenhum prompt textual ou menu de texto TUI deve aparecer.
   - O console faz autologin imediato e a tela sobe direto no ambiente gráfico.
   - O Quickshell surge bloqueado com a tela de fundo desfocada e o campo de senha.
3. Digite sua senha: a sessão desbloqueia diretamente na área de trabalho.

## Como reverter

1. Para voltar ao prompt tradicional de login no tty1 (pedindo usuário e senha no console):
   ```bash
   sudo rm -rf /etc/systemd/system/getty@tty1.service.d
   sudo systemctl daemon-reload
   sudo systemctl restart getty@tty1.service
   ```
2. Para desativar o bloqueio de tela automático no boot:
   Alterar em `~/.config/illogical-impulse/config.json`:
   ```json
   "launchOnStartup": false,
   ```
