# Híbrido: Fish como backend, Zsh como frontend (Terminal Kitty)

**Data:** 2026-09-27  
**Status:** Aplicado — validado e em pleno funcionamento  

---

## 1. Motivo

O usuário desejava migrar seu shell principal do **Fish** para o **Zsh**, principalmente pela compatibilidade com a sintaxe POSIX / Bash (snippets da internet, scripts copiados, substituição de processos `<(...)`, operadores lógicos `&&`/`||`, etc.).

No entanto, o ecossistema de dotfiles da máquina (*illogical-impulse / End-4*) foi desenhado e está acoplado ao Fish:
- Scripts internos e botões em QML (QuickShell) executam chamadas explícitas com `fish -c` ou `fish -i -c`;
- Variáveis no `variables.lua` chamam `kitty -1 fish -c yazi/btop`;
- Trocar o shell do usuário no sistema via `chsh` quebraria o boot caso o `greetd` estivesse desativado e exigiria manutenção contínua após atualizações (`git pull`) do repositório de dotfiles.

A solução adotada foi o **Modo Híbrido**:
- **Backend / Sistema:** Mantém o `/bin/fish` como shell do usuário no `/etc/passwd`. Nenhuma chamada interna da interface quebra e nenhuma atualização das dotfiles é afetada.
- **Frontend / Terminal:** O emulador de terminal **Kitty** foi configurado para lançar o `zsh` por padrão.

---

## 2. O que foi feito

### A. Troca de Shell no Kitty
Editado `~/dots-hyprland/dots/.config/kitty/kitty.conf` para apontar `shell zsh` em vez de `shell fish`. Sincronizado para `~/.config/kitty/kitty.conf` através do `./setup install-files`.

### B. Construção do `~/.zshrc` com Paridade Visual 1:1 com o Fish
Para que a experiência visual e de uso ficasse idêntica ao Fish original, foram configurados:

1. **Remoção do Powerlevel10k conflitante:** Descartado o carregamento do `cachyos-config.zsh` que forçava o tema p10k e gerava conflito de *instant prompt* (`[WARNING] Console output during zsh initialization`).
2. **Paleta de Cores Dinâmica (Matugen / Quickshell):** Leitura de `~/.local/state/quickshell/user/generated/terminal/sequences.txt` mantida para injetar a paleta do wallpaper atual.
3. **Prompt Starship com Transiência:** O Starship foi integrado e configurado com a função `zle-line-finish` para encolher o prompt ao dar Enter (transient prompt igual ao `enable_transience` do Fish).
4. **Syntax Highlighting (Estilo Fish):** Plugin `/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh` ativado (verde para comando válido, vermelho para comando inexistente).
5. **Autossugestões (Estilo Fish):** Plugin `/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh` ativado com cor `fg=244` (cinza discreto baseado no histórico).
6. **Histórico e Busca Rápida:** Ativado `history-substring-search` nas setas Cima/Baixo e integração com `fzf` (`key-bindings.zsh` e `completion.zsh`).
7. **Completions inteligentes:** `compinit` com menu interativo e case-insensitive.
8. **Aliases portados do Fish:** `clear`, `celar`, `claer` (com sequência de escape ANSI do Kitty), `pamcan` -> `pacman`, `q` -> `qs -c ii`, `ls` -> `eza --icons=auto`, `ssh` -> `kitten ssh`, `update` -> `sudo pacman -Syu`.

---

## Como realizar (Passo a passo)

### 1. Instalar os plugins e ferramentas necessárias

```bash
sudo pacman -S zsh zsh-autosuggestions zsh-syntax-highlighting fzf starship eza
yay -S zsh-history-substring-search
```

### 2. Configurar o Kitty para abrir Zsh por padrão

Edite `~/dots-hyprland/dots/.config/kitty/kitty.conf` e altere a linha:
```
shell fish
```
para:
```
shell zsh
```

Sincronie com o setup:
```bash
cd ~/dots-hyprland
./setup install-files -f --skip-backup --skip-allgreeting
```

### 3. Criar o `~/.zshrc` completo

