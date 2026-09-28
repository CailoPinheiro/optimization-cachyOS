# Greeter tuigreet (greetd) com autologin e tema dinamico

**Data:** 2026-09-26
**Status:** **Aplicado e validado.** Bloco de sudo executado, reboot real feito
em 2026-09-26 17:29, autologin e cores confirmados.

## Motivo

O Hyprland subia sozinho pelo tty1 via autologin do `auto-Hypr.fish`, mas
**nao havia tela de login** — sair da sessao deixava o tty cru, sem como
voltar. O usuario escolheu um greeter **TUI** e o **tuigreet** (greetd) como
vencedor entre 10 opcoes comparadas.

Dois requisitos: autologin no boot (nao perguntar senha), e senha ao sair da
sessao. E as cores da tela de login seguindo o wallpaper, como o resto do
sistema.

## O que foi feito

### 1. Pesquisa (previo)

`~/Projects/os-setup/telas-de-login-greeters.md` — 10 greeters comparados.
O registro de pesquisa esta em
[2026-09-26-tela-login-greeter-pesquisa.md](2026-09-26-tela-login-greeter-pesquisa.md).

### 2. Pacotes (instalado)

`greetd` 0.10.3-2.1 e `greetd-tuigreet` 0.11.1-2.1, ambos do
`cachyos-extra-v3` — **nao** precisou de AUR. A pesquisa original dizia que
so havia `greetd-tuigreet-git` no AUR; estava desatualizado.

### 3. `~/.profile` (criado)

Problema real: o greetd comeca a sessao com PATH cru, sem `~/.local/bin`. Isso
quebraria `~/.local/bin/caffeine` (o botao Keep awake) dentro da sessao
iniciada pelo greetd. Causa: o `~/.profile` **nao existia**, e o End-4 so
adiciona `~/.local/bin` via `fish_add_path` no `config.fish`. Nao ha
`~/.config/environment.d/`, e o `/etc/environment` so tem comentarios.

O `~/.profile` repõe `PATH` e e idempotente em `sh`. **Nao** quebra
`bash -l` (nao tem early return).

### 4. Configs (prontos, em `~/Projects/tui-setup/config/`)

| Arquivo | Vai para |
|---|---|
| `greetd-config.toml` | `/etc/greetd/config.toml` |
| `tuigreet-config.toml` | `/etc/tuigreet/config.toml` |

Decisoes no `greetd-config.toml`:

- **`[initial_session]`** = autologin (`sleep 2 && exec start-hyprland`).
  Roda so no primeiro start, controlado pelo `/run/greetd.run`.
- **`sleep 2`** = guard contra o Debian bug #1129070 (fev/2026): o greetd
  sobe antes do `dbus-broker`/`rtkit` e a sessao morre. Sintoma: o tuigreet
  aparece sem ter pedido.
- **`[default_session]`** = tuigreet com senha. E o que aparece ao sair da
  sessao.
- **`--cmd start-hyprland`** fixa a sessao. Sem isso o tuigreet descobre
  `/usr/share/wayland-sessions` e oferece `hyprland-uwsm.desktop`, a
  armadilha que o End-4 avisa pra nunca escolher. Sem `--cmd`, **nao ha** o
  que escolher.
- **Sem `-c /etc/greetd/hyprland.lua`** — o Hyprland 0.56 acha o
  `hyprland.lua` sozinho (provado pelo autologin via `auto-Hypr.fish`).
- **`~/.profile` existe** para o `source_profile = true` padrao repor o PATH.

### 5. Template do matugen (criado, no repo)

`dots/.config/matugen/templates/tuigreet/config.toml` + entrada
`[templates.tuigreet]` em `dots/.config/matugen/config.toml`.

Sincronizado com `./setup install-files -f --skip-backup --skip-allgreeting`.

O `output_path` e `/usr/local/share/tuigreet/config.toml`, **nao** `/etc`,
porque o matugen roda como usuario comum.

**O `chown` no ARQUIVO e obrigatorio** (bug corrigido em 2026-09-26, depois de
travar em producao). O doc ensinava so o `chown` do diretorio, e com isso as
cores nunca apareceram: `sudo cp` cria o arquivo como `root:root`, e o
`chmod 644` ajusta so o modo, nao o dono. Resultado: `644 root:root`, que so
o root escreve. O matugen usa `fs::write` (trunca o arquivo existente, nao
apaga e recria) e o `switchwall.sh` do End-4 roda como usuario, sem `sudo` e
sem `systemd-run` — logo, `Permission denied` a cada troca de wallpaper. Ter o
diretorio do usuario **nao** resolve. O conserto:

```fish
sudo chown cailoop:cailoop /usr/local/share/tuigreet/config.toml
matugen --source-color-index 0 image "$(cat ~/.local/state/quickshell/user/generated/wallpaper/path.txt)"
```

