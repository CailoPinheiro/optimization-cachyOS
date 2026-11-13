# unlock-deadlock

Arquivos de otimização do Deadlock no Linux (Proton). A base é o
[OptimizationLock](https://github.com/Sqooky/OptimizationLock/tree/main) (Sqooky).
O passo a passo completo está em `otimizacao-deadlock.md`.

## Estrutura

```
unlock-deadlock/
├── README.md                  este arquivo
├── otimizacao-deadlock.md     guia: como aplicar, opções da Steam, mods, reversão
├── gameinfo.gi                config principal (OptimizationLock 1.5.1)
├── video.txt                  perfil de vídeo mínimo (iGPU)
└── extra/                     configs alternativas, só para consulta
    ├── config-lina-deadlock/
    │   └── gameinfo.gi        OptimizationLock 1.5 (build antiga do jogo)
    └── seco-seco-seco/        pack "Full FPS UP cfg SSH"
        ├── gameinfo.gi
        ├── video.txt
        ├── autoexec.cfg
        └── pak01_dir.vpk      texturas a ~10% do tamanho (só local, fora do git)
```

## O que é cada arquivo

| Arquivo | Destino no jogo | Função |
|---|---|---|
| `gameinfo.gi` | `steamapps/common/Deadlock/game/citadel/` | Injeta ~500 cvars de desempenho no boot. |
| `video.txt` | `userdata/<STEAM_ID>/1422450/local/cfg/` | Configurações de vídeo (render interno reduzido, sombras e efeitos desligados). |
| `extra/` | nenhum | Referência. Não instalar inteiro: `gameinfo.gi` de build antiga e valores pensados para outro hardware. |

## Mods (.vpk)

Os mods não ficam neste repositório: arquivos `.vpk` estão no `.gitignore`
porque passam do limite de tamanho do GitHub. Baixe-os em
[Performance Improving Mods](https://github.com/Sqooky/OptimizationLock/tree/main/Performance%20Improving%20Mods)
e copie para `steamapps/common/Deadlock/game/citadel/addons/`. A seção 6 de
`otimizacao-deadlock.md` explica cada um.

## Avisos

- Update do jogo ou "Verificar integridade" restaura o `gameinfo.gi` original e
  apaga `addons/`. Esta pasta é o backup das configs; os mods precisam ser
  baixados de novo.
- Os nomes `pakNN_dir.vpk` só definem a ordem de carga. Se dois mods tiverem o
  mesmo nome, renomeie um deles antes de copiar.
- Nunca substitua o `game/citadel/pak01_dir.vpk` do jogo: mods vão só em `addons/`.
