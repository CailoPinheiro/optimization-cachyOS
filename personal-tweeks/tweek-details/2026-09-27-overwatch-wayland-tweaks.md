# Otimização Wayland / Hyprland para Overwatch 2

**Data**: 2026-09-27 · **Status**: Aplicado e funcionando

## Motivo
Aplicar a segunda fase do guia de otimização de CachyOS, focada em resolver o input lag de micro-travadas do cursor do mouse, engasgos de processamento via Wayland e remover latências no servidor do compositor nativo para otimizar especificamente jogos competitivos como Overwatch 2, utilizando o repositório lógico-impulse/End-4.

## O que foi feito
Ajustes injetados como `override` na dotfile da `illogical-impulse`. 

1. **Aceleração 1:1 e Cursor**: Aceleração forçada para "flat" (Raw Input via `general.lua`), varredura de frames direta (direct_scanout = 2), agendamentos triplos para renderização foram zerados, e desabilitada a renderização de cursores em hardware pelo lado do software.
2. **Latência de Tearing**: Liberado rasgo instantâneo da tela (immediate tearing) no compositor focado para as janelas da Steam e Overwatch (`steam_app_2357570`) dentro do arquivo customizado `rules.lua`.
3. **Modo Jogo (GameMode Toggle)**: Criado um atalho e script utilitário próprio localizado em `~/.local/bin/hypr-gamemode-toggle` para injetar em tempo de execução o desligamento de todas as decorações, animações, blur, sombras e gaps.

## Como realizar (Passo a passo)

### 1. Configurar aceleração Raw e renderização em `~/.config/hypr/custom/general.lua`:
```lua
hl.config({
    input = {
        kb_layout = "us,br",
        kb_variant = ",abnt2",
        kb_options = "grp:alt_shift_toggle",
        accel_profile = "flat",
        force_no_accel = 0,
    },
    render = {
        direct_scanout = 2,
        new_render_scheduling = false,
    },
    cursor = {
        no_hardware_cursors = true,
    }
})
```

### 2. Configurar regras de Tearing e Fullscreen em `~/.config/hypr/custom/rules.lua`:
```lua
-- Correções essenciais e Tearing para Overwatch 2 (steam_app_2357570)
hl.window_rule({
    match = { class = "^(steam_app_2357570)$" },
    immediate = true,
})
hl.window_rule({
    match = { class = "^(steam_app_2357570)$" },
    fullscreen = true,
})
hl.window_rule({
    match = { class = "^(steam_app_2357570)$" },
    tile = true,
})
```

### 3. Adicionar atalho do Modo Jogo em `~/.config/hypr/custom/keybinds.lua`:
```lua
hl.bind("SUPER + ALT + G", hl.dsp.exec_cmd("~/.local/bin/hypr-gamemode-toggle"), {
    locked = true,
    description = "[Utilities] game mode",
})
```

### 4. Recarregar as configurações do Hyprland:
```bash
hyprctl reload
```

## Arquivos tocados
- `~/.config/hypr/custom/general.lua`: Modificado (input do mouse, renderização e cursor).
- `~/.config/hypr/custom/rules.lua`: Modificado (regras do App Steam para fullscreen/immediate tearing).
- `~/.config/hypr/custom/keybinds.lua`: Novo atalho `Super + Alt + G`.
- `~/.local/bin/hypr-gamemode-toggle`: Script utilitário.

## Como verificar
```fish
# Verificar aceleração Raw do mouse desligada no Hyprland:
hyprctl getoption input:accel_profile
hyprctl getoption render:direct_scanout

# Testar o Game Mode
~/.local/bin/hypr-gamemode-toggle
# ou pressione Super + Alt + G
```

## Como reverter
Basta retirar os blocos correspondentes nos arquivos customizados de Lua `general.lua` / `rules.lua` / `keybinds.lua`, e apagar o script em `~/.local/bin/hypr-gamemode-toggle`. Recarregue o compositor via `hyprctl reload`.
