# Power Control Híbrido (P-Cores vs E-Cores)

**Data**: 2026-09-28
**Status**: Aplicado no instalador (pronto para execução)

## Motivo
O script customizado de power-control aplicava regulagens agressivas (`energy_performance_preference`) de maneira arbitrária/global a todas as threads, o que nas arquiteturas híbridas da Intel (12ª Gen) causava engasgos, ativava a armadilha do escalonador de energia inadequado (E-Cores puxando carga ou P-cores paralisados no "Race to Sleep") e deixava o desktop pouco responsivo no modo de economia (battery).

## O que foi feito
1. **Particionamento Híbrido Ciente da Arquitetura**: Reescrevi a lógica dos quatro perfis (Game, Performance, Daily, Battery) do `power-control` para lidar assimetricamente com a CPU (i5-1235U):
   - **P-Cores** (`cpu0` a `cpu3`): Tratados para manter fluidez (ficam em `balance_power` até mesmo na economia máxima e alcançam máximo peak no Gamer Mode).
   - **E-Cores** (`cpu4` a `cpu11`): Estrangulados rigidamente durante modos conservadores para reter bateria sem travar as lides primárias (`power`), e limitados a `balance_performance` nos modos de jogo para não superaquecer a placa mãe em vão.

## Como realizar (Passo a passo com comandos)
Como reescrevi apenas o instalador oficial (`install-power-control.sh`), execute o instalador para atualizar o binário no sistema (`/usr/local/bin/power-control`):
```bash
cd ~/Projects/mandar-cailo/tools/game-config/scripts/
./install-power-control.sh
```

A partir daí, os comandos para uso ou automação do CachyOS/GameMode mantêm a sintaxe limpa de sempre:
```bash
sudo power-control battery
sudo power-control game
```

## Arquivos tocados
- `~/Projects/mandar-cailo/tools/game-config/scripts/install-power-control.sh` (modificadas as regras do instalador de automação).
- `~/Projects/optimization-cachyos/optimization-cachyOS.md` (Substituído o script global antigo pelo novo script híbrido como fonte da verdade).
- Guias avulsos/teóricos extra adicionados em `~/Projects/pesquisas/hybrid-power-control.md` e `~/Projects/pesquisas/2026-09-28-guia-taskset.md`.

## Como verificar
Execute `sudo power-control check` nos perfis novos. As diferenças deverão aparecer para um núcleo contra outro. Para diagnóstico hardcore em tempo real, use `watch -n 0.5 "grep -E 'cpu[0-4]' /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference"`.

## Como reverter
Se houver regressão de comportamento de energia da placa, abra o `install-power-control.sh` e reverta a lógica onde diz `cpu[X-Y]` de volta para a curinga global `cpu*`. Em seguida, execute a mesma linha `./install-power-control.sh` para recompilar e atualizar o path dos sudoers.
