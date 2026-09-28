# Menu de Contexto no Dolphin para Definir Wallpaper (Vídeo / Imagem)

**Data**: 2026-09-28 · **Status**: Aplicado e funcionando

## Motivo
Permitir que o usuário defina qualquer vídeo (`.mp4`, `.webm`, `.mkv`, etc.) ou imagem como wallpaper diretamente pelo gerenciador de arquivos Dolphin com um clique no botão direito, sem a necessidade de abrir o seletor visual com o atalho `Super + Ctrl + T`.

## O que foi feito
1. Criado um **Service Menu do KDE (KIO)** em `~/.local/share/kio/servicemenus/set-as-wallpaper.desktop`.
2. Mapeados os tipos MIME de vídeo (`video/mp4`, `video/webm`, `video/x-matroska`, etc.) e imagens (`image/png`, `image/jpeg`, etc.).
3. Ação configurada para chamar diretamente o script do End-4: `~/.config/quickshell/ii/scripts/colors/switchwall.sh --image %f`.
4. Atualizado o cache de serviços do KDE via `kbuildsycoca6`.

## Como realizar (Passo a passo)

### 1. Criar o diretório de Service Menus do KDE (se não existir):
```bash
mkdir -p ~/.local/share/kio/servicemenus
```

### 2. Criar o arquivo de ação de contexto:
Crie o arquivo `~/.local/share/kio/servicemenus/set-as-wallpaper.desktop` com o seguinte conteúdo:
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

### 3. Atualizar a base de dados do KDE:
```bash
kbuildsycoca6 --noincremental
```

## Arquivos tocados
- `~/.local/share/kio/servicemenus/set-as-wallpaper.desktop`: Criado.

## Como verificar
1. Abra o Dolphin (`Super + E` ou terminal `dolphin`).
2. Clique com o botão direito em qualquer arquivo de vídeo (`.mp4`, etc.) ou imagem.
3. No menu de contexto, clique em **"Definir como Wallpaper"**.
4. O wallpaper de vídeo (via `mpvpaper`) ou estático será aplicado instantaneamente e as cores do sistema/KDE/Quickshell serão recalculadas pelo `matugen`.

## Como reverter
Basta apagar o arquivo do menu de contexto:
```bash
rm -f ~/.local/share/kio/servicemenus/set-as-wallpaper.desktop
kbuildsycoca6 --noincremental
```
