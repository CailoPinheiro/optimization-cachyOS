# Guia de Otimização do Deadlock

Guia geral de otimização do Deadlock nesta máquina (CachyOS + Hyprland + Intel
Iris Xe). Reúne o estado atual, os arquivos de referência, as recomendações dos
autores das configs usadas, os argumentos de lançamento da Steam e um espaço
para registrar mods testados.

Tudo aqui é cliente-side. Update do jogo ou "verificar integridade" sobrescreve
os arquivos em `game/`, então guarde as cópias desta pasta.

Boa parte do conteúdo daqui saiu do repositório do OptimizationLock:
<https://github.com/Sqooky/OptimizationLock/tree/main>. Se qualquer coisa quebrar
depois de um update do Deadlock, a primeira ação é visitar esse repo, comparar a
versão do `gameinfo.gi` e dos mods e atualizar o que estiver defasado.

---

## 1. Identificação do jogo e do hardware

| Item | Valor |
|---|---|
| AppID Steam | `1422450` |
| Instalação | `~/.local/share/Steam/steamapps/common/Deadlock` |
| Binários | somente `win64` (roda via Proton, não é build nativo Linux) |
| Proton | `Proton-CachyOS Latest` (compatdata `1422450`, versão `CachyOS-11.0-100`) |
| Userdata | `~/.local/share/Steam/userdata/1146272440/1422450` |
| CPU | Intel Core i5-1235U (2 P-cores com HT: CPU 0-3; 8 E-cores: CPU 4-11) |
| GPU | Intel Iris Xe Graphics 96EU (ADL GT2), driver `i915`, 1200 MHz máx. |
| Memória | 32 GB compartilhados com o iGPU |
| Tela | eDP 1920x1080@60 Hz, sem VRR (único modo disponível) |
| Térmico | PL1 15 W / PL2 55 W / pico 123 W |
| Sistema | CachyOS, kernel CachyOS, Mesa 26.2.5, Hyprland 0.56.2 |

Consequência prática: em 1080p o limitador é o iGPU em cena aberta e a CPU em
teamfight (Source 2 é CPU-bound quando sobe a contagem de entidades). Metas de
60 FPS exigem combinar as três frentes: config do jogo, energia/CPU e medição.

---

## 2. Arquivos de referência desta pasta

Cópias fiéis, verificadas com `cmp` em 28/10/2026.

| Arquivo | Origem | SHA256 |
|---|---|---|
| `video.txt` | `~/.local/share/Steam/userdata/1146272440/1422450/local/cfg/video.txt` | `aeb2498704e9ceb4fd94652229e40cf2a257f2aa85413efa4c9e9fe019cb8b35` |
| `gameinfo.gi` | `~/.local/share/Steam/steamapps/common/Deadlock/game/citadel/gameinfo.gi` | `ccc659c140c43c5f1ad947a7886d81971f092a77f889a27d03dcdac26a695661` |

Como reatualizar as cópias depois de mexer no jogo:

```bash
cp ~/.local/share/Steam/userdata/1146272440/1422450/local/cfg/video.txt \
   ~/Projects/unlock-deadlock/video.txt

cp ~/.local/share/Steam/steamapps/common/Deadlock/game/citadel/gameinfo.gi \
   ~/Projects/unlock-deadlock/gameinfo.gi
```

Observações importantes sobre as cópias:

- `video.txt` é **regravado pelo jogo** ao sair ou ao aplicar configurações de
  vídeo. A cópia aqui é um retrato do momento, não uma config "instalada".
- `gameinfo.gi` é **sobrescrito por update do jogo e por verificar integridade**.
  O backup vanilla já existe no jogo, em `game/citadel/gameinfo.gi.bkp`
  (678 linhas, sem as cvars do mod).
- Não copie estes arquivos de volta "no escuro": a seção de reversão explica o
  caminho seguro.

Além dessas cópias, a pasta `seco-seco-seco/` guarda um pack alternativo
completo (Full FPS UP cfg SSH), com `gameinfo.gi`, `video.txt`, `autoexec.cfg`
e um VPK de texturas. A análise está na seção 10.

---

## 3. Estado atual (o que já está aplicado)

| Item | Situação em 28/10/2026 |
|---|---|
| `gameinfo.gi` | Config do OptimizationLock (Sqooky), 505 cvars ativas |
| `video.txt` | Praticamente no mínimo: render 3D interno em 512x288 (`mat_viewportscale 0.4` sobre 1280x720), mip bias 8, sombras/AA/SSAO/fog/bloom desligados |
| `machine_convars.vcfg` | `fps_max 75`, `cl_ragdoll_limit 0`, `cl_updaterate 128`, `rate 786432` |
| Turbo Boost | **desligado** (`/sys/devices/system/cpu/intel_pstate/no_turbo = 1`), P-cores em 1.3 GHz e E-cores em 0.9 GHz |
| Governador | `performance` em todos os núcleos |
| Compositor | blur desligado em runtime; `render:direct_scanout = 0` (direto) |
| Argumentos Steam | `mangohud DXVK_LOG_LEVEL=none DXVK_HUD=shaders,compiler %command%` |

Leitura: o lado gráfico já foi cortado até o osso. O que falta é energia/CPU,
limite de FPS coerente com o painel e os ajustes residuais do `gameinfo.gi`.

---

## 4. `video.txt`

### 4.1 O que é

Arquivo de configurações de vídeo do Source 2. Cada chave `setting.*` corresponde
a uma opção do menu de vídeo do jogo. Ele é lido no boot e reescrito pelo jogo
quando você sai ou confirma uma mudança no menu.

Referência desta pasta: **`./video.txt`** (cópia fiel do atual).

### 4.2 Como editar sem perder a alteração

