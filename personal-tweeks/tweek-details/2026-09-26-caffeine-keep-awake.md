# Caffeine / Keep awake que realmente funciona

**Data:** 2026-09-26
**Status:** Aplicado — validado

## ⚠️ Decisão de projeto: o comportamento PADRÃO é o desejado

**Não remova os 3 `listener` do `hypridle.conf`.** Isso foi avaliado e
**rejeitado** explicitamente pelo usuário em 2026-09-26.

O que foi proposto como simplificação, e por que foi descartado:

| Alternativa considerada | Por que foi rejeitada |
|---|---|
| Apagar os 3 `listener` do `hypridle.conf` (5/10/15 min) | O usuário **quer** o comportamento padrão. O botão existe justamente para as **exceções** temporárias, não para substituir a regra. |
| `HandleLidSwitch=ignore` no logind | Desligaria a tampa **permanentemente**, inclusive com o café desligado — isso quebra o comportamento padrão, que o usuário quer manter. |
| `LidSwitchIgnoreInhibited=no` em `logind.conf.d` | Funciona, mas exige `sudo` + `reboot` e mexe em config **de sistema** para um problema **de sessão**. **Nao foi usado.** A tampa terminou no comportamento padrao do sistema — ver a revisao em [caffeine-lid-e-selfheal.md](2026-09-26-caffeine-lid-e-selfheal.md). |
| Remover o botão de café do painel | O botão **é** a solução desejada. |

O que ficou: comportamento padrão intacto (`hypridle.conf` no repo, sem
qualquer edição) + o botão do café funcionando de verdade, agora cobrindo
inhibitor persistente e auto-cura — **sem nenhum `sudo` e sem reboot**.

## Motivo

O botão de café ("Keep awake") do Quickshell estava **ligado**
(`~/.local/state/quickshell/states.json` → `"inhibit": true`), mas a tela
mesmo assim apagava depois de ~10 minutos de inatividade.

## Causa raiz

O toggle usava a API `Idle` do Quickshell:

`~/.config/quickshell/ii/modules/common/models/quickToggles/IdleInhibitorToggle.qml`
```qml
toggled: Idle.inhibit
mainAction: () => { Idle.toggleInhibit(); }
```

O `Idle.inhibit` do Quickshell é implementado com o protocolo Wayland
`ext_idle_inhibit_v1`. Isso **só** impede o compositor de enviar *notificações
de ociosidade para o próprio processo do Quickshell*. Não afeta nenhum outro
processo do sistema.

O hypridle é um **processo separado** (`/usr/bin/hypridle`) com timers
próprios, e o `~/.config/hypr/hypridle.conf` faz:

```
listener { timeout = 300;  on-timeout = loginctl lock-session }
listener { timeout = 600;  on-timeout = hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })' }
listener { timeout = 900;  on-timeout = $suspend_cmd }
```

Ou seja: em 5 min trava a sessão, em 10 min **desliga a tela na força**, em
15 min suspende. Nenhum inhibitor de Wayland impede nada disso — ele desliga a
tela por conta própria.

Confirmado com `systemd-inhibit --list`: zero inhibitors do Quickshell, só o
`delay` do próprio hypridle. O botão era inútil.

## O que foi feito

Criado o script `~/.local/bin/caffeine`, que age no hypridle diretamente:

- **Liga:** `pkill -STOP -x hypridle` (congela os 3 listeners) + sobe
  `systemd-inhibit --what=idle:sleep --mode=block sleep infinity` (trava
  suspensão no logind, que é independente do hypridle).
- **Desliga:** reinicia o hypridle (ver "armadilha" abaixo) + mata o inhibitor.

Estado persistido em `~/.local/state/caffeine` (só `on` ou `off`).

> ⚠️ **O script foi reescrito** no mesmo dia, em
> [2026-09-26-caffeine-lid-e-selfheal.md](2026-09-26-caffeine-lid-e-selfheal.md).
> A versão final usa `setsid` no inhibitor, tem subcomando `reconcile` e o
> `status` diagnostica. Esta seção descreve a **versão original**, para
> entender a causa raiz. Onde este doc citar
> `~/.local/state/caffeine.inhibitor`, saiba que esse arquivo **não existe
> mais** — foi removido de propósito.

### A armadilha do SIGCONT

Congelar com `SIGSTOP` é o que impede o desligamento, **mas** os timeouts do
hypridle continuam envelhecendo enquanto o processo está parado. Ao mandar
`SIGCONT`, todos os listeners vencidos disparam de uma vez e a tela apaga
na hora — justo o oposto do que o usuário quer ao desativar o caffeine.

