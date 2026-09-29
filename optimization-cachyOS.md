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

## 3 - Otimizações de Interface (Hyprland & Mouse) - Não mexer se não estiver com problema

Correções essenciais para eliminar as micro-travadas de mouses com alto Polling Rate e bugs de renderização no Wayland.

**1. Reduzir o Polling Rate do Mouse (Anti-Stutter):**

Isso estabiliza a leitura do mouse em 250Hz, evitando engasgos de CPU ao virar a câmera bruscamente.

```
echo 'options usbhid mousepoll=4' | sudo tee /etc/modprobe.d/mousepoll.conf
sudo mkinitcpio -P
```

*(As mudanças no mouse só entram em vigor após reiniciar o PC).*

**Para reverter:** remova o arquivo de configuracao e regenere o initramfs:

```
sudo rm /etc/modprobe.d/mousepoll.conf
sudo mkinitcpio -P
```

Reinicie o PC. O polling rate voltara ao padrao do kernel (geralmente 125Hz).

**2. Correção de Cursor e Janela (Hyprland):**

Adicione o bloco abaixo no arquivo de configuracao do Hyprland correspondente a sua dotfile. Se voce nao sabe qual e, verifique se existe um diretorio `~/.config/hypr/custom/` — a grande maioria das dotfiles modernas carrega esse diretorio por ultimo, o que significa que qualquer arquivo `.conf` ou `.lua` dentro dele sobrepoe as configuracoes padrao sem risco de ser revertido por um update da dotfile. Crie um arquivo com nome descritivo, como `~/.config/hypr/custom/gaming.conf`.

Conteudo a adicionar:

```
cursor {
    no_hardware_cursors = true
}

windowrulev2 = fullscreen, class:^(steam_app_2357570)$
windowrulev2 = tile, class:^(steam_app_2357570)$
```

Recarregue o Hyprland imediatamente com:

```
hyprctl reload
```

## 4 - Raw Input e Layout de Teclado (Hyprland)

Para quem utiliza dotfiles modulares no Hyprland (como o Hyprdots), o arquivo `userprefs.conf` é o local onde as configurações pessoais sobrepõem os padrões do sistema. Garantir que a aceleração do mouse esteja desligada no nível do compositor (Raw Input) é vital para não sabotar sua memória muscular em jogos competitivos.

**1. Editar o arquivo de preferências do Hyprland:**

O arquivo geralmente fica na sua pasta de configurações:

```
nano ~/.config/hypr/userprefs.conf
```

*(Se você não usar dotfiles modulares, basta procurar o bloco `input` diretamente no seu `~/.config/hypr/hyprland.conf`).*

**2. Adicionar as regras de Input:**

Procure pelo bloco `input { ... }` (ou crie a estrutura) e adicione as seguintes linhas:

```
input {
    kb_layout = us, br
    force_no_accel = 0
    accel_profile = flat
}
```

Salve e recarregue o Hyprland imediatamente com `hyprctl reload`.

**Legenda:**

- **`kb_layout = us, br`:** Define e mantém o suporte para alternar entre o layout americano e o brasileiro no seu teclado.

- **`accel_profile = flat`:** É a chave mestra para jogar. O perfil "flat" ativa o "Raw Input" no Wayland. Ele garante que o movimento do ponteiro na tela seja 1:1 com o movimento físico do seu mouse (DPI puro), sem que o sistema tente "adivinhar" e acelerar o cursor em movimentos rápidos.

- **`force_no_accel = 0`:** Em muitas configurações do Hyprland, funciona em conjunto com o `flat` para garantir que nenhuma camada legada de aceleração interfira na leitura bruta do sensor do mouse.

## 5 - Argumentos Steam

**Nas Propriedades do Overwatch 2, cole exatamente esta linha em "Opções de inicialização":**

```
DXVK_LOG_LEVEL=none DXVK_STATE_CACHE=1 DXVK_HUD=shaders,compiler MESA_DISK_CACHE_MAX_SIZE=10G MESA_DISK_CACHE_SINGLE_FILE=1 PROTON_ENABLE_WAYLAND=1 vblank_mode=0 MESA_VK_WSI_PRESENT_MODE=immediate MESA_GLTHREAD=1 %command%
```