1. Feche o Deadlock.
2. Faça backup: `cp video.txt video.txt.bak`.
3. Edite (ou ajuste pelo menu do jogo, que é o caminho mais seguro).
4. Abra o jogo, confirme e saia. Se o menu sobrescrever, o valor do menu vence.

Editar com o jogo aberto não funciona: no exit ele grava o estado em memória por
cima do arquivo.

### 4.3 Valores atuais e o que cada um faz

| Chave | Valor | Efeito / avaliação |
|---|---|---|
| `Version` | 20 | Versão do formato. Não mexer. |
| `VendorID` / `DeviceID` | 32902 / 18088 | Intel `0x8086` / Iris Xe `0x46A8`. Detectado. |
| `knowndevice` | 0 | O jogo **não** reconheceu o iGPU como dispositivo conhecido; por isso caiu no preset recomendado de 720p. Não muda FPS. |
| `defaultres` / `defaultresheight` | 1280 / 720 | Resolução de **saída**. É aqui que mora o teste 1080p vs 720p. |
| `refreshrate_numerator/denominator` | 60 / 1 | Coerente com o painel. |
| `fullscreen` | 1 | Manter. |
| `nowindowborder` | 0 | Irrelevante em fullscreen. |
| `mat_vsync` | 0 | Manter desligado (junto com cap de 60). |
| `high_dpi` | 0 | Manter. |
| `mat_viewportscale` | 0.39999998 | Escala do render 3D: 0.4 x 1280x720 = **512x288** internos. |
| `r_texture_stream_mip_bias` | 8 | Texturas extremamente borradas. É o knob de "menos banda de textura". |
| `cpu_level` | 2 | Nível de detalhe do lado CPU. |
| `mem_level` | 2 | Uso de memória para assets. |
| `gpu_mem_level` | 3 | Cache de texturas na VRAM compartilhada. |
| `gpu_level` | 0 | Mínimo. |
| `shaderquality` | 0 | Mínimo. |
| `r_citadel_shadow_quality` | 0 | Sombras desligadas. |
| `r_citadel_ssao_quality` | 0 | AO desligado. |
| `r_citadel_fog_quality` | 0 | Névoa mínima. |
| `r_citadel_antialiasing` | 0 | Sem AA. |
| `r_citadel_upscaling` | 0 | Upscaling do jogo desligado. |
| `r_citadel_dlss_settings_mode` / `r_dlss_preset` | 0 / 6 | DLSS não se aplica a Intel. |
| `r_depth_of_field` | false | Desligado. |
| `r_effects_bloom` / `r_post_bloom` | false / false | Desligados. |
| `r_arealights` | false | Desligado. |
| `r_citadel_motion_blur` | 0 | Desligado. |
| `r_dashboard_render_quality` | 0 | UI/HUD no mínimo. |
| `r_low_latency` | 1 | Modo baixa latência (estilo Reflex). |
| `r_fullscreen_gamma` | 1.6 | Cosmético. |
| `monitor_index` | 0 | eDP. Correto. |
| `aspectratiomode` | 0 | Automático. |

### 4.4 O que ainda dá para testar (e o ganho honesto)

| Mudança | Como testar | Ganho esperado | Custo visual |
|---|---|---|---|
| Saída 1080p + `mat_viewportscale` 0.35-0.4 | `defaultres/defaultresheight` para 1920/1080 e escala 0.4 (3D em 768x432) | Neutro a negativo em FPS, **muito** melhor em HUD/texto | Nenhum, melhora |
| `mat_viewportscale` 0.3 | 384x216 internos | Poucos % (já não é GPU-bound) | Alto |
| `r_texture_stream_mip_bias` 4-5 | Volta nitidez de textura | ~0 a -2% | Melhora muito |
| `cpu_level` 0 | Reduz detalhe do lado CPU | 1-3% em fight | Pequeno |
| `mem_level` 1 | Menos cache de assets | Marginal, risco de hitch | Pequeno |
| `r_low_latency` 0 | Desliga o sleep de baixa latência | 0-3%, mas sobe latência de input | Nenhum |
| `r_citadel_upscaling` (FSR2) | 1080p de saída + FSR2 em 0.5 | Não ganha FPS, mas fica bem melhor que bilinear em 0.4 | Nenhum |

Regra prática: abaixo de 0.4 de escala o retorno é quase nulo. Se ainda falta
frame, o problema não está no `video.txt`.

### 4.5 Recomendações dos autores

- **O `video.txt` não tem autor.** Ele é gerado pelo jogo. O conteúdo atual é o
  preset "recomendado" que o Deadlock escolheu quando não reconheceu o iGPU
  (`knowndevice 0`, `recommendedheight 720`) somado a ajustes manuais.
- **Sqooky (OptimizationLock)** não distribui `video.txt`: o mod dele é só o
  `gameinfo.gi` + argumentos de lançamento. Ele recomenda explicitamente
  **experimentar `-dx11` ou `-vulkan`** e usar o preset mais baixo possível
  dentro do jogo.
- **Presets "low end" da comunidade** (ex.: `video_v2_for_low_settings.txt` do
  repositório w0nxyApex) misturam chaves válidas com chaves que **não existem
  nesta build**. Verificado nos binários (`client.dll`, `materialsystem2.dll`,
  `engine2.dll`, `worldrenderer.dll`, `scenesystem.dll`, `panorama.dll`):

| Chave | Existe nesta build? |
|---|---|
| `r_screen_space_shadows` | Não |
| `r_displacement_mapping` | Não |
| `r_render_portals` | Não |
| `r_env_map_uses_height_map` | Não |
| `r_citadel_half_res_noisy_effects` | Não |
| `r_particle_depth_feathering` | Não |
| `mat_colorcorrection` | Sim (`materialsystem2.dll`) |
| `r_citadel_distancefield_ao_quality` | Sim (`client.dll`) |
| `r_citadel_distancefield_shadows` | Sim (`client.dll`) |
| `r_citadel_mboit` | Sim (`client.dll`) |
| `csm_max_shadow_dist_override` | Sim (`client.dll`) |
| `r_enable_volume_fog` | Sim (`client.dll`) |
| `r_lightmap_size` | Sim (`worldrenderer.dll`) |
| `mat_viewportscale` | Sim (`scenesystem.dll`, `panorama.dll`) |

