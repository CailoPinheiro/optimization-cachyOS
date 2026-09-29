# Guia Definitivo: Otimização Extrema para Overwatch 2 (CachyOS + Hyprland)

Este guia cobre a desativação de daemons conflitantes, a criação do gerenciador de energia personalizado (com Turbo Boost liberado) e as correções essenciais para Wayland.

## 1 - Limpeza de Conflitos de Energia

O CachyOS traz um gerenciador de energia padrão que sabota as frequências do processador. É obrigatório desativá-lo permanentemente.

**1. Pare e mascare o serviço padrão:**

```
sudo systemctl stop power-profiles-daemon.service
sudo systemctl mask power-profiles-daemon.service
```

## 2 - Criação do `power-control` (Com Turbo Ativo)

Este script assume o controle total da CPU, alternando entre força bruta para o jogo e silêncio para o uso diário.

**1. Crie o arquivo:**

```
sudo nano /usr/local/bin/power-control
```

**2. Cole o código abaixo (Versão Híbrida P-Cores/E-Cores):**

```
#!/bin/bash

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# (i5-1235U: 0-3 sao P-Cores, 4-11 sao E-Cores)

set_turbo() {
    if ! echo "$1" | tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null 2>&1; then
        echo -e "${RED}Turbo nao pode ser alterado.${NC}"
    fi
}

print_full_game() {
    echo -e "${CYAN}  Governador (P-Cores): performance"
    echo -e "  EPP (P-Cores):        performance"
    echo -e "  EPP (E-Cores):        balance_performance"
    echo -e "  Turbo:                0 (ligado)"
    echo -e "  Comportamento: P-Cores no maximo para latencia minima. E-Cores balanceados para nao roubar termica.${NC}"
}

print_full_performance() {
    echo -e "${CYAN}  Governador:           performance global"
    echo -e "  EPP:                  performance global"
    echo -e "  Turbo:                0 (ligado)"
    echo -e "  Comportamento: Forca total sustentada em todos os nucleos. Alto consumo.${NC}"
}

print_full_daily() {
    echo -e "${CYAN}  Governador:           powersave global"
    echo -e "  EPP:                  balance_performance"
    echo -e "  Turbo:                0 (ligado)"
    echo -e "  Comportamento: CPU sobe e desce conforme a carga. Uso geral do dia a dia.${NC}"
}

print_full_battery() {
    echo -e "${CYAN}  Governador (E-Cores): powersave"
    echo -e "  EPP (E-Cores):        power"
    echo -e "  EPP (P-Cores):        balance_power"
    echo -e "  Turbo:                1 (desligado)"
    echo -e "  Comportamento: Economia extrema nos E-Cores. P-Cores retem folga minima para fluidez da UI.${NC}"
}

# --- CHECK / DETECT MODE ---
detect_mode() {
    local p_epp=$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference 2>/dev/null || echo "")
    local e_epp=$(cat /sys/devices/system/cpu/cpu4/cpufreq/energy_performance_preference 2>/dev/null || echo "")

    if [ "$p_epp" = "performance" ] && [ "$e_epp" = "balance_performance" ]; then
        echo -e "Modo Atual:    ${RED}Game (Smart Boost Hibrido)${NC}"
    elif [ "$p_epp" = "performance" ] && [ "$e_epp" = "performance" ]; then
        echo -e "Modo Atual:    ${RED}Performance (Forca Bruta Maxima)${NC}"
    elif [ "$p_epp" = "balance_performance" ] && [ "$e_epp" = "balance_performance" ]; then
        echo -e "Modo Atual:    ${GREEN}Daily (Padrao Equilibrado)${NC}"
    elif [ "$p_epp" = "balance_power" ]; then
        echo -e "Modo Atual:    ${YELLOW}Battery (Economia Hibrida)${NC}"
    else
        echo -e "Modo Atual:    ${NC}Customizado/Desconhecido${NC}"
    fi
}

# --- MODO GAME (SMART BOOST HIBRIDO) ---
set_game() {
    cpupower -c 0-3 frequency-set -g performance > /dev/null
    echo performance | tee /sys/devices/system/cpu/cpu[0-3]/cpufreq/energy_performance_preference > /dev/null

    cpupower -c 4-11 frequency-set -g powersave > /dev/null
    echo balance_performance | tee /sys/devices/system/cpu/cpu[4-9]/cpufreq/energy_performance_preference > /dev/null
    echo balance_performance | tee /sys/devices/system/cpu/cpu1[0-1]/cpufreq/energy_performance_preference > /dev/null

    set_turbo 0
    echo -e "${GREEN}Modo Game (smart hibrido): ativo! [ok]${NC}"
    [ "${2:-}" = "--full" ] && print_full_game
}

# --- MODO PERFORMANCE (INTERMEDIÁRIO) ---
set_performance() {
    cpupower frequency-set -g performance > /dev/null
    echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference > /dev/null
    set_turbo 0
    echo -e "${RED}Modo Performance (global): ativo! [ok]${NC}"
    [ "${2:-}" = "--full" ] && print_full_performance
}

# --- MODO DAILY (EQUILIBRADO) ---
set_daily() {
    cpupower frequency-set -g powersave > /dev/null
    echo balance_performance | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference > /dev/null
    set_turbo 0
    echo -e "${GREEN}Modo Daily: ativo! [ok]${NC}"
    [ "${2:-}" = "--full" ] && print_full_daily
}

# --- MODO BATTERY (ECONOMIA INTELIGENTE) ---
set_battery() {
    cpupower -c 4-11 frequency-set -g powersave > /dev/null
    echo power | tee /sys/devices/system/cpu/cpu[4-9]/cpufreq/energy_performance_preference > /dev/null
    echo power | tee /sys/devices/system/cpu/cpu1[0-1]/cpufreq/energy_performance_preference > /dev/null

    cpupower -c 0-3 frequency-set -g powersave > /dev/null
    echo balance_power | tee /sys/devices/system/cpu/cpu[0-3]/cpufreq/energy_performance_preference > /dev/null

    set_turbo 1
    echo -e "${YELLOW}Modo Battery (hibrido): ativo! [ok]${NC}"
    [ "${2:-}" = "--full" ] && print_full_battery
}

# --- CHECK ---
run_check() {
    echo -e "${YELLOW}--- DIAGNOSTICO ---${NC}"
    detect_mode
    echo "Daemon:        $(systemctl is-active power-profiles-daemon 2>/dev/null || echo 'inativo')"
    echo "P-Cores EPP:   $(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference 2>/dev/null || echo 'N/A')"
    echo "E-Cores EPP:   $(cat /sys/devices/system/cpu/cpu4/cpufreq/energy_performance_preference 2>/dev/null || echo 'N/A')"
    echo "Turbo Real:    $(cat /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || echo 'N/A') (0 = Ligado / 1 = Desligado)"
}

# --- MONITOR ---
run_monitor() {
    watch -n 0.5 "grep 'MHz' /proc/cpuinfo | awk '{print \$4 \" MHz\"}' | nl -v 0 -s ': Core '"
}

case "$1" in
    game) set_game "$@" ;;
    performance) set_performance "$@" ;;
    daily) set_daily "$@" ;;
    battery) set_battery "$@" ;;
    check) run_check ;;
    monitor) run_monitor ;;
    *)
        echo "Exemplo de Uso: sudo power-control {game|performance|daily|battery|check|monitor} [--full]"
        ;;
esac
```

