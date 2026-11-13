# Animated Wallpaper (mpvpaper), Suporte a GIF, Menu no Dolphin e Correção do Shell

**Data**: 2026-09-30 (Atualizado em 2026-11-03) · **Status**: Aplicado e funcionando

## Motivo

Permitir a personalização do Hyprland com suporte a wallpapers de vídeo e arquivos GIF animados usando o `mpvpaper`, integrando um atalho prático de clique com o botão direito no gerenciador de arquivos Dolphin e garantindo sincronia total com o gerador de temas Matugen. Além disso, sanar a instabilidade crítica em que a troca para papéis de parede animados esgotava a memória RAM ou quebrava a renderização de cores do Quickshell, e estender o suporte nativo para GIFs animados sem sobrecarregar o identificador de imagens.

---

## O que foi feito

1. **Instalação das Dependências**: Adicionados os pacotes `mpvpaper` e `ffmpeg`.
2. **Suporte a GIFs Animados**: Ajustada a função `is_video` no script de troca de wallpapers e as checagens `wallpaperIsVideo` no Quickshell para tratar arquivos `.gif` exatamente como mídias animadas (`mpvpaper`), extraindo o primeiro frame via `ffmpeg` para geração de miniaturas e cálculo de cores do Matugen.
3. **Integração com o Dolphin (KIO Service Menu)**: Criada a ação de contexto para arquivos de imagem, vídeo e GIF permitindo definir wallpapers diretamente pelo botão direito.
4. **Correção de Memória OOM (`Background.qml`)**: Bloqueada a chamada do `magick identify -format` sobre arquivos de vídeo e GIF, forçando o uso do thumbnail JPEG intermediário para cálculo de escala e zoom.
5. **Resiliência na Carga de Cores (`MaterialThemeLoader.qml`)**: Implementado um laço de retentativas (Retry Loop) com `try`/`catch` no carregamento do `colors.json`.
6. **Escrita atômica do config (`switchwall.sh`)**: Miniatura JPEG extraída pelo `ffmpeg` antes de alterar o `config.json`.
7. **Estabilidade e Persistência do mpvpaper (`switchwall.sh`)**: Flags do `mpv` ajustadas (`no-audio`, `loop-file=inf`, `hwdec=auto-safe`, `--auto-pause`) e execução desacoplada com `nohup ... & disown`.

---

## Passo a passo (reprodução / re-aplicação)

### 1. Instalar pacotes necessários
```bash
sudo pacman -S --needed mpvpaper ffmpeg
```

### 2. Criar o Menu de Contexto no Dolphin
Diretório: `~/.local/share/kio/servicemenus/set-as-wallpaper.desktop`
```ini
[Desktop Entry]
Type=Service
MimeType=image/jpeg;image/png;image/webp;image/bmp;image/svg+xml;image/gif;video/mp4;video/webm;video/x-matroska;video/quicktime;video/x-msvideo;video/ogg;
Actions=SetAsWallpaper;
X-KDE-Priority=TopLevel

[Desktop Action SetAsWallpaper]
Name=Definir como Wallpaper
Name[pt_BR]=Definir como Wallpaper
Name[en]=Set as Wallpaper
Icon=preferences-desktop-wallpaper
Exec=/home/cailoop/.config/quickshell/ii/scripts/colors/switchwall.sh --image %f
```

Atualizar o cache de serviços do KDE:
```bash
kbuildsycoca6 --noincremental
```

### 3. Ajustes no Script `switchwall.sh`
No arquivo `~/dots-hyprland/dots/.config/quickshell/ii/scripts/colors/switchwall.sh`, a função `is_video` inclui a verificação de extensões de vídeo e gif:
```bash
is_video() {
    local extension="${1##*.}"
    local ext_lower="${extension,,}"
    [[ "$ext_lower" == "mp4" || "$ext_lower" == "webm" || "$ext_lower" == "mkv" || "$ext_lower" == "avi" || "$ext_lower" == "mov" || "$ext_lower" == "gif" ]] && return 0 || return 1
}
```