Por isso o `off` **mata e relança** o hypridle, zerando todos os timers:

```sh
pkill -CONT -x hypridle; pkill -x hypridle; sleep 1
setsid hypridle >/dev/null 2>&1 </dev/null &
```

### Ligação com o botão do Quickshell

Os dois QML do botão de café foram trocados de `Idle.toggleInhibit()` para
`Process` chamando o script, lendo a saída (`on`/`off`) para atualizar o
estado visual do botão:

- `.../modules/common/models/quickToggles/IdleInhibitorToggle.qml` (usado pelo
  painel Android e pelo classic)
- `.../modules/ii/sidebarRight/quickToggles/classicStyle/IdleInhibitor.qml`

O caminho é absoluto (`Quickshell.env("HOME") + "/.local/bin/caffeine"`) em
vez de `"caffeine"`, porque o `Process` do Quickshell não herdou o PATH com
`~/.local/bin` — usar só `"caffeine"` falhava com
`Process failed to start, likely because the binary could not be found`.

O `Idle.toggleInhibit(true)` do `LockScreen.qml:84` foi **mantido**: ali faz
sentido (evitar o blanking durante a tela de unlock, onde só o Quickshell
importa).

## Arquivos tocados

- `~/.local/bin/caffeine` (novo, chmod +x)
- `~/dots-hyprland/dots/.config/quickshell/ii/modules/common/models/quickToggles/IdleInhibitorToggle.qml`
- `~/dots-hyprland/dots/.config/quickshell/ii/modules/ii/sidebarRight/quickToggles/classicStyle/IdleInhibitor.qml`
- `~/dots-hyprland/dots/.config/hypr/hyprland/env.lua` (bônus, abaixo)
- `~/dots-hyprland/dots/.config/fish/config.fish` (bônus, abaixo)

### Bônus: `~/.local/bin` no PATH

`~/.local/bin` não estava no PATH em lugar nenhum (nem no Hyprland, nem no
fish), então o script não era achado pelo nome. Adicionado:

- `env.lua`: prepend de `~/.local/bin` no `PATH` da sessão
- `config.fish`: `fish_add_path ~/.local/bin`

O QML **não** depende disso (usa caminho absoluto), mas o terminal agora
encontra o `caffeine` pelo nome.

## Como verificar

Saída **atual** do script (o `status` foi reescrito no tweak do
[selfheal](2026-09-26-caffeine-lid-e-selfheal.md) — agora inclui PIDs e sai com
código 1 se o estado não bater com a realidade):

```sh
caffeine status
# caffeine: off | hypridle: running (pid 865) (frozen: no) | logind inhibitor: no

caffeine on
caffeine status
# caffeine: on | hypridle: running (pid 865) (frozen: yes) | logind inhibitor: yes (pid 175107)
# exit=0

ps -o pid,stat,comm -p "$(pgrep -x hypridle)"
#   PID STAT COMMAND
#   865 T<sl hypridle     <- o "T" no STAT = congelado

systemd-inhibit --list | grep caffeine
# caffeine  1000 cailoop  170179  systemd-inhibit  sleep:idle  caffeine mode enabled  block

caffeine off
ps -o pid,stat,comm -p "$(pgrep -x hypridle)"   # Note: o PID muda = reiniciou
```

Teste final: ligar o café, esperar mais de 10 min sem tocar nada, a tela não
pode apagar.

Depois de desligar, a tela **não** deve apagar imediatamente (era o bug do
SIGCONT) — o hypridle reinicia os timers do zero.

## Como reverter

```sh
~/.local/bin/caffeine off          # garante hypridle rodando
systemctl --user disable --now caffeine-watch.timer
rm ~/.config/systemd/user/caffeine-watch.{timer,service}
rm ~/.local/bin/caffeine
```

E reverter no repo os dois QML para `Idle.toggleInhibit()` e remover o PATH de
`env.lua`/`config.fish`, depois `./setup install-files -f --skip-backup`.
Reiniciar o Quickshell (`qs -c ii`) para o QML recarregar.

> **Amanheceu:** este tweak original deixou **3 furos** (tampa, inhibitor morre
> no reload do Quickshell, sem auto-cura). Todos corrigidos no mesmo dia em
> [2026-09-26-caffeine-lid-e-selfheal.md](2026-09-26-caffeine-lid-e-selfheal.md).
> O script atual é o reescrito com `setsid` + `reconcile`.

## Como realizar (Passo a passo)

> ⚠️ O tweak completo (incluindo o timer de auto-cura e a revisão da tampa) está em [2026-09-26-caffeine-lid-e-selfheal.md](2026-09-26-caffeine-lid-e-selfheal.md). Os passos abaixo cobrem a implementação base.

