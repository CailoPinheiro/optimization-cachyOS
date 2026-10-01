# Animated Wallpaper (mpvpaper), Menu no Dolphin e Correção do Shell

**Data**: 2026-09-30 · **Status**: Aplicado e funcionando

## Motivo
Permitir a personalização do Hyprland com suporte a wallpapers de vídeo usando o `mpvpaper`, integrando um atalho prático de clique com o botão direito no gerenciador de arquivos Dolphin e garantindo sincronia total com o gerador de temas Matugen. Além disso, sanar a instabilidade crítica em que a troca para papéis de parede animados esgotava a memória RAM ou quebrava a renderização de cores do Quickshell.

## O que foi feito
1. **Instalação das Dependências**: Adicionados os pacotes `mpvpaper` e `ffmpeg`.
2. **Integração com o Dolphin (KIO Service Menu)**: Criada a ação de contexto para arquivos de imagem e vídeo permitindo definir wallpapers diretamente pelo botão direito.
3. **Correção de Memória OOM (`Background.qml`)**: Bloqueada a chamada do `magick identify -format` sobre arquivos de vídeo (`.mp4`, `.mkv`, `.webm`, etc.), forçando o uso do thumbnail JPEG intermediário para cálculo de escala e zoom, impedindo que o ImageMagick tente carregar o vídeo inteiro na memória.
4. **Resiliência na Carga de Cores (`MaterialThemeLoader.qml`)**: Implementado um laço de retentativas (Retry Loop) com `try`/`catch` no carregamento do `colors.json`, permitindo que o Quickshell aguarde a finalização da escrita concorrente do Matugen sem abortar as amarrações (bindings) visuais.
5. **Escrita atômica do config (`switchwall.sh`)**: A miniatura JPEG passou a ser extraída pelo `ffmpeg` **antes** de qualquer alteração no `config.json`, e os campos `background.wallpaperPath` + `background.thumbnailPath` passaram a ser gravados em uma única chamada do `jq` (arquivo temporário + `mv`). O Quickshell nunca mais enxerga um estado intermediário com vídeo sem miniatura.
6. **Proteção contra saída inválida (`AbstractBackgroundWidget.qml`)**: O `JSON.parse` da saída do `least_busy_region.py` foi envolvido em `try`/`catch`, ignorando silenciosamente tracebacks do Python em vez de lançar exceção não tratada dentro do `onStreamFinished`.
7. **Validação das dimensões (`Background.qml`)**: O `onStreamFinished` do `magick identify` agora descarta saída vazia ou não numérica antes de calcular `minSuitableScale`, evitando `NaN`/`Infinity` na escala do wallpaper.
8. **Estabilidade e Persistência do mpvpaper (`switchwall.sh`)**:
   - As flags do `mpv` foram ajustadas para remover `video-sync=display-resample` (que sem áudio causava descompasso de buffer e crash após alguns minutos de loop) e fixar `loop-file=inf` com `hwdec=auto-safe`.
   - Adicionada a flag nativa `--auto-pause` para suspender a renderização quando janelas cobrem o wallpaper.
   - A chamada do `mpvpaper` agora usa a saída universal `ALL` (gerenciando todas as telas em um único processo) e é desacoplada com `nohup ... </dev/null >/dev/null 2>&1 & disown`, impedindo que o encerramento do script mate o processo em segundo plano.

> **Nota**: os itens 5, 6 e 8 garantem a estabilidade completa: a interface do Quickshell não fecha por corrida de escrita e o wallpaper animado não encerra após alguns minutos.

---

## Como realizar (Passo a passo)

### 1. Instalar pacotes necessários
```bash
sudo pacman -S --needed mpvpaper ffmpeg
```

### 2. Criar o Menu de Contexto no Dolphin

Crie o diretório de serviços KIO (se não existir):
```bash
mkdir -p ~/.local/share/kio/servicemenus
```

