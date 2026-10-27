# Minecraft Dungeons II (SteamRIP/RUNE) - apontar o Hydra para o Shipping.exe

## Motivo

O Minecraft Dungeons II (build Microsoft GDK / Microsoft Store) crashava
imediatamente ao ser aberto pelo HydraLauncher. O processo abria um dialogo de
dependencia faltando e, ao confirmar, morria.

Causa: o `Dungeons.exe` da raiz do jogo **nao e o jogo**. E o
launcher/dependency-checker da Microsoft GDK (200 KB, PE32+). O jogo real e
`Dungeons/Binaries/WinGDK/Dungeons-WinGDK-Shipping.exe` (Unreal Engine).

O stub faz checagens de dependencia antes de subir o jogo:

1. **Visual C++ Runtime** - le
   `HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64` e compara
   `Major`/`Minor`/`Bld` contra 14 / 42 (0x2a) / 34438 (0x8686).
2. **DirectX Runtime**.
3. **Gaming Services** - le `HKLM\Software\Microsoft\GamingServices` e a DWORD
   `ForceUseLocalServices`.

As checagens 1 e 2 passavam (vcrun2022 14.42.34438 instalado e registrado no
prefixo). A 3 falhava, o stub mostrava `Missing Gaming Services` e oferecia
executar `Engine\Extras\ThirdPartyNotUE\GamingRepair\exe\GamingRepair.exe
scenarioExternal`. Esse `GamingRepair.exe` e o instalador de Gaming Services e
depende de servicos do Windows inexistentes no Wine - ai vinha o crash.

### Gaming Services nao e instalavel no Wine/Proton

Confirmado por pesquisa. Gaming Services e um pacote MSIX/UWP que depende da
infraestrutura AppX, `InstallService`, BITS e servicos do Windows Update. O Wine
nao implementa esse stack, e o `winetricks` nao tem verbo para ele. Por isso o
`GamingRepair.exe` sempre morre ali, e instalar os "servicos Xbox" nao e caminho
viavel. A comunidade resolve com um shim (`xgameruntime.dll` falso) - ver
`Alextibtab/Dungeons2_linux_fix` -, mas isso aqui nao se aplica (explicado em
"Por que o shim da comunidade nao foi usado").

Esta copia e **SteamRIP com crack RUNE** (`RUNE.dll`, `winmm.dll`,
`xgameruntime.dll` e `ms_emu.json` em `Dungeons/Binaries/WinGDK/`), e **nao**
OnlineFix. O `winmm.dll` da pasta faz sideload de `xgameruntime.dll` e
`RUNE.dll`, ou seja, o proprio crack ja cobre a parte de Gaming Services em
tempo de execucao. O jogo em si nao precisa de Gaming Services real.

## Tentativa que NAO funcionou (chave de registro)

Antes da solucao final foi criada a DWORD `ForceUseLocalServices` = 1 em
`HKLM\Software\Microsoft\GamingServices` no prefixo Wine do Hydra, com o
intencao de satisfazer a checagem 3. Disassembly do stub confirma que a logica
e exatamente:

```
RegGetValueW(HKLM, L"Software\\Microsoft\\GamingServices",
             L"ForceUseLocalServices", RRF_ZEROONFAILURE, NULL, &valor, &tam)
return valor != 0;
```

**Resultado: nao funcionou.** O dialogo de Gaming Services continuou aparecendo
e o processo continuou morrendo. A chave permaneceu no prefixo (verificada),
o stub e x86-64 (le a visao nativa, sem WOW64) e o prefixo nao foi recriado -
entao a discrepancia esta no proprio check, que evidently tem condicao
adicional alem do registro. Nao valeu mais insistir nessa via.

A chave foi deixada no prefixo porque e inofensiva. Pode ser removida sem
qualquer efeito no funcionamento do jogo (ver "Como reverter").

Backup do `system.reg` antes da alteracao: `/tmp/opencode/system.reg.bak`.

## O que foi feito (solucao valida)

O executavel configurado no HydraLauncher foi apontado para o executavel real
do jogo, pulando o stub da Microsoft:

```
antes:  /home/cailoop/Downloads/Minecraft.Dungeons.II-SteamRIP.com/Minecraft.Dungeons.II/Dungeons.exe
depois: /home/cailoop/Downloads/Minecraft.Dungeons.II-SteamRIP.com/Minecraft.Dungeons.II/Dungeons/Binaries/WinGDK/Dungeons-WinGDK-Shipping.exe
```

O Shipping.exe nao faz nenhuma checagem de dependencia e sobe direto. O sideload
do RUNE continua funcionando porque `winmm.dll`, `xgameruntime.dll`, `RUNE.dll`
e `ms_emu.json` estao todos na mesma pasta do Shipping.exe.

Foi verificado empiricamente que o **cwd nao interfere**: o jogo sobe com o cwd
em WinGDK, na raiz do jogo, ou no home. Nenhuma `WINEDLLOVERRIDES` e necessaria.
Isso importa porque o HydraLauncher nao faz `cd` para a pasta do jogo.

Tambem foi criado um atalho independente do launcher:

- `~/bin/dungeons2` - script que lanca o Shipping.exe pelo mesmo umu-run e
  prefixo do Hydra.
- `~/.local/share/applications/dungeons2.desktop` - entrada no menu de
  aplicativos.

## Como realizar (passo a passo)

Pelo proprio HydraLauncher, na pagina do jogo:

1. Abrir o Minecraft Dungeons II na biblioteca do Hydra.
2. Clicar no caminho do executavel exibido - a interface mostra
   "Clique para alterar o caminho do executavel".
3. Escolher
   `.../Minecraft.Dungeons.II/Dungeons/Binaries/WinGDK/Dungeons-WinGDK-Shipping.exe`.
4. Dar play normalmente.

Para confirmar que a mudanca foi gravada, o registro do jogo esta em
`~/.config/hydralauncher/hydra-db/` (LevelDB). A entrada do jogo deve mostrar
`executablePath` apontando para o Shipping.exe. **O Hydra precisa estar
fechado** para o LevelDB poder ser lido com seguranca.

Alternativa pelo script, sem depender do Hydra:

```bash
~/bin/dungeons2
```

## Arquivos tocados

- `~/.config/hydralauncher/hydra-db/` (campo `executablePath` do jogo, via
  interface do Hydra)
- `~/bin/dungeons2` (novo - atalho de linha de comando)
- `~/.local/share/applications/dungeons2.desktop` (novo - atalho de menu)
- `/home/cailoop/.config/hydralauncher/wine-prefixes/1912410/system.reg`
  (chave `GamingServices\ForceUseLocalServices`, ineffective e inofensiva)

Nenhum arquivo de dotfiles foi alterado. O jogo e o crack nao foram modificados.

## Como verificar

1. Abrir o jogo pelo HydraLauncher.
2. Nenhum dialogo de dependencia deve aparecer.
3. O jogo deve subir direto na janela.

Comparativo de comportamento medido com `umu-run` + timeout de 25-40s:

| Executavel | Resultado |
|---|---|
| `Dungeons.exe` (stub) | fica preso no dialogo, nao sobe |
| `Dungeons-WinGDK-Shipping.exe` | fica vivo ate o timeout (exit 124) |

Verificar a chave de registro inefetiva:

```bash
PX=/home/cailoop/.config/hydralauncher/wine-prefixes/1912410
grep -A3 'GamingServices' "$PX/system.reg"
```

## Como reverter

Restaurar o executavel original na interface do Hydra (mesmo caminho do passo a
passo, escolhendo o `Dungeons.exe` da raiz). O jogo volta a crashar, como antes.

Remover a chave de registro inofensiva:

```bash
PX=/home/cailoop/.config/hydralauncher/wine-prefixes/1912410
PF="/home/cailoop/.local/share/Steam/compatibilitytools.d/Proton-CachyOS Latest/files"

export WINEPREFIX="$PX"
export WINESERVER="$PF/bin/wineserver"
export PATH="$PF/bin:$PATH"

"$PF/bin/wine" reg delete 'HKLM\Software\Microsoft\GamingServices' /f
"$PF/bin/wineserver" -k
```

Ou restaurar o backup:

```bash
cp -a /tmp/opencode/system.reg.bak \
  /home/cailoop/.config/hydralauncher/wine-prefixes/1912410/system.reg
```

Remover os atalhos:

```bash
rm -f ~/bin/dungeons2 ~/.local/share/applications/dungeons2.desktop
update-desktop-database ~/.local/share/applications
```

## Por que o shim da comunidade nao foi usado

O repositorio `Alextibtab/Dungeons2_linux_fix` resolve o mesmo problema com uma
abordagem diferente: compila um `xgameruntime.dll` falso e um `xauth.py` que faz
login OAuth da conta Microsoft. Ele foi avaliado e **descartado** porque:

- O `install.sh` e hardcoded para instalacao Steam
  (`steamapps/common/Minecraft Dungeons II`, `steamapps/compatdata/1912410/pfx`)
  e para a pasta `Dungeons/Binaries/Win64`. Aqui o jogo esta em `~/Downloads/`,
  a build e `WinGDK` e o prefixo e o do Hydra - o script falha na hora.
- O jogo **ja tem** `xgameruntime.dll`, do proprio crack RUNE. Copiar o shim
  por cima quebraria a emulacao de identidade do crack.
- O `xauth.py` exige login em conta Microsoft real e guarda tokens OAuth num
  `tokens.txt`. E irrelevante aqui: o RUNE ja emula o gamertag via
  `ms_emu.json`.

## Observacoes / riscos

- O prefixo e gerenciado pelo HydraLauncher. Se o Proton for atualizado, o
  Hydra pode recriar o prefixo - nesse caso reaplicar a chave inofensiva e
  reconferir o `executablePath`.
- O jogo roda em DirectX com DXVK (prefixo tem `d3d11.dll`/`dxgi.dll` nativos)
  sobre Intel Iris Xe com Mesa. Performance pode ser limitada, e `d3d12.dll` no
  prefixo vem do vkd3d-proton embutido no Proton. Problema separado deste.