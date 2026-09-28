# Caffeine: a tampa, o inhibitor persistente e a auto-cura

**Data:** 2026-09-26 (revisado no mesmo dia)
**Status:** Aplicado e validado. **Sem sudo, sem reboot, sem tocar no logind.**

Tweak sequel de [2026-09-26-caffeine-keep-awake.md](2026-09-26-caffeine-keep-awake.md).

## Resumo

A primeira versão do botão resolvia a tela, mas a auditoria achou **3 furos** —
caminhos por onde o sistema ainda dormia com o café "ligado". Este tweak fechou
os três. Nenhum exigiu `sudo`.

| # | Achado | Correção | Custo |
|---|---|---|---|
| 1 | Fechar a tampa suspendia com o café ligado | `handle-lid-switch` no inhibitor — **REVERTIDO, ver abaixo** | 0 |
| 2 | O inhibitor morria a cada reload do Quickshell | `setsid` | 0 |
| 3 | Nenhuma auto-cura se o hypridle reiniciasse | subcomando `reconcile` + timer de 60 s | ~30 ms/min |

> **Revisão 2026-09-26 (depois):** o achado 1 foi **revertido por decisão do
> usuário**. A tampa voltou ao comportamento padrão do sistema. Os achados 2 e 3
> seguem valendo. Ver "A tampa: decisão final".

---

## A tampa: decisão final

**O que está no script hoje: `--what=idle:sleep`. Sem `handle-lid-switch`.**

Consequência, que é o comportamento de fábrica do sistema:

| Situação | O que acontece ao fechar a tampa |
|---|---|
| Café **desligado** | suspende |
| Café **ligado** | **suspende** (igual) |

O café continua bloqueando o que é blockbuster de alto nível: apagar a tela
(`idle`) e suspender por `systemctl suspend` / menu de energia (`sleep`). Ele
simplesmente **não mexe mais na tampa**.

### Por que o logind já fazia isso sozinho

O achado original constatou que `LidSwitchIgnoreInhibited=` tem **default `yes`**
(systemd 262, o desta máquina), e o logind **ignora** locks de alto nível para a
tampa. Ou seja: o `systemd-inhibit --what=idle:sleep` do café **já era inútil
contra a tampa antes de qualquer coisa** — o default do sistema é exatamente
"a tampa suspende sempre".

Conferido nesta máquina:

```
/etc/systemd/logind.conf.d/   -> vazio, nenhum override
/etc/systemd/logind.conf       -> só as linhas comentadas do padrão
HandleLidSwitch=suspend       -> default do systemd
LidSwitchIgnoreInhibited=yes  -> default do systemd
chassis_type=10, bateria ADP1 -> é notebook, tem tampa
```

### O que foi removido, e por quê

O script usava `--what=idle:sleep:handle-lid-switch`. Esse terceiro valor é um
lock de **baixo nível**, e o `man logind.conf` é explícito:

> Low level inhibitor locks […] are **always honored, irrespective of this
> setting**. […] logind will not take any action when that key or switch is
> triggered and **the `Handle*=` settings are irrelevant**.

Ou seja, o `handle-lid-switch` **sobrescreve o `HandleLidSwitch` do sistema**.
Funcionava, era elegante (zero sudo, zero reboot, dinâmico, por usuário) — e
justamente por isso passava despercebido como "a correção do furo".

O usuário pediu para voltar ao comportamento padrão. Removido.

**Isso foi escolha, não limitação.** O caminho para ter a tampa obedecendo ao
café continua disponível e continua sem sudo:

```sh
# adicionar handle-lid-switch de volta no --what do script
setsid systemd-inhibit --what=idle:sleep:handle-lid-switch --mode=block ...
```

Alternativas que exigem `sudo` + reboot (nenhuma foi usada):

| Alternativa | Por que não |
|---|---|
| `LidSwitchIgnoreInhibited=no` em `logind.conf.d` | Config de **sistema** para problema de **sessão**. Exige sudo + reboot. O default `yes` existe como proteção contra travamento de laptop. |
| `HandleLidSwitch=ignore` em `logind.conf.d` | Desligaria a tampa **para sempre**, inclusive com o café desligado. |

### O custo aceito

Fechar a tampa com o café ligado **suspende**. E, como o hypridle está
congelado, o `before_sleep_cmd = loginctl lock-session` do `hypridle.conf`
**não executa** — então se ao suspender você acabar numa sessão destravada,
a causa é esta, e o consome é ligar o café de novo e travar à mão, ou usar o
botão de lock do Hyprland antes de fechar.