Crie o arquivo `~/.local/share/kio/servicemenus/set-as-wallpaper.desktop` com o conteúdo:
```ini
[Desktop Entry]
Type=Service
MimeType=image/jpeg;image/png;image/webp;image/bmp;image/svg+xml;video/mp4;video/webm;video/x-matroska;video/quicktime;video/x-msvideo;video/ogg;
Actions=SetAsWallpaper;
X-KDE-Priority=TopLevel

[Desktop Action SetAsWallpaper]
Name=Definir como Wallpaper
Name[pt_BR]=Definir como Wallpaper
Name[en]=Set as Wallpaper
Icon=preferences-desktop-wallpaper
Exec=/home/cailoop/.config/quickshell/ii/scripts/colors/switchwall.sh --image %f
```

Atualize o cache de serviços do KDE:
```bash
kbuildsycoca6 --noincremental
```

### 3. Aplicar a proteção de zoom em `Background.qml`

No repositório da dotfile (`~/dots-hyprland/dots/.config/quickshell/ii/modules/ii/background/Background.qml`), altere a função `updateZoomScale()` para garantir que vídeos usem a miniatura:

```qml
        // Wallpaper zoom scale
        function updateZoomScale() {
            var pathToCheck = bgRoot.wallpaperPath;
            if (pathToCheck.match(/\.(mp4|mkv|webm|avi|mov)$/i)) {
                pathToCheck = Config.options.background.thumbnailPath;
            }
            getWallpaperSizeProc.path = pathToCheck;
            getWallpaperSizeProc.running = true;
        }
```

### 4. Aplicar o retry loop de cores em `MaterialThemeLoader.qml`

No arquivo `~/dots-hyprland/dots/.config/quickshell/ii/services/MaterialThemeLoader.qml`:

1. Proteja a função `applyColors` com `try`/`catch`:
```qml
    function applyColors(fileContent) {
        try {
            if (!fileContent || fileContent.trim() === "") return false;
            const json = JSON.parse(fileContent);
            for (const key in json) {
                if (json.hasOwnProperty(key)) {
                    const camelCaseKey = key.replace(/_([a-z])/g, (g) => g[1].toUpperCase());
                    const m3Key = `m3${camelCaseKey}`;
                    Appearance.m3colors[m3Key] = json[key];
                }
            }
            Appearance.m3colors.darkmode = (Appearance.m3colors.m3background.hslLightness < 0.5);
            return true;
        } catch (e) {
            return false;
        }
    }
```

2. Atualize o `Timer` e o `FileView` para retentar a leitura e aplicar as cores dinamicamente:
```qml
    Timer {
        id: delayedFileRead
        interval: Config.options?.hacks?.arbitraryRaceConditionDelay ?? 50
        repeat: false
        running: false
        property int attempts: 0
        onTriggered: {
            themeFileView.reload();
            const content = themeFileView.text();
            if (!root.applyColors(content)) {
                attempts += 1;
                if (attempts < 10) {
                    delayedFileRead.interval = 50;
                    delayedFileRead.start();
                } else {
                    attempts = 0;
                }
            } else {
                attempts = 0;
            }
        }
    }

    FileView { 
        id: themeFileView
        path: Qt.resolvedUrl(root.filePath)
        watchChanges: true
        onFileChanged: {
            this.reload();
            delayedFileRead.attempts = 0;
            delayedFileRead.start();
        }
        onLoadedChanged: {
            const fileContent = themeFileView.text();
            if (!root.applyColors(fileContent)) {
                delayedFileRead.attempts = 0;
                delayedFileRead.start();
            }
        }
        onLoadFailed: root.resetFilePathNextTime();
    }
```

### 5. Tornar a escrita do `switchwall.sh` atômica

