# Caffeine: Auto-Cura (Self-Heal), Unit do Inhibitor e Correção de Bloqueio Prematuro

**Data:** 2026-09-30  
**Status:** **Aplicado e consolidado** (atualizado em 2026-10-25)

## Motivo

1. **Auto-Cura contra Deriva de Estado**: Garantir que o modo Caffeine continue efetivamente ativo mesmo se o processo `hypridle` reiniciar, se cair ou se o processo de bloqueio no systemd for interrompido.
2. **Correção do Bloqueio Imediato**: Eliminar o comportamento em que desativar o Caffeine fazia a sessão bloquear instantaneamente e disparar o lockscreen.
3. **Persistência do Inhibitor**: O inhibitor do logind deve rodar em unit systemd própria de usuário com `Restart=always`, garantindo que não seja encerrado pelo cgroup transitório do serviço de verificação periódica.

## Causa Raiz

### 1. Deriva de Estado e Morte do Inhibitor em cgroup
Ao ativar o Caffeine, o `hypridle` era pausado com `SIGSTOP` e um processo `systemd-inhibit` era disparado em segundo plano. Porém, comandos como `setsid` criam uma nova sessão POSIX mas não escapam do cgroup do systemd: ao rodar dentro de um serviço oneshot (`caffeine-watch.service`) ou ser atrelado ao ciclo de vida do Quickshell, o inhibitor morria silenciosamente quando o processo pai terminava. Além disso, se o `hypridle` morresse, o script antigo não o trazia de volta.

### 2. Armadilha do SIGCONT ao Desativar
Para reiniciar o `hypridle` ao sair do Caffeine, o script enviava `SIGCONT` antes de tentar reiniciar. Como os contadores de inatividade do `hypridle` continuavam envelhecendo internamente enquanto o processo estava pausado (`SIGSTOP`), o envio de `SIGCONT` fazia todos os eventos acumulados dispararem de imediato: o listener de 300 segundos (`loginctl lock-session`) executava no mesmo milissegundo, trancando a tela.

### 3. Código de Retorno do Reconcile
O subcomando `reconcile` executava `apply_on()`, que retornava `1` quando corrigia algum estado divergente. O systemd interpretava qualquer código diferente de 0 como falha do serviço `caffeine-watch.service`, poluindo os logs do journal.

## O que foi feito

1. **Unit Dedicada para o Inhibitor (`caffeine-inhibitor.service`)**:
   - O comando `systemd-inhibit` passou a rodar como um serviço simples de usuário do systemd, com `Restart=always` e `RestartSec=5`, completamente independente de processos transitórios.
2. **Isolamento de Processos no Watchdog (`KillMode=process`)**:
   - `caffeine-watch.service` configurado com `KillMode=process`. Assim, quando o oneshot de verificação termina, processos de longa duração disparados por ele (como um `hypridle` reiniciado) continuam vivos.
3. **Subcomando `reconcile` Robusto**:
   - Retorna sempre `0` para o systemd.
   - Respawn automático do `hypridle` caso ele não esteja rodando antes de aplicar o congelamento (`SIGSTOP`).
4. **Eliminação do SIGCONT no Encerramento**:
   - A rotina `restart_hypridle()` encerra o processo diretamente com `pkill -9 -x hypridle`.
   - Sem receber `SIGCONT`, o `hypridle` é encerrado sem executar listeners atrasados, e uma nova instância limpa é iniciada com `setsid`.

## Como realizar (Passo a passo)

### 1. Criar a unit do inhibitor no systemd

Arquivo `~/.config/systemd/user/caffeine-inhibitor.service`:

```ini
[Unit]
Description=Caffeine logind idle/sleep inhibitor

[Service]
Type=simple
ExecStart=/usr/bin/systemd-inhibit --what=idle:sleep --mode=block --who=caffeine --why="caffeine mode enabled" sleep infinity
Restart=always
RestartSec=5
```

### 2. Criar o serviço e timer de auto-cura periódica

Arquivo `~/.config/systemd/user/caffeine-watch.service`:

