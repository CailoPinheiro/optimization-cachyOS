# Caffeine: Auto-Cura (Self-Heal) e Correcao de Bloqueio Prematuro

**Data**: 2026-09-30 · **Status**: Aplicado e validado

## Motivo
1. **Auto-Cura contra Deriva de Estado**: Garantir que o Caffeine continue ativo mesmo se o processo `hypridle` reiniciar ou se o processo de bloqueio no systemd cair.
2. **Correcao do Bloqueio Imediato**: Eliminar o comportamento em que desativar o Caffeine fazia a sessao bloquear instantaneamente e ir para a tela de lockscreen.

## Causa Raiz

### 1. Deriva de Estado (State Drift)
Ao ativar o Caffeine, o `hypridle` era congelado com `SIGSTOP` e um processo `systemd-inhibit` era criado. Caso o `hypridle` caisse ou reiniciasse por qualquer motivo externo, ele voltava descongelado, fazendo a tela apagar apos 10 minutos enquanto a interface visual ainda informava que o modo estava ativo. Alem disso, sem `setsid`, o inhibitor morria a cada recarregamento da interface do Quickshell (`qs -c ii`).

### 2. Armadilha do SIGCONT ao Desativar
Para reiniciar o `hypridle` de forma limpa ao sair do Caffeine, o script enviava `SIGCONT` seguido de `pkill`. Como os contadores de inatividade do `hypridle` continuavam envelhecendo internamente enquanto o processo estava pausado (`SIGSTOP`), o ato de descongelar (`SIGCONT`) fazia com que todos os eventos acumulados disparassem de uma vez. O listener de 300 segundos (`loginctl lock-session`) executava no mesmo milissegundo, antes que o comando de encerramento pudesse alcancar o processo.

## O que foi feito

1. **Desvinculacao com setsid**:
   - A funcao `start_inhibitor()` no script `~/.local/bin/caffeine` passou a usar `setsid` para rodar desvinculada do ciclo de vida do Quickshell, sobrevivendo a reloads da barra.

2. **Mecanismo de Auto-Cura**:
   - Adicionado o subcomando `reconcile` no script `~/.local/bin/caffeine`, que verifica se o estado desejado (`~/.local/state/caffeine`) corresponde a realidade dos processos e corrige desvios silenciosamente.
   - Criados os arquivos de unidade de usuario no systemd (`caffeine-watch.service` e `caffeine-watch.timer`) rodando o subcomando `reconcile` a cada 60 segundos sem necessidade de permissoes administrativas (`sudo`).

3. **Eliminacao do Lockscreen Indesejado**:
   - A rotina `restart_hypridle()` foi alterada para aplicar diretamente `pkill -9 -x hypridle` no processo que estava pausado.
   - Sem receber `SIGCONT`, o `hypridle` e finalizado sem processar os timers pendentes, e uma nova instancia e iniciada do zero com os contadores de inatividade limpos.

## Arquivos tocados
- `~/.local/bin/caffeine`: Atualizado com `setsid`, subcomando `reconcile` e eliminacao do `SIGCONT` no `restart_hypridle()`.
- `~/.config/systemd/user/caffeine-watch.service`: Servico oneshot de reconciliacao.
- `~/.config/systemd/user/caffeine-watch.timer`: Timer periodico com intervalo de 60 segundos.

## Como realizar (Passo a passo)

### 1. Atualizar o script ~/.local/bin/caffeine

O script reside em `~/.local/bin/caffeine`. A funcao de reinicio deve conter:
```bash
restart_hypridle() {
    pkill -9 -x hypridle 2>/dev/null
    sleep 1
    setsid hypridle >/dev/null 2>&1 </dev/null &
    disown 2>/dev/null
    sleep 1
    hypridle_running
}
```

### 2. Configurar o servico e timer de auto-cura no systemd (sem sudo)

```bash
mkdir -p ~/.config/systemd/user

# Criar a unidade de servico
cat > ~/.config/systemd/user/caffeine-watch.service << 'EOF'
[Unit]
Description=Re-assert caffeine keep-awake state if it drifted

[Service]
Type=oneshot
ExecStart=%h/.local/bin/caffeine reconcile
EOF

# Criar o timer periodico
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

# Ativar e iniciar o timer
systemctl --user daemon-reload
systemctl --user enable --now caffeine-watch.timer
```

## Como verificar

1. **Verificar estado e auto-cura**:
```bash
caffeine on
caffeine status
# Saida esperada: caffeine: on | hypridle: running (pid ...) (frozen: yes) | logind inhibitor: yes (pid ...)
```

2. **Simular queda do hypridle com cafe ligado**:
```bash
pkill -9 -x hypridle
sleep 70
caffeine status
# O hypridle deve ter retornado ao estado congelado (frozen: yes)
```

3. **Verificar desativacao sem bloqueio de tela**:
```bash
caffeine on
# Aguarde alguns minutos e entao desative
caffeine off
# O desktop deve continuar ativo e destravado, sem disparar a tela de bloqueio
```

## Como reverter

```bash
caffeine off
systemctl --user disable --now caffeine-watch.timer
rm -f ~/.config/systemd/user/caffeine-watch.{timer,service}
systemctl --user daemon-reload
```