### 1. Criar o script `~/.local/bin/caffeine`

```bash
mkdir -p ~/.local/bin
# Crie o arquivo ~/.local/bin/caffeine com o conteúdo do script
# (ver o arquivo em ~/.local/bin/caffeine no sistema)
chmod +x ~/.local/bin/caffeine
```

### 2. Modificar os QML do botão no repositório de dotfiles

Edite `~/dots-hyprland/dots/.config/quickshell/ii/modules/common/models/quickToggles/IdleInhibitorToggle.qml`
substituindo o uso de `Idle.toggleInhibit()` por um `Process` que chama o script:

```qml
Process {
    id: caffeineProcess
    command: [Quickshell.env("HOME") + "/.local/bin/caffeine", "toggle"]
    onExited: (code) => {
        caffeineState.read()
    }
}
```

Faça o mesmo para `~/dots-hyprland/dots/.config/quickshell/ii/modules/ii/sidebarRight/quickToggles/classicStyle/IdleInhibitor.qml`.

### 3. Sincronizar a dotfile

```bash
cd ~/dots-hyprland
./setup install-files -f --skip-backup --skip-allgreeting
```

### 4. Criar os serviços de auto-cura do systemd

```bash
# caffeine-watch.service
cat > ~/.config/systemd/user/caffeine-watch.service << 'EOF'
[Unit]
Description=Re-assert caffeine keep-awake state if it drifted
Documentation=file://%h/Projects/personal-tweeks-list/2026-09-26-caffeine-lid-e-selfheal.md

[Service]
Type=oneshot
ExecStart=%h/.local/bin/caffeine reconcile
EOF

# caffeine-watch.timer
cat > ~/.config/systemd/user/caffeine-watch.timer << 'EOF'
[Unit]
Description=Check caffeine keep-awake state every minute

[Timer]
OnBootSec=20s
OnUnitActiveSec=60s
AccuracySec=5s
Unit=caffeine-watch.service

[Install]
WantedBy=timers.target
EOF
```

### 5. Ativar o timer (sem sudo)

```bash
systemctl --user enable --now caffeine-watch.timer
systemctl --user status caffeine-watch.timer  # deve aparecer: active (waiting)
```

### 6. (Bônus) Garantir `~/.local/bin` no PATH da sessão Hyprland

Em `~/dots-hyprland/dots/.config/hypr/hyprland/env.lua`, adicione no início do PATH:
```lua
-- prepend ~/.local/bin para que scripts como caffeine sejam achados
env = { "PATH", os.getenv("HOME") .. "/.local/bin:" .. (os.getenv("PATH") or "") }
```

Em `~/dots-hyprland/dots/.config/fish/config.fish`, adicione:
```fish
fish_add_path ~/.local/bin
```

Depois sincronize:
```bash
cd ~/dots-hyprland && ./setup install-files -f --skip-backup --skip-allgreeting
```

## `~/.config/hypr/hypridle.conf.new` — não é lixo, e não é do CachyOS antigo

**Correção:** a primeira versão deste doc dizia que esse arquivo era "lixo
gerado pelo setup" e sugeria apagar. Estava incompleto e misledo quanto à
origem. A verdade:

- O arquivo **foi criado por mim**, durante a aplicação deste tweak, na primeira
  `./setup install-files` da sessão (2026-09-26). **Não** é resíduo do CachyOS
  nem de uma instalação falhada do End-4.
- Evidência: `hypridle.conf` tem mtime 2026-09-24 19:36 (instalação do End-4);
  `hypridle.conf.new` tem mtime 2026-09-26 13:29 (a sessão de hoje). O arquivo é
  byte-idêntico ao `dots/.config/hypr/hypridle.conf` do repo e não existe no
  `~/ii-original-dots-backup`.
- Mecanismo: em `sdata/subcmd-install/3.files-legacy.sh:64-70`, `hypridle.conf`
  é o **único** config do repo instalado via `install_file__auto_backup()`, que
  quando não é firstrun executa `cp_file $s $t.new` — isto é, `cp -f` para
  `hypridle.conf.new`. É by-design: o End-4 quer mostrar a versão upstream caso
  você tenha editado a sua.

**Consequência prática:** apagar não resolve — `./setup install-files` recria o
arquivo a cada execução. O hypridle só lê `hypridle.conf`, então o `.new` é
inofensivo. **O certo é ignorar.** Foi removido uma vez por indicância do usuário,
sabendo que volta.

```sh
rm -f ~/.config/hypr/hypridle.conf.new   # volta no próximo ./setup install-files
```
