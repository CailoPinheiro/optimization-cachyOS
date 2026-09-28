# Autologin do Hyprland no tty1

**Data:** 2026-09-26
**Status:** Aplicado e validado — mas **deixou de ser o caminho do boot**.
Desde 2026-09-26 17:29 o greetd segura o tty1 e quem faz o autologin e o
`[initial_session]` dele. Este script virou **fallback**: so tem efeito se o
greetd for desabilitado.

## Motivo

Ao ligar o notebook, o login automático no tty1 funcionava, mas o Hyprland
**não** subia: aparecia a tela preta com o prompt e era preciso digitar
`start-hyprland` manualmente.

## Estado atual (2026-09-26 17:29, pos-greetd)

O greetd esta `enabled` e `active`, e declara `Conflicts=getty@tty1.service`.
Isso significa que o boot **nao passa mais por este script**:

- boot comecou as `17:29:18`, greetd subiu as `17:29:32`
- `~/.cache/hyprland.log` foi modificado as `17:28:57` — **antes** do boot
- logo o `auto-Hypr.fish` nao rodou neste boot

Quem subiu a sessao foi o `[initial_session]` do greetd, que roda
`sleep 2 && exec start-hyprland` via `sh(1)`, sem passar por shell de login.

O script continua no disco e continua correto, mas so importa em dois casos:

1. o greetd for desabilitado (`sudo systemctl disable greetd`)
2. o fallback for para ambiente sem greetd

Nao apagar. Se um dia o `getty@tty1` voltar a ser o dono do tty1, este
script e o que faz o Hyprland subir sem digitar nada.

## Causa raiz

O script que faz o autologin existia e estava correto:

`~/.config/fish/auto-Hypr.fish`
```fish
# Auto start Hyprland on tty1
if test -z "$DISPLAY" ;and test "$XDG_VTNR" -eq 1
    mkdir -p ~/.cache
    exec start-hyprland > ~/.cache/hyprland.log 2>&1
end
```

O problema é a **localização** dele. O fish só carrega automaticamente:

- `~/.config/fish/config.fish` (arquivo principal)
- `~/.config/fish/conf.d/*.fish` (autoload)
- `~/.config/fish/functions/*.fish` (lazy load)

Arquivos `.fish` soltos na **raiz** de `~/.config/fish/` — como estava o
`auto-Hypr.fish` — **nunca são executados**. Não havia `conf.d/` no repo, nem
um `source` dele no `config.fish`. O script era código morto.

## O que foi feito

Editado no repositório de dotfiles e sincronizado com `./setup install-files`.
No topo de `config.fish`, **antes** do bloco `if status is-interactive`:

```fish
# Auto start Hyprland on tty1.
# fish only auto-sources config.fish and conf.d/*.fish, so this file sitting
# in the config root would never run. Source it explicitly.
if test -f ~/.config/fish/auto-Hypr.fish
    source ~/.config/fish/auto-Hypr.fish
end
```

Foi escolhido o `source` em vez de mover o arquivo para `conf.d/` para manter
o `auto-Hypr.fish` no mesmo lugar onde o resto da dotfile espera que ele
esteja (e preserva a variante `~/.config/zshrc.d/auto-Hypr.sh` para quem usa
zsh).

## Como realizar (Passo a passo)

> ⚠️ **Atenção:** Desde 2026-09-26 o greetd gerencia o boot. Este tweak só importa se o greetd for desabilitado. Os passos abaixo documentam como replicar caso o getty@tty1 volte a ser o dono do tty1.

### 1. Confirmar que o `auto-Hypr.fish` existe no lugar correto

```bash
ls ~/.config/fish/auto-Hypr.fish
# Conteúdo esperado:
cat ~/.config/fish/auto-Hypr.fish
```

O conteúdo deve ser:
```fish
# Auto start Hyprland on tty1
if test -z "$DISPLAY" ;and test "$XDG_VTNR" -eq 1
    mkdir -p ~/.cache
    exec start-hyprland > ~/.cache/hyprland.log 2>&1
end
```

### 2. Adicionar o `source` no topo do `config.fish` do repositório

Edite `~/dots-hyprland/dots/.config/fish/config.fish` e adicione **antes** do bloco `if status is-interactive`:

```fish
# Auto start Hyprland on tty1.
# fish only auto-sources config.fish and conf.d/*.fish, so this file sitting
# in the config root would never run. Source it explicitly.
if test -f ~/.config/fish/auto-Hypr.fish
    source ~/.config/fish/auto-Hypr.fish
end
```

### 3. Sincronizar com o setup

```bash
cd ~/dots-hyprland
./setup install-files -f --skip-backup --skip-allgreeting
```

### 4. Verificar sem reiniciar (com stub)

```bash
mkdir -p /tmp/stub
printf '#!/bin/sh\necho "[STUB] start-hyprland CHAMOU"\n' > /tmp/stub/start-hyprland
chmod +x /tmp/stub/start-hyprland
rm -f ~/.cache/hyprland.log
env -u DISPLAY -u WAYLAND_DISPLAY XDG_VTNR=1 PATH="/tmp/stub:$PATH" fish -i -c true
cat ~/.cache/hyprland.log   # deve mostrar a linha do stub
```

Teste negativo (não deve disparar fora do tty1):
```bash
env -u DISPLAY -u WAYLAND_DISPLAY XDG_VTNR=2 PATH="/tmp/stub:$PATH" fish -i -c true
# ~/.cache/hyprland.log NÃO deve ser modificado
```

### 5. Verificar definitivamente: reiniciar o sistema

```bash
reboot
# Não deve aparecer prompt para digitar start-hyprland
```

## Arquivos tocados

- `~/dots-hyprland/dots/.config/fish/config.fish` (fonte da mudança)
- `~/.config/fish/config.fish` (gerado por `./setup install-files`)

Nada foi editado direto em `~/.config`, conforme as regras da dotfile.

## Como verificar

**Teste real (o que importa):** reiniciar a máquina. Não deve pedir
`start-hyprland`.

**Teste sem reboot**, simulando o login do tty1 com um stub no lugar do
Hyprland (para não subir uma segunda sessão):

```sh
mkdir -p /tmp/stub
printf '#!/bin/sh\necho "[STUB] start-hyprland CHAMOU"\n' > /tmp/stub/start-hyprland
chmod +x /tmp/stub/start-hyprland
rm -f ~/.cache/hyprland.log
env -u DISPLAY -u WAYLAND_DISPLAY XDG_VTNR=1 PATH="/tmp/stub:$PATH" fish -i -c true
cat ~/.cache/hyprland.log    # deve mostrar a linha do stub
```

O `auto-Hypr.fish` redireciona a saída para `~/.cache/hyprland.log`, então é
aí que aparece o resultado — e é também o log para diagnosticar falha de
boot do Hyprland.

Verificar o caso negativo (não deve chamar fora do tty1): mesma comando com
`XDG_VTNR=2` e confirme que `~/.cache/hyprland.log` **não** é criado.

## Como reverter

Remover o bloco de 6 linhas do `source` no topo do `config.fish` do repo e
rodar `./setup install-files -f --skip-backup`.

## Nota

O `getty@tty1.service` da máquina está com o template padrão do systemd
(`agetty --noreset --noclear - ${TERM}`), sem override de autologin em
`/etc/systemd/system/`. Ou seja, o autologin vem de outro lugar (provavelmente
`/etc/inittab` ou config do pacote CachyOS). Funciona, mas não está documentado
em lugar nenhum do systemd.
