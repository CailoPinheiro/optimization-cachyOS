# Personal Tweaks — Registro

Registro de todos os ajustes pessoais feito no sistema, para consulta,
reprodução e reversão.

Estrutura:
- 1 arquivo `.md` por tweak: `YYYY-MM-DD-descricao-curta.md`
- Toda vez que um tweak for aplicado, o assistente cria/atualiza a entrada
  (estado, data, arquivos tocados, como verificar, como reverter).

## Índice

| Data | Tweak | Status | Arquivo |
|---|---|---|---|
| 2026-09-24 | Teclado: us/br (ABNT-2) via Alt+Shift | Aplicado | [2026-09-24-teclado-us-br.md](tweek-details/2026-09-24-teclado-us-br.md) |
| 2026-09-25 | MEGAsync: Wayland nativo (qt5-wayland) | Aplicado — resolvido | [2026-09-25-megasync-wayland.md](tweek-details/2026-09-25-megasync-wayland.md) |
| 2026-09-26 | Autologin: Hyprland sobe sozinho no tty1 | Aplicado — validado | [2026-09-26-autologin-hyprland-tty1.md](tweek-details/2026-09-26-autologin-hyprland-tty1.md) |
| 2026-09-26 | Greeter tuigreet (greetd): autologin + senha ao sair + tema dinâmico | **Aplicado e funcionando** | [2026-09-26-greeter-tuigreet.md](tweek-details/2026-09-26-greeter-tuigreet.md) |
| 2026-09-27 | Híbrido: Fish como backend, Zsh como frontend (Terminal Kitty) | **Aplicado e funcionando** | [2026-09-27-kitty-zsh-hibrido.md](tweek-details/2026-09-27-kitty-zsh-hibrido.md) |
| 2026-09-27 | Otimizações Wayland/Hyprland (Input Lag, Tearing e GameMode) | **Aplicado e funcionando** | [2026-09-27-overwatch-wayland-tweaks.md](tweek-details/2026-09-27-overwatch-wayland-tweaks.md) |
| 2026-09-28 | Integração Suave do Game Mode com Quickshell e Hyprland | **Aplicado e funcionando** | [2026-09-28-gamemode-quickshell-integration.md](tweek-details/2026-09-28-gamemode-quickshell-integration.md) |
| 2026-09-28 | Dolphin: Definir Wallpaper (Vídeo/Imagem) via Botão Direito | **Aplicado e funcionando** | [2026-09-28-dolphin-wallpaper-context-menu.md](tweek-details/2026-09-28-dolphin-wallpaper-context-menu.md) |
| 2026-09-28 | Fastfetch: Sorteio Aleatório de Logos (ASCII/ANSI e Imagens) | **Aplicado e funcionando** | [2026-09-28-fastfetch-random-logo.md](tweek-details/2026-09-28-fastfetch-random-logo.md) |
| 2026-09-28 | Terraria: Resolução de Performance (Turbo Boost e MangoHud) | **Aplicado** | [2026-09-28-terraria-performance-fix.md](tweek-details/2026-09-28-terraria-performance-fix.md) |
| 2026-09-28 | Power Control: Inteligência Híbrida (P-Cores e E-Cores) | **Aplicado no Instalador** | [2026-09-28-power-control-hibrido.md](updated-tweeks/2026-09-28-power-control-hibrido.md) |
| 2026-09-30 | Animated Wallpaper (mpvpaper) e Correção Total de Crashes no Shell | **Aplicado e funcionando** | [2026-09-30-animated-wallpaper-mpvpaper-shell-fix.md](tweek-details/2026-09-30-animated-wallpaper-mpvpaper-shell-fix.md) |
| 2026-09-30 | Caffeine: Auto-Cura (Self-Heal) e Correção de Bloqueio Prematuro | **Aplicado e validado** | [2026-09-30-caffeine-selfheal-e-lock-fix.md](tweek-details/2026-09-30-caffeine-selfheal-e-lock-fix.md) |

## Decisoes que nao devem ser revertidas sem o usuario pedir

- **2026-09-26 - o comportamento padrao do idle foi mantido de proposito.** Os 3
  `listener` do `hypridle.conf` (lock 5min / dpms-off 10min / suspend 15min)
  **nao** devem ser removidos. O botao de cafe existe para as *excecoes*
  temporarias, nao para substituir a regra. A "simplificacao" de apagar os
  listeners foi proposta e **rejeitada** pelo usuario. Detalhes em
  [2026-09-30-caffeine-selfheal-e-lock-fix.md](tweek-details/2026-09-30-caffeine-selfheal-e-lock-fix.md).