O `--source-color-index 0` tambem e obrigatorio fora de um TTY: sem ele o
matugen extrai varias cores candidatas, tenta perguntar qual usar, aborta com
`Multiple source colors found...` e nao escreve nada. O `switchwall.sh` sempre
passa a flag (linha 184), e por isso a troca automatica funciona.

Checagem de que passou pelo matugen: `grep -c '{{colors\.'` no arquivo
gerado tem que dar **0**.

### 6. Documentacao

`~/Projects/tui-setup/` — `00-rapido` (os 3 passos, porta de entrada), README,
01-instalacao, 02-design, 03-matugen-dinamico, 04-referencia. Os TOMLs tambem
sao versionados em `~/Projects/tui-setup/config/` (o `/tmp/opencode/` se limpa
sozinho).

Erros de doc corrigidos em 2026-09-26:

- `03-matugen-dinamico.md` ensinava o passo unico sem o `chown` do arquivo —
  ver acima.
- `04-referencia.md` listava um terceiro modo em `secret.mode`
  (`"asterisks"`) que **nao existe**. O enum `SecretMode` tem so `Hidden` e
  `Characters`; testado no binario instalado, `"asterisks"` e descartado
  silenciosamente pelo `--dump-config`.

## Como realizar (Passo a passo)

### 1. Instalar os pacotes (sem AUR)

```bash
sudo pacman -S greetd greetd-tuigreet
```

### 2. Criar o `~/.profile` para garantir PATH correto na sessão do greetd

```bash
cat > ~/.profile << 'EOF'
# POSIX sh puro — sourced pelo greetd (source_profile=true) para repor PATH
if [ -d "$HOME/.local/bin" ] ; then
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) PATH="$HOME/.local/bin:$PATH" ;;
    esac
fi
export PATH
EOF
```

### 3. Criar o diretório e arquivo de destino do matugen (com permissões corretas)

```bash
# Criar diretório acessível pelo greeter
sudo mkdir -p /usr/local/share/tuigreet
sudo chown cailoop:cailoop /usr/local/share/tuigreet

# Copiar o config inicial como base (depois o matugen vai sobrescrever)
sudo cp ~/Projects/tui-setup/config/tuigreet-config.toml /usr/local/share/tuigreet/config.toml
# CRUCIAL: chown no ARQUIVO, não só no diretório
sudo chown cailoop:cailoop /usr/local/share/tuigreet/config.toml
```

### 4. Criar o symlink em `/etc/tuigreet/`

```bash
sudo mkdir -p /etc/tuigreet
sudo ln -sf /usr/local/share/tuigreet/config.toml /etc/tuigreet/config.toml
# Verificar:
ls -la /etc/tuigreet/config.toml
# Deve mostrar: /etc/tuigreet/config.toml -> /usr/local/share/tuigreet/config.toml
```

### 5. Instalar o config do greetd

```bash
sudo cp ~/Projects/tui-setup/config/greetd-config.toml /etc/greetd/config.toml
```

### 6. Adicionar o template do matugen ao repositório de dotfiles e sincronizar

O template já está em `~/dots-hyprland/dots/.config/matugen/templates/tuigreet/config.toml`
e a entrada `[templates.tuigreet]` já está em `~/dots-hyprland/dots/.config/matugen/config.toml`.

```bash
cd ~/dots-hyprland
./setup install-files -f --skip-backup --skip-allgreeting
```

### 7. Gerar as cores iniciais com o matugen

```bash
# --source-color-index 0 é OBRIGATÓRIO fora de um TTY (evita prompt interativo)
matugen --source-color-index 0 image "$(cat ~/.local/state/quickshell/user/generated/wallpaper/path.txt)"

# Verificar que não há placeholders não substituídos:
grep -c '{{colors\.' /usr/local/share/tuigreet/config.toml
# Deve retornar 0
```

### 8. Ativar o greetd e desativar o getty

```bash
sudo systemctl enable --now greetd.service
sudo systemctl disable getty@tty1.service
```

### 9. Preview antes do reboot (opcional)

```bash
tuigreet --config ~/Projects/tui-setup/config/tuigreet-config.toml --mock
```

### 10. Reiniciar o sistema

```bash
reboot
```

> ⚠️ **Lembrete:** Se após o reboot o greetd aparecer pedindo senha sem ter feito autologin, verifique o `sleep 2` no `[initial_session]` — pode ser a race condition com dbus-broker. Aguarde e tente novamente.

## A solucao do caminho do config

O ponto mais delicado. Restricoes reais da maquina:

1. `/home/cailoop` e `drwx------` (700) — o usuario `greeter` **nao
   atravessa** o home. Mata a ideia de apontar para `~/.config/tuigreet/`.
2. `/etc` e do root — o matugen nao escreve la.
3. O `greeter` tem home `/var/lib/noctalia-greeter` (residuo do Noctalia) e
   shell `/usr/bin/nologin` (padrao Arch e `-` / `/bin/bash`).

