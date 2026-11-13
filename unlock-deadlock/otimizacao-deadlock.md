# Otimização do Deadlock

Guia direto para otimizar o Deadlock no Linux (via Proton), sem depender de
ferramentas específicas de nenhuma máquina. Serve para qualquer hardware que
rode o jogo.

São dois arquivos para substituir, a pasta de mods e uma linha de opções da
Steam. **Os dois arquivos prontos acompanham este guia na mesma pasta**
(`video.txt` e `gameinfo.gi`) — não colar conteúdo à mão, só copiar
integralmente os arquivos.

**Antes de tudo:** um update do jogo ou o botão "Verificar Integridade
dos Arquivos" da Steam desfaz tudo — restaura o `gameinfo.gi` original e apaga
os mods em `addons/`. Guarde cópias dos arquivos desta pasta (e dos mods que
usar) em outro lugar antes de mexer.

## 1. Contexto: os dois arquivos

- **`video.txt`** — são as configurações de vídeo do jogo (resolução, sombras,
  escala do render interno etc.) em forma de arquivo. O jogo lê ao iniciar e
  regrava quando você sai ou confirma algo no menu de vídeo.
- **`gameinfo.gi`** — é a definição do jogo para a engine Source 2. O bloco
  `ConVars` no final dele injeta ~500 cvars de desempenho como padrão a cada
  boot; é o mecanismo usado pelo mod OptimizationLock (Sqooky).

Tudo aqui é client-side: afeta apenas como o jogo roda e renderiza na sua
máquina. Os passos 2 a 4 funcionam igual no Windows (muda só o caminho da
pasta); a seção 5 é específica de Linux.

## 2. `video.txt`

**Caminho (Linux):** `~/.steam/steam/userdata/<SEU_STEAM_ID>/1422450/local/cfg/video.txt`
(equivale a `~/.local/share/Steam/userdata/...` na configuração padrão; se a
sua biblioteca estiver em outro disco, troque o começo do caminho)

**Como aplicar:**

1. Feche o jogo.
2. Backup da sua config: renomeie o `video.txt` atual para `video.txt.bak`
   na mesma pasta.
3. Copie o arquivo `video.txt` **desta pasta** (que acompanha o guia) para o
   caminho acima, substituindo o original.
4. Abra o jogo: ele carrega o arquivo e o regrava quando você sai —
   comportamento normal.

A config local já vem no perfil mínimo (render interno reduzido, sombras/AA/
SSAO/fog/bloom desligados), pensado para iGPU fraca. Ajustes por máquina
(resolução de saída, mip bias) estão na seção 8.

## 3. `gameinfo.gi`

**Caminho:** `<BIBLIOTECA_STEAM>/steamapps/common/Deadlock/game/citadel/gameinfo.gi`
(na configuração padrão do Steam no Linux equivale a
`~/.local/share/Steam/steamapps/common/Deadlock/game/citadel/gameinfo.gi`)

**Como aplicar:**

1. Feche o jogo.
2. Confirme que o backup vanilla `gameinfo.gi.bkp` está na mesma pasta —
   é a sua volta para o padrão.
3. Backup da config atual que funcionava (ex.: `gameinfo.gi.meu`) e então
   copie o arquivo `gameinfo.gi` **desta pasta** por cima do original.
4. Não mexa na linha `UserSettingsPathID` dentro de `FileSystem` (o comentário
   ao lado explica o que acontece se ela sair).

## 4. Addons (pasta de mods)

**Local:** `<BIBLIOTECA_STEAM>/steamapps/common/Deadlock/game/citadel/addons/`

É aqui que ficam os `.vpk` dos mods. O `gameinfo.gi` otimizado já monta a
pasta — o `SearchPaths` dele inclui `citadel/addons` (e `citadel/custom`).

- Crie a pasta se ela não existir.
- Copie os `.vpk` dos mods para dentro dela, com o jogo fechado.
- **Nunca** substitua o `pak01_dir.vpk` da pasta central do jogo
  (`game/citadel/`): ele é o índice de todo o conteúdo. Addon de texturas vai
  em `addons/`.

## 5. Argumentos de lançamento da Steam

**Onde:** Biblioteca > Deadlock (botão direito) > Propriedades > Geral >
**Opções de Inicialização**.

Linha base:

```
MESA_DISK_CACHE_MAX_SIZE=10G %command% -dx11 -high -preload -fullscreen +@panorama_min_comp_layer_cache_cost_TURNED_OFF 256
```

Com MangoHud (overlay de FPS/frametime): instale o pacote `mangohud` (e o
`lib32-mangohud`) pelo gerenciador da sua distro e cole:

```
MESA_DISK_CACHE_MAX_SIZE=10G mangohud %command% -dx11 -high -preload -fullscreen +@panorama_min_comp_layer_cache_cost_TURNED_OFF 256
```

| Item | Função |
|---|---|
| `MESA_DISK_CACHE_MAX_SIZE=10G` | Amplia o cache de shaders da GPU em disco; menos recompilação, menos engasgo. |
| `mangohud` | Overlay de métricas (opcional; se não estiver instalado, tire-o da linha). |
| `-dx11` | Renderiza via D3D11. Alternativa: `-vulkan` — teste os dois; se der problema no Vulkan, volte para `-dx11`. |
| `-high` | Prioridade alta do processo. |
| `-preload` | Pré-carrega assets; menos stutter. |
| `-fullscreen` | Tela cheia. |
| `+@panorama_min_comp_layer_cache_cost_TURNED_OFF 256` | Ajuste de cache da UI (receita do mod). O sufixo `_TURNED_OFF` mantém a opção desligada de propósito. |