- **2026-09-26 - a tampa fica no comportamento PADRAO do sistema, de proposito.**
  O `caffeine` usa `--what=idle:sleep`, **sem** `handle-lid-switch`. Fechar a
  tampa suspende, com o cafe ligado ou nao — e o que o usuario pediu. Um
  `handle-lid-switch` no inhibitor **sobrescreveria** o `HandleLidSwitch` do
  logind (lock de baixo nivel e sempre honrado, independente do
  `LidSwitchIgnoreInhibited=`), ou seja, ele "corrigia" a tampa as escondidas.
  **Nao reintroduzir** achando que e a configuracao original. Detalhes em
  [2026-09-30-caffeine-selfheal-e-lock-fix.md](tweek-details/2026-09-30-caffeine-selfheal-e-lock-fix.md);
  e `LidSwitchIgnoreInhibited=no` / `HandleLidSwitch=ignore` em `logind.conf.d`
  continuam descartados (sudo + reboot, e o segundo desligaria a tampa para
  sempre).
- **2026-09-26 - a sessao do greetd e fixada com `--cmd start-hyprland` e nao
  descoberta.** Sem isso, o tuigreet lista `/usr/share/wayland-sessions`, onde
  esta o `hyprland-uwsm.desktop` — a armadilha que o proprio End-4 avisa pra
  nunca escolher. Por isso **nao ha menu de sessao** e o F3 fica sem efeito
  propositalmente. Nao adicionar `-c /etc/greetd/hyprland.lua`: o Hyprland
  0.56 acha o `hyprland.lua` sozinho. Ver
  [2026-09-26-greeter-tuigreet.md](tweek-details/2026-09-26-greeter-tuigreet.md).
- **2026-09-26 - o `background.kind` do tuigreet comeca em `"none"`.** O
  conserto "background animations no longer bleed into the login form" so
  entrou no tuigreet 0.12.0, e o binario do CachyOS (`0.11.1-2.1`) se reporta
  como `0.11.0`. Se animar, a animacao cobre a caixa de login. Nao e erro de
  config. Ver `~/Projects/tui-setup/02-design.md`.
- **2026-09-26 - o `chown` do `config.toml` gerado e obrigatorio.** Em
  `/usr/local/share/tuigreet/`, o **arquivo** precisa ser do `cailoop`, nao
  so o diretorio. `sudo cp` cria como `root:root` e o `chmod 644` ajusta so o
  modo; o matugen usa `fs::write` (trunca o arquivo) e o `switchwall.sh` roda
  como usuario, entao sem o `chown` da `Permission denied` a cada troca de
  wallpaper — com o symlink correto e o template no lugar, o que faz a falha
  parecerinnocua. O mesmo vale para o `--source-color-index 0` no comando
  manual do matugen. Nao "simplificar" removendo o `chown`. Detalhes em
  [2026-09-26-greeter-tuigreet.md](tweek-details/2026-09-26-greeter-tuigreet.md).
- **2026-09-30 - o logo de imagem do Fastfetch e `kitty-direct`, nao `kitty`.**
  Com `--logo-type kitty` o Fastfetch pre-renderiza a imagem e cacheia o
  payload em `~/.cache/fastfetch/images/<caminho>/<tamanho>/kittyc`, com chave
  por **caminho** (sem mtime/hash): editar a imagem no lugar nao invalida nada e
  a foto antiga continua aparecendo. Nao voltar para `kitty` sem usar
  `--logo-recache true`. Detalhes em
  [2026-09-30-fastfetch-logo-cache-kitty-direct.md](tweek-details/2026-09-30-fastfetch-logo-cache-kitty-direct.md).

## Listas Auxiliares e Recursos

- **[Pacotes e Recursos Extras Úteis](../pacotes-extras-uteis.md)**: Tabela contínua de bibliotecas, ferramentas CLI e apps extras instalados após o sistema (como `mpvpaper`, `yt-dlp`), documentando utilidade e comando de instalação.

## Regras para novas entradas

- Nome do arquivo: `YYYY-MM-DD-<slug>.md`
- Conteúdo mínimo: **Motivo · O que foi feito · Como realizar (Passo a passo com comandos/snippets) · Arquivos tocados · Como verificar · Como reverter**
- Referencia os arquivos reais em `~/.config` / `~/dots-hyprland` (caminho exato).