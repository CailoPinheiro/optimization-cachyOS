# Integração Suave do Game Mode com Quickshell e Hyprland

**Data**: 2026-09-28 · **Status**: **Aplicado e consolidado** (atualizado em 2026-09-30 e 2026-10-25)

## Erratas Resolvidas (2026-09-30)
1. **Fix do comportamento EasyEffects Autostart**: EasyEffects não inicia mais automaticamente no boot, permitindo que a UI (Quickshell toggle) tenha controle total sobre o estado (ON inicia, OFF mata). O script do game mode apenas modula (`easyeffects -b 1 / 2`) caso o programa já esteja aberto.
2. **Fix de Integração com Power Control**: Ao criar condições `detect_power_mode()`, o `hypr-gamemode-toggle` agora puxa em cascata o `sudo power-control game` com reversão exata do que já estava aplicado quando o game-mode é desligado (não travando mais em apenas um modo).

## Motivo
Otimizar ao máximo o desempenho da GPU integrada (Intel Iris Xe) e CPU durante sessões de jogos competitivos, eliminando micro-travadas, cálculos de transparência/blur/sombras, latência de renderização e consumo de recursos em segundo plano (vídeo wallpapers, sincronização de nuvem e efeitos DSP de áudio), sem utilizar comandos destrutivos (`hyprctl reload` ou `kill -9`).

## O que foi feito
1. **Otimização visual e de latência no Hyprland**:
   - `animations:enabled 0`
   - `decoration:shadow:enabled 0`
   - `decoration:blur:enabled 0`
   - `decoration:rounding 0`
   - `decoration:active_opacity 1.0` e `decoration:inactive_opacity 1.0` (zero processamento de alfa)
   - `decoration:dim_inactive 0`, `dim_special 0`, `dim_around 0`
   - `general:gaps_in 0` e `general:gaps_out 0`
   - `general:border_size 1`
   - `general:allow_tearing 1` (latência zero / immediate mode)
2. **Economia de CPU no Áudio**:
   - Ativação de desvio global no EasyEffects (`easyeffects -b 1`) ao iniciar o Game Mode.
   - Restauração automática dos efeitos normais (`easyeffects -b 2`) ao desativar.
3. **Congelamento suave de processos em background (SIGSTOP / reinício seguro do hypridle)**:
   - `mpvpaper` (se houver wallpaper animado/vídeo rodando, congela e poupa 10–15% de GPU).
   - `megasync` (pausa uploads/downloads e I/O de disco).
   - `hypridle` (congelado via `SIGSTOP` ao ativar; na desativação é reiniciado do zero via `kill -9` + `setsid`, nunca `SIGCONT`, respeitando o Caffeine se já estiver ativo).
   - `tracker-miner-fs-3` e `baloo_file` (indexadores de arquivos pausados).
4. **Sincronia Total e Unificada**:
   - O atalho `Super + Alt + G` e o botão da UI do Quickshell (`GameModeToggle.qml`) executam o mesmo script `~/.local/bin/hypr-gamemode-toggle`.
   - Modificações aplicadas de forma suave via `shellOverrides/main.lua` sem quedas ou reinicialização do compositor.
5. **Backups Seguros**:
   - Arquivos originais salvos em `~/Projects/optimization-cachyos/personal-tweeks/bkp/`.

## Como realizar (Passo a passo)

### 1. Fazer backup dos arquivos originais

```bash
mkdir -p ~/Projects/optimization-cachyos/personal-tweeks/bkp
cp ~/.local/bin/hypr-gamemode-toggle ~/Projects/optimization-cachyos/personal-tweeks/bkp/hypr-gamemode-toggle.2026-09-28.bak
cp ~/dots-hyprland/dots/.config/quickshell/ii/modules/common/models/quickToggles/GameModeToggle.qml \
   ~/Projects/optimization-cachyos/personal-tweeks/bkp/GameModeToggle.qml.2026-09-28.bak
```

### 2. Configurar o script expandido `~/.local/bin/hypr-gamemode-toggle`

O script detecta o estado atual via `hyprctl getoption animations:enabled`:
- Se animações **ligadas** → **ativa** o Game Mode.
- Se animações **desligadas** → **desativa** o Game Mode.

No gerenciamento de processos, o `hypridle` é tratado separadamente dos processos de background para evitar que timers acumulados disparem ao descongelar:

```bash
BG_PROCESSES=("mpvpaper" "megasync" "tracker-miner-fs-3" "baloo_file")

hypridle_frozen() {
    local pid st
    pid=$(pgrep -x hypridle | head -1)
    [ -n "$pid" ] || return 1
    st=$(ps -o stat= -p "$pid" 2>/dev/null | tr -d ' ')
    case "$st" in
        T*) return 0 ;;
        *) return 1 ;;
    esac
}

freeze_hypridle() {
    pkill -STOP -x hypridle 2>/dev/null
}

restart_hypridle() {
    # kill -9 em vez de SIGCONT: evita disparar listeners acumulados
    pkill -9 -x hypridle 2>/dev/null
    sleep 1
    setsid hypridle >/dev/null 2>&1 </dev/null &
    disown 2>/dev/null
    sleep 1
}
```

