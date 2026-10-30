# Personal Tweaks — Guia Arquitetural e Diretorio de Arquivos

Este diretorio e o repositorio central de documentacao, rastreamento, manutencao
e reproducibilidade de todas as otimizacoes, correcoes e recursos personalizados
aplicados no sistema (CachyOS + Hyprland + Quickshell / End-4).

---

## 1. Principio da Finalidade Unica

Cada subsistema, ajuste ou recurso modificado possui **um unico arquivo correspondente**.
- Se um ajuste for alterado, melhorado ou corrigido, o arquivo original deve ser atualizado
  diretamente, registrando a evolucao historica no proprio documento.
- Nao devem ser criados arquivos redundantes ou duplicados para a mesma finalidade.
- Todo tweak criado ou atualizado deve obrigatoriamente atualizar o indice `lista.md`
  e registrar regras criticas na secao "Decisoes que nao devem ser revertidas sem o usuario pedir".

---

## 2. Estrutura Atual de Pastas e Arquivos

```
personal-tweeks/
├── README.md                          # Este guia explicativo do diretorio
├── lista.md                           # Indice central tabular e registro de decisoes irreversiveis
├── changelog-modificacoes-dots.md     # Cruzamento das modificacoes locais em ~/dots-hyprland vs tweaks
├── tweek-details/                     # Documentacao detalhada de cada tweak individual consolidado
├── updated-tweeks/                    # Tweaks mantidos ou modificados por instaladores/scripts
├── provisory/                         # Categoria de correcoes temporarias (aguardando upstream merge)
└── bkp/                               # Backups de arquivos de configuracao antes da aplicacao de tweaks
```

### Funcao de cada item

- **`lista.md`**: Ponto de entrada rapido. Contem a tabela com data, nome, status e link para a documentacao de cada tweak, alem do rol de diretrizes tecnicas que nao podem ser revertidas por engano.
- **`changelog-modificacoes-dots.md`**: Mapeamento detalhado de todos os arquivos modificados e nao rastreados no clone local `~/dots-hyprland`, explicando o motivo tecnico da mudanca e sua correlacao com os tweaks documentados.
- **`tweek-details/`**: Armazena os documentos definitivos de tweaks de sistema, interface, terminal e jogos.
- **`updated-tweeks/`**: Reservado para tweaks gerados ou gerenciados dinamicamente por scripts de instalacao (ex.: instalador do `power-control`).
- **`provisory/`**: Nova categoria criada para isolar contornos (workarounds) e correcoes provisorias aplicadas para mitigar bugs de transicao do upstream (ex.: Hyprland 0.57+), mantendo clara a condicao de descontinuacao quando o upstream for atualizado.
- **`bkp/`**: Copias de seguranca com timestamp dos arquivos de configuracao antes de qualquer edicao.

---

## 3. Proposta de Categorizacao / Taxonomia

Para organizar o crescimento contínuo da pasta e facilitar a localizacao por dominio tecnico, propoe-se a seguinte taxonomia de categorias:

| Categoria | Proposito | Exemplos de Tweaks Mapeados |
|---|---|---|
| `system/` | Modificacoes de boot, login, energia, servicos systemd e baixo nivel | `autologin-hyprland-tty1`, `power-control-hibrido`, `caffeine-selfheal-e-lock-fix`, `greeter-tuigreet` |
| `gaming/` | Otimizacoes de latencia, game mode, prefixos Wine/Proton e jogos | `overwatch-wayland-tweaks`, `gamemode-quickshell-integration`, `terraria-performance-fix`, `minecraft-dungeons-ii-gamingservices-reg` |
| `ui-shell/` | Quickshell, temas dinamicos Matugen, gerenciamento de papel de parede e integracao Dolphin | `animated-wallpaper-mpvpaper-shell-fix`, `matugen-apps-theming-integration`, `dolphin-wallpaper-context-menu` |
| `terminal/` | Shells interativas (Fish backend + Zsh frontend), emuladores e estetica CLI | `kitty-zsh-hibrido`, `fastfetch-random-logo` |
| `input/` | Mapeamento de teclado, troca de layouts, keybinds e lock de tela | `teclado-us-br`, `super-l-quickshell-lock` |
| `apps/` | Compatibilidade e ajustes especificos para softwares terceiros | `megasync-wayland` |
| `provisory/` | Correcoes e contornos temporarios aguardando resolucao no upstream | `hyprland-super-chording-fix`, `hyprland-shadow-render-power-fix` |

