# Integração Suave do Game Mode com Quickshell e Hyprland

**Data**: 2026-09-28 · **Status**: Aplicado e funcionando

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
3. **Congelamento suave de processos em background (SIGSTOP / SIGCONT)**:
   - `mpvpaper` (se houver wallpaper animado/vídeo rodando, congela e poupa 10–15% de GPU).
   - `megasync` (pausa uploads/downloads e I/O de disco).
   - `hypridle` (impede suspensão ou desligamento de tela durante uso de controles/gamepads).
   - `tracker-miner-fs-3` e `baloo_file` (indexadores de arquivos pausados).
4. **Sincronia Total e Unificada**:
   - O atalho `Super + Alt + G` e o botão da UI do Quickshell (`GameModeToggle.qml`) executam o mesmo script `~/.local/bin/hypr-gamemode-toggle`.
   - Modificações aplicadas de forma suave via `shellOverrides/main.lua` sem quedas ou reinicialização do compositor.
5. **Backups Seguros**:
   - Arquivos originais salvos em `~/Projects/bkp-das-coisa/`.

## Como realizar (Passo a passo)

### 1. Fazer backup dos arquivos originais

```bash
mkdir -p ~/Projects/bkp-das-coisa
cp ~/.local/bin/hypr-gamemode-toggle ~/Projects/bkp-das-coisa/hypr-gamemode-toggle.bak
cp ~/dots-hyprland/dots/.config/quickshell/ii/modules/common/models/quickToggles/GameModeToggle.qml \
   ~/Projects/bkp-das-coisa/GameModeToggle.qml.bak
```

### 2. Instalar o script expandido `~/.local/bin/hypr-gamemode-toggle`

O script já está instalado no sistema. Para criá-lo do zero em outra máquina:

```bash
mkdir -p ~/.local/bin
# Crie o arquivo ~/.local/bin/hypr-gamemode-toggle com o conteúdo completo
# do script (ver ~/.local/bin/hypr-gamemode-toggle no sistema atual como referência)
chmod +x ~/.local/bin/hypr-gamemode-toggle
```

O script detecta o estado atual via `hyprctl getoption animations:enabled`:
- Se animações **ligadas** → **ativa** o Game Mode (SIGSTOP nos processos, desliga blur/sombras/gaps, bypass EasyEffects)
- Se animações **desligadas** → **desativa** o Game Mode (SIGCONT, remove overrides via hyprconfigurator, restaura EasyEffects)

### 3. Modificar o `GameModeToggle.qml` no repositório de dotfiles

Edite `~/dots-hyprland/dots/.config/quickshell/ii/modules/common/models/quickToggles/GameModeToggle.qml` para que o botão chame o script diretamente via `Quickshell.execDetached`:

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

### 5. O atalho de teclado `Super + Alt + G` já está configurado

O atalho foi adicionado no tweak anterior em `~/.config/hypr/custom/keybinds.lua`:
```lua
hl.bind("SUPER + ALT + G", hl.dsp.exec_cmd("~/.local/bin/hypr-gamemode-toggle"), {
    locked = true,
    description = "[Utilities] game mode",
})
```

Se ainda não estiver lá, adicione-o e recarregue:
```bash
hyprctl reload
```

## Arquivos tocados
- `~/.local/bin/hypr-gamemode-toggle`: Script expandido com otimizações completas, bypass de áudio e gerenciamento de processos.
- `~/dots-hyprland/dots/.config/quickshell/ii/modules/common/models/quickToggles/GameModeToggle.qml`: Integrado para acionar o script unificado.
- `~/.config/quickshell/ii/modules/common/models/quickToggles/GameModeToggle.qml`: Sincronizado com a dotfile.
- `~/Projects/bkp-das-coisa/hypr-gamemode-toggle.bak`: Backup do script original.
- `~/Projects/bkp-das-coisa/GameModeToggle.qml.bak`: Backup do QML original.

## Como verificar
```fish
# 1. Pressionar Super + Alt + G ou clicar no botão "Game mode" na sidebar:
~/.local/bin/hypr-gamemode-toggle

# 2. Conferir se as animações foram desligadas:
hyprctl getoption animations:enabled -j | jq '.bool'
# false = Modo Jogo Ativo | true = Modo Normal

# 3. Conferir o arquivo de overrides dinâmicos:
cat ~/.config/hypr/hyprland/shellOverrides/main.lua

# 4. Conferir camadas do Quickshell ativas:
hyprctl layers
```

## Como reverter
Basta restaurar os arquivos da pasta de backup:
```bash
cp ~/Projects/bkp-das-coisa/hypr-gamemode-toggle.bak ~/.local/bin/hypr-gamemode-toggle
cp ~/Projects/bkp-das-coisa/GameModeToggle.qml.bak ~/dots-hyprland/dots/.config/quickshell/ii/modules/common/models/quickToggles/GameModeToggle.qml
cp ~/Projects/bkp-das-coisa/GameModeToggle.qml.bak ~/.config/quickshell/ii/modules/common/models/quickToggles/GameModeToggle.qml
```