### 4. Ajustes no Quickshell (`Background.qml`, `AbstractBackgroundWidget.qml`, `Appearance.qml`)
Garantir que `.gif` seja reconhecido como vídeo/mídia animada:
- Em `Background.qml`:
```qml
property bool wallpaperIsVideo: Config.options.background.wallpaperPath.endsWith(".mp4") || Config.options.background.wallpaperPath.endsWith(".webm") || Config.options.background.wallpaperPath.endsWith(".mkv") || Config.options.background.wallpaperPath.endsWith(".avi") || Config.options.background.wallpaperPath.endsWith(".mov") || Config.options.background.wallpaperPath.endsWith(".gif")

function updateZoomScale() {
    var pathToCheck = bgRoot.wallpaperPath;
    if (pathToCheck.match(/\.(mp4|mkv|webm|avi|mov|gif)$/i)) {
        pathToCheck = Config.options.background.thumbnailPath;
    }
    getWallpaperSizeProc.path = pathToCheck;
    getWallpaperSizeProc.running = true;
}
```
- Em `AbstractBackgroundWidget.qml`:
```qml
property bool wallpaperIsVideo: Config.options.background.wallpaperPath.endsWith(".mp4") || Config.options.background.wallpaperPath.endsWith(".webm") || Config.options.background.wallpaperPath.endsWith(".mkv") || Config.options.background.wallpaperPath.endsWith(".avi") || Config.options.background.wallpaperPath.endsWith(".mov") || Config.options.background.wallpaperPath.endsWith(".gif")
```
- Em `Appearance.qml`:
```qml
property bool wallpaperIsVideo: wallpaperPath.endsWith(".mp4") || wallpaperPath.endsWith(".webm") || wallpaperPath.endsWith(".mkv") || wallpaperPath.endsWith(".avi") || wallpaperPath.endsWith(".mov") || wallpaperPath.endsWith(".gif")
```

Aplicar alterações na dotfile e sincronizar:
```bash
cd ~/dots-hyprland && ./setup install-files -f
```

---

## Arquivos tocados
- `~/dots-hyprland/dots/.config/quickshell/ii/scripts/colors/switchwall.sh`
- `~/dots-hyprland/dots/.config/quickshell/ii/modules/ii/background/Background.qml`
- `~/dots-hyprland/dots/.config/quickshell/ii/modules/ii/background/widgets/AbstractBackgroundWidget.qml`
- `~/dots-hyprland/dots/.config/quickshell/ii/modules/common/Appearance.qml`
- `~/.local/share/kio/servicemenus/set-as-wallpaper.desktop`

---

## Como verificar

1. Abra o Dolphin e clique com o botão direito em um arquivo `.gif` ou vídeo.
2. Selecione **Definir como Wallpaper**.
3. Confirme que o GIF é reproduzido animado no fundo via `mpvpaper` e que as cores do sistema foram atualizadas pelo `matugen`.
4. Verifique pacotes:
   ```bash
   pacman -Q mpvpaper ffmpeg
   ```

---

## Como reverter

1. Remover o arquivo de menu de contexto do Dolphin:
   ```bash
   rm -f ~/.local/share/kio/servicemenus/set-as-wallpaper.desktop
   kbuildsycoca6 --noincremental
   ```
2. Reverter as edições nas dotfiles e rodar `./setup install-files -f`.

---

## Riscos e observações importantes

- O uso de GIFs animados consome ciclos de GPU/CPU através do mpvpaper, de forma análoga aos vídeos. A flag `--auto-pause` mitiga o consumo quando janelas cobrem o wallpaper.

---

## Histórico de atualizações

- **2026-09-30:** Criação da tweak inicial para suporte a mpvpaper e vídeos.
- **2026-11-03:** Adicionado suporte completo a arquivos GIF animados (`mpvpaper`, integração no Dolphin e tratamento de zoom/miniaturas no Quickshell).
