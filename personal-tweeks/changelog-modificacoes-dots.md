# Changelog e Cruzamento: Modificações Locais em ~/dots-hyprland vs Personal Tweaks

Mapeamento completo de todas as alterações existentes na cópia local do repositório
`~/dots-hyprland` (arquivos modificados e arquivos não rastreados), suas motivações
técnicas, o tweak correspondente documentado e o comportamento esperado caso ocorra
uma atualização do upstream (`git pull origin main` / `./setup install-files`).

---

## 1. Modificações Rastreadas (git diff)

### 1.1 dots/.config/fish/config.fish
- **Alteração:** Adição do bloco condicional para carregar `~/.config/fish/auto-Hypr.fish` em sessões tty1 e inclusão de `~/.local/bin` no PATH (`fish_add_path ~/.local/bin`).
- **Motivação:** O Fish só carrega automaticamente `config.fish` e arquivos em `conf.d/`. O script de autologin do Hyprland ficava inerte na raiz de config sem esse source explícito. A adição de `~/.local/bin` garante que scripts do usuário (como `caffeine`) sejam localizados por comandos interativos do terminal.
- **Tweak correspondente:** [2026-09-26-autologin-hyprland-tty1.md](tweek-details/2026-09-26-autologin-hyprland-tty1.md) e [2026-09-30-caffeine-selfheal-e-lock-fix.md](tweek-details/2026-09-30-caffeine-selfheal-e-lock-fix.md).
- **Risco em git pull:** Conflito de merge se o upstream alterar `config.fish`. Sobrescrito se rodar `./setup install-files -f`.

### 1.2 dots/.config/hypr/hyprland/env.lua
- **Alteração:** Injeção de `~/.local/bin` na variável de ambiente `PATH` da sessão do Hyprland via `hl.env`.
- **Motivação:** Garante que atalhos e daemons iniciados diretamente pelo compositor encontrem utilitários em `~/.local/bin` (ex.: `caffeine`, `hypr-gamemode-toggle`, `lock-session`).
- **Tweak correspondente:** [2026-09-30-caffeine-selfheal-e-lock-fix.md](tweek-details/2026-09-30-caffeine-selfheal-e-lock-fix.md).
- **Risco em git pull:** Conflito direto no `env.lua`.

### 1.3 dots/.config/hypr/hyprland/execs.lua
- **Alteração:** Comentada a inicialização automática do EasyEffects (`hl.exec_cmd("easyeffects --hide-window --service-mode")`).
- **Motivação:** Evita o consumo de recursos e processamento de áudio desnecessário na inicialização para quem não usa efeitos ativos no microfone/fone.
- **Tweak correspondente:** Ajuste de inicialização limpa do sistema.
- **Risco em git pull:** Conflito de merge se o upstream mexer nas linhas vizinhas.

### 1.4 dots/.config/hypr/hyprland/general.lua
- **Alteração:** Linha do `render_power` ajustada de 10 para 4 (`render_power = 4`).
- **Motivação:** O Hyprland 0.57+ valida rigorosamente o intervalo `1..4` para `decoration:shadow:render_power`. O valor 10 usado pelo End-4 gera erro de sintaxe vermelho na inicialização e descarta a renderização da sombra.
- **Tweak correspondente:** [2026-10-30-hyprland-shadow-render-power-fix.md](tweek-details/2026-10-30-hyprland-shadow-render-power-fix.md).
- **Risco em git pull:** O upstream ainda usa 10. Um `git pull` trará o valor 10 de volta até que o upstream aprove o PR de correção.

### 1.5 dots/.config/kitty/kitty.conf
- **Alteração:** Troca da shell padrão de `fish` para `zsh` (`shell zsh`) e ajuste suave do rastro do cursor (`cursor_trail_decay 0.1 0.35`).
- **Motivação:** Integração do modelo híbrido de terminal: Fish roda como backend do sistema/scripts, mas o Kitty abre o Zsh interativo para o usuário.
- **Tweak correspondente:** [2026-09-27-kitty-zsh-hibrido.md](tweek-details/2026-09-27-kitty-zsh-hibrido.md).
- **Risco em git pull:** Conflito simples de linha em `kitty.conf`.

