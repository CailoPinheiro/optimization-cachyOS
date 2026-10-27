# Super + L: lock da Quickshell em vez do hyprlock

**Data**: 2026-10-25 · **Status**: Aplicado — aguardando validacao do usuario

## Motivo
O atalho `Super + L` abria o `hyprlock` diretamente. O usuario quer o lock da
shell (Quickshell), que ja e o padrao do sistema (`lock.useHyprlock = false`).

## Causa raiz
O bind em `~/.config/hypr/custom/keybinds.lua` chamava:

```text
pidof hyprlock || hyprlock & loginctl lock-session
```

O `hyprlock` era iniciado antes de qualquer tentativa de lock da shell. O
`loginctl lock-session` dependia do `hypridle`, que pode estar congelado pelo
Caffeine ou pelo Game Mode.

O lock da shell esta exposto no IPC:

```bash
qs -c ii ipc call lock activate
```

O target `lock` e a funcao `activate` estao em
`~/.config/quickshell/ii/modules/common/panels/lock/LockScreen.qml`.

## O que foi feito
1. Criado `~/.local/bin/lock-session`.
2. O script tenta o IPC da Quickshell primeiro; se a shell nao responder, usa
   `hyprlock` como fallback.
3. O bind `Super + L` passou a chamar o script.
4. `hypridle.conf` nao foi alterado: ele ja usa `quickshell:lock` como `lock_cmd`.
5. `useHyprlock` continua `false` em `~/.config/illogical-impulse/config.json`.

## Como realizar (Passo a passo)

### 1. Fazer backup

```bash
cp ~/.config/hypr/custom/keybinds.lua \
   ~/Projects/optimization-cachyos/personal-tweeks/bkp/keybinds.lua.2026-10-25.bak
```

### 2. Criar o script

```bash
#!/usr/bin/env bash
# Prefere o WlSessionLock da Quickshell. hyprlock so se a shell estiver fora.
if timeout 2 qs -c ii ipc call lock activate >/dev/null 2>&1; then
    exit 0
fi
if ! pidof hyprlock >/dev/null 2>&1; then
    exec hyprlock
fi
```

Salvar em `~/.local/bin/lock-session` e dar permissao:

```bash
chmod +x ~/.local/bin/lock-session
```

### 3. Trocar o bind

Em `~/.config/hypr/custom/keybinds.lua`:

```lua
-- Lock da Quickshell primeiro; hyprlock apenas como fallback.
hl.unbind("SUPER + L")
hl.bind("SUPER + L", hl.dsp.exec_cmd("~/.local/bin/lock-session"), {
    description = "Session: Lock (Quickshell)",
})
```

### 4. Aplicar

```bash
hyprctl reload
```

## Arquivos tocados
- `~/.local/bin/lock-session`
- `~/.config/hypr/custom/keybinds.lua`
- `~/Projects/optimization-cachyos/personal-tweeks/bkp/keybinds.lua.2026-10-25.bak`

## Como verificar
1. Pressione `Super + L`.
2. Deve aparecer o lock da Quickshell, com o wallpaper e o campo de senha do
   shell, nao a tela do `hyprlock`.
3. Enquanto o lock da shell estiver ativo, `pgrep -a hyprlock` deve ficar vazio.
4. Digite a senha e confirme que a sessao volta com os aplicativos ainda abertos.

O diretorio `~/.config/hypr/custom` e tratado como `skip-if-exists` pelo
`./setup install-files`, entao essa edicao nao e sobrescrita.

## Como reverter

Para voltar ao comportamento antigo:

```lua
hl.unbind("SUPER + L")
hl.bind("SUPER + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock & loginctl lock-session"), {
    description = "Session: Lock (Bypass Caffeine)",
})
```

Ou restaurar o backup:

```bash
cp ~/Projects/optimization-cachyos/personal-tweeks/bkp/keybinds.lua.2026-10-25.bak \
   ~/.config/hypr/custom/keybinds.lua
hyprctl reload
```

## Atualizacoes
- Corrige o atalho que dependia do `hyprlock` e do `loginctl lock-session`.
- O `hypridle.conf` continua com `quickshell:lock` como primeira opcao.
