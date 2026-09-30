# Fastfetch: Sorteio Aleatório de Logos (ASCII/ANSI e Imagens) no Zsh

**Data**: 2026-09-28 · **Status**: Aplicado e funcionando

## Motivo
Exibir automaticamente uma arte em texto (ASCII/ANSI art) ou imagem aleatória ao abrir o terminal Kitty com a shell Zsh, integrando o Fastfetch de maneira dinâmica e flexível.

## O que foi feito
1. **Diretório central de logos**: Criada a pasta `~/.config/fastfetch/logos/` para armazenar artes e imagens.
2. **Sorteador inteligente no Zsh**: Adicionado bloco de script no `~/.zshrc` que:
   - Sorteia aleatoriamente um arquivo da pasta `logos`.
   - Identifica a extensão do arquivo.
   - Aplica `--logo-type kitty` para imagens (`.png`, `.jpg`, `.jpeg`, `.webp`), renderizando gráficos de alta fidelidade no Kitty.
   - Aplica `--logo-type file` para artes de texto (`.txt`, `.ans`), preservando cores ANSI e formatação.
3. **Arquivo de configuração**: Gerado `~/.config/fastfetch/config.jsonc` para permitir controle granular sobre quais módulos de hardware/sistema são exibidos.

## Como realizar (Passo a passo)

### 1. Criar a pasta de logos e adicionar as artes/imagens:
```bash
mkdir -p ~/.config/fastfetch/logos
# Copie suas artes ASCII (.txt, .ans) ou imagens (.png, .jpg, .webp) para lá:
cp ~/Downloads/ascii\ arts/*.txt ~/.config/fastfetch/logos/
```

### 2. Gerar a configuração base do Fastfetch:
```bash
fastfetch --gen-config
```

### 3. Inserir o script de inicialização no início do `~/.zshrc`:
Adicione no topo do arquivo `~/.zshrc`:
```zsh
# Fastfetch com logo aleatório (suporta .txt, .ans, .png, .jpg, .webp)
LOGO_DIR="$HOME/.config/fastfetch/logos"
if [ -d "$LOGO_DIR" ] && [ -n "$(ls -A "$LOGO_DIR" 2>/dev/null)" ]; then
    RANDOM_LOGO=$(find "$LOGO_DIR" -type f \( -name "*.txt" -o -name "*.ans" -o -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" \) | shuf -n 1)

    case "${RANDOM_LOGO:e:l}" in
        png|jpg|jpeg|webp)
            # Renderização de imagem em alta definição nativa do Kitty
            fastfetch --logo "$RANDOM_LOGO" --logo-type kitty --logo-width 32 --logo-padding-right 2
            ;;
        txt|ans)
            # Renderização de ASCII / ANSI art em texto
            fastfetch --logo "$RANDOM_LOGO" --logo-type file
            ;;
        *)
            fastfetch
            ;;
    esac
else
    fastfetch
fi
```

## Arquivos tocados
- `~/.config/fastfetch/logos/`: Diretório criado com as artes (`luffy.txt`, `terraria.txt`, etc.).
- `~/.config/fastfetch/config.jsonc`: Arquivo de configuração de módulos do Fastfetch gerado.
- `~/.zshrc`: Adicionado bloco de inicialização com sorteio condicional do Fastfetch.

## Como verificar
1. Abra uma nova aba ou janela no terminal Kitty (ou rode `zsh`).
2. Uma arte aleatória de `~/.config/fastfetch/logos/` será exibida ao lado das informações do sistema.
3. Teste adicionar uma imagem PNG/JPG em `~/.config/fastfetch/logos/` para verificar a renderização gráfica.

## Como reverter
1. Remover o bloco do Fastfetch no início de `~/.zshrc`.
2. (Opcional) Apagar a pasta de configuração:
   ```bash
   rm -rf ~/.config/fastfetch
   ```

## Atualizacoes

- **2026-09-30** — `--logo-type kitty` foi trocado por `--logo-type kitty-direct`
  no `~/.zshrc`. Motivo: com `kitty` o Fastfetch cacheia a imagem renderizada
  por caminho de arquivo, e editar a imagem no lugar nao atualizava o logo (a
  foto antiga continuava aparecendo). Ver
  [2026-09-30-fastfetch-logo-cache-kitty-direct.md](2026-09-30-fastfetch-logo-cache-kitty-direct.md).
