# CachyOS + Hyprland (End-4) — Hub de Otimizações & Tweaks

Repositório central de configurações, guias de otimização de performance, ajustes pessoais e assets para o sistema baseado em **CachyOS**, compositor **Hyprland** e dotfiles **End-4** (*illogical-impulse*).

---

## 🖥️ Ambiente Base

| Componente | Especificação |
|---|---|
| **Sistema Operacional** | CachyOS (Arch-based) |
| **Compositor / WM** | Hyprland (Wayland) |
| **Dotfiles Base** | End-4 / illogical-impulse (`dots-hyprland`) |
| **Shell** | Fish (backend/scripts) + Zsh (terminal Kitty interativo) |
| **Theme Engine** | Matugen (Material You dinâmico) + Quickshell UI |

---

## 📁 Estrutura do Diretório

```
optimization-cachyos/
├── optimization-cachyOS.md      # Guia de otimização extrema de performance (CPU/GPU/Wayland)
├── personal-tweeks/              # Registro de ajustes finos aplicados no sistema
│   ├── lista.md                  # Índice de todos os tweaks com status
│   ├── pacotes-extras-uteis.md   # Pacotes e utilitários instalados sob demanda
│   └── tweek-details/            # Documentação detalhada e passo a passo de cada tweak
├── wallpapers/                   # Coleção de papéis de parede (estáticos e animados)
└── README.md                     # Este hub
```

---

## ⚡ Conteúdo Disponível

### 1. [Guia de Otimização de Performance](optimization-cachyOS.md)
Guia focado em extrair o máximo desempenho em jogos competitivos e uso diário no CachyOS:
- **Gerenciador de Energia (`power-control`)**: perfis de CPU com Turbo Boost desbloqueado (`game`, `performance`, `daily`, `battery`).
- **Desativação de conflitos**: remoção do `power-profiles-daemon` conflitante.
- **Wayland & Compositor**: ajustes de direct scanout, aceleração raw 1:1, tearing imediato e redução de latência no Hyprland.

### 2. [Personal Tweaks](personal-tweeks/lista.md)
Registro contínuo e reprodutível de todas as customizações feitas no sistema:
- **Áudio & CPU**: Bypass suave do EasyEffects e congelamento via `SIGSTOP`/`SIGCONT` no Modo Jogo.
- **Shell Híbrido**: Zsh como frontend no Kitty com paridade visual ao Fish, mantendo o Fish como backend do sistema.
- **Login & Greeter**: Integração do `tuigreet` (greetd) com autologin e cores dinâmicas via Matugen.
- **Caffeine / Keep-Awake**: Inhibitor de suspensão com auto-cura via systemd timer.
- **Customizações de Terminal & UI**: Menu de contexto no Dolphin para trocar wallpaper, artes ASCII/ANSI aleatórias no Fastfetch, e mais.

### 3. `wallpapers/`
Diretório reservado para armazenamento e organização de wallpapers (imagens estáticas e vídeos para uso com `mpvpaper`).
