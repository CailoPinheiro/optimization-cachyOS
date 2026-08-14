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

**2. Cole o código abaixo (Versão com Bateria / Turbo Desbloqueado):**

```
#!/bin/bash

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# --- MODO GAME (SMART BOOST) ---
set_game() {
    echo -e "${RED}🔥 ATIVANDO MODO GAMER (SMART BOOST)...${NC}"
    MIN_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
    MAX_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
    cpupower frequency-set -d $MIN_FREQ -u $MAX_FREQ -g powersave > /dev/null
    echo 10 | tee /sys/devices/system/cpu/intel_pstate/min_perf_pct > /dev/null
    echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference > /dev/null
    echo 0 | tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null
    echo -e "${GREEN}✅ Boost Agressivo Ativo (Turbo Liberado).${NC}"
}

# --- MODO PERFORMANCE (INTERMEDIÁRIO) ---
set_performance() {
    echo -e "${RED}⚡ ATIVANDO MODO PERFORMANCE...${NC}"
    MIN_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
    MAX_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
    cpupower frequency-set -d $MIN_FREQ -u $MAX_FREQ -g performance > /dev/null
    echo 10 | tee /sys/devices/system/cpu/intel_pstate/min_perf_pct > /dev/null
    echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference > /dev/null
    echo 0 | tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null
    echo -e "${GREEN}✅ Governor Performance ativo. Turbo Liberado.${NC}"
}

# --- MODO DAILY (EQUILIBRADO) ---
set_daily() {
    echo -e "${GREEN}🍃 ATIVANDO MODO DAILY...${NC}"
    MIN_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
    MAX_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
    cpupower frequency-set -d $MIN_FREQ -u $MAX_FREQ -g powersave > /dev/null
    echo 10 | tee /sys/devices/system/cpu/intel_pstate/min_perf_pct > /dev/null
    echo balance_performance | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference > /dev/null
    echo 0 | tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null
    echo -e "${GREEN}✅ Modo Equilibrado Ativo.${NC}"
}

# --- MODO BATTERY (ECONOMIA) ---
set_battery() {
    echo -e "${YELLOW}🔋 ATIVANDO MODO ECONOMIA...${NC}"
    MIN_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
    MAX_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
    cpupower frequency-set -d $MIN_FREQ -u $MAX_FREQ -g powersave > /dev/null
    echo 10 | tee /sys/devices/system/cpu/intel_pstate/min_perf_pct > /dev/null
    echo power | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference > /dev/null
    echo 1 | tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null
    echo -e "${GREEN}✅ Economia Máxima. Turbo Desativado.${NC}"
}

# --- CHECK ---
run_check() {
    echo -e "${YELLOW}--- DIAGNÓSTICO ---${NC}"
    echo "Daemon:   $(systemctl is-active power-profiles-daemon)"
    echo "Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
    echo "EPP:      $(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference)"
    echo "Turbo:    $(cat /sys/devices/system/cpu/intel_pstate/no_turbo) (0 = Ligado / 1 = Desligado)"
}

# --- MONITOR ---
run_monitor() {
    watch -n 0.5 "grep 'MHz' /proc/cpuinfo | awk '{print \$4 \" MHz\"}' | nl -v 0 -s ': Core '"
}

case "$1" in
    game) set_game ;;
    performance) set_performance ;;
    daily) set_daily ;;
    battery) set_battery ;;
    check) run_check ;;
    monitor) run_monitor ;;
    *) 
        echo "Uso: sudo power-control {game|performance|daily|battery|check|monitor}" 
        ;;
esac
```

**3. Dê permissão de execução:**

```
sudo chmod +x /usr/local/bin/power-control
```

**4. Permita a execução sem senha (Vital para a Steam):**

Abra o arquivo de permissões:

```
sudo visudo
```

Cole esta linha **exatamente no final** do arquivo e salve:

```
ALL ALL=(ALL) NOPASSWD: /usr/local/bin/power-control
```

## 3 - Otimizações de Interface (Hyprland & Mouse) - Não mexer se não estiver com problema

Correções essenciais para eliminar as micro-travadas de mouses com alto Polling Rate e bugs de renderização no Wayland.

**1. Reduzir o Polling Rate do Mouse (Anti-Stutter):**

Isso estabiliza a leitura do mouse em 250Hz, evitando engasgos de CPU ao virar a câmera bruscamente.

```
echo 'options usbhid mousepoll=4' | sudo tee /etc/modprobe.d/mousepoll.conf
sudo mkinitcpio -P
```

*(As mudanças no mouse só entram em vigor após reiniciar o PC).*

**2. Correção de Cursor e Janela (Hyprland):**

Abra o seu arquivo de configuração do Hyprland:

```
nano ~/.config/hypr/hyprland.conf
```

Adicione este bloco para evitar que o cursor fique invisível ou com lag, e para forçar o jogo a abrir em tela cheia real:

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
