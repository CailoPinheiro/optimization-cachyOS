# Integração e Tematização Dinâmica do Matugen em Aplicativos (Xed, VS Code, MarkText, qBittorrent)

**Data**: 2026-09-30  
**Status**: Aplicado e funcionando  
**Autor**: Antigravity Assistant

---

## Motivo
O sistema utiliza o Matugen como motor de paletas Material You dinâmicas geradas a partir do papel de parede. No entanto, aplicativos externos como editores de texto (Xed), IDEs (VS Code), editores markdown (MarkText) e clientes torrent (qBittorrent) precisavam de integração direta para sincronizar automaticamente suas interfaces, fundos, abas, ícones e destaque de sintaxe às cores geradas pelo Matugen.

---

## O que foi feito

1. **Xed (GTK3 / GtkSourceView 3 & 4)**:
   - Criado o template de esquema de cores `~/.config/matugen/templates/gtksourceview/matugen.xml` mapeando tokens semânticos do Matugen (`surface`, `on_surface`, `primary`, `secondary`, `tertiary`, `outline`, etc.).
   - Registrados os destinos de saída `~/.local/share/gtksourceview-3.0/styles/matugen.xml` e `~/.local/share/gtksourceview-4/styles/matugen.xml` no `config.toml` do Matugen.
   - Definido o esquema padrão do editor no Xed como `matugen` via `gsettings`.

2. **VS Code (`Code`)**:
   - Criada a extensão local `~/.vscode/extensions/matugen-theme/` com manifesto `package.json` provendo o tema "Matugen Material You".
   - Criado o template `~/.config/matugen/templates/vscode/matugen.json` com mapeamento completo de interface (activity bar, side bar, tabs, title bar, terminal ANSI colors, breadcrumbs, status bar e destaque sintático).
   - O Matugen compila diretamente para `~/.vscode/extensions/matugen-theme/themes/matugen.json`. O VS Code recarrega as cores instantaneamente em tempo de execução.
   - Configurado `"workbench.colorTheme": "Matugen Material You"` no `~/.config/Code/User/settings.json`.

3. **MarkText**:
   - Criado o template `~/.config/matugen/templates/marktext/custom.css` com todas as variáveis de CSS e overrides do editor e interface do MarkText.
   - O Matugen compila o CSS para `~/.config/marktext/custom.css`.
   - Criado o script `~/.config/quickshell/ii/scripts/colors/marktext/marktext-set-color.sh` chamado automaticamente no `post_process` do `switchwall.sh` para injetar o CSS compilado no campo `customCss` do `~/.config/marktext/preferences.json`.

4. **qBittorrent (Qt6 com Ícones Material Design e QSS Dinâmico)**:
   - Criado um pacote completo de templates em `~/.config/matugen/templates/qbittorrent/`:
     - `icons/*.svg`: Conjunto de 34 ícones vetoriais no estilo Material Design/Fluent (adicionar, pausar, iniciar, deletar, configurações, status de upload/download, categorias, tags, etc.) com cores semânticas atreladas aos tokens do Matugen.
     - `stylesheet.qss`: Folha de estilo completa Qt6 eliminando bordas duras, estilizando barras de progresso, abas arredondadas e cabeçalhos.
     - `resources.qrc` e `config.json`: Mapeamento de recursos Qt.
   - Criado o compilador de tema `~/.config/quickshell/ii/scripts/colors/qbittorrent/build-theme.sh` integrado ao `switchwall.sh` que gera o binário `~/.config/qBittorrent/material-theme.qbtheme` via `/usr/lib/qt6/rcc`.
   - Configurado o `~/.config/qBittorrent/qBittorrent.conf` para carregar o `material-theme.qbtheme` e desabilitar `useSystemIconTheme` para exibir os novos ícones Material.

---

## Arquivos tocados

- `~/dots-hyprland/dots/.config/matugen/templates/gtksourceview/matugen.xml` (novo)
- `~/dots-hyprland/dots/.config/matugen/templates/vscode/matugen.json` (novo)
- `~/dots-hyprland/dots/.config/matugen/templates/marktext/custom.css` (novo)
- `~/dots-hyprland/dots/.config/matugen/templates/qbittorrent/stylesheet.qss` (novo)
- `~/dots-hyprland/dots/.config/matugen/templates/qbittorrent/config.json` (novo)
- `~/dots-hyprland/dots/.config/matugen/templates/qbittorrent/resources.qrc` (novo)
- `~/dots-hyprland/dots/.config/matugen/templates/qbittorrent/icons/*.svg` (34 novos ícones)
- `~/dots-hyprland/dots/.config/quickshell/ii/scripts/colors/marktext/marktext-set-color.sh` (novo)
- `~/dots-hyprland/dots/.config/quickshell/ii/scripts/colors/qbittorrent/build-theme.sh` (novo)
- `~/dots-hyprland/dots/.config/quickshell/ii/scripts/colors/switchwall.sh` (adicionadas chamadas de pós-processamento)
- `~/dots-hyprland/dots/.config/matugen/config.toml` (registrados templates `gtksourceview3`, `gtksourceview4`, `vscode`, `marktext`)
- `~/.vscode/extensions/matugen-theme/package.json` (novo)
- `~/.config/Code/User/settings.json` (tema ativo alterado para `Matugen Material You`)
- `~/.config/qBittorrent/qBittorrent.conf` (tema ativo alterado para `material-theme.qbtheme`)

---

## Como verificar

1. Trocar de wallpaper através do Quickshell, atalho `Ctrl+Super+T` ou via terminal:
   ```bash
   ~/.config/quickshell/ii/scripts/colors/switchwall.sh --image <caminho_da_imagem>
   ```
2. Verificar os arquivos gerados:
   ```bash
   ls -la ~/.local/share/gtksourceview-3.0/styles/matugen.xml
   ls -la ~/.vscode/extensions/matugen-theme/themes/matugen.json
   ls -la ~/.config/marktext/custom.css
   ls -la ~/.config/qBittorrent/material-theme.qbtheme
   ```
3. Abrir os aplicativos:
   - **Xed**: Abrir qualquer arquivo de código. A sintaxe e UI estarão harmonizadas com as cores do papel de parede.
   - **VS Code**: A janela inteira, abas, barra lateral, terminal e sintaxe usarão as cores ativas do Matugen.
   - **MarkText**: A área de edição e barras refletirão a paleta gerada pelo Matugen.
   - **qBittorrent**: A barra de ferramentas e lista de transferências exibirão os novos ícones limpos do Material Design/Fluent, com barras de progresso e seleção com a cor do papel de parede.

---

## Como reverter

1. No `~/dots-hyprland/dots/.config/matugen/config.toml`, remover as seções de templates adicionadas.
2. Sincronizar com `./setup install-files -f`.
3. No VS Code, alterar `"workbench.colorTheme"` no `settings.json` para o tema anterior.
4. No Xed, redefinir o tema padrão:
   ```bash
   gsettings set org.x.editor.preferences.editor scheme 'oblivion'
   ```
5. No MarkText, limpar a chave `"customCss"` no `~/.config/marktext/preferences.json`.
6. No qBittorrent, desmarcar a opção de tema personalizado em *Ferramentas > Opções > Comportamento*.