Isso é o trade-off consciente do comportamento padrão.

---

## Furo 2 — o inhibitor do logind morria a cada reload do Quickshell

A linha original era:

```sh
systemd-inhibit --what=idle:sleep ... sleep infinity >/dev/null 2>&1 &
```

Sem `setsid`. O `systemd-inhibit` era filho do script, no mesmo process group
do `Process` do QML. Quando o QML é destruído (hot-reload ao editar qualquer
arquivo da config, ou `qs -c ii`), o processo morre e **o blocker do logind é
liberado silenciosamente** — enquanto o arquivo de estado continuava dizendo
`on` e o ícone de café continuava aceso.

O hypridle continuava congelado (o `SIGSTOP` é no processo do hypridle, não
depende de quem congelou), então a falha era **parcial e traiçoe**: a tela não
apagava, mas a proteção de systemd tinha sumido. Ninguém percebia até precisar
dela.

Comparação: a linha do `restart_hypridle` **usava** `setsid` corretamente. A
inconsistência é que mascarava o bug.

## Furo 3 — nenhuma auto-cura

- Se o hypridle reiniciasse (crash, `pkill`, sessão nova), o `SIGSTOP` se perdia
  e a tela passava a apagar em 10 min com a UI ainda mostrando "ligado".
- O `enable()` antigo fazia `return` antecipado olhando **só o arquivo de
  estado**, sem conferir a realidade. Estado `on` + hypridle morto = café
  "ligado" e completamente inoperante.
- Nada reconcilia estado e realidade periodicamente.

## O que **não** era risco (verificado, pra não procurar fantasma)

| Candidato | Veredito |
|---|---|
| `power-profiles-daemon` (instalado) | Só troca governor de CPU. Nunca desliga tela nem suspende. |
| logind `IdleAction` | `#IdleAction=ignore` comentado = padrão `ignore`. Não age. |
| Quickshell | `grep` em todo `ii/`: só usa `Idle` no toggle e no `LockScreen`. Nenhum hook idle→suspend. |
| TLP / auto-cpufreq / laptop-mode / thermald | Nenhum instalado. |
| `xdph.conf` | Só config de `screencopy`. Sem relação. |
| `dpms` | Só aparece no `hypridle.conf` (o listener de 600s) e em `general.lua` como `mouse_move_enables_dpms` (que reacende). |
| `Battery.qml` auto-suspend | `battery.automaticSuspend: false`. Inerte. |
| `mem_sleep = [s2idle] deep` | irrelevante: só importa **depois** que algo dispara o suspend. |

---

## O que foi feito

### Passo 1 — script reescrito

`~/.local/bin/caffeine` — 4 mudanças:

1. **`setsid` no inhibitor** (fecha o furo 2). Verificado: `PPID=1`, `SID` próprio.
2. **Fonte da verdade = a realidade, não o arquivo.** `inhibitor_pid()` localiza
   o processo por `pgrep -f '^systemd-inhibit .*caffeine mode enabled'` — a
   string do `--why` é o marcador. O arquivo de PID foi **removido**: um PID
   obsoleto não pode mais fazer o script "perder" o inhibitor.
3. **Novo subcomando `reconcile`** (fecha o furo 3). Idempotente: se o estado é
   `on`, re-gela o hypridle e/ou recria o inhibitor, o que estiver faltando.
4. **`--what=idle:sleep`** (revisão). Era `idle:sleep:handle-lid-switch`; o
   lock da tampa saiu. Ver "A tampa: decisão final".

`status` também foi reescrito: sai com código **1** e imprime
`PROBLEMA:<lista>` quando o estado diz `on` mas a realidade não confirma.
`enable()` deixou de retornar cedo: sempre passa por `apply_on`, que compara o
estado desejado com o que está de fato rodando. `disable()` ficou mais
surgical: reinicia o hypridle **só se foi ele quem congelou**, e só o respawna se
não estiver rodando — assim `caffeine off` duas vezes não reinicia nada à toa.

### Passo 2 — timer de auto-cura (sem sudo)

**Fora do repo** (verificado: o repo não tem `dots/.config/systemd`, e
`2.setups.sh` só cria symlink do ydotool em `/usr/lib/systemd/user` — nada toca
`~/.config/systemd/user`):