Este é o passo que resolve a UI sumir. A ordem antiga era:
`set_wallpaper_path` → inicia `mpvpaper` → `ffmpeg` gera thumbnail →
`set_thumbnail_path`. Nesse intervalo o `config.json` continha o `.mp4` com
`thumbnailPath` antigo/vazio, e o Quickshell reagia de forma inconsistente.

No repositório da dotfile
(`~/dots-hyprland/dots/.config/quickshell/ii/scripts/colors/switchwall.sh`):

1. Atualize a definição de `VIDEO_OPTS` e a função `create_restore_script`:
```bash
VIDEO_OPTS="no-audio loop-file=inf hwdec=auto-safe scale=bilinear panscan=1.0 load-scripts=no"

create_restore_script() {
    local video_path=$1
    cat > "$RESTORE_SCRIPT.tmp" << EOF
#!/bin/bash
# Generated by switchwall.sh - Don't modify it by yourself.
# Time: $(date)

pkill -f -9 mpvpaper

nohup mpvpaper --auto-pause -o "$VIDEO_OPTS" ALL "$video_path" </dev/null >/dev/null 2>&1 & disown
EOF
    mv "$RESTORE_SCRIPT.tmp" "$RESTORE_SCRIPT"
    chmod +x "$RESTORE_SCRIPT"
}
```

2. Substitua o bloco de tratamento de vídeo da função `switch()` por:
```bash
            # Extract first frame for color generation and thumbnail
            thumbnail="$THUMBNAIL_DIR/$(basename "$imgpath").jpg"
            ffmpeg -y -i "$imgpath" -vframes 1 "$thumbnail" 2>/dev/null

            # Set wallpaper path and thumbnail path atomically
            if [ -f "$SHELL_CONFIG_FILE" ]; then
                jq --arg wp "$imgpath" --arg tp "$thumbnail" '.background.wallpaperPath = $wp | .background.thumbnailPath = $tp' "$SHELL_CONFIG_FILE" > "$SHELL_CONFIG_FILE.tmp" && mv "$SHELL_CONFIG_FILE.tmp" "$SHELL_CONFIG_FILE"
            fi

            # Set video wallpaper
            local video_path="$imgpath"
            nohup mpvpaper --auto-pause -o "$VIDEO_OPTS" ALL "$video_path" </dev/null >/dev/null 2>&1 & disown
```

E no ramo `else` (wallpaper estático), zere o `thumbnailPath` na mesma escrita:

```bash
            # Update wallpaper path in config
            if [ -f "$SHELL_CONFIG_FILE" ]; then
                jq --arg wp "$imgpath" '.background.wallpaperPath = $wp | .background.thumbnailPath = ""' "$SHELL_CONFIG_FILE" > "$SHELL_CONFIG_FILE.tmp" && mv "$SHELL_CONFIG_FILE.tmp" "$SHELL_CONFIG_FILE"
            fi
```

As funções `set_wallpaper_path` e `set_thumbnail_path` continuam no arquivo,
mas a troca de wallpaper não depende mais delas.

### 6. Blindar o `AbstractBackgroundWidget.qml`

O script `scripts/images/least_busy_region.py` usa OpenCV e falha com
traceback se receber um caminho de vídeo. Proteja o consumo da saída em
`~/dots-hyprland/dots/.config/quickshell/ii/modules/ii/background/widgets/AbstractBackgroundWidget.qml`:

```qml
        stdout: StdioCollector {
            id: leastBusyRegionOutputCollector
            onStreamFinished: {
                const output = leastBusyRegionOutputCollector.text;
                if (output.length === 0) return;
                try {
                    const parsedContent = JSON.parse(output);
                    root.dominantColor = parsedContent.dominant_color || Appearance.colors.colPrimary;
                    if (root.placementStrategy === "free") return;
                    root.targetX = parsedContent.center_x * root.wallpaperScale - root.width / 2;
                    root.targetY  = parsedContent.center_y * root.wallpaperScale - root.height / 2;
                } catch (e) {
                    // Ignore malformed or non-JSON output gracefully
                }
            }
        }
```