```ini
[Unit]
Description=Re-assert caffeine keep-awake state if it drifted
Documentation=file://%h/Projects/optimization-cachyos/personal-tweeks/tweek-details/2026-09-30-caffeine-selfheal-e-lock-fix.md

[Service]
Type=oneshot
KillMode=process
ExecStart=%h/.local/bin/caffeine reconcile
```

Arquivo `~/.config/systemd/user/caffeine-watch.timer`:

```ini
[Unit]
Description=Check caffeine keep-awake state every minute

[Timer]
OnBootSec=20s
OnUnitActiveSec=60s
AccuracySec=5s
Unit=caffeine-watch.service

[Install]
WantedBy=timers.target
```

### 3. Configurar o script `~/.local/bin/caffeine`

Certificar-se de que `~/.local/bin/caffeine` gerencia a unit do inhibitor e faz o auto-heal:

```bash
INHIB_UNIT="caffeine-inhibitor.service"

inhibitor_alive() {
    systemctl --user is-active --quiet "$INHIB_UNIT"
}

start_inhibitor() {
    systemctl --user reset-failed "$INHIB_UNIT" 2>/dev/null || true
    systemctl --user start "$INHIB_UNIT"
    inhibitor_alive
}

stop_inhibitor() {
    systemctl --user stop "$INHIB_UNIT" 2>/dev/null || true
}

restart_hypridle() {
    # Sem SIGCONT: finaliza direto para evitar disparar timers pendentes
    pkill -9 -x hypridle 2>/dev/null
    sleep 1
    setsid hypridle >/dev/null 2>&1 </dev/null &
    disown 2>/dev/null
    sleep 1
    hypridle_running
}

reconcile() {
    if [ "$(read_state)" = "on" ]; then
        apply_on >/dev/null || true
    fi
    return 0
}
```

### 4. Recarregar os serviços de usuário

```bash
systemctl --user daemon-reload
systemctl --user enable --now caffeine-watch.timer
```

## Arquivos tocados

- `~/.local/bin/caffeine` (script principal de controle e reconciliação)
- `~/.config/systemd/user/caffeine-inhibitor.service` (unidade do bloqueador de inatividade do logind)
- `~/.config/systemd/user/caffeine-watch.service` (serviço de reconciliação periódica com KillMode=process)
- `~/.config/systemd/user/caffeine-watch.timer` (agendador de 60 segundos)

## Como verificar

1. **Verificar status com o café ligado**:
   ```bash
   caffeine on
   caffeine status
   # Saída esperada: caffeine: on | hypridle: running (pid ...) (frozen: yes) | logind inhibitor: yes (unit caffeine-inhibitor.service)
   ```

2. **Verificar execução limpa do serviço watchdog**:
   ```bash
   systemctl --user status caffeine-watch.service
   # Esperado: Result=success / ExecMainStatus=0
   ```

3. **Testar auto-cura (simular queda do hypridle)**:
   ```bash
   pkill -9 -x hypridle
   sleep 70
   caffeine status
   # O hypridle deve ter sido ressuscitado e recongelado automaticamente (frozen: yes)
   ```

4. **Testar desativação sem bloqueio**:
   ```bash
   caffeine off
   # A tela deve continuar ativa imediatamente, sem bloquear ou disparar lockscreen
   ```

## Como reverter

```bash
caffeine off
systemctl --user disable --now caffeine-watch.timer
systemctl --user stop caffeine-inhibitor.service
rm -f ~/.config/systemd/user/caffeine-watch.{service,timer}
rm -f ~/.config/systemd/user/caffeine-inhibitor.service
systemctl --user daemon-reload
```

## Histórico e Evolução

- **2026-09-30 (Original)**: Implementado o subcomando `reconcile`, o timer no systemd e a substituição do `SIGCONT` por `pkill -9` no `restart_hypridle()`.
- **2026-10-25 (Consolidação)**: Resolvida a perda do inhibitor movendo-o para a unit `caffeine-inhibitor.service` (escapando do cgroup do oneshot). Adicionado `KillMode=process` no watch service, respawn explícito de hypridle no `apply_on()` e retorno forçado de `0` no `reconcile()`.