Conclusão: não cole listas de cvars "mágicas" no `video.txt`. Use o menu para o
que existe e deixe os extras para o `gameinfo.gi`, onde há comentário do autor
explicando cada linha.

---

## 5. `gameinfo.gi`

### 5.1 O que é

Arquivo de definição do jogo. A seção `ConVars` dele injeta cvars como
**defaults** na inicialização. Defaults perdem para o que o usuário já tem salvo
em `machine_convars.vcfg`/`user_convars`, mas valem para tudo que não foi setado
manualmente. É o mecanismo que o OptimizationLock usa para aplicar ~500 cvars de
uma vez sem console.

Referência desta pasta: **`./gameinfo.gi`** (cópia fiel do atual, 1538 linhas).

### 5.2 Autor, versão e links

- Autor: **Sqooky** — projeto **OptimizationLock**.
- GitHub: <https://github.com/Sqooky/OptimizationLock>
- GameBanana: <https://gamebanana.com/mods/656341>
- Tutorial do autor: <https://www.youtube.com/watch?v=zC3wBYY98vU>
- Versão no cabeçalho do arquivo: **1.5.1**; a seção de ConVars diz **"ver.
  Maxfps 1.6"**. Ou seja, o arquivo está com cabeçalho e ConVars de versões
  diferentes — provável atualização parcial. Ao atualizar, pegue o pacote
  inteiro do GitHub/GameBanana para não misturar versões.

### 5.3 Instalação segundo o autor

1. Extrair o pacote do mod.
2. Copiar o `gameinfo.gi` para `Deadlock/game/citadel/`, substituindo o original.
3. Colar nos argumentos de lançamento:
   `-dx11 -high -preload -fullscreen +@panorama_min_comp_layer_cache_cost_TURNED_OFF 256`
4. O autor sugere experimentar `-dx11` **ou** `-vulkan`.

O ponto 3 é o que falta na configuração atual desta máquina (ver seção 6).

### 5.4 O que está ativo hoje

505 cvars ativas, agrupadas em:

- **Sombras**: `r_citadel_shadow_quality 0`, `lb_*` (cascatas, barnlights,
  sparse shadow tree, resolução base 16), `r_ssao 0`.
- **Partículas**: fallback agressivo, `r_particle_max_texture_layers 4`,
  `r_citadel_disable_particle_lights true`.
- **Geometria/LOD**: `sc_screen_size_lod_scale_override 0.00001`,
  `r_farz 7000`, `r_mapextents 7000`, `sc_clutter_enable false`.
- **Iluminação**: `r_rendersun 0`, `lb_enable_dynamic_lights false`,
  `lb_enable_stationary_lights false`, `r_multiscattering 1`,
  `r_lightmap_size 2048`.
- **UI/HUD**: `panorama_max_fps 30`, `panorama_disable_blur true`,
  `v8_maximum_heap_size_mb 1024`, `citadel_unit_status_old_update_rate 15`.
- **Câmera/input**: `citadel_camera_wobble_disable true`,
  `r_aspectratio 2.5` (FOV ~100), `cam_ideallag 0`.
- **Física**: `cl_phys_enabled false`, `cl_ragdoll_limit 0`.

### 5.5 Avisos do próprio autor que estão violados no arquivo atual

| Linha | Situação | O que o autor diz |
|---|---|---|
| 931 | `cl_disable_ragdolls "1"` | "Keep set to 0 — enabling this (disabling ragdolls) can cause issue with Doorman's ultimate". Ou seja, o arquivo está com o valor que o autor manda **não** usar. Como `cl_ragdoll_limit 0` já resolve o custo, não há motivo para manter 1. |
| 789 | `r_citadel_enable_pano_world_blur "true"` | O autor manda `false`: melhora "dramatically" a loja/pause. O aviso de bug é só para **Nvidia rodando Vulkan**, não é o seu caso (Intel). |
| 1016 | `citadel_video_preset "9"` | Preset 9 (custom) no `gameinfo.gi`, enquanto `machine_convars.vcfg` tem `0`. Inofensivo, mas confunde diagnóstico. |

### 5.6 Ajustes residuais que valem teste

Edite as linhas no `gameinfo.gi` **e** reflita na cópia desta pasta.

| Linha | Atual | Sugerido | Motivo | Risco |
|---|---|---|---|---|
| 931 | `cl_disable_ragdolls "1"` | `0` | Evita bug do ult do Doorman; `cl_ragdoll_limit 0` já cobre o FPS | Nenhum |
| 789 | `r_citadel_enable_pano_world_blur "true"` | `false` | Loja/pause bem mais leves | Nenhum em Intel |
| 944 | `mat_colorcorrection "1"` | `0` | Pós-processamento de cor | Cores mais lavadas |
| 922 | `r_lightmap_bicubic_filtering "1"` | `0` | Filtro bicúbico de lightmap | Leve perda em iluminação |
| 925 | `r_multiscattering "1"` | `0` | Aproximação de multi-scattering | Leve perda em iluminação |
| 923 | `r_lightmap_size "2048"` | `512` ou `1024` | Menos memória/banda no iGPU | Iluminação mais grosseira |
| 935 | `cl_fasttempentcollision "1000"` | `5` (default) | Comentário do autor diz que maior = mais trabalho | Nenhum |
| 875 | `thread_pool_option "2"` | `-1` (default) | Topologia 2P+8E; valor 2 não é documentado | Testar A/B |
| 1475 | `fps_max "400"` | `60` | Painel 60 Hz; cap errado gera judder e calor | Nenhum |
| 1476 | `fps_max_ui "120"` | `60` | Menu não precisa de 120 | Nenhum |

