# 2026-10-30 - Hyprland: correcao do disparo indevido do search/overview ao soltar Super (chording fix)

## Categoria
Provisorio (`provisory/`) — contorno local aguardando merge upstream no `end-4/dots-hyprland` (PRs #3724, #3725 e #3726).

## Motivo

Na migracao das dotfiles do End-4 para a configuracao em Lua (Hyprland 0.57+), os binds de teclado que enviavam o sinal de interrupcao `quickshell:searchToggleReleaseInterrupt` deixaram de ser registrados.

No Quickshell (`Overview.qml`), o componente de busca escuta o evento global `quickshell:searchToggleRelease`. Ao segurar a tecla Super, a variavel `GlobalStates.superReleaseMightTrigger` e marcada como `true`. Se nenhuma outra tecla ou evento sinalizar a interrupcao, o ato de soltar a tecla Super dispara a abertura do overview/search.

Como o sinal de interrupcao nao existia:
- Ao pressionar `Super + T`, o terminal Kitty abria, mas ao soltar a tecla Super o overview de workspaces surgia por cima.
- Ao pressionar `Super + V`, o gerenciador de area de transferencia abria e imediatamente perdia o foco/fechava porque o overview era acionado na liberacao da tecla.
- Qualquer atalho combinado baseado em Super apresentava comportamento erratico.

## O que foi feito

Adicionado tratamento nativo de interrupcao diretamente no arquivo de customizacoes do usuario (`~/.config/hypr/custom/keybinds.lua`), sem tocar nos arquivos core da dotfile:

1. **Listener nativo de teclado (`hl.on("input.keyboard.key")`):**
   - Roda internamente no loop C++ do Hyprland.
   - Detecta qualquer tecla pressionada (`state == 1`) que nao seja `Super_L` (keycode XKB 133) ou `Super_R` (keycode XKB 134).
   - Se uma das teclas Super estiver retida (`hl.is_key_down`), despacha imediatamente o global `quickshell:searchToggleReleaseInterrupt`.

2. **Binds transparentes de mouse (`mouse:272..277`, `mouse_up`, `mouse_down`):**
   - Evitam que arrastar janelas ou usar o scroll com a tecla Super pressione acidentalmente o gatilho de busca ao soltar.

3. **Performance:**
   - Zero daemons ou processos de monitoramento em segundo plano (zero polling).
   - Zero consumo adicional de memoria ou CPU.

## Passo a passo (reproducao / re-aplicacao)

1. Adicionar o seguinte bloco ao final de `~/.config/hypr/custom/keybinds.lua`:

```lua
-- Correcao provisoria: evitar abertura indesejada do search/overview ao soltar Super apos combinacoes de teclas ou mouse
hl.on("input.keyboard.key", function(keycode, _, state)
    -- XKB keycodes (evdev + 8): 133 = Super_L, 134 = Super_R. State 1 = keydown.
    if state ~= 1 or keycode == 133 or keycode == 134 then return end
    if hl.is_key_down("Super_L") or hl.is_key_down("Super_R") then
        hl.dispatch(hl.dsp.global("quickshell:searchToggleReleaseInterrupt"))
    end
end)

for _, mouse_key in ipairs({
    "mouse:272", "mouse:273", "mouse:274", "mouse:275", "mouse:276", "mouse:277",
    "mouse_up", "mouse_down"
}) do
    hl.bind("SUPER + " .. mouse_key, hl.dsp.global("quickshell:searchToggleReleaseInterrupt"), { transparent = true })
end
```

2. Validar a sintaxe Lua e recarregar a configuracao:

```bash
luac -p ~/.config/hypr/custom/keybinds.lua
hyprctl reload
hyprctl configerrors
```

## Arquivos tocados

- `~/.config/hypr/custom/keybinds.lua`

## Como verificar

1. `hyprctl configerrors` deve retornar vazio.
2. Pressionar e soltar a tecla `Super` sozinha: deve abrir e fechar a busca/overview normalmente.
3. Pressionar `Super + T`: o terminal Kitty deve abrir diretamente, sem o overview sobrepor ao soltar a tecla.
4. Pressionar `Super + V`: o painel da area de transferencia deve abrir e permanecer ativo na tela.
5. Pressionar `Super` + scroll do mouse: a acao do scroll ocorre sem abrir o launcher ao soltar `Super`.

## Como reverter

1. Abrir `~/.config/hypr/custom/keybinds.lua`.
2. Remover o bloco de codigo adicionado (ou comentar as linhas de `hl.on` e do loop de mouse).
3. Executar `hyprctl reload`.

## Condicao de descontinuacao / remocao

Este tweak e provisorio e devera ser removido assim que o upstream do End-4 integrar formalmente a correcao no arquivo central `dots/.config/hypr/hyprland/keybinds.lua` atraves do merge de um dos Pull Requests (#3724, #3725, #3726) e o usuario atualizar o repositorio local.