- `~/.config/systemd/user/caffeine-watch.service` → `ExecStart=%h/.local/bin/caffeine reconcile`
- `~/.config/systemd/user/caffeine-watch.timer` → `OnBootSec=20s`, `OnUnitActiveSec=60s`, `AccuracySec=5s`

Ativado com `systemctl --user enable --now caffeine-watch.timer` (unidade de
usuário, **não precisa de sudo**). Custo: um `oneshot` de ~30 ms por minuto.

### Passo 3 — a tampa (revisão)

Remover `handle-lid-switch` do `--what` e reescrever os comentários do script
que explicavam o mecanismo do lock de baixo nível, para ninguém reintroduzir
achando que é a configuração original.

---

## Como realizar (Passo a passo)

> Este é o tweak completo e final do caffeine. Presupõe que o script base `~/.local/bin/caffeine` e os QML já foram configurados conforme [caffeine-keep-awake.md](2026-09-26-caffeine-keep-awake.md).

### 1. Reescrever o script `~/.local/bin/caffeine` com `setsid` e `reconcile`

O script completo está em `~/.local/bin/caffeine`. As diferenças-chave em relação à versão original:
- O `start_inhibitor()` usa `setsid` para desacoplar o processo do caller (Quickshell não mata mais o inhibitor no reload)
- Novo subcomando `reconcile`: idempotente, re-asserta o estado "on" sem tocar o state file
- `--what=idle:sleep` **sem** `handle-lid-switch` (tampa volta ao comportamento padrão)
- `status` diagnostica e retorna código 1 se estado ≠ realidade

```bash
# Verificar que o script atual já tem setsid:
grep -n "setsid" ~/.local/bin/caffeine
# Deve retornar linhas com: setsid systemd-inhibit ... e setsid hypridle ...
```

### 2. Criar os arquivos do timer de auto-cura (sem sudo)

```bash
# Criar o service
cat > ~/.config/systemd/user/caffeine-watch.service << 'EOF'
[Unit]
Description=Re-assert caffeine keep-awake state if it drifted
Documentation=file://%h/Projects/personal-tweeks-list/2026-09-26-caffeine-lid-e-selfheal.md

[Service]
Type=oneshot
ExecStart=%h/.local/bin/caffeine reconcile
EOF

# Criar o timer
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

### 3. Ativar o timer (sem sudo)

```bash
systemctl --user enable --now caffeine-watch.timer
```

### 4. Verificar que o inhibitor sobrevive ao kill do caller (simula reload do Quickshell)

```bash
~/.local/bin/caffeine on
# Anotar o PID do inhibitor:
IPID=$(pgrep -f "systemd-inhibit.*caffeine mode enabled")
# Matar o processo pai (simula o Quickshell ser recarregado):
kill -9 $$   # ou matar o terminal e testar em outro
# Em outro terminal, verificar que o inhibitor ainda existe:
kill -0 $IPID && echo "SOBREVIVEU (correto)"
```

### 5. Verificar que o timer de auto-cura funciona

```bash
# Com caffeine on, matar o hypridle à mão:
~/.local/bin/caffeine on
pkill -x hypridle
# Esperar ~70 segundos e verificar que o hypridle voltou congelado:
sleep 70
~/.local/bin/caffeine status
# Deve mostrar: hypridle: running (frozen: yes)
```

## Arquivos tocados

| Arquivo | Ação |
|---|---|
| `~/.local/bin/caffeine` | reescrito (`setsid` + `reconcile` + `status` diagnóstico); depois `--what` ajustado para `idle:sleep` |
| `~/.config/systemd/user/caffeine-watch.service` | **criado** |
| `~/.config/systemd/user/caffeine-watch.timer` | **criado** |
| `~/.config/systemd/user/timers.target.wants/caffeine-watch.timer` | symlink criado pelo `systemctl --user enable` |
| `~/.local/state/caffeine.inhibitor` | **removido** (o PID file não é mais usado) |
| `~/Projects/personal-tweeks-list/2026-09-26-caffeine-lid-e-selfheal.md` | este arquivo |
| `~/Projects/personal-tweeks-list/2026-09-26-caffeine-keep-awake.md` | decisão + seções corrigidas |
| `~/Projects/personal-tweeks-list/README.md` | índice |
| `~/Projects/illogical-impulse-dotfiles.md` | mapa: hypridle.conf + nova seção 9b |

**Nenhum arquivo do repo `~/dots-hyprland` foi tocado** — nem os QML, nem o
`hypridle.conf`. `~/.local/bin/` e `~/.config/systemd/user/` não são
sincronizados pelo `./setup install-files`, então o End-4 não reverte nada.

**`hypridle.conf` segue intacto, de propósito.** Os 3 `listener` (300/600/900s)
continuam exatamente como o End-4 instalou — é o comportamento padrão que o
usuário escolheu manter. Este tweak **não** mexe no config do hypridle, só no
processo em runtime. Não rode `./setup install-files` esperando mudança no
hypridle: não há nenhuma.

**Nada em `/etc` foi alterado.** Nenhum `sudo`, nenhum reboot.

## Como verificar

```sh
# 1. o timer está armado e rodando
systemctl --user list-timers caffeine-watch.timer
systemctl --user show caffeine-watch.service -p Result   # deve ser: success