Atenção: `fps_max` também está em `machine_convars.vcfg` (75). O valor do
`machine_convars` é config de usuário e tende a vencer o default do
`gameinfo.gi`; ajuste os dois para 60 para não ficar na dúvida.

### 5.7 Manutenção

- Update do jogo ou "verificar integridade" restaura o `gameinfo.gi` original.
  Depois de cada update, compare com a cópia desta pasta e reaplique se preciso:
  `diff -u ./gameinfo.gi ~/.local/share/Steam/steamapps/common/Deadlock/game/citadel/gameinfo.gi`
- Se o jogo passar a crashar logo no boot depois de um update, o primeiro
  suspeito é cvar removida/renomeada no `gameinfo.gi`. Teste com o
  `gameinfo.gi.bkp` para isolar.
- **Se algo quebrar, volte ao repositório e atualize.** O projeto é atualizado a
  cada patch do Deadlock (o `gameinfo.gi` é reescrito em updates grandes e cvars
  mudam de nome). Baixe a versão mais recente em
  <https://github.com/Sqooky/OptimizationLock/tree/main>, substitua o
  `gameinfo.gi` e reavalie os ajustes residuais da seção 5.6, que podem já ter
  sido corrigidos pelo autor.

---

## 6. Argumentos de lançamento da Steam

Onde colar: Biblioteca > Deadlock > botão direito > Propriedades > Geral >
Opções de inicialização.

### 6.1 Linha atual

```
mangohud DXVK_LOG_LEVEL=none DXVK_HUD=shaders,compiler %command%
```

### 6.2 Linha recomendada

Base do autor do mod + os itens de log/overlay que já estavam em uso:

```
mangohud DXVK_LOG_LEVEL=none DXVK_HUD=shaders,compiler MESA_DISK_CACHE_MAX_SIZE=10G %command% -dx11 -high -preload -fullscreen +@panorama_min_comp_layer_cache_cost_TURNED_OFF 256
```

### 6.3 O que cada item faz

| Item | Função | Impacto em FPS |
|---|---|---|
| `mangohud` | Overlay de métricas (FPS, frametime, 1% low, clocks) | Custo desprezível |
| `DXVK_LOG_LEVEL=none` | Silencia log do DXVK | Zero (só log) |
| `DXVK_HUD=shaders,compiler` | Overlay do DXVK com contagem de shaders/compilações | Zero a desprezível (só desenho) |
| `MESA_DISK_CACHE_MAX_SIZE=10G` | Cache de shaders do Mesa maior, menos recompilação | Reduz stutter |
| `-dx11` | Força o renderer D3D11 (via DXVK) | Base de comparação |
| `-high` | Prioridade alta do processo no Wine | Pequeno |
| `-preload` | Pré-carrega assets | Reduz stutter, mais RAM |
| `-fullscreen` | Força fullscreen exclusivo | Evita composição extra |
| `+@panorama_min_comp_layer_cache_cost_TURNED_OFF 256` | Ajuste de cache de camadas da UI (receita do mod) | Pequeno, ajuda na UI |

Sobre os itens de log: `DXVK_LOG_LEVEL=none`, `DXVK_HUD=shaders,compiler` e
`mangohud` **servem apenas para log/diagnóstico** e não devem ser vendidos como
ganho de FPS. Podem ficar enquanto você estiver medindo; numa sessão limpa,
remova os dois primeiros e mantenha só o `mangohud` se quiser overlay.

### 6.4 A/B obrigatório: `-dx11` vs `-vulkan`

O autor do OptimizationLock recomenda experimentar os dois. No seu caso
(Intel/ANV), `-vulkan` pula a tradução do DXVK e pode reduzir overhead de CPU —
que é justamente o gargalo em teamfight. Teste uma partida inteira com cada um,
olhando **1% low** e não a média:

```
... %command% -vulkan -high -preload -fullscreen +@panorama_min_comp_layer_cache_cost_TURNED_OFF 256
```

Se crashar, travar ou perder desempenho, volte para `-dx11`.

### 6.5 Variáveis opcionais (só depois de medir)

| Variável | Efeito | Risco |
|---|---|---|
| `PROTON_ENABLE_WAYLAND=1` | Roda em Wayland nativo, sem XWayland | Pode dar problema de input/janela em Source 2; testar |
| `MESA_VK_WSI_PRESENT_MODE=immediate` | Presente imediato, sem fila | Tearing (você já joga com vsync off) |
| `taskset -c 0-3` | Prende o jogo nos P-cores | Deixa 8 E-cores ociosos; testar A/B |

---

## 7. Energia e CPU

Esta é a frente que mais pesa hoje. O turbo está desligado e o Deadlock é
CPU-bound em fight.

```bash
# diagnóstico (turbo real, EPP, governador)
sudo power-control check

# modo recomendado para jogar: turbo ligado, P-cores performance, E-cores powersave
sudo power-control game

# conferência direta (0 = turbo ligado, 1 = desligado)
cat /sys/devices/system/cpu/intel_pstate/no_turbo
```

Notas:

- O estado atual (EPP `performance` em todos os núcleos + turbo desligado) não
  corresponde a nenhum modo do script. Rode o `check` antes de jogar.
- `sudo power-control performance` libera tudo, inclusive E-cores, mas num 15 W
  isso rouba cota térmica do iGPU. `game` é o equilíbrio certo.
- Turbo não é ganho garantido: o PL1 de 15 W limita o sustentado. O ganho vem
  nos picos de thread principal (1.3 GHz -> até ~4.4 GHz).
- Verifique dual channel (importante para iGPU):
  `sudo dmidecode -t memory | grep -E "Size|Locator|Speed"`.
  Se for single channel, é um teto difícil de contornar.
