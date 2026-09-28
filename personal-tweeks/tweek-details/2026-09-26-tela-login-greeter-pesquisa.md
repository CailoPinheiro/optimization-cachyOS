# Tela de login (greeter) — pesquisa e安装 de opções

**Data:** 2026-09-26
**Status:** Documento de referência criado. **Nenhuma configuração foi aplicada** —
ainda não há greeter instalado, o login no tty1 continua como estava.

## Motivo

O usuário queria uma **UI de login** no lugar do prompt de texto do tty1 (o
`agetty` com `cailoop login:`), e queria "usar o que vem no End-4".

## Diagnóstico: o End-4 não tem greeter

Confirmado por três vias:

1. `grep -ri "greeter" ~/dots-hyprland` → **0 resultados** (nenhum arquivo,
   script, QML, doc ou dependência).
2. `sdata/subcmd-install/3.files-legacy.sh` → nenhum DM/greeter é instalado.
   A única menção a DM no repo inteiro é um *aviso* do instalador
   (`3.files.sh:241`) e o tema `sddm-breeze`, que existe **só no Fedora**.
3. Wiki oficial (`ii.clsty.link/en/ii-qs/01setup/`) → *"To launch Hyprland, you
   can use a DM (Display Manager) or just tty."*

O repo é um clone limpo de `sh1zicus/dots-hyprland` (fork do End-4), sem commit
local nenhum (`.git/logs/HEAD` tem 1 entrada: `clone:`).

**Conclusão:** o End-4 é compatível com DM, mas não **fornece** um. Qualquer
greeter é adição externa.

## O que foi feito

Criado o documento de referência com 10 opções da comunidade, em
`~/Projects/formatation/telas-de-login-greeters.md`:

- Tabela com nome, tipo, visual, peso instalado, repositório de origem e link
  GitHub de cada opção.
- Preview via OpenGraph do GitHub (URL estável, gerada pelo GitHub).
- Análise de cada opção + menções honrosas (LightDM+webkit, hyprlogin,
  sysc-greet, door, noctalia-greeter, snry-dm, etc).
- Template de instalação e reversão.

### Estado atual do sistema (verificado)

- **Nenhum DM instalado.** `display-manager.service` não existe; nenhum de
  sddm/gdm/lightdm/greetd/ly está instalado.
- `getty@tty1.service` = template stock do systemd, sem override de autologin.
  `/etc/inittab` não existe. **Não há autologin** — o usuário digita
  usuário e senha, e o Hyprland sobe sozinho pelo fix do
  [tweak de autologin](2026-09-26-autologin-hyprland-tty1.md).
- Qt6/plasma-workspace/kio/dolphin **já instalados** (stack KDE em uso), então
  um DM baseado em Qt teria custo real baixo.

### Destaques da pesquisa

- **`greetd` é o padrão da comunidade Hyprland** — daemon de 754 KiB com greeter
  trocável. Itens 1–7 da tabela são todos greetd + greeter diferente.
- **Opção mais alinhada ao setup:** `qsgreeter` / `quickshell-greetd`, escritos
  em **Quickshell** (mesma tecnologia do End-4) e que rodam dentro do próprio
  Hyprland — o visual do login fica idêntico ao resto do sistema. ⚠️ Mas o
  `qsgreeter-hyprland` foi submetido ao AUR em 26/09/2026, 0 votos, experimental.
- ⚠️ **Hyprland 0.55+ é Lua.** Todo greeter precisa de
  `command = "start-hyprland -- -c /etc/greetd/hyprland.lua"`, não `.conf`.
  O ArchWiki documenta isso.
- Se escolher SDDM/GDM/LightDM: eles `Provides: display-manager` e conflitam
  entre si — só pode ter **um** DM por vez.
- `IgnoreGroup=illogical-impulse` no `/etc/pacman.conf` é recomendado pelo wiki
  do End-4; essa linha **não existe** no `/etc/pacman.conf` atual.

## Arquivos tocados

- **Criado:** `~/Projects/formatation/telas-de-login-greeters.md`
- **Criado:** este arquivo de tweak + entrada no `README.md` do índice

Nenhum arquivo de configuração do sistema foi tocado neste tweak.

## Como verificar

O documento tem tabela e análise por opção. Para ver o estado do sistema:

```sh
# nenhum DM deve estar instalado
for p in sddm gdm lightdm greetd ly; do pacman -Q $p 2>/dev/null; done

# confirma que o login ainda é o agetty do tty1
systemctl status getty@tty1 --no-pager
grep 'ExecStart=' /etc/systemd/system/display-manager.service 2>/dev/null || echo "sem DM (esperado)"
```

## Como reverter

Nenhum sistema alterado — só apagar os docs:

```sh
rm ~/Projects/formatation/telas-de-login-greeters.md
rm ~/Projects/personal-tweeks-list/2026-09-26-tela-login-greeter-pesquisa.md
# e remover a linha correspondente do README.md do índice
```

## Próximo passo (aguardando decisão do usuário)

O usuário ainda precisa escolher qual greeter quer. Quando escolher, é um tweak
separado e precisa de `sudo` para: instalar o pacote, escrever
`/etc/greetd/config.toml`, e `systemctl disable getty@tty1` + `enable greetd`.
Ver `~/Projects/formatation/telas-de-login-greeters.md` para o template.
