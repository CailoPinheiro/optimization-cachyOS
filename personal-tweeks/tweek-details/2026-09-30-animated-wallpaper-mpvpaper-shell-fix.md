# Animated Wallpaper (mpvpaper), Menu no Dolphin e Correção do Shell

**Data**: 2026-09-30 · **Status**: Aplicado e funcionando

## Motivo
Permitir a personalização do Hyprland com suporte a wallpapers de vídeo usando o `mpvpaper`, integrando um atalho prático de clique com o botão direito no gerenciador de arquivos Dolphin e garantindo sincronia total com o gerador de temas Matugen. Além disso, sanar a instabilidade crítica em que a troca para papéis de parede animados esgotava a memória RAM ou quebrava a renderização de cores do Quickshell.

## O que foi feito
1. **Instalação das Dependências**: Adicionados os pacotes `mpvpaper` e `ffmpeg`.
2. **Integração com o Dolphin (KIO Service Menu)**: Criada a ação de contexto para arquivos de imagem e vídeo permitindo definir wallpapers diretamente pelo botão direito.
3. **Correção de Memória OOM (`Background.qml`)**: Bloqueada a chamada do `magick identify -format` sobre arquivos de vídeo (`.mp4`, `.mkv`, `.webm`, etc.), forçando o uso do thumbnail JPEG intermediário para cálculo de escala e zoom, impedindo que o ImageMagick tente carregar o vídeo inteiro na memória.
4. **Resiliência na Carga de Cores (`MaterialThemeLoader.qml`)**: Implementado um laço de retentativas (Retry Loop) com `try`/`catch` no carregamento do `colors.json`, permitindo que o Quickshell aguarde a finalização da escrita concorrente do Matugen sem abortar as amarrações (bindings) visuais.

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

2. Atualize o `Timer` e o `FileView` para retentar a leitura em caso de escrita em andamento:
```qml
    Timer {
        id: delayedFileRead
        interval: Config.options?.hacks?.arbitraryRaceConditionDelay ?? 100
        repeat: false
        running: false
        property int attempts: 0
        onTriggered: {
            attempts += 1;
            if (attempts <= 20) {
                themeFileView.reload();
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
            delayedFileRead.attempts = 0;
            delayedFileRead.start();
        }
        onLoadedChanged: {
            const fileContent = themeFileView.text();
            if (!root.applyColors(fileContent)) {
                if (delayedFileRead.attempts < 20) {
                    delayedFileRead.start();
                } else {
                    delayedFileRead.attempts = 0;
                }
            } else {
                delayedFileRead.stop();
                delayedFileRead.attempts = 0;
            }
        }
        onLoadFailed: root.resetFilePathNextTime();
    }
```

### 5. Sincronizar dotfiles e reiniciar o Quickshell

```bash
cd ~/dots-hyprland
./setup install-files -f --skip-backup --skip-allgreeting
qs -c ii
```

---

## Arquivos tocados
- `~/.local/share/kio/servicemenus/set-as-wallpaper.desktop`: Criado.
- `~/dots-hyprland/dots/.config/quickshell/ii/modules/ii/background/Background.qml`: Modificado.
- `~/dots-hyprland/dots/.config/quickshell/ii/services/MaterialThemeLoader.qml`: Modificado.

## Como verificar
1. Abra o Dolphin (`Super + E`), navegue até um arquivo de vídeo (`.mp4`, `.webm`, etc.) e clique com o botão direito.
2. Selecione **"Definir como Wallpaper"**.
3. O vídeo começará a rodar no plano de fundo através do `mpvpaper`.
4. As cores do tema (Matugen) serão atualizadas suavemente sem travamentos e as barras do Quickshell permanecerão estáveis e ativas.

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
git checkout origin/main -- dots/.config/quickshell/ii/services/MaterialThemeLoader.qml
./setup install-files -f --skip-backup --skip-allgreeting
qs -c ii
```
3. Desinstalar os pacotes:
```bash
sudo pacman -Rs mpvpaper
```
