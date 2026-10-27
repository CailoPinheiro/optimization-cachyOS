# Personal Tweaks — Registro

Registro de todos os ajustes pessoais feito no sistema, para consulta,
reprodução e reversão.

Estrutura:
- 1 arquivo `.md` por tweak: `YYYY-MM-DD-descricao-curta.md`
- `bkp/` = backups dos arquivos alterados pelos tweaks
- `updated-tweeks/` = tweaks gerados ou alterados por instaladores/scripts
- Toda vez que um tweak for aplicado, o assistente cria/atualiza a entrada
  (estado, data, arquivos tocados, como verificar, como reverter).

## Índice

| Data | Tweak | Status | Arquivo |
|---|---|---|---|
| 2026-09-24 | Teclado: us/br (ABNT-2) via Alt+Shift | Aplicado | [2026-09-24-teclado-us-br.md](tweek-details/2026-09-24-teclado-us-br.md) |
| 2026-09-25 | MEGAsync: Wayland nativo (qt5-wayland) | Aplicado — resolvido | [2026-09-25-megasync-wayland.md](tweek-details/2026-09-25-megasync-wayland.md) |
| 2026-09-26 | Autologin no tty1 (agetty) e Lockscreen Quickshell | **Aplicado e consolidado** | [2026-09-26-autologin-hyprland-tty1.md](tweek-details/2026-09-26-autologin-hyprland-tty1.md) |
| 2026-09-26 | Greeter tuigreet (greetd): autologin + tema dinâmico | Legado — substituído por autologin direto | [2026-09-26-greeter-tuigreet.md](tweek-details/2026-09-26-greeter-tuigreet.md) |
| 2026-09-27 | Híbrido: Fish como backend, Zsh como frontend (Terminal Kitty) | **Aplicado e funcionando** | [2026-09-27-kitty-zsh-hibrido.md](tweek-details/2026-09-27-kitty-zsh-hibrido.md) |
| 2026-09-27 | Otimizações Wayland/Hyprland para Overwatch (Tearing e Janelas) | **Aplicado e funcionando** | [2026-09-27-overwatch-wayland-tweaks.md](tweek-details/2026-09-27-overwatch-wayland-tweaks.md) |
| 2026-09-28 | Integração Suave do Game Mode com Quickshell e Hyprland | **Aplicado e consolidado** | [2026-09-28-gamemode-quickshell-integration.md](tweek-details/2026-09-28-gamemode-quickshell-integration.md) |
| 2026-09-28 | Dolphin: Definir Wallpaper (Vídeo/Imagem) via Botão Direito | **Aplicado e funcionando** | [2026-09-28-dolphin-wallpaper-context-menu.md](tweek-details/2026-09-28-dolphin-wallpaper-context-menu.md) |
| 2026-09-28 | Fastfetch: Sorteio Aleatório de Logos (ASCII/ANSI e Imagens) | **Aplicado e funcionando** | [2026-09-28-fastfetch-random-logo.md](tweek-details/2026-09-28-fastfetch-random-logo.md) |
| 2026-09-28 | Terraria: Resolução de Performance (Turbo Boost e MangoHud) | **Aplicado** | [2026-09-28-terraria-performance-fix.md](tweek-details/2026-09-28-terraria-performance-fix.md) |
| 2026-09-28 | Power Control: Inteligência Híbrida (P-Cores e E-Cores) | **Aplicado no Instalador** | [2026-09-28-power-control-hibrido.md](updated-tweeks/2026-09-28-power-control-hibrido.md) |
| 2026-09-30 | Animated Wallpaper (mpvpaper) e Correção Total de Crashes no Shell | **Aplicado e funcionando** | [2026-09-30-animated-wallpaper-mpvpaper-shell-fix.md](tweek-details/2026-09-30-animated-wallpaper-mpvpaper-shell-fix.md) |
| 2026-09-30 | Caffeine: Auto-Cura (Self-Heal), Unit do Inhibitor e Correção de Lock | **Aplicado e consolidado** | [2026-09-30-caffeine-selfheal-e-lock-fix.md](tweek-details/2026-09-30-caffeine-selfheal-e-lock-fix.md) |
| 2026-09-30 | Integração e Tematização Dinâmica do Matugen em Aplicativos (Xed, MarkText, qBittorrent) | **Aplicado e funcionando** | [2026-09-30-matugen-apps-theming-integration.md](tweek-details/2026-09-30-matugen-apps-theming-integration.md) |
| 2026-10-05 | Minecraft Dungeons II: chave `GamingServices\ForceUseLocalServices` no prefixo do Hydra | **Aplicado — aguardando teste** | [2026-10-05-minecraft-dungeons-ii-gamingservices-reg.md](tweek-details/2026-10-05-minecraft-dungeons-ii-gamingservices-reg.md) |
| 2026-10-25 | Super + L: lock da Quickshell com fallback para hyprlock | **Aplicado e funcionando** | [2026-10-25-super-l-quickshell-lock.md](tweek-details/2026-10-25-super-l-quickshell-lock.md) |

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
  `~/Projects/pesquisas/personalizando-logos-fastfetch.md`.