### 1.6 dots/.config/matugen/config.toml
- **Alteração:** Inclusão de seções de template para `tuigreet`, `gtksourceview3`, `gtksourceview4` e `marktext`.
- **Motivação:** Permite que a troca de wallpaper via Matugen regenere dinamicamente as cores do tema da tela de login (tuigreet), do editor MarkText e de apps baseados em GtkSourceView (como Xed).
- **Tweak correspondente:** [2026-09-26-greeter-tuigreet.md](tweek-details/2026-09-26-greeter-tuigreet.md) e [2026-09-30-matugen-apps-theming-integration.md](tweek-details/2026-09-30-matugen-apps-theming-integration.md).
- **Risco em git pull:** Conflito se o upstream adicionar novos templates nativos ao final do arquivo.

### 1.7 dots/.config/quickshell/ii/modules/common/models/quickToggles/GameModeToggle.qml
- **Alteração:** Substituição do bloco nativo de desativação parcial pelo disparo do script desacoplado `Quickshell.execDetached(["/home/cailoop/.local/bin/hypr-gamemode-toggle"])`.
- **Motivação:** O toggle nativo apenas alterava algumas variáveis cosméticas do Hyprland. O script personalizado desativa animações, blur, sombras, ativa tearing e gerencia o congelamento de timers do `hypridle` e `caffeine`.
- **Tweak correspondente:** [2026-09-28-gamemode-quickshell-integration.md](tweek-details/2026-09-28-gamemode-quickshell-integration.md).
- **Risco em git pull:** Conflito inevitável se o componente QML for atualizado pelo End-4.

### 1.8 dots/.config/quickshell/ii/modules/common/models/quickToggles/IdleInhibitorToggle.qml
### 1.9 dots/.config/quickshell/ii/modules/ii/sidebarRight/quickToggles/classicStyle/IdleInhibitor.qml
- **Alteração:** Substituição da chamada `Idle.inhibit` (protocolo wayland isolado) pelo controle real do processo `caffeine` via `Quickshell.Process` executando `~/.local/bin/caffeine toggle` e `state`.
- **Motivação:** `Idle.inhibit` do Quickshell não impedia o `hypridle` de disparar `lock-session` e desligar a tela. O `caffeine` envia `SIGSTOP` ao `hypridle` e assume o lock de logind.
- **Tweak correspondente:** [2026-09-30-caffeine-selfheal-e-lock-fix.md](tweek-details/2026-09-30-caffeine-selfheal-e-lock-fix.md).
- **Risco em git pull:** Conflito de merge em ambos os arquivos QML.

### 1.10 dots/.config/quickshell/ii/modules/ii/background/Background.qml
- **Alteração:** Verificação de extensão de vídeo (`.mp4`, `.mkv`, etc.) para ler as dimensões da thumbnail e validação de segurança para evitar valores NaN ou nulos na resolução do wallpaper.
- **Motivação:** Impede que o Quickshell quebre ao receber um vídeo como wallpaper em vez de imagem estática.
- **Tweak correspondente:** [2026-09-30-animated-wallpaper-mpvpaper-shell-fix.md](tweek-details/2026-09-30-animated-wallpaper-mpvpaper-shell-fix.md).
- **Risco em git pull:** Conflito de merge se o componente Background sofrer alterações upstream.

### 1.11 dots/.config/quickshell/ii/modules/ii/background/widgets/AbstractBackgroundWidget.qml
- **Alteração:** Proteção com `try/catch` no `JSON.parse` que consome o output de `leastBusyRegionOutputCollector`.
- **Motivação:** Evita crashes em cascata na interface quando a análise de região do wallpaper retorna texto corrompido ou trace de erro do Python.
- **Tweak correspondente:** [2026-09-30-animated-wallpaper-mpvpaper-shell-fix.md](tweek-details/2026-09-30-animated-wallpaper-mpvpaper-shell-fix.md).
- **Risco em git pull:** Conflito de merge se a função for reestruturada.