# 2. diagnóstico do estado real (código 1 + PROBLEMA se algo divergiu)
~/.local/bin/caffeine status; echo "exit=$?"

# 3. com o café ligado, as DUAS camadas ativas
~/.local/bin/caffeine on; sleep 1
~/.local/bin/caffeine status
# esperado: hypridle: running (pid N) (frozen: yes) | logind inhibitor: yes (pid N)

# 4. o inhibitor está detached (PPID=1, SID próprio = não morre com o QML)
ps -o pid,ppid,sid,pgid -p "$(pgrep -f '^systemd-inhibit .*caffeine mode enabled')" --no-headers

# 5. o logind reconhece os DOIS tipos
systemd-inhibit --list | grep caffeine
# esperado: caffeine 1000 cailoop N systemd-inhibit sleep:idle ... block
# NÃO deve aparecer handle-lid-switch

# 6. o conteúdo bruto do lock em /run/systemd/inhibit
strings /run/systemd/inhibit/<N> | sed -n 2p
# esperado: WHAT=sleep:idle

# 7. desligar remove o lock
~/.local/bin/caffeine off
strings /run/systemd/inhibit/<N> 2>/dev/null || echo "lock removido (correto)"
```

**Teste da tampa:** ligue o café, feche a tampa, reabra. **Deve suspender** — é
o comportamento padrão, restaurado. O mesmo teste com o café desligado também
suspende. É o único teste que não dá para automatizar: exige fechar a tampa.

**Teste do timer:** ligue o café, mate o hypridle à mão (`pkill -x hypridle`),
espere ~70 s. O hypridle tem que voltar **congelado** (`STAT` começando com
`T`) sozinho, sem você tocar em nada.

## Validação feita em 2026-09-26

| # | Teste | Resultado |
|---|---|---|
| 1 | `caffeine on` | `frozen: yes`, `inhibitor: yes` |
| 2 | Camadas verificadas no SO | hypridle `T<sl`; inhibitor `PPID=1` |
| 3 | **`kill -9` no caller** (simula reload do Quickshell) | caller morreu, **inhibitor sobreviveu**, hypridle segue congelado |
| 4 | Lock materializado | `/run/systemd/inhibit/N` com `WHAT=sleep:idle`, `MODE=block`, `UID=1000` |
| 5 | Deriva 1: inhibitor `kill -9` | estado dizia `on` com 0 processos; `reconcile` recriou, `status` voltou a `exit=0` |
| 6 | `toggle` → off | hypridle reiniciado com PID novo, `S<sl`; `off` repetido **não** reiniciou o hypridle |
| 7 | Timer | `Result=success`, `Trigger` agendado 60 s à frente |
| 8 | **Revisão da tampa** | `off` → `on` deixa `WHAT=sleep:idle`; nenhum lock de baixo nível no SO; `handle-lid-switch` ausente |

O teste da tampa em si (fechar a tampa) continua pendente de execução manual.

## Como reverter

```sh
~/.local/bin/caffeine off
systemctl --user disable --now caffeine-watch.timer
rm ~/.config/systemd/user/caffeine-watch.timer \
   ~/.config/systemd/user/caffeine-watch.service
rm ~/.local/bin/caffeine
```

Nada em `/etc` para reverter — não houve alteração de sistema.

Os QML não precisam ser tocados — eles só chamam
`~/.local/bin/caffeine toggle` / `state`, que continuam com a mesma interface.
Sem o script, o botão volta a não fazer nada (e o `ext_idle_inhibit_v1` volta a
ser insuficiente, como antes deste par de tweaks).