- `taskset -c 0-3` (você usa em outros jogos) impede o render thread de cair em
  E-core de 0.9 GHz. Teste com e sem; com 2 P-cores o jogo pode perder
  throughput de worker threads.

Compositor: `~/.config/hypr/config/misc.lua` **não é carregado** pelo
`hyprland.lua` (resto de config antiga). Por isso `render:direct_scanout` está
em 0. Se for testar, coloque em `~/.config/hypr/custom/general.lua` e valide com
`hyprctl getoption render:direct_scanout`. VRR é inútil neste painel (só tem
60 Hz).

---

## 8. Medição (antes de cortar mais qualidade)

1. `sudo pacman -S intel-gpu-tools` e rode `intel_gpu_top` numa partida.
2. Se a GPU ficar **abaixo de ~90%** enquanto o FPS cai, o gargalo é CPU:
   nenhuma opção gráfica resolve, invista em energia/CPU.
3. Olhe **1% low e frametime** no MangoHud, não a média.
4. Teste no **Street Brawl** (4v4, sem tropas): se o FPS lá for estável e cair no
   modo normal, o problema é contagem de entidades, não render.
5. Mude **uma coisa por vez** e anote. Sem baseline não dá para separar ganho de
   placebo.

---

## 9. Mods a testar

### 9.1 Fonte

Os mods de performance e de correção de bugs usados aqui saem do próprio
repositório do OptimizationLock, na pasta `Performance Improving Mods`:

<https://github.com/Sqooky/OptimizationLock/tree/main/Performance%20Improving%20Mods>

Os commits mais recentes dos mods são do hotfix **3.7.1** (correção de partículas
que quebravam), de 2 dias antes desta consulta (26/10/2026). Confira no repo
antes de instalar: os mods são recompilados junto com o jogo.

### 9.2 Regras antes de instalar

- Mods empacotados vão em `game/citadel/addons` (o `SearchPaths` do jogo já
  inclui `citadel/custom` e `citadel/addons`).
- A linha `Game "citadel/addons"` precisa estar **sem `//`** no `gameinfo.gi`.
- **Update do jogo e verificar integridade apagam.** Guarde o pacote original.
- O README do projeto recomenda instalar manualmente. O **Deadlock Mod Manager**
  pode substituir o `gameinfo.gi` se a checagem interna dele falhar.
- Se o jogo não abrir depois de instalar (`FATAL ERROR: ...xml`), esvazie
  `game/citadel/addons` ou comente `Game "citadel/addons"` e abra de novo.
- Mexer em arquivos do jogo é por sua conta e risco; não há garantia de
  compatibilidade com o anti-cheat.
- Teste um mod por vez, com baseline anotado.

### 9.3 Lista

| Mod | O que faz | Impacto esperado | Status |
|---|---|---|---|
| **Blur Disabler** | Remove todo o blur dos elementos de UI. O autor relata redução grande de stutter. Faz na prática o mesmo que `panorama_disable_blur`, mas via mod. | Menos stutter em menu/loja e HUD. Não muda FPS de render. | A testar |
| **Clutter be Gone** | Remove clutter e partículas do mapa: ambiente da cidade (velas, postes, fumaça), screenspace (low-health, queimando, fumaça de vent), efeitos de habilidade, rastro de dash, partículas de walker e o feixe ao pegar alma. Vem em variantes (`all`, `all-no-abilities`, `abilities`, `screenspace_city`, `pickups`, `movement`, `walker`). | Ganho real de GPU/CPU em fight. `all` é o pacote completo recomendado pelo autor; custo visual alto (mapa mais limpo e "morto"). | A testar |
| **Optimized Soul Container** | Substitui o modelo da alma (soul orb) por uma versão com menos polígonos. Original de Jayie. | Alivia vértices/draw calls em cenas com muitas almas no chão. Ganho pequeno e localizado. | A testar |
| **Sinner Light Fix Mod** | Corrige a leitura das luzes dos "sinners" quando o `mip bias` está abaixo de 4. Versão de HoppCX para o update The City Never Sleeps. | Não dá FPS: permite baixar o `r_texture_stream_mip_bias` (seção 4.4) sem as luzes virarem triângulo. | A testar |
| **Texture Downscaler (WIP)** | Reduz **todas** as texturas do jogo para 25% da resolução base, derrubando o consumo de VRAM. Baixar pelos Releases do repo (tag `mod`), não pela pasta. | Ajuda em VRAM/banda, que é o gargalo do iGPU. Em troca o mapa fica lavado e brilhante, segundo o próprio autor. | A testar (WIP) |
| **Vindicta Scope Downscale** | A mira da Vindicta é uma textura 4096x4096 sem mipmap; o mod reduz para 1080p. Original de Tamara Mochaccinae. | Elimina o engasgo ao abrir a mira em máquinas com pouca VRAM. Ganho pontual. | A testar |
| **OptimizationLock (config)** | ~500 cvars de performance no `gameinfo.gi` (não é mod em `addons`). | Ver seção 5. | Em uso |

Observações:

- `Clutter be Gone` tem versões separadas; comece por `screenspace_city` (menos
  radical) e só vá para `all` se precisar de mais frame.
- `Texture Downscaler` e `Clutter be Gone` atacam coisas diferentes: textura
  (VRAM) e partículas (GPU/CPU). Teste separado para saber o que ajudou.
- Nenhum desses mods mexe em `gameinfo.gi`, então convivem com o
  OptimizationLock. O que conflita é o Deadlock Mod Manager, que pode
  sobrescrever o arquivo.
- Se um mod quebrar depois de um patch, volte ao repo e baixe a versão
  atualizada antes de tentar diagnosticar por conta própria.

---

## 10. Config alternativa: Full FPS UP cfg SSH

