# 2026-10-30 - Hyprland: fix de erro de config (shadow render_power)

## Motivo

O Hyprland 0.57.0 (build 2026-10-28) passou a validar `decoration:shadow:render_power`
com range 1..4 como ERRO (hyprlang). O illogical-impulse (end-4) usa
`render_power = 10` no `hyprland/general.lua`, que era tolerado em versoes
anteriores e agora e rejeitado. O upstream (end-4/dots-hyprland e o fork
sh1zicus/dots-hyprland, que e o origin) ainda NAO corrigiu o valor (checado em
2026-10-30).

Sintomas:
- Popup "Your config has errors" na tela:
  `/home/cailoop/.config/hypr/hyprland/general.lua:39: error setting
  'decoration.shadow.render_power': value 10 is more than the maximum of 4`
- `hyprctl configerrors` listando o erro;
- A opcao era descartada: `hyprctl getoption decoration:shadow:render_power`
  retornava `int: 3, set: false` (default, nao setada).

## O que foi feito

Parche local NO CLONE da dotfile (nao commitado — regra: nunca commitar no
~/dots-hyprland): `render_power = 10` -> `render_power = 4` (o maximo valido,
sombra mais suave possivel, mais proximo da intencao original do upstream).
Depois, cp do arquivo do repo para a config ativa (equivalente ao que o
`./setup install-files` faz para este arquivo) + reload.

## Passo a passo (reproducao/re-aplicacao)

```bash
# 1. parche no clone local
sed -i 's/render_power = 10/render_power = 4/' \
  ~/dots-hyprland/dots/.config/hypr/hyprland/general.lua

# 2. propagar para a config ativa
cp ~/dots-hyprland/dots/.config/hypr/hyprland/general.lua \
  ~/.config/hypr/hyprland/general.lua

# 3. validar e recarregar
hyprctl configerrors   # deve vir vazio
hyprctl reload         # deve retornar "ok"
```

## Arquivos tocados

- `~/dots-hyprland/dots/.config/hypr/hyprland/general.lua` (linha 98, mudanca
  NAO committada)
- `~/.config/hypr/hyprland/general.lua` (copia sincronizada)
- Backup: `bkp/general.lua.repo.2026-10-30.bak` e
  `bkp/general.lua.active.2026-10-30.bak`

## Como verificar

- `hyprctl configerrors` -> vazio (antes listava o erro da linha 39/98)
- `hyprctl getoption decoration:shadow:render_power` -> `int: 4, set: true`
- `hyprctl reload` -> "ok"
- Visual: sombras das janelas continuam presentes (levemente mais suaves que o
  default 3 que estava em efeito por causa do erro).

## Como reverter

```bash
sed -i 's/render_power = 4/render_power = 10/' \
  ~/dots-hyprland/dots/.config/hypr/hyprland/general.lua
cp ~/dots-hyprland/dots/.config/hypr/hyprland/general.lua \
  ~/.config/hypr/hyprland/general.lua
hyprctl reload
```
(Obs: reverter re-expoe o erro do popup no Hyprland >= 0.57.)

## Risco / observacoes importantes

- A mudanca no `~/dots-hyprland` nao e commitada (regra do AGENTS: nunca
  commitar na dotcore). Um futuro `git pull` que toque nesse arquivo vai
  RECUSAR o merge ("Your local changes would be overwritten") em vez de
  apagar o parche. Fluxo: `git stash && git pull && git stash pop` (ou
  refazer o `sed` de 1 linha acima).
- `./setup install-files` NAO apaga o parche, pois ele copia DO clone local
  (que esta parcheado) para `~/.config`. Por isso o fix precisa estar no repo,
  nunca so no `~/.config` (rsync com --delete reverte).
- Override em `~/.config/hypr/custom/general.lua` NAO elimina o popup: o erro e
  registrado durante o parse do `hyprland/general.lua` ANTES do custom ser
  carregado (custom carrega por ultimo; overwrite parcial tipo `blur.size`
  funciona apenas para valores validos).
- `hyprctl configvalid` NAO existe no 0.57 ("unknown request"); use
  `hyprctl configerrors`.
- Candidato a report no upstream (end-4/dots-hyprland e/ou fork sh1zicus):
  fix de uma linha, evita o erro para todos os usuarios em Hyprland 0.57+.