Solucao: `matugen` -> `/usr/local/share/tuigreet/config.toml`
(`cailoop`, 755 dir / 644 arquivo) e `/etc/tuigreet/config.toml` vira
**symlink** para ele. O `/usr/local/share` e `755 root:root`, entao o
diretorio e criado com sudo e depois entregue ao `cailoop`; assim o greeter
consegue ler atraves do symlink.

Alternativa rejeitada: `chmod o+x /home/cailoop` (701) para usar
`~/.config/tuigreet/`. Descartado por afrouxar o home inteiro; o
`/usr/local/share` nao tem esse custo.

Nota de seguranca: `/etc/tuigreet/config.toml` (root) aponta para um arquivo
controlado pelo usuario. **Nao e escalacao de privilegio** — o unico
consumidor e o login do proprio usuario, que ele ja controla. Ainda assim
e um padrao que vale registrar.

## Como verificar

```fish
systemctl is-enabled greetd.service            # esperado: enabled
systemctl is-active greetd.service             # esperado: active
echo $PATH | tr ':' '\n' | grep -c local/bin  # esperado: >= 1
systemctl --user is-active caffeine-watch.timer # esperado: active
```

Preview sem ativar:

```fish
tuigreet --config ~/Projects/tui-setup/config/tuigreet-config.toml --mock
```

Validar um TOML antes de instalar (nao precisa de socket nem TTY):

```fish
tuigreet --config <arquivo> --dump-config
```

## Como reverter

```fish
sudo systemctl disable --now greetd.service
sudo systemctl enable getty@tty1.service
sudo rm -f /etc/greetd/config.toml /etc/greetd/environments
sudo rm -rf /etc/tuigreet /usr/local/share/tuigreet
```

O autologin do `auto-Hypr.fish` reassume o tty1 e o sistema volta como
estava. O `~/.profile` pode ficar (e inofensivo). Para desinstalar os
pacotes: `sudo pacman -Rns greetd greetd-tuigreet`.

## Pendencias

Nada bloqueante. Restam duas opcionais:

- `sudo ls -la /var/lib/noctalia-greeter/` — o diretorio existe e e do `greeter`
  (`drwxr-x--- greeter:greeter`, uid 961). **Nao** e preciso pro tuigreet
  funcionar: ele roda via `sh(1)` e le `/etc/tuigreet/config.toml`, sem
  passar pelo home do greeter. O home `700` do `cailoop` e o que ja eliminou a
  alternativa de usar `~/.config/tuigreet/`. So limpar se o Noctalia tiver
  deixado `.profile` la, porque o greetd (`source_profile = true`) tentaria
  sourciar.
- Confirmar que **sair** do Hyprland mostra o tuigreet com senha. O boot com
  autologin foi validado; o caminho de saida nao foi exercitado.

## Validacao real (2026-09-26 17:29)

Tudo verificado contra o sistema, nao presumido:

| Checagem | Resultado |
|---|---|
| `systemctl is-enabled greetd.service` | `enabled` |
| `systemctl is-active greetd.service` | `active` |
| `getty@tty1.service` | `disabled` + `inactive` (por causa do `Conflicts=` do greetd) |
| `echo $PATH` com `local/bin` | aparece 2x — o `~/.profile` foi sourciado na sessao |
| `systemctl --user is-active caffeine-watch.timer` | `active` |
| Placeholders no config gerado | `0` — passou pelo matugen |
| Cores geradas | `#a4c9fe` — bate com a paleta viva do Hyprland |

**Prova de que o boot NAO passou pelo fish.** `~/.cache/hyprland.log` foi
modificado em `17:28:57`, enquanto o boot atual comecou em `17:29:18` e o
greetd subiu em `17:29:32`. O log nao foi tocado neste boot, o que prova que o
`auto-Hypr.fish` **nao rodou** — quem subiu a sessao foi o
`[initial_session]` do greetd (`sleep 2 && exec start-hyprland`). O
`auto-Hypr.fish` continua no disco, mas virou **fallback**: so volta a ter
efeito se o greetd for desabilitado.

**A prova de que a parte dinamica funciona sem intervencao.** Em 2026-09-27
12:58 o wallpaper mudou para `~/Imagens/Wallpapers/random_wallpaper.png` e o
matugen reescreveu `/usr/local/share/tuigreet/config.toml` sozinho, sem
ninguem rodar comando. As 11 cores mudaram:

| cor | antes (frieren) | depois (random_wallpaper) |
|---|---|---|
| `time`/`title`/`greet` | `#a4c9fe` | `#b0c6ff` |
| `container` | `#1d2024` | `#1e1f25` |
| `border` | `#43474e` | `#44464f` |

Isso valida de uma vez o `chown` do arquivo (o bug de 26/09), o
`--source-color-index 0` que o `switchwall.sh` sempre passa, e o symlink.
Trocou o wallpaper, a tela de login mudou de cor junto.

Consequencia para migracao de shell: com o greetd ativo, trocar o shell do
usuario **nao afeta o boot**. O greetd nao usa shell de login — roda `sh(1)`.
O que ainda depende do shell do usuario e so o `auto-Hypr.fish`, no caminho
alternativo.