### 10.1 O que é e onde está

Pack baixado à parte, com o nome "Full FPS UP cfg SSH". O original fica em
`/home/cailoop/Downloads/full_fps_up_cfg_ssh/Full FPS UP cfg SSH/` (com uma
subpasta de mesmo nome). A cópia desta pasta, já achatada, está em
`./seco-seco-seco/` e foi conferida com `cmp` em 28/10/2026.

| Arquivo | Tamanho | Linhas | SHA256 |
|---|---|---|---|
| `autoexec.cfg` | 2.499 B | 48 | `ff4d28a5f5c0ba5c90d2a3f3bf103fa8cf01a2dfe307d5cd1be10c32e7636a9f` |
| `gameinfo.gi` | 28.691 B | 913 | `6e643c90a529943dd0f7df604965bb469ec680ebafbb7ac2d2378b98fcddc872` |
| `video.txt` | 1.263 B | 39 | `7a69b5233b77e96ebf566465c48fd34529babe045d767eb2256da49330f27ea5` |
| `pak01_dir.vpk` | 125.160.379 B | — | `5e15bc1e76df19d5e05ffbea5d51335d63795dc41689e525b88f27405bdb9dcd` |

O VPK é o motivo de a pasta passar de 120 MB. O `gameinfo.gi` do pack tem 913
linhas e cerca de 190 entradas no bloco `ConVars`; o atual tem 1.538 linhas e
505 cvars ativas.

### 10.2 É a mesma config? Não. É mais agressiva? Depende do eixo.

O pack não é um superconjunto do OptimizationLock. Ele corta coisas que o atual
não corta, mas é mais leve em outros pontos:

| Eixo | Pack SSH | Config atual | Quem corta mais |
|---|---|---|---|
| Resolução interna | `mat_viewportscale 0.75` sobre 1280x960 = 960x720 | `mat_viewportscale 0.4` sobre 1280x720 = 512x288 | atual |
| Mip bias | 2 no `video.txt`, 4 no `.gi` | 8 no `video.txt`, 3 no `.gi` | atual |
| Pool de textura | `r_texture_pool_size 800` | `256` | atual |
| LOD de textura | `r_texture_lod_scale 0` | `8` | atual |
| LOD de geometria | `sc_instanced_mesh_lod_bias 10` + `sc_fade_distance_scale_override 180` | `sc_screen_size_lod_scale_override 0.00001` | atual (equivalente) |
| FPS da UI | `panorama_max_fps 60` | `30` | atual |
| `r_size_cull_threshold` | 1.2 | 1.4 | atual |
| `r_farz` | 6000 | 7000 | pack |
| Decals | `r_decals 0`, `r_drawmodeldecals 0`, `r_character_decal_resolution 1` | não mexe (linhas comentadas) | pack |
| Skybox 3D | `r_draw3dskybox 0` | só `r_monitor_3dskybox 0` | pack |
| Cloth | `cloth_update 0` | `cloth_sim_on_tick 0` | pack (mais amplo) |
| Física | `cl_phys_timescale 0` | `cl_phys_enabled false` | empate (mecanismos diferentes) |
| Áudio | `snd_steamaudio_load_{pathing,reverb,occlusion}_data 0` + `enable_pathing/reverb 0` | só reduz amostras, não desliga o pathing | pack |
| Partículas screenspace | `r_citadel_screenspace_particles_full_res 0` | `true` | pack |
| Texturas | VPK com 1.690 arquivos a ~10% do tamanho | nenhum mod de textura | pack |

Leitura: o pack ganha nos cortes de **conteúdo** (decals, skybox 3D, cloth,
áudio) e no **VPK de texturas**; perde feio em **resolução, pool e LOD de
textura**. Instalar o pacote inteiro como está tende a **derrubar** o FPS, porque
o `mat_viewportscale 0.75` do `video.txt` anula o ganho do resto.

### 10.3 `gameinfo.gi`

O arquivo é organizado em blocos comentados (`CORE QUALITY`, `FOV`, `LIGHTING &
SHADOWS`, `PARTICLE SYSTEM`, `AUDIO`, etc.) e depois emenda um bloco grande de
defaults da Valve (rate, áudio, rede) copiado de outra build.

**PGIVersion**: o pack traz
`39A735A413003C88A806B364C32DFC6D077E551B9E4EC6C7B11D41E8E67BFA0C`. A build
instalada, o `gameinfo.gi.bkp` vanilla e o repo do Sqooky (28/10/2026) usam
`48C04ECAFC6448F8D3F41F0AA3A15D065501751CF45FBE32DF6CB951BC4F7F6E`. O arquivo
foi montado para **outra build** do jogo: carrega defaults desatualizados, cvars
que já não existem e não há garantia de que todas as seções sejam aceitas pela
build atual.

**SearchPaths reescrito pelo Mod Manager**: o bloco tem `// Deadlock Mod Manager
- Start` e lista `citadel/addons`, `citadel` e `core`, mas **não** lista
`citadel/custom`. Se você usa alguma coisa em `custom`, ela deixa de carregar
com esse `.gi` (o atual monta `custom` e `addons`).

Cortes que o pack adiciona em relação ao atual:

- `r_directlighting 0`, `r_shadows 0`, `r_rendersun 0` (o atual já zera o
  `r_rendersun`).
- `r_decals 0`, `r_drawmodeldecals 0`, `r_character_decal_resolution 1`.
- `r_draw3dskybox 0` e `r_monitor_3dskybox 0`.
- `cloth_update 0` e `cl_phys_timescale 0`.
- `r_citadel_screenspace_particles_full_res 0`.
- `snd_steamaudio_load_pathing_data 0`, `..._load_reverb_data 0`,
  `..._load_occlusion_data 0`, `..._enable_pathing 0`, `..._enable_reverb 0`,
  `snd_steamaudio_num_threads 1` e `audio_enable_vmix_mastering 0`.