**Legendas da nova linha:**

- **`sudo power-control game;`** → Acorda a CPU e liga o Turbo antes de o jogo iniciar.

- **Sem `gamemoderun`:** Removido, pois o Kernel do CachyOS já aplica as otimizações de agendamento (scheduler) e prioridade nativamente, evitando conflitos.

- **`DXVK_STATE_CACHE=1` e `MESA_DISK_CACHE_MAX_SIZE=10G`** → Expande o limite de armazenamento e força o salvamento do cache de shaders no disco para eliminar engasgos.

- **`DXVK_HUD=shaders,compiler`** → Exibe na tela apenas informações úteis sobre a compilação dos shaders em tempo real.

- **`vblank_mode=0` e `MESA_VK_WSI_PRESENT_MODE=immediate`** → Forçam a desativação absoluta do V-Sync, enviando quadros direto para a tela sem fila de espera.

- **`MESA_GLTHREAD=1`** → Descarrega o processamento gráfico para múltiplas threads da CPU, aliviando o núcleo principal.

## 6 - Latência Zero no Compositor (Hyprland)

O Hyprland não pode adicionar *sync/queue* em cima do jogo. Vamos configurar o `hyprland.lua` para injetar os quadros direto na tela.

**1. (SOMENTE SE TIVER COM PROBLEMAS DE STUTERRING) Reduzir o Polling Rate do Mouse (Anti-Stutter do Wayland):** Estabiliza a leitura do mouse em 250Hz.

```
echo 'options usbhid mousepoll=4' | sudo tee /etc/modprobe.d/mousepoll.conf
sudo mkinitcpio -P
```

**2. Configuração de Latência (Lua):** Edite o arquivo principal do HyDE:

```
nano ~/.config/hypr/hyprland.lua
```

Adicione este bloco no **final** do arquivo:

```
-- ══ Competitive gaming: latência mínima ══
hl.config({
    input = {
        accel_profile = "flat",            -- Mouse 1:1 (Raw Input)
        force_no_accel = 0
    },
    render = {
        direct_scanout = 2,                -- Pula a composição em fullscreen (-1 frame lag)
        new_render_scheduling = false,     -- Desliga triple-buffering automático (-1 frame lag)
    },
    general = {
        allow_tearing = true,              -- Master switch para entregar quadros fora do vblank
    },
})

-- Tearing imediato exclusivo para Overwatch 2
hl.window_rule({
    match = { class = "steam_app_2357570" },
    immediate = true,
})
```

**3. Correção de Escala do Monitor:** O Hyprland sofre penalidade de performance com escalas fracionárias. Edite `~/.config/hypr/monitors.lua` e garanta que o valor de `scale` seja um número inteiro exato (ex: `1` em vez de `0.999999`):

```
hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@60.0",
    position = "1280x1080",
    scale = 1
})
```

**4. (HYDE PROJECT ONLY) Script de Game Mode (HyDE):** Desliga firulas visuais (blur, sombras, gaps) enquanto joga. Crie o executável:

```
sudo nano ~/.local/bin/hypr-gamemode-toggle
```

Cole o código:

```
#!/usr/bin/env bash
cur="$(grep -oP '^HYPR_WORKFLOW=\K.*' "$HOME/.local/state/hyde/staterc" 2>/dev/null | tr -d '"')"
if [ "$cur" = "gaming" ]; then    hyde-shell workflows --set defaultelse    hyde-shell workflows --set gamingfihyprctl reload
```

Dê permissão:

```
sudo chmod +x ~/.local/bin/hypr-gamemode-toggle
```

Volte ao `hyprland.lua` e crie o atalho para ativar isso rapidamente:

```
hl.bind("SUPER + ALT + G", hl.dsp.exec_cmd("hypr-gamemode-toggle"), {
    locked = true,
    description = "[Utilities] game mode",
})
```

## 7 - Alternativa com o Daemon Padrão do CachyOS

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