### 7. Validar a saída do `magick identify` no `Background.qml`

Ainda em `~/dots-hyprland/dots/.config/quickshell/ii/modules/ii/background/Background.qml`,
valide antes de usar as dimensões:

```qml
                onStreamFinished: {
                    const output = wallpaperSizeOutputCollector.text;
                    if (!output || output.trim() === "") return;
                    const parts = output.trim().split(" ").map(Number);
                    if (parts.length < 2 || isNaN(parts[0]) || isNaN(parts[1]) || parts[0] <= 0 || parts[1] <= 0) return;
                    const [width, height] = parts;
                    const [screenWidth, screenHeight] = [bgRoot.screen.width, bgRoot.screen.height];
                    bgRoot.wallpaperWidth = width;
                    bgRoot.wallpaperHeight = height;

                    // Perfect image; scale = 1
                    // Small picture; scale > 1; will zoom in the picture
                    // Big picture; scale < 1; will zoom out the picture
                    // Choose max number so every side will fit
                    bgRoot.minSuitableScale = Math.max(screenWidth / width, screenHeight / height);
                }
```

### 8. Sincronizar dotfiles e reiniciar o Quickshell

```bash
cd ~/dots-hyprland
./setup install-files -f --skip-backup --skip-allgreeting
qs -c ii
```

---

## Arquivos tocados
- `~/.local/share/kio/servicemenus/set-as-wallpaper.desktop`: Criado.
- `~/dots-hyprland/dots/.config/quickshell/ii/scripts/colors/switchwall.sh`: Modificado (escrita atômica do config).
- `~/dots-hyprland/dots/.config/quickshell/ii/modules/ii/background/Background.qml`: Modificado (OOM + validação de dimensões).
- `~/dots-hyprland/dots/.config/quickshell/ii/modules/ii/background/widgets/AbstractBackgroundWidget.qml`: Modificado (`try`/`catch` no `JSON.parse`).
- `~/dots-hyprland/dots/.config/quickshell/ii/services/MaterialThemeLoader.qml`: Modificado (retry loop + aplicação dinâmica).

Cada arquivo do repositório tem cópia viva em `~/.config/quickshell/ii/...`,
sincronizada por `./setup install-files`.

## Como verificar
1. Abra o Dolphin (`Super + E`), navegue até um arquivo de vídeo (`.mp4`, `.webm`, etc.) e clique com o botão direito.
2. Selecione **"Definir como Wallpaper"**.
3. O vídeo começará a rodar no plano de fundo através do `mpvpaper`.
4. As cores do tema (Matugen) serão atualizadas suavemente sem reiniciar o shell, e as barras do Quickshell permanecerão estáveis e ativas.
5. Confirme a atomicidade: `jq -r '.background | {wallpaperPath, thumbnailPath}' ~/.config/illogical-impulse/config.json` deve sempre mostrar um caminho de vídeo **junto** de uma miniatura existente em disco.

## Como reverter
1. Remover o menu de contexto do Dolphin:
```bash
rm -f ~/.local/share/kio/servicemenus/set-as-wallpaper.desktop
kbuildsycoca6 --noincremental
```
2. Reverter os arquivos do Quickshell:
```bash
cd ~/dots-hyprland
git checkout origin/main -- dots/.config/quickshell/ii/modules/ii/background/Background.qml
git checkout origin/main -- dots/.config/quickshell/ii/modules/ii/background/widgets/AbstractBackgroundWidget.qml
git checkout origin/main -- dots/.config/quickshell/ii/scripts/colors/switchwall.sh
git checkout origin/main -- dots/.config/quickshell/ii/services/MaterialThemeLoader.qml
./setup install-files -f --skip-backup --skip-allgreeting
qs -c ii
```
3. Desinstalar os pacotes:
```bash
sudo pacman -Rs mpvpaper
```