---

## 4. Mapeamento Completo dos Tweaks Existentes

Abaixo esta a classificacao de todos os tweaks registrados atualmente de acordo com as categorias propostas:

### Categoria: Provisorio (`provisory/`)
- `2026-10-30-hyprland-super-chording-fix.md`: Listener de interrupcao de atalhos com Super no Hyprland 0.57 (aguarda PRs #3724/#3725/#3726 no End-4).
- `2026-10-30-hyprland-shadow-render-power-fix.md`: Correcao de validacao de `render_power = 4` no `general.lua` do Hyprland 0.57 (candidato a mover de `tweek-details/` para `provisory/`).

### Categoria: Sistema (`system/`)
- `2026-09-26-autologin-hyprland-tty1.md`: Autologin via agetty no tty1 com inicializacao direta do Hyprland.
- `2026-09-26-greeter-tuigreet.md`: Configuracao do greeter tuigreet via greetd (historico/legado).
- `2026-09-28-power-control-hibrido.md`: Otimizacoes de gerenciamento termico e CPU para arquiteturas hibridas (P-cores / E-cores).
- `2026-09-30-caffeine-selfheal-e-lock-fix.md`: Inhibitor de idle/sleep Caffeine com supervisao systemd (self-heal).

### Categoria: Jogos (`gaming/`)
- `2026-09-27-overwatch-wayland-tweaks.md`: Otimizacao de tearing imediato e foco de janela no Overwatch sob Wayland.
- `2026-09-28-gamemode-quickshell-integration.md`: Integracao do Game Mode com Quickshell, desativando efeitos e gerenciando hypridle.
- `2026-09-28-terraria-performance-fix.md`: Ajustes de Turbo Boost e monitoramento MangoHud para o Terraria.
- `2026-10-05-minecraft-dungeons-ii-gamingservices-reg.md`: Chave de registro local para o prefixo Wine/Proton do Minecraft Dungeons II.

### Categoria: Interface e Shell (`ui-shell/`)
- `2026-09-28-dolphin-wallpaper-context-menu.md`: Acao de contexto no Dolphin para definir wallpapers estaticos ou animados.
- `2026-09-30-animated-wallpaper-mpvpaper-shell-fix.md`: Suporte a videos via mpvpaper e escrita atomica do config.json do Quickshell.
- `2026-09-30-matugen-apps-theming-integration.md`: Geracao e aplicacao de paletas dinamicas em apps GtkSourceView, MarkText e qBittorrent.

### Categoria: Terminal (`terminal/`)
- `2026-09-27-kitty-zsh-hibrido.md`: Configuracao hibrida do terminal Kitty com Zsh interativo mantendo o Fish no sistema.
- `2026-09-28-fastfetch-random-logo.md`: Script para selecao aleatoria de artes e logos no Fastfetch.

### Categoria: Entrada e Atalhos (`input/`)
- `2026-09-24-teclado-us-br.md`: Alternancia entre layouts de teclado US Internacional e ABNT-2.
- `2026-10-25-super-l-quickshell-lock.md`: Vinculacao do atalho Super + L ao lock do Quickshell com fallback para hyprlock.

### Categoria: Aplicativos (`apps/`)
- `2026-09-25-megasync-wayland.md`: Forcamento do backend Wayland nativo para o cliente MEGAsync.

---

## 5. Estrutura Padrao para Novos Tweaks

Cada novo arquivo de documentacao de tweak deve respeitar a nomenclatura `YYYY-MM-DD-slug.md` e conter as seguintes secoes:

1. **Titulo**: `YYYY-MM-DD - Nome descritivo e objetivo`
2. **Categoria**: Indicacao da categoria correspondente
3. **Motivo**: Problema identificado, contexto e por que a intervencao foi necessaria
4. **O que foi feito**: Resumo tecnico da solucao implementada
5. **Passo a passo (reproducao / re-aplicacao)**: Codigo exato, comandos ou configuracoes necessarias para replicar o tweak do zero
6. **Arquivos tocados**: Lista completa e caminhos absolutos dos arquivos modificados ou criados
7. **Como verificar**: Procedimentos praticos para validar o funcionamento correto
8. **Como reverter**: Comandos ou instrucoes passo a passo para desfazer a alteracao com seguranca
9. **Condicao de descontinuacao** *(obrigatorio apenas para `provisory/`)*: Gatilho ou versao upstream que torna o tweak obsoleto