```bash
cat > ~/.zshrc << 'ZSHRC'
# Fastfetch com logo aleatório (suporta .txt, .ans, .png, .jpg, .webp)
LOGO_DIR="$HOME/.config/fastfetch/logos"
if [ -d "$LOGO_DIR" ] && [ -n "$(ls -A "$LOGO_DIR" 2>/dev/null)" ]; then
    RANDOM_LOGO=$(find "$LOGO_DIR" -type f \( -name "*.txt" -o -name "*.ans" -o -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" \) | shuf -n 1)
    case "${RANDOM_LOGO:e:l}" in
        png|jpg|jpeg|webp)
            fastfetch --logo "$RANDOM_LOGO" --logo-type kitty --logo-width 32 --logo-padding-right 2
            ;;
        txt|ans)
            fastfetch --logo "$RANDOM_LOGO" --logo-type file
            ;;
        *)
            fastfetch
            ;;
    esac
else
    fastfetch
fi

# 1. Cores dinâmicas do Quickshell / Matugen
if [[ -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt ]]; then
    cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
fi

# 2. Histórico
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_EXPIRE_DUPS_FIRST AUTO_CD INTERACTIVE_COMMENTS

# 3. Completions inteligentes (Tab)
autoload -Uz compinit
compinit -d ~/.cache/zsh/zcompdump 2>/dev/null || compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# 4. Prompt Starship com Transiência
eval "$(starship init zsh)"
if [[ -o zle ]] || [[ -t 1 ]]; then
    STARSHIP_ORIG_PROMPT="$PROMPT"
    STARSHIP_ORIG_RPROMPT="$RPROMPT"
    function starship-zle-line-finish() {
        PROMPT="$(starship module character)"
        RPROMPT=""
        zle reset-prompt 2>/dev/null
    }
    zle -N zle-line-finish starship-zle-line-finish 2>/dev/null
    function starship-restore-prompt() {
        PROMPT="$STARSHIP_ORIG_PROMPT"
        RPROMPT="$STARSHIP_ORIG_RPROMPT"
    }
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd starship-restore-prompt
fi

# 5. Plugins Fish-like
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"
    export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
if [[ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
fi
[[ -f /usr/share/doc/pkgfile/command-not-found.zsh ]] && source /usr/share/doc/pkgfile/command-not-found.zsh
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# 6. Aliases
alias clear='printf "\033[2J\033[3J\033[1;1H"'
alias celar='printf "\033[2J\033[3J\033[1;1H"'
alias claer='printf "\033[2J\033[3J\033[1;1H"'
alias pamcan=pacman
alias q='qs -c ii'
alias update='sudo pacman -Syu'
[[ "$TERM" != "linux" ]] && alias ls='eza --icons=auto'
[[ "$TERM" == "xterm-kitty" ]] && alias ssh='kitten ssh'
ZSHRC
```

### 4. Criar o diretório de cache do Zsh

```bash
mkdir -p ~/.cache/zsh
```

### 5. Verificar

Abra um novo terminal Kitty e confirme:
```bash
# Shell ativo no processo:
ps -p $$
# Deve retornar: zsh

# Compatibilidade POSIX:
cat <(echo "POSIX funcionando no Zsh")

# Fish continua como shell do sistema (não afetado):
cat /etc/passwd | grep cailoop
# Deve mostrar /bin/fish no final
```

---

## 3. Compatibilidade POSIX / Bash no Terminal

Com o Zsh ativo no Kitty, os seguintes padrões agora funcionam nativamente:

| Recurso / Sintaxe | No Fish (quebrava ❌) | No Zsh agora (funciona ✅) |
|---|---|---|
| **Process Substitution** | `cat <(echo "teste")` | `cat <(echo "teste")` |
| **Definição de variável inline** | `VAR=1 comando` | `VAR=1 comando` |
| **Export padrão com `=`** | `export FOO="bar"` | `export FOO="bar"` |
| **Operadores encadeados** | `cmd1 && cmd2 \|\| cmd3` | `cmd1 && cmd2 \|\| cmd3` |
| **Condicionais e Loops** | `if [[ -f arq ]]; then ...; fi` | `if [[ -f arq ]]; then ...; fi` |
| **Expansão de parâmetros** | `${VAR:-padrao}` | `${VAR:-padrao}` |
| **Subshells** | `(cd /tmp && ls)` | `(cd /tmp && ls)` |

---

## 4. Arquivos Tocados

- `~/dots-hyprland/dots/.config/kitty/kitty.conf` (alterado `shell zsh`)
- `~/.config/kitty/kitty.conf` (sincronizado via `./setup`)
- `~/.zshrc` (reescrito com a configuração limpa do Zsh)
- `~/.cache/zsh/` (criado diretório de cache de autocompletion)

### Backups de Segurança
Criados em `~/Projects/dotfile-migration/bkp-kitty-zsh/`:
- `kitty.conf.bak`
- `.zshrc.bak`

---

## 5. Como Verificar

1. Abrir um novo terminal Kitty (`Ctrl+Super+T` ou via launcher).
2. **Verificar shell ativo no processo:**
   ```sh
   ps -p $$
   # Retorna: zsh
   ```
3. **Verificar compatibilidade POSIX:**
   ```sh
   cat <(echo "POSIX funcionando no Zsh")
   ```
4. **Verificar recursos visuais:**
   - Digite `ls` -> fica **verde**.
   - Digite `comandoerrado` -> fica **vermelho**.
   - Digite uma letra -> veja a **sugestão cinza** do histórico.
   - Pressione Enter em um comando -> o prompt anterior encolhe (**transiência**).
   - Cores do Starship acompanham o wallpaper do **Matugen**.

---

## 6. Como Reverter

Caso queira voltar o Kitty para o Fish original:

```sh
cp ~/Projects/dotfile-migration/bkp-kitty-zsh/kitty.conf.bak ~/dots-hyprland/dots/.config/kitty/kitty.conf
cp ~/Projects/dotfile-migration/bkp-kitty-zsh/.zshrc.bak ~/.zshrc
cd ~/dots-hyprland && ./setup install-files -f --skip-backup --skip-allgreeting
```
