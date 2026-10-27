# Hyprland para Gaming (CachyOS + End-4 / illogical-impulse)

Guia de ajustes no compositor Hyprland para latencia minima, Raw Input e tearing em jogos competitivos. Todos os overrides vivem em `~/.config/hypr/custom/*.lua`, que a dotfile End-4 carrega por ultimo (nunca e sobrescrito por updates).

## 1 - Raw Input, Renderizacao e Cursor

Edite (ou crie) o arquivo `~/.config/hypr/custom/general.lua`:

```lua
hl.config({
    input = {
        kb_layout = "us,br",
        kb_variant = ",abnt2",
        kb_options = "grp:alt_shift_toggle",
        accel_profile = "flat",            -- Mouse 1:1 (Raw Input)
        force_no_accel = 0,
    },
    render = {
        direct_scanout = 2,                -- Pula a composicao em fullscreen (-1 frame lag)
        new_render_scheduling = false,     -- Desliga triple-buffering automatico (-1 frame lag)
    },
    general = {
        allow_tearing = true,              -- Master switch para entregar quadros fora do vblank
    },
    cursor = {
        no_hardware_cursors = true,
    },
})
```

**Legenda:**

- **`accel_profile = "flat"`:** Ativa Raw Input no Wayland. Movimento do ponteiro na tela sera 1:1 com o movimento fisico do mouse (DPI puro), sem aceleracao.
- **`force_no_accel = 0`:** Funciona em conjunto com o `flat` para garantir que nenhuma camada legada de aceleracao interfira.
- **`direct_scanout = 2`:** Pula a composicao do Hyprland em fullscreen, eliminando 1 frame de latencia.
- **`new_render_scheduling = false`:** Desliga o triple-buffering automatico do compositor.
- **`allow_tearing = true`:** Habilita o master switch para que janelas marcadas com `immediate` entreguem quadros fora do vblank.

## 2 - Regras de Janela (Tearing e Fullscreen)

Edite (ou crie) o arquivo `~/.config/hypr/custom/rules.lua`:

```lua
-- Tearing imediato, fullscreen e tile para Overwatch 2
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

Para adicionar outros jogos, duplique o bloco trocando a class. Descubra a class de qualquer janela com `hyprctl clients | grep class`.

## 3 - Escala do Monitor

O Hyprland sofre penalidade de performance com escalas fracionarias. Garanta que o valor de `scale` seja um numero inteiro exato (ex: `1` em vez de `0.999999`). Verifique em `~/.config/hypr/hyprland/monitors.lua` ou crie um override em `~/.config/hypr/custom/monitors.lua`:

```lua
hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@60.0",
    position = "1280x1080",
    scale = 1
})
```

## 4 - Script de Game Mode (Toggle)

O script real vive em `~/.local/bin/hypr-gamemode-toggle` e e mais amplo que o
exemplo antigo: troca o perfil de energia (`sudo power-control`), chama o
`hyprconfigurator.py`, desliga animacoes/blur/sombras/gaps, congela processos de
fundo e reinicia o `hypridle` sem `SIGCONT` ao desativar.

O estado das animacoes e lido como booleano (`.bool`), nao como `"int"`:

```bash
IS_ANIM_ENABLED=$(hyprctl getoption animations:enabled -j 2>/dev/null | jq -r '.bool // empty')
if [ -z "$IS_ANIM_ENABLED" ]; then
    IS_ANIM_ENABLED=$(hyprctl getoption animations:enabled 2>/dev/null | awk 'NR==1{print $2}')
fi

if [ "$IS_ANIM_ENABLED" = "true" ] || [ "$IS_ANIM_ENABLED" = "1" ]; then
    # ativar Game Mode
else
    # desativar Game Mode
fi
```

O script completo, incluindo o tratamento do `hypridle` e dos processos de
fundo, esta em
[personal-tweeks/tweek-details/2026-10-25-gamemode-hypridle-restart.md](personal-tweeks/tweek-details/2026-10-25-gamemode-hypridle-restart.md).

O atalho e `Super + Alt + G` (tambem existe o QuickToggle no Quickshell):

```lua
hl.bind("SUPER + ALT + G", hl.dsp.exec_cmd("~/.local/bin/hypr-gamemode-toggle"), {
    locked = true,
    description = "[Utilities] game mode",
})
```

Nao use `SIGCONT` no `hypridle`: os timers continuam envelhecendo enquanto o
processo esta parado e disparam todos de uma vez ao retomar.

## 5 - Polling Rate do Mouse (Opcional)

Aplicar **somente** se houver micro-stuttering visivel ao mover o mouse rapidamente em jogo. Estabiliza a leitura do mouse em 250Hz.

```bash
echo 'options usbhid mousepoll=4' | sudo tee /etc/modprobe.d/mousepoll.conf
sudo mkinitcpio -P
```

Requer reinicio do PC para surtir efeito.

**Para reverter:**

```bash
sudo rm /etc/modprobe.d/mousepoll.conf
sudo mkinitcpio -P
```

Reinicie o PC. O polling rate voltara ao padrao do kernel.

## 6 - Verificacao

```bash
# Raw Input ativo:
hyprctl getoption input:accel_profile

# Direct scanout ativo:
hyprctl getoption render:direct_scanout

# Tearing habilitado:
hyprctl getoption general:allow_tearing

# Testar Game Mode:
~/.local/bin/hypr-gamemode-toggle
# ou pressione Super + Alt + G
```

Recarregue todas as configs de uma vez com `hyprctl reload`.
