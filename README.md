# CachyOS + Hyprland (End-4) — Hub de Otimizações & Tweaks

Repositório central de configurações, guias de otimização de performance e ajustes pessoais para o sistema baseado em **CachyOS**, compositor **Hyprland** e dotfiles **End-4** (*illogical-impulse*).

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
├── custom-power-controll.md      # Perfis de energia da CPU (P-Cores/E-Cores)
├── hyprland-for-gaming.md        # Ajustes de Hyprland para jogos competitivos
├── pacotes-extras-uteis.md       # Pacotes e utilitários instalados sob demanda
├── steam-arguments-overwatch.md  # Argumentos de inicialização da Steam/Overwatch
├── personal-tweeks/              # Registro de ajustes finos aplicados no sistema
│   ├── bkp/                      # Backups dos arquivos alterados
│   ├── lista.md                  # Índice de todos os tweaks com status
│   ├── updated-tweeks/           # Tweaks modificados/atualizados
│   └── tweek-details/            # Documentação detalhada e passo a passo de cada tweak
└── README.md                     # Este hub
```

---

## ⚡ Conteúdo Disponível

### 1. Guias de Performance
- [Hyprland para Gaming](hyprland-for-gaming.md): direct scanout, raw input, tearing e Game Mode.
- [Power Control](custom-power-controll.md): perfis de CPU com Turbo Boost e EPP híbrido.
- [Steam/Overwatch](steam-arguments-overwatch.md): argumentos e ajustes de inicialização.

### 2. [Personal Tweaks](personal-tweeks/lista.md)
Registro contínuo e reprodutível de todas as customizações feitas no sistema:
- **Áudio & CPU**: Bypass suave do EasyEffects e congelamento via `SIGSTOP` + reinício limpo do `hypridle` no Modo Jogo.
- **Shell Híbrido**: Zsh como frontend no Kitty com paridade visual ao Fish, mantendo o Fish como backend do sistema.
- **Login & Greeter**: Integração do `tuigreet` (greetd) com autologin e cores dinâmicas via Matugen.
- **Caffeine / Keep-Awake**: Inhibitor de suspensão com auto-cura via systemd timer.
- **Customizações de Terminal & UI**: Menu de contexto no Dolphin para trocar wallpaper, artes ASCII/ANSI aleatórias no Fastfetch, e mais.

### 3. `personal-tweeks/bkp/`
Diretório de backups dos arquivos alterados pelos tweaks.
