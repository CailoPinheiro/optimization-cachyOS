# Teclado: dois layouts (us/br ABNT-2) com Alt+Shift

**Data**: 2026-09-24 · **Status**: Aplicado e funcionando

## Motivo
Usar layout brasileiro ABNT-2 no teclado, mantendo US como base e alternando por atalho de teclado (`Alt + Shift` ou `Super + K`).

## O que foi feito
Sobrescrito apenas o bloco `input` via overlay `custom/` (sem modificar arquivos do repositório base).

## Como realizar (Passo a passo)

### 1. Criar ou editar o arquivo de overlay `~/.config/hypr/custom/general.lua`:
Adicione a configuração de múltiplos layouts:
```lua
hl.config({
    input = {
        kb_layout = "us,br",
        kb_variant = ",abnt2",
        kb_options = "grp:alt_shift_toggle",
    },
})
```

### 2. (Opcional) Adicionar atalho alternativo `Super + K` em `~/.config/hypr/custom/keybinds.lua`:
```lua
hl.bind("SUPER + K", hl.dsp.exec_raw("switchxkblayout current next"), { description = "Layout: alternar us/br" })
```

### 3. Recarregar as configurações do Hyprland:
```bash
hyprctl reload
```

## Arquivos tocados
- `~/.config/hypr/custom/general.lua`: Overlay do Hyprland (sobrepõe `hyprland/general.lua`).
- `~/.config/hypr/custom/keybinds.lua`: Bind opcional de tecla `Super + K`.

## Como verificar
```fish
hyprctl getoption input:kb_layout   # str: us,br
hyprctl getoption input:kb_variant  # str: ,abnt2
hyprctl getoption input:kb_options  # str: grp:alt_shift_toggle
```
- Pressione `Alt + Shift` (ou `Super + K`) para alternar entre `English (US)` e `Portuguese (Brazil)`.
- O indicador de layout aparecerá automaticamente na barra do Quickshell.

## Como reverter
Remover/simplificar `~/.config/hypr/custom/general.lua` para apenas `kb_layout = "us"` (ou apagar o bloco) e recarregar: `hyprctl reload`.