- **2026-09-30 - a troca de wallpaper escreve o `config.json` de forma
  atomica.** A UI do Quickshell sumia porque o `switchwall.sh` gravava
  `background.wallpaperPath` (o `.mp4`) e `background.thumbnailPath` em duas
  escritas separadas, com o `ffmpeg` rodando entre elas: o shell via um estado
  inconsistente (video sem miniatura) e o `least_busy_region.py` recebia um
  video, devolvia traceback e o `JSON.parse` sem `try`/`catch` derrubava a
  renderizacao. Regra: **miniatura primeiro, depois uma unica chamada do `jq`
  com os dois campos, tmp + `mv`**. Nao voltar a usar
  `set_wallpaper_path` + `set_thumbnail_path` em sequencia na troca de
  wallpaper. Detalhes em
  [2026-09-30-animated-wallpaper-mpvpaper-shell-fix.md](tweek-details/2026-09-30-animated-wallpaper-mpvpaper-shell-fix.md).
- **2026-10-05 - a chave `HKLM\Software\Microsoft\GamingServices\ForceUseLocalServices`
  = 1 no prefixo do Hydra (`1912410`) existe de proposito.** O `Dungeons.exe` da
  raiz do Minecraft Dungeons II nao e o jogo, e o dependency-checker da Microsoft
  GDK. Sem essa chave ele acusa "Missing Gaming Services" e tentai rodar o
  `GamingRepair.exe`, que crasha no Wine. **Nao remover essa chave achando que e
  lixo do prefixo.** O jogo em si nao usa Gaming Services de verdade - o crack
  RUNE faz sideload de `xgameruntime.dll`. Se o Proton for atualizado e o Hydra
  recriar o prefixo, reaplicar. Detalhes em
  [2026-10-05-minecraft-dungeons-ii-gamingservices-reg.md](tweek-details/2026-10-05-minecraft-dungeons-ii-gamingservices-reg.md).
- **2026-10-25 - o Game Mode nunca deve enviar `SIGCONT` para o `hypridle`
  congelado.** Os timers continuam envelhecendo durante o `SIGSTOP`; ao
  retomar, lock/dpms/suspend disparam de uma vez. O Game Mode agora reinicia o
  `hypridle` com `kill -9` + `setsid`, exceto quando o Caffeine está `on` e já
  mantém o processo congelado. Detalhes em
  [2026-09-28-gamemode-quickshell-integration.md](tweek-details/2026-09-28-gamemode-quickshell-integration.md).
- **2026-10-25 - o `Super + L` deve chamar o lock da Quickshell primeiro.**
  O `hyprlock` fica apenas como fallback para quando a shell não responde. Não
  voltar a iniciar o `hyprlock` direto no atalho. Detalhes em
  [2026-10-25-super-l-quickshell-lock.md](tweek-details/2026-10-25-super-l-quickshell-lock.md).
- **2026-10-25 - o inhibitor do Caffeine deve viver fora do cgroup do
  `caffeine-watch.service`.** `setsid` não escapa do cgroup de um serviço
  oneshot; por isso o inhibitor agora é a unit `caffeine-inhibitor.service` e o
  watch service usa `KillMode=process` para o `hypridle` respawnado também
  sobreviver. Detalhes em
  [2026-09-30-caffeine-selfheal-e-lock-fix.md](tweek-details/2026-09-30-caffeine-selfheal-e-lock-fix.md).

## Listas Auxiliares e Recursos

- **[Pacotes e Recursos Extras Úteis](../pacotes-extras-uteis.md)**: Tabela contínua de bibliotecas, ferramentas CLI e apps extras instalados após o sistema (como `mpvpaper`, `yt-dlp`), documentando utilidade e comando de instalação.

## Regras para novas entradas

- **Princípio da Finalidade Única (IMPORTANTE)**: Cada recurso ou subsistema possui um único arquivo de documentação. Ao solicitar alterações, melhorias ou correções em uma funcionalidade existente, o arquivo original DEVE ser atualizado no mesmo lugar (registrando o histórico na seção de Atualizações/Evolução), e **NUNCA** deve ser criado um arquivo novo redundante.
- Nome do arquivo para novas features: `YYYY-MM-DD-<slug>.md`
- Conteúdo mínimo: **Motivo · O que foi feito · Como realizar (Passo a passo com comandos/snippets) · Arquivos tocados · Como verificar · Como reverter**
- Referência aos arquivos reais em `~/.config` / `~/dots-hyprland` (caminho exato).