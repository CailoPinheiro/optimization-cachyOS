# Pacotes e Recursos Extras Úteis

Este documento centraliza a lista de utilitários de terminal, bibliotecas e aplicativos extras instalados no sistema após o setup inicial. O objetivo é manter um registro contínuo dos pacotes que incrementam a experiência no CachyOS/Hyprland.

| Nome do Pacote | Descrição | Comando de Instalação (Origem) |
|---|---|---|
| **mpvpaper** | Ferramenta usada pela dotfile para renderizar vídeos animados no fundo da tela (Wayland). Ele usa o motor do `mpv` nativamente, garantindo aceleração de hardware (GPU) sem pesar a CPU do sistema. | `sudo pacman -S mpvpaper` (CachyOS/Extra) |
| **yt-dlp** | Utilitário poderoso de linha de comando para baixar vídeos e extrair áudio do YouTube e centenas de outros sites. Extremamente versátil para salvar mídia com qualidade máxima ou formatos específicos. | `sudo pacman -S yt-dlp` (Arch/Extra) |
| **ffmpeg** | Canivete suíço de áudio e vídeo de terminal. As dotfiles se apoiam fortemente nesse pacote (junto ao mpvpaper) para gerar thumbnails limpas dos wallpapers de forma automática e silenciosa. | `sudo pacman -S ffmpeg` (Arch/Extra) |

*Nota: Esta lista deve ser atualizada sempre que um pacote ou ferramenta CLI útil for instalada por demanda.*