# Animated Wallpaper (mpvpaper) e Correção de Bugs no Shell

**Data**: 2026-09-30 · **Status**: Aplicado e funcionando

## Motivo
Permitir a personalização impecável do Hyprland com suporte a wallpapers de vídeo usando o pacote `mpvpaper`, criando coerência entre a detecção do tema (Matugen) e o motor da interface visual (Quickshell). Consequentemente, sanar a instabilidade extrema onde as modificações e carga sobre a CPU matavam/crachavam a interface do sistema.

## O que foi feito
1. Instalados os pacotes necessários via pacman: `mpvpaper`, `ffmpeg`.
2. Habilitado e configurado o recurso de wallpaper animado através de `switchwall.sh`, que usa o painel de contexto do gerenciador de arquivos (referência a `@Projects/optimization-cachyos/personal-tweeks/tweek-details/2026-09-28-dolphin-wallpaper-context-menu.md`).
3. Foram consertadas duas gravíssimas "race conditions" (condições de corrida) dentro do código do Quickshell que ocasionavam o sumiço da interface de repente e das barras:
   - **Prevenção de Memória OOM (`Background.qml`)**: Foi programado um bloqueio antes que a engrenagem QML chame o comando pesado `magick identify -format` para calcular dimensões. Se for um vídeo(`.mp4`, `.mkv`, etc), forçamos a engine a utilizar o JPEG reduzido do thumbnail ao invés de atolar a memória tentando ler o vídeo de alta definição para processar zoom, o que fatalmente levava o kernel a matar o shell sem aviso.
   - **Correção da Carga Lenta de Cores (`MaterialThemeLoader.qml`)**: O gerador de temas estava recebendo atrasos pesados ao operar concorrentemente com o `ffmpeg` extraindo vídeo, impossibilitando a gravação simultânea de `colors.json` em menos de 20ms. O bloqueio consistiu em adicionar re-tentativas (Retry Loop com `try`/`catch`) na leitura e conversão para objetos com `JSON.parse` até ler com integridade toda a paleta Matugen sem abortar os componentes QML inteiros.

## Arquivos tocados
- `~/dots-hyprland/dots/.config/quickshell/ii/modules/ii/background/Background.qml`
- `~/dots-hyprland/dots/.config/quickshell/ii/services/MaterialThemeLoader.qml`

## Como verificar
1. Aplique um wallpaper utilizando um vídeo qualquer via menu de contexto no Dolphin (ver instrução na tweak antiga supracitada).
2. Repare que nem as cores base do Matugen quebram a meio caminho, nem o Quickshell ou Barra Lateral e Superiores se fecham abruptamente.
3. Teste redimensionando barras e interagindo em alto estresse.

## Como reverter
Restaure os arquivos de layout no repositório de modificações `dots-hyprland` com um `git checkout` para o momento em que a verificação nativa não estava aplicada:
```bash
git checkout origin/main -- dots/.config/quickshell/ii/modules/ii/background/Background.qml
git checkout origin/main -- dots/.config/quickshell/ii/services/MaterialThemeLoader.qml
./setup install-files
```
Para as dependências:
```bash
sudo pacman -Rs mpvpaper
```