**A ordem importa (Linux):** variáveis de ambiente (`NOME=valor`) no início, o
`mangohud` imediatamente antes do `%command%`, flags do jogo depois do
`%command%`. Fora dessa ordem o jogo não abre.

## 6. Mods

Fonte oficial — pasta "Performance Improving Mods" do OptimizationLock; baixe
sempre a versão compatível com o update atual do jogo:

<https://github.com/Sqooky/OptimizationLock/tree/main/Performance%20Improving%20Mods>

| Mod | O que faz | Use se |
|---|---|---|
| **Blur Disabler** | Remove todo o blur da UI (loja, pause, HUD). | Quer menos stutter sem cortar o mapa. |
| **Clutter be Gone** | Remove clutter e partículas do cenário; variantes da leve (`screenspace_city`) à completa (`all`). | Precisa de mais FPS e aceita o mapa mais limpo. |
| **Optimized Soul Container** | Troca a alma (soul orb) por um modelo de menos polígonos. | Dá engasgo com muitas almas espalhadas. |
| **Sinner Light Fix** | Corrige as luzes dos sinners quando o `mip bias` está baixo. | Vai usar `r_texture_stream_mip_bias` abaixo de 4. |
| **Texture Downscaler (WIP)** | Reduz todas as texturas a 25% — grande economia de VRAM. | Está no limite de memória de vídeo. |
| **Vindicta Scope Downscale** | Reduz a mira 4096x4096 da Vindicta. | Joga com a Vindicta. |

Instale com o jogo fechado, um mod por vez, direto na pasta `addons/`. Se um
mod quebrar depois de um update do jogo, baixe a versão atualizada no repo
antes de tentar diagnosticar por conta própria.

## 7. Como reverter

```bash
cd "<BIBLIOTECA_STEAM>/steamapps/common/Deadlock/game/citadel"
cp gameinfo.gi.bkp gameinfo.gi            # restaura o gameinfo original
rm -f addons/*                            # tira os mods
rm ~/.steam/steam/userdata/<SEU_STEAM_ID>/1422450/local/cfg/video.txt   # apaga (o jogo recria no próximo boot)
```

Em seguida, limpe o campo **Opções de Inicialização** nas Propriedades do jogo
na Steam e abra o jogo uma vez para ele recriar as configurações dele.

## 8. Recomendações

### Correções manuais no `gameinfo.gi` copiado (seção 3)

1. `cl_disable_ragdolls "1"` -> `"0"` — o próprio autor manda manter `0`:
   desativar ragdolls quebra o ultimate do Doorman; `cl_ragdoll_limit "0"` já
   cobre o FPS.
2. `fps_max "400"` (e `fps_max_ui "120"`) -> cap na taxa de refresh do seu
   monitor (ex.: 144 Hz -> `144`). Cap acima do monitor gera judder e calor;
   abaixo, desperdiça frames dos menus à toa.
3. `r_citadel_enable_pano_world_blur "true"` -> `"false"` — desliga o blur da
   loja e do pause, ganho grande segundo o autor. Único caso que pede teste:
   Nvidia com Vulkan pode dar defeito visual no pause.

### Uso e manutenção

4. Feche o jogo antes de editar qualquer arquivo. O `gameinfo.gi` só é lido no
   boot, mas o `video.txt` é regravado ao sair ou ao confirmar algo no menu de
   vídeo — editado com o jogo aberto, a mudança se perde.
5. Em grandes atualizações (ou verificar integridade), repita a instalação:
   baixe o `gameinfo.gi` recente do repositório do Sqooky para evitar
   travamentos por cvars obsoletas (e espelhe de volta nesta pasta), e
   recoloque os mods em `addons/`.
6. Verifique a sintaxe após editar: blocos de chaves `{}` abertos travam o
   jogo.
7. Guarde cópia da última versão que funcionou dos dois arquivos e dos mods —
   o `.bkp` do jogo só devolve o vanilla; a volta para o "estava bom ontem"
   depende da sua cópia.
8. Não cole listas de cvars "mágicas" no `video.txt`: várias que circulam na
   comunidade não existem nesta build; ajuste pelo menu do jogo.
9. `r_texture_stream_mip_bias` abaixo de `4` distorce as luzes dos sinners em
   triângulos; se quiser descer mais, instale antes o mod **Sinner Light Fix**.
10. Mods um por vez, com a pasta `addons/` limpa entre os testes e o resultado
    anotado. Prefira instalação manual — o Deadlock Mod Manager pode
    sobrescrever o seu `gameinfo.gi`.
11. Ajustes por máquina no `video.txt`: `defaultres`/`defaultresheight` na
    resolução nativa, e `mat_viewportscale` só se sobrar desempenho (abaixo de
    0.4 o ganho é nulo).
12. Jogo não abrir depois de mexer (erro `FATAL ERROR` citando arquivos
    `.xml`/mods): esvazie `addons/` e abra de novo; se persistir, restaure o
    `gameinfo.gi.bkp`.

## 9. Referências e recursos

- OptimizationLock (Sqooky) — fonte principal deste guia:
  <https://github.com/Sqooky/OptimizationLock/tree/main>
- Pasta de mods de desempenho:
  <https://github.com/Sqooky/OptimizationLock/tree/main/Performance%20Improving%20Mods>
- GameBanana: <https://gamebanana.com/mods/656341>
- Tutorial do autor (vídeo): <https://www.youtube.com/watch?v=zC3wBYY98vU>
- Preset low end da comunidade:
  <https://github.com/w0nxyApex/Deadlock-Tweaks-config>
- ProtonDB do Deadlock: <https://www.protondb.com/app/1422450>

Cada linha do `gameinfo.gi` do OptimizationLock vem comentada pelo autor com o
que faz — use o próprio arquivo desta pasta como documentação.
