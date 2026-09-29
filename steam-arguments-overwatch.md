# Argumentos Steam

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