Cvars que **não localizei nos binários desta build** (procurei em `client.dll`,
`server.dll` e nas DLLs de `game/bin/win64`, em ASCII e UTF-16): `r_multiscattering`,
`mat_async_shader_load`, `panorama_max_fps`, `panorama_max_overlay_fps`,
`r_citadel_screenspace_particles_full_res`, `r_citadel_ssao_radius`,
`r_citadel_ssao_bent_normals`, `r_citadel_ssao_denoise_passes`,
`r_citadel_ssao_thin_occluder_compensation`, `r_drawmodeldecals`,
`sc_disable_shadow_materials`, `cl_eye_yaw_multiplier`. Podem ser cvars
removidas ou registradas de forma indireta; na prática, trate como
provavelmente inertes. (O próprio config atual usa algumas delas, então isso não
é exclusividade do pack.)

Inconsistências internas do pack:

- `snd_steamaudio_enable_pathing` aparece **duas vezes** (linhas 805 e 808).
- `r_multiscattering "1"` com o comentário "Disable multiscattering" — para
  desligar, o valor teria que ser `0`.
- `cl_interp_ratio 0` e `cl_updaterate 128` no bloco de defaults, contra
  `cl_interp_ratio 1` e `cl_updaterate 64` no `autoexec.cfg` do mesmo pacote.
- `fps_max 400` aqui, `fps_max 0` no `autoexec.cfg` e `fps_max 75` no
  `machine_convars.vcfg` desta máquina.

Recomendação: **não substituir** o `.gi` atual por esse. Se quiser testar,
backup primeiro e, de preferência, copiar só as linhas que interessam para o
`.gi` atual (uma por vez, com baseline).

### 10.4 `video.txt`

É o retrato da máquina do autor, não uma recomendação universal:

| Campo | Pack SSH | Seu estado atual |
|---|---|---|
| GPU | `VendorID 4098` (AMD, 0x1002), `DeviceID 29759` | Intel Iris Xe (i915) |
| Resolução | 1280x960 (4:3), `fullscreen 1`, `nowindowborder 1` | 1280x720 |
| `mat_viewportscale` | 0.75 (960x720 internos) | 0.4 (512x288 internos) |
| `r_texture_stream_mip_bias` | 2 | 8 |
| SSAO / bloom / AA / upscaling | 0 / false / 0 / 0 | 0 / false / 0 / 0 |
| DLSS | `r_citadel_dlss_settings_mode 0`, `r_dlss_preset 6` | sem DLSS |

Problemas: 1280x960 em painel 16:9 vira letterbox ou esticado (não há
`aspectratiomode` no arquivo); o `mip bias 2` deixa a textura bem mais nítida e
consome mais banda; e o `viewportscale 0.75` tem **quase 4,7x mais pixels** que
o seu 0.4. `setting.r_particle_depth_feathering` também não aparece nos binários desta
build. Não use esse arquivo como está.

### 10.5 `autoexec.cfg`

É um script de inicialização no estilo Source 1/CS, com 48 linhas e blocos de
sensibilidade, FPS, gráfico, rede e "performance". O Deadlock **não executa
isso automaticamente**: para valer, o arquivo tem que ir para
`game/citadel/cfg/autoexec.cfg` e o jogo precisa ser iniciado com
`+exec autoexec.cfg` nos argumentos da Steam (depois do `%command%`). No estado
atual, ele é inerte.

Conteúdo por bloco:

- **Sensibilidade**: `zoom_sensitivity_ratio 0.8189...` (ADS 1:1).
- **FPS**: `fps_max 0`, `fps_max_tools 60`, `fps_max_ui 60`.
- **Gráfico**: `mat_viewportscale 0.1` e `r_drawskybox false`.
- **Deadlock/cl**: `cl_auto_cursor_scale false`, `cl_lagcompensation true`,
  `cl_ragdoll_limit 0`, `cl_tickpacket_desired_queuelength 1`.
- **Performance**: `r_low_latency 1`,
  `engine_low_latency_sleep_after_client_tick false`,
  `r_drawtracers_firstperson false`.
- **Rede**: `cl_interp_ratio 1`, `rate 786432`, `cl_updaterate 64`.
- **Diversos**: `r_flush_on_pooled_ib_resize false`,
  `r_smooth_morph_normals false`, `sv_networkvar_validate false`,
  `sv_networkvar_perfieldtracking false`.

Por que não usar:

- **`mat_viewportscale 0.1` é absurdo**: em 1280x960 isso dá 128x96 internos. Se
  o autoexec rodar, ele atropela o `video.txt` (0.75 no pack, 0.4 no seu) e o
  jogo fica impraticável.
- **`sv_*` não funcionam em servidor oficial**: são cvars de servidor.
- **Conflitos**: `fps_max 0` contra `400` do `.gi` e `75` do
  `machine_convars.vcfg`; `cl_interp_ratio 1`/`cl_updaterate 64` contra
  `0`/`128` do próprio pack.
- **`r_drawskybox false`** tira o céu e deixa a iluminação/fog estranhos,
  principalmente combinado com `r_draw3dskybox 0`.
- O arquivo manda olhar um `autoexec_options.txt` que **não existe** no pacote.
- `cl_ragdoll_limit 0` já está no `machine_convars.vcfg`. `r_low_latency` e
  `r_drawtracers_firstperson` não estão no `.gi` atual; se quiser testar, coloque
  essas duas linhas direto no `gameinfo.gi`, sem o autoexec inteiro.

Veredito: é uma config genérica de Source com ajustes de rede, não um arquivo
pensado para Deadlock. Não instale.

### 10.6 `pak01_dir.vpk`

É um pacote de texturas/materiais, não de cvars:

