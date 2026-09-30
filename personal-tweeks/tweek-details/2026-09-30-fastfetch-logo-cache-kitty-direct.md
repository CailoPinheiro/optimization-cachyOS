# Fastfetch: Imagem do Logo "Atualizada" mas continua Velha (cache) — Troca por `kitty-direct`

**Data**: 2026-09-30 · **Status**: Aplicado

Continuacao/correcao de
[2026-09-28-fastfetch-random-logo.md](2026-09-28-fastfetch-random-logo.md).

## Motivo

Editar uma imagem em `~/.config/fastfetch/logos/` nao mudava nada no terminal:
a foto antiga continuava aparecendo mesmo depois de salvar a edicao.

Causa: o bloco do `~/.zshrc` usava `--logo-type kitty`. Nesse modo o Fastfetch
**pre-renderiza** a imagem e grava o payload ja pronto em disco:

```
~/.cache/fastfetch/images/home/cailoop/.config/fastfetch/logos/<arquivo>/288*0/kittyc
```

A chave do cache e so **caminho do arquivo + tamanho renderizado** — nao tem
mtime nem hash do conteudo. Editar a imagem no lugar nao invalida a entrada, e o
Fastfetch reusa o `kittyc` antigo indefinidamente.

Como o cache so e invalidado por caminho, o unico contorno era salvar com um
nome novo (ex.: `gear5.png 1.png`), que cria outra chave. Foi exatamente o que
fez o cache crescer com 3,7 MB de entradas de arquivos que **nao existem mais**
(`frieren.png`, `ktn.png`, `gato-joinha.png`, `gear5.png`, `arquivo colado.png`).

Limitacao conhecida do upstream: issues
[#1174](https://github.com/fastfetch-cli/fastfetch/issues/1174) e
[#1338](https://github.com/fastfetch-cli/fastfetch/issues/1338). O maintainer:
*"If you don't use `type: kitty-direct`, the images will be cached. You have to
use `recache: true`"*. Recomendacao upstream tambem e `kitty-direct` por ser
mais rapido e ter menos problemas.

## O que foi feito

1. `~/.zshrc` (linhas 8-9): `--logo-type kitty` -> `--logo-type kitty-direct`.
   Nesse modo o proprio Kitty le o arquivo do disco, nao existe cache, e a
   imagem atual sempre aparece. `--logo-width 32 --logo-padding-right 2`
   foram mantidos.
2. Cache antigo removido: `rm -rf ~/.cache/fastfetch` (3,7 MB de entradas
   obsoletas).
3. Imagem renomeada: `gear5.png 1.png` -> `gear5.png` (tira o espaco do caminho,
   que ia dentro do protocolo grafico do Kitty, e evita confusao com a entrada
   velha chamada `gear5.png`).

Backup do arquivo antes da edicao: `~/.zshrc.bak-2026-09-30`.

## Como realizar (Passo a passo)

### 1. Trocar o tipo de logo no `~/.zshrc`
```zsh
# antes
fastfetch --logo "$RANDOM_LOGO" --logo-type kitty --logo-width 32 --logo-padding-right 2
# depois
fastfetch --logo "$RANDOM_LOGO" --logo-type kitty-direct --logo-width 32 --logo-padding-right 2
```

### 2. Apagar o cache de imagem do Fastfetch
```bash
rm -rf ~/.cache/fastfetch
```

### 3. (Opcional, recomendado) Renomear arquivos de logo sem espaco
```bash
mv ~/.config/fastfetch/logos/'gear5.png 1.png' ~/.config/fastfetch/logos/gear5.png
```

## Arquivos tocados

- `~/.zshrc`: bloco do Fastfetch (linhas 8-9) — tipo do logo de imagem.
- `~/.config/fastfetch/logos/gear5.png`: imagem renomeada (era `gear5.png 1.png`).
- `~/.cache/fastfetch/`: removido (cache, nao config).
- `~/.zshrc.bak-2026-09-30`: backup do `~/.zshrc` anterior a edicao.

## Como verificar

1. Abra um terminal novo no Kitty (`Ctrl+Shift+T`).
2. Edite qualquer imagem de `~/.config/fastfetch/logos/` e abra outro terminal: a
   versao nova tem que aparecer, sem rodar nenhum comando extra.
3. `find ~/.cache/fastfetch -newermt '-3 minutes'` deve vir **vazio** — prova de
   que nada esta sendo cacheado.

## Como reverter

Voltar para `--logo-type kitty` (imagem volta a ser pre-renderizada/cacheada) e,
se o cache atrapalhar de novo:

```bash
fastfetch --logo-recache true --logo "$HOME/.config/fastfetch/logos/gear5.png" --logo-type kitty --logo-width 32
# ou, para limpar tudo:
rm -rf ~/.cache/fastfetch
```

Restore completo do `~/.zshrc`:
```bash
cp ~/.zshrc.bak-2026-09-30 ~/.zshrc
```

## Observacoes

- `~/.config/fastfetch/config.jsonc` **nao** tem bloco `logo`: o logo vem so
  pelas flags do `~/.zshrc`, porque o sorteio aleatorio (`shuf -n 1`) precisa
  ser dinamico. Nao adianta mover o logo para o JSONC sem perder a aleatoriedade.
- Se um dia `--logo-type kitty` for necessario de volta por causa de
  `kitty-direct`, o parametro `--logo-recache true` e a saida oficial.