**3. Dê permissão de execução:**

```
sudo chmod +x /usr/local/bin/power-control
```

**4. Permita a execução sem senha (Vital para a Steam):**

Em vez de editar o `/etc/sudoers` diretamente, crie um arquivo dedicado em `/etc/sudoers.d/`. Isso isola a regra, facilita remover depois e elimina o risco de corromper o sudoers principal. O comando abaixo ja cria o arquivo e insere a regra de uma vez.

Escolha **uma** das opções abaixo:

---

**Opcao A — Todos os usuarios do sistema**

Esta configuracao se aplica a qualquer usuario da maquina. Caso voce nao queira isso, use a Opcao B.

Execute os dois comandos:

```
echo 'ALL ALL=(ALL) NOPASSWD: /usr/local/bin/power-control' | sudo tee /etc/sudoers.d/power-control
```

```
sudo chmod 440 /etc/sudoers.d/power-control
```

---

**Opcao B — Somente o seu usuario**

Substitua `seu_usuario` pelo seu nome de usuario real (o mesmo que aparece no terminal antes do `@`):

```
echo 'seu_usuario ALL=(ALL) NOPASSWD: /usr/local/bin/power-control' | sudo tee /etc/sudoers.d/power-control
```

```
sudo chmod 440 /etc/sudoers.d/power-control
```

---

Para verificar se a regra foi aplicada corretamente:

```
sudo cat /etc/sudoers.d/power-control
```

A saida deve mostrar a linha que voce colou.

## 3 - Alternativa com o Daemon Padrão do CachyOS

Caso prefira não utilizar o script customizado `power-control` e queira manter o sistema 100% original, você pode extrair a performance máxima utilizando o gerenciador de energia nativo do CachyOS.

**1. Reativar o serviço padrão (Caso tenha desativado na Fase 1):**

```
sudo systemctl unmask power-profiles-daemon.service
sudo systemctl enable --now power-profiles-daemon.service
```

**2. Destravar o Turbo Boost e forçar o modo Performance:**

O comando nativo altera a agressividade da CPU (EPP), mas é sempre recomendado garantir que a trava física do Turbo esteja desligada para liberar o clock máximo.

```
# Ativa o EPP de performance
powerprofilesctl set performance

# Garante o desbloqueio do Turbo Boost (Picos de clock)
echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null
```

#### Tornando Permanente

**Método via `tmpfiles.d` - Mais limpo e nativo):**

```
echo "w /sys/devices/system/cpu/intel_pstate/no_turbo - - - - 0" | sudo tee /etc/tmpfiles.d/intel-turbo.conf
```

**Legenda:** O `systemd-tmpfiles` é a ferramenta nativa do Arch/CachyOS feita especificamente para gravar valores em diretórios virtuais (`sysfs`) durante o boot. A letra `w` significa "write" (escrever). Ele vai injetar o `0` no arquivo do Turbo toda vez que o PC ligar, sem precisar rodar scripts em segundo plano.

**Método via Serviço `systemd` - Clássico):**

Caso você queira ter um serviço que possa ser ligado/desligado manualmente via terminal:

1. **Crie o serviço:**

```
sudo nano /etc/systemd/system/intel-turbo.service
```

2. **Cole o conteúdo:**

```
[Unit]
Description=Ativar Intel Turbo Boost no Boot
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo'
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
```

3. **Ative para iniciar com o sistema:**

```
sudo systemctl daemon-reload
sudo systemctl enable --now intel-turbo.service
```

**Sugestão:** O Método 1 é estruturalmente superior para o CachyOS, pois não cria processos extras no gerenciador de serviços do sistema. Use-o se o objetivo for apenas aplicar a regra e esquecer.