- 3.903 arquivos: 2.758 `vtex_c`, 1.143 `vmat_c` e 2 `vpcf_c`.
- 125.160.379 bytes.
- Cruzando com o `pak01_dir.vpk` do jogo: 1.690 caminhos são idênticos aos do
  jogo. Nesses, o original soma 147,7 MB e o pack entrega 14,3 MB — cerca de
  **10% do tamanho**. É um downscale pesado, na linha do Texture Downscaler da
  seção 9.3, só que já empacotado.

Instalação: copiar para `game/citadel/addons/pak01_dir.vpk`. A linha
`Game "citadel/addons"` já está descomentada no `gameinfo.gi` atual (linha 247).
Se já existir outro `pak01_dir.vpk` em `addons`, faça backup antes.

Dois avisos:

- O pack é **autocontido**: todas as 3.903 entradas têm os dados embutidos no
  próprio arquivo. **Não** substitua o `citadel/pak01_dir.vpk` do jogo (8,4 MB,
  apenas o índice dos 329 arquivos `pak01_000..328`, que somam 33 GB) por ele:
  trocar o índice pelo pack quebra o carregamento do jogo. O lugar certo é
  `citadel/addons/`.
- O VPK é **versão 1** do formato; os paks do jogo são versão 2. Se o addon não
  aparecer no jogo, a versão do arquivo é o primeiro suspeito: vale reempacotar
  em v2 com uma ferramenta de VPK do Source 2 antes de desistir.

Efeito esperado: menos VRAM e menos banda de textura (bom para iGPU), ao custo
de mapa lavado, brilho estourado e leitura pior. Os 2.211 arquivos sem caminho
idêntico podem ser materiais recompilados ou variantes; se algum material
quebrar, o sintoma é superfície preta/rosa ou textura faltando.

Teste **sozinho primeiro**, sem trocar o `.gi` e sem trocar o `video.txt`, para
saber quanto do ganho veio dele.

### 10.7 Protocolo de teste

1. **Baseline**: estado atual, 3 partidas/medições iguais, anotando média e 1%
   low na tabela da seção 8.
2. **VPK sozinho**: copiar só o `pak01_dir.vpk` para `addons`, manter o `.gi` e o
   `video.txt` atuais. Medir. Se não houver ganho ou o mapa ficar ilegível,
   remover.
3. **`.gi` do pack**: só depois do passo 2. Backup do `.gi` atual, copiar o do
   pack, manter o `video.txt` atual. Medir. Se piorar, reverter na hora.
4. **`video.txt`**: não copiar o do pack. Se o VPK ajudar, testar subir o
   `mat_viewportscale` atual de 0.4 para 0.5 e depois 0.6 (com o jogo fechado,
   porque ele regrava o arquivo ao sair). Um passo por vez.
5. Anotar cada passo. Sem baseline, o ganho do VPK se confunde com o do `.gi`.

### 10.8 Como reverter

```bash
# VPK
rm ~/.local/share/Steam/steamapps/common/Deadlock/game/citadel/addons/pak01_dir.vpk

# gameinfo.gi
cp ~/.local/share/Steam/steamapps/common/Deadlock/game/citadel/gameinfo.gi.bkp \
   ~/.local/share/Steam/steamapps/common/Deadlock/game/citadel/gameinfo.gi

# video.txt: feche o jogo e apague; ele gera de novo no próximo boot
mv ~/.local/share/Steam/userdata/1146272440/1422450/local/cfg/video.txt \
   ~/.local/share/Steam/userdata/1146272440/1422450/local/cfg/video.txt.old
```

Update do jogo ou "verificar integridade" também restaura o `gameinfo.gi` e
apaga o VPK.

### 10.9 Veredito

Vale testar **apenas o VPK**, isolado, porque é a única parte que ataca um eixo
que o estado atual não ataca (VRAM/banda de textura). O `.gi` é de outra build,
mexe no `SearchPaths` e mistura cortes fortes com valores mais leves que os
seus; o `autoexec.cfg` é inerte ou conflitante; e o `video.txt` é mais pesado
que o seu. Não instale o pacote como bloco.

---

## 11. Reversão

```bash
# 1. gameinfo.gi original
cp ~/.local/share/Steam/steamapps/common/Deadlock/game/citadel/gameinfo.gi.bkp \
   ~/.local/share/Steam/steamapps/common/Deadlock/game/citadel/gameinfo.gi

# 2. video.txt: apagar faz o jogo gerar de novo no próximo boot
mv ~/.local/share/Steam/userdata/1146272440/1422450/local/cfg/video.txt \
   ~/.local/share/Steam/userdata/1146272440/1422450/local/cfg/video.txt.old

# 3. argumentos Steam: limpar o campo nas propriedades do jogo

# 4. energia
sudo power-control daily
```

Depois de reverter, abra o jogo uma vez para ele regravar `video.txt` e
`machine_convars.vcfg`.

---

## 12. Referências

- OptimizationLock (Sqooky), raiz do projeto — **fonte principal deste guia**:
  <https://github.com/Sqooky/OptimizationLock/tree/main>
- Mods de performance e correção de bugs:
  <https://github.com/Sqooky/OptimizationLock/tree/main/Performance%20Improving%20Mods>
- OptimizationLock no GameBanana: <https://gamebanana.com/mods/656341>
- Preset low end da comunidade (w0nxyApex): <https://github.com/w0nxyApex/Deadlock-Tweaks-config>
- ProtonDB do Deadlock: <https://www.protondb.com/app/1422450>
- Documentação de cvars do Source 2 / Deadlock: `game/citadel/cfg` e o próprio
  `gameinfo.gi` do mod (cada cvar tem comentário do autor).

Se qualquer coisa quebrar depois de um update do jogo, comece pelo repositório:
ele é a fonte das configs e dos mods usados aqui e costuma ser atualizado antes
de qualquer guia de terceiros.