### 1.12 dots/.config/quickshell/ii/scripts/colors/switchwall.sh
- **Alteração:**
  1. Adição dos pós-processadores de cores para MarkText e qBittorrent em `post_process`.
  2. Ajuste de parâmetros de reprodução do mpvpaper (`loop-file=inf`, `hwdec=auto-safe`, execução via `nohup` e `disown`).
  3. Escrita atômica do `config.json` via `jq` e arquivo temporário (`.tmp` + `mv`) ao invés de atualizar caminhos em chamadas separadas.
- **Motivação:** Corrige desaparecimento de widgets e quebra de interface ao trocar wallpapers pesados/vídeos, além de propagar cores dinâmicas para apps extras.
- **Tweak correspondente:** [2026-09-30-animated-wallpaper-mpvpaper-shell-fix.md](tweek-details/2026-09-30-animated-wallpaper-mpvpaper-shell-fix.md) e [2026-09-30-matugen-apps-theming-integration.md](tweek-details/2026-09-30-matugen-apps-theming-integration.md).
- **Risco em git pull:** Alto risco de conflito por ser um script frequentemente mexido pelo End-4.

### 1.13 dots/.config/quickshell/ii/services/MaterialThemeLoader.qml
- **Alteração:** Proteção com `try/catch` no `JSON.parse`, validação de conteúdo vazio e mecanismo de timer com tentativas de recarregamento (`attempts < 10`) para evitar condições de corrida na leitura do arquivo de cores gerado pelo Matugen.
- **Motivação:** Elimina perda temporária do tema quando o Quickshell lia o arquivo no exato milissegundo em que o Matugen ainda estava gravando o payload.
- **Tweak correspondente:** [2026-09-30-animated-wallpaper-mpvpaper-shell-fix.md](tweek-details/2026-09-30-animated-wallpaper-mpvpaper-shell-fix.md).
- **Risco em git pull:** Conflito de merge.

---

## 2. Arquivos Não Rastreados (untracked)

Estes arquivos foram adicionados exclusivamente pelo usuário para suporte a apps terceiros. Eles **não** existem no repositório oficial do End-4. Um `git pull` não os apagará, mas um `git clean -fd` apagaria tudo se executado sem cuidado.

1. **Templates do Matugen:**
   - `dots/.config/matugen/templates/gtksourceview/matugen.xml`
   - `dots/.config/matugen/templates/marktext/custom.css`
   - `dots/.config/matugen/templates/tuigreet/config.toml`
   - `dots/.config/matugen/templates/qbittorrent/*` (config.json, stylesheet.qss, resources.qrc e ícones SVG temáticos)
   - **Tweak correspondente:** [2026-09-26-greeter-tuigreet.md](tweek-details/2026-09-26-greeter-tuigreet.md) e [2026-09-30-matugen-apps-theming-integration.md](tweek-details/2026-09-30-matugen-apps-theming-integration.md).

2. **Scripts de Cores e Automação do Quickshell:**
   - `dots/.config/quickshell/ii/scripts/colors/marktext/marktext-set-color.sh`
   - `dots/.config/quickshell/ii/scripts/colors/qbittorrent/build-theme.sh`
   - **Tweak correspondente:** [2026-09-30-matugen-apps-theming-integration.md](tweek-details/2026-09-30-matugen-apps-theming-integration.md).

---

## 3. Resumo de Preservação para Reaplicação

Para que o usuário possa dizer "ei aplique as tweeks novamente" após atualizar o repositório oficial, as alterações acima se dividem em:

1. **Patches diretos no core do End-4 (que demandam reaplicação pós-update):**
   - `render_power = 4` em `hyprland/general.lua`
   - Escrita atômica e mpvpaper no `switchwall.sh`
   - Proteções de parsing e timers em `MaterialThemeLoader.qml`, `Background.qml`, `AbstractBackgroundWidget.qml`
   - Integração do `caffeine` e `hypr-gamemode-toggle` nos botões do Quickshell
   - Configurações do `config.fish` e `kitty.conf`
2. **Arquivos independentes (que sobrevivem fora do core):**
   - Todos os binários em `~/.local/bin/` (`caffeine`, `hypr-gamemode-toggle`, `lock-session`, etc.)
   - Todas as units do systemd (`caffeine-inhibitor.service`, `caffeine-watch.service`)
   - Todos os arquivos sob `~/.config/hypr/custom/`
   - Templates adicionais em `matugen/templates/`
