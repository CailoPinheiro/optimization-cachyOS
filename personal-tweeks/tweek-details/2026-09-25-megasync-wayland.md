# MEGAsync: correção definitiva via Wayland nativo (qt5-wayland)

**Data**: 2026-09-25 · **Status**: Aplicado (resolvido)

## Motivo
Diálogos do MEGAsync (ex.: "Adicionar sincronização") abriam **ocultos**
(`size=[1,639]`, `hidden:true`, `acceptsInput:false`, `xwayland:1`) sob
XWayland/Hyprland, em qualquer pacote (`megasync` fonte e `megasync-bin`
6.6.2 empacotado). É o bug upstream **meganz/MEGAsync#1150** (fechado como
"completed" em 2026-08-28): janela de login/Setup invisível `1×1/1×N hidden`
em Hyprland/Wayland. A correção da MEGA veio no **Wayland nativo**, não
XWayland.

## O que foi feito
Instalado o plugin de plataforma Qt5 Wayland:

```
yay -S qt5-wayland
```

Com `qt5-wayland` presente, o env global `QT_QPA_PLATFORM=wayland;xcb`
(já existente em `~/.config/hypr/hyprland/env.lua`) faz o megasync rodar em
**Wayland nativo** em vez de cair no `xcb`→XWayland. Nenhuma regra de janela
do Hyprland, override de `.desktop` ou `force_zero_scaling` é necessária.

## Como realizar (Passo a passo)

### 1. Instalar o plugin Qt5 Wayland

```bash
yay -S qt5-wayland
```

### 2. Verificar que o MEGAsync já usa Wayland nativo

```bash
pacman -Q qt5-wayland   # confirma instalação
pgrep -n megasync       # obter PID do processo

# Verificar plataforma ativa (substituir <PID> pelo valor obtido):
tr '\0' '\n' < /proc/<PID>/environ | grep QT_QPA
# Deve retornar: QT_QPA_PLATFORM=wayland;xcb  (e o megasync estará em Wayland)
```

### 3. Confirmar que nenhuma janela do MEGAsync usa XWayland

```bash
hyprctl -j clients | jq '.[] | select(.class=="MEGAsync") | {title, xwayland}'
# Esperado: xwayland: false  (se não aparecer, o megasync ainda não está aberto)
```

> O env `QT_QPA_PLATFORM=wayland;xcb` já estava configurado globalmente em
> `~/.config/hypr/hyprland/env.lua` pela dotfile do End-4. Com o `qt5-wayland`
> instalado, o Qt5 consegue carregar o plugin Wayland e o megasync migra
> automaticamente sem nenhuma config adicional.

## Arquivos tocados
- Nenhum config alterado. Apenas o pacote **`qt5-wayland`** instalado.

## Como verificar
```fish
pacman -Q qt5-wayland   # → 5.15.19+kde+r55-1.1
pgrep -n megasync       # pegar PID
tr '\0' '\n' < /proc/<PID>/environ | rg QT_QPA
```
Abrir megasync → cliques/janelas de login e sincronização aparecem
normalmente; `hyprctl -j clients` não lista nenhum `class=MEGAsync` com
`xwayland:1`.

## Como reverter
```
yay -R qt5-wayland
```
(voltaria a cair em xcb → XWayland → bug #1150 volta)

## Observações
- O antigo tweak `2026-09-24-megasync-x11.md` (forçar X11/xcb + regras) foi
  **revertido** e não é mais necessário.
- O bug meganz/MEGAsync#501 (segfault em Wayland nativo, antigo: 2020–2023),
  que motivava evitar `qt5-wayland`, não ocorre na 6.6.2 (suporte Wayland
  melhorado em 6.5.x). Caso apareça segfault, forçar xcb pontual:
  `QT_QPA_PLATFORM=xcb megasync`.