Ao ativar o modo:
```bash
freeze_hypridle
```

Ao desativar o modo:
```bash
if [ "$("$HOME/.local/bin/caffeine" state 2>/dev/null)" = "on" ] && hypridle_frozen; then
    : # Caffeine é o dono do estado congelado; não mexe
else
    restart_hypridle
fi
```

### 3. Modificar o `GameModeToggle.qml` no repositório de dotfiles

Edite `~/dots-hyprland/dots/.config/quickshell/ii/modules/common/models/quickToggles/GameModeToggle.qml` para acionar o script via `Quickshell.execDetached`:

```qml
import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common.models.hyprland
import qs.services

QuickToggleModel {
    id: root
    name: Translation.tr("Game mode")
    toggled: !confOpt.value
    icon: "gamepad"

    mainAction: () => {
        Quickshell.execDetached(["/home/cailoop/.local/bin/hypr-gamemode-toggle"])
    }

    HyprlandConfigOption {
        id: confOpt
        key: "animations:enabled"
    }

    tooltipText: Translation.tr("Game mode")
}
```

### 4. Sincronizar a dotfile e recarregar o Quickshell

```bash
cd ~/dots-hyprland
./setup install-files -f --skip-backup --skip-allgreeting
qs -c ii   # recarrega o Quickshell para o QML novo entrar em vigor
```

### 5. Configurar o atalho de teclado `Super + Alt + G`

Em `~/.config/hypr/custom/keybinds.lua`:
```lua
hl.bind("SUPER + ALT + G", hl.dsp.exec_cmd("~/.local/bin/hypr-gamemode-toggle"), {
    locked = true,
    description = "[Utilities] game mode",
})
```

Recarregar o compositor:
```bash
hyprctl reload
```

## Arquivos tocados
- `~/.local/bin/hypr-gamemode-toggle`: Script de ativação/desativação, gerenciamento de processos e perfis de energia.
- `~/dots-hyprland/dots/.config/quickshell/ii/modules/common/models/quickToggles/GameModeToggle.qml`: Toggle no Quickshell.
- `~/.config/quickshell/ii/modules/common/models/quickToggles/GameModeToggle.qml`: Arquivo ativo sincronizado com a dotfile.
- `~/.config/hypr/custom/keybinds.lua`: Atalho `Super + Alt + G`.
- `~/dots-hyprland/dots/.config/hypr/hyprland/execs.lua`: Desativação do autostart automático do EasyEffects.

## Como verificar
```bash
# 1. Ativar o Game Mode via atalho ou comando:
~/.local/bin/hypr-gamemode-toggle

# 2. Conferir se as animações foram desligadas:
hyprctl getoption animations:enabled -j | jq '.bool'
# false = Modo Jogo Ativo | true = Modo Normal

# 3. Conferir se o hypridle foi pausado:
ps -o pid,stat,cmd -p $(pgrep -x hypridle)
# O campo STAT deve conter 'T'

# 4. Aguardar alguns minutos e desativar:
~/.local/bin/hypr-gamemode-toggle
# A tela NÃO deve bloquear, suspender ou sair da sessão.
```

## Como reverter
Basta restaurar os arquivos da pasta de backup:
```bash
cp ~/Projects/optimization-cachyos/personal-tweeks/bkp/hypr-gamemode-toggle.2026-09-28.bak ~/.local/bin/hypr-gamemode-toggle
cp ~/Projects/optimization-cachyos/personal-tweeks/bkp/GameModeToggle.qml.2026-09-28.bak ~/dots-hyprland/dots/.config/quickshell/ii/modules/common/models/quickToggles/GameModeToggle.qml
cp ~/Projects/optimization-cachyos/personal-tweeks/bkp/GameModeToggle.qml.2026-09-28.bak ~/.config/quickshell/ii/modules/common/models/quickToggles/GameModeToggle.qml
```

## Histórico e Evolução

- **2026-09-28 (Original)**: Criação da integração unificada entre Quickshell (`GameModeToggle.qml`), atalho `Super + Alt + G` e o script `hypr-gamemode-toggle`.
- **2026-09-30 (Erratas)**: Correção do EasyEffects (bypass em vez de autostart) e integração dinâmica com `power-control`.
- **2026-10-25 (Consolidação do Hypridle)**: Removido o `hypridle` do loop genérico de `SIGCONT`. O processo passou a ser encerrado com `kill -9` e reiniciado com `setsid`, eliminando a armadilha de timers acumulados que trancava a tela ou suspendia o sistema ao desativar o Game Mode. Respeito mútuo adicionado caso o Caffeine esteja ativo.
