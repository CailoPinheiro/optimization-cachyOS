# 2026-11-03 - EasyEffects: calibracao de microfone com qualidade de audio estilo Discord (Broadcast / Krisp)

## Motivo

O audio cru de microfones no Linux (headsets USB, microfones embutidos ou condensadores) frequentemente sofre com:
- Ruido de fundo constante (ventiladores, ruidos eletricos, chiado/hiss de pre-amplificadores integrados);
- Ruido mecânico transiente (digitacao em teclado mecanico, cliques de mouse, batidas na mesa);
- Sub-graves indesejados abaixo de 80 Hz gerados por ressonancia do ambiente e manuseio;
- Sibilância excessiva (sons de "s", "t", "ch" agudos e estridentes);
- Variacao dinamica desregulada (voz baixa ao falar suave e distorcao/clipping ao rir ou falar alto).

No Discord, essa qualidade e alcancada de fabrica por uma pipeline integrada composta pelo algoritmo Krisp (supressao neural de ruidos), Voice Activity Detection (gate de sensibilidade), passa-alta e controle de ganho.
O objetivo deste tweak e replicar e disponibilizar exatamente essa mesma qualidade de voz do Discord para **todos os demais aplicativos do sistema** (OBS, jogos, Google Meet, Telegram, navegadores e ferramentas de gravacao) via PipeWire e EasyEffects, criando a fonte virtual `easyeffects_source`.

## O que foi feito

1. Mapeamento da cadeia ideal de plugins no EasyEffects (ordem estrita de processamento):
   - **DeepFilterNet** (ou RNNoise): supressao neural de ruidos em tempo real antes de qualquer compressao.
   - **Filter (High-Pass)**: corte de sub-graves em 80 Hz com inclinacao de 12 dB/oitava.
   - **Gate**: sensibilidade de atividade vocal (-38 dB) com retencao de palavras (attack 5ms, release 250ms).
   - **De-esser**: atenuacao seletiva de sibilancia aguda em 6.0 kHz.
   - **Equalizer**: curva de presenca vocal (corte de frequencias abafadas em 315 Hz e ganho sutil em 3.2 kHz e 10 kHz).
   - **Compressor**: nivelamento da dinamica vocal com taxa de 3.5:1 e ganho de compensacao (makeup gain +5 dB).
   - **Limiter**: teto seguro em -1.0 dB para evitar qualquer distorcao digital.

2. Criacao dos perfis de preset de entrada na pasta padrao XDG de dados do EasyEffects (`~/.local/share/easyeffects/input/`):
   - `Discord-Broadcast.json` (perfil principal com IA DeepFilterNet equivalente ao Krisp do Discord).
   - `Discord-Broadcast-RNNoise.json` (perfil alternativo ultraleve utilizando o motor nativo RNNoise para economia de processador).

3. Identificacao e instalacao dos pacotes necessarios dos plugins profissionais para PipeWire/LADSPA/LV2:
   - `deepfilternet-ladspa` (LADSPA AI speech enhancement).
   - `lsp-plugins-lv2` (Linux Studio Plugins para equalizador, compressor, limiter e gate).

## Passo a passo (reproducao / re-aplicacao)

### 1. Instalacao dos plugins

```bash
sudo pacman -Sy --needed easyeffects deepfilternet-ladspa lsp-plugins-lv2
```

### 2. Estrutura de diretorios

No EasyEffects 8+, os presets sao armazenados na pasta de dados XDG do usuario:
```bash
mkdir -p ~/.local/share/easyeffects/input ~/.local/share/easyeffects/output
```

### 3. Criacao dos arquivos de preset

Os arquivos de definicao de preset devem ser criados diretamente em `~/.local/share/easyeffects/input/`.
Abaixo estao os conteudos integrais de cada preset para reproducao manual ou automatizada:

#### Conteudo integral: `~/.local/share/easyeffects/input/Discord-Broadcast.json`

```json
{
    "input": {
        "blocklist": [],
        "plugins_order": [
            "deepfilternet#0",
            "filter#0",
            "gate#0",
            "deesser#0",
            "equalizer#0",
            "compressor#0",
            "limiter#0"
        ],
        "deepfilternet#0": {
            "attenuation-limit": 100.0,
            "bypass": false,
            "input-gain": 0.0,
            "max-df-processing-threshold": 20.0,
            "max-erb-processing-threshold": 30.0,
            "min-processing-buffer": 0,
            "min-processing-threshold": -10.0,
            "output-gain": 0.0,
            "post-filter-beta": 0.02
        },
        "filter#0": {
            "balance": 0.0,
            "bypass": false,
            "equal-mode": "IIR",
            "frequency": 80.0,
            "gain": 0.0,
            "input-gain": 0.0,
            "mode": "APO (DR)",
            "output-gain": 0.0,
            "quality": 0.707,
            "slope": "x1",
            "type": "High-pass",
            "width": 4.0
        },
        "gate#0": {
            "attack": 5.0,
            "bypass": false,
            "curve-threshold": -38.0,
            "curve-zone": -6.0,
            "dry": -80.01,
            "hpf-frequency": 10.0,
            "hpf-mode": "Off",
            "hysteresis": false,
            "hysteresis-threshold": -12.0,
            "hysteresis-zone": -6.0,
            "input-gain": 0.0,
            "input-to-link": -80.01,
            "input-to-sidechain": -80.01,
            "link-to-input": -80.01,
            "link-to-sidechain": -80.01,
            "lpf-frequency": 20000.0,
            "lpf-mode": "Off",
            "makeup": 0.0,
            "output-gain": 0.0,
            "reduction": -24.0,
            "release": 250.0,
            "sidechain": {
                "lookahead": 0.0,
                "mode": "RMS",
                "preamp": 0.0,
                "reactivity": 10.0,
                "source": "Middle",
                "stereo-split-source": "Left/Right",
                "type": "Internal"
            },
            "sidechain-to-input": -80.01,
            "sidechain-to-link": -80.01,
            "stereo-split": false,
            "wet": 0.0
        },
        "deesser#0": {
            "bypass": false,
            "detection": "RMS",
            "f1-freq": 2000.0,
            "f1-level": 0.0,
            "f2-freq": 6000.0,
            "f2-level": 6.0,
            "f2-q": 1.0,
            "input-gain": 0.0,
            "laxity": 10,
            "makeup": 0.0,
            "mode": "Wide",
            "output-gain": 0.0,
            "ratio": 3.0,
            "sc-listen": false,
            "threshold": -20.0
        },
        "equalizer#0": {
            "balance": 0.0,
            "bypass": false,
            "input-gain": 0.0,
            "left": {
                "band0": {
                    "frequency": 20.0,
                    "gain": -12.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band1": {
                    "frequency": 25.0,
                    "gain": -12.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band2": {
                    "frequency": 31.5,
                    "gain": -10.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band3": {
                    "frequency": 40.0,
                    "gain": -8.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band4": {
                    "frequency": 50.0,
                    "gain": -6.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band5": {
                    "frequency": 63.0,
                    "gain": -4.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band6": {
                    "frequency": 80.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band7": {
                    "frequency": 100.0,
                    "gain": 1.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band8": {
                    "frequency": 125.0,
                    "gain": 1.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band9": {
                    "frequency": 160.0,
                    "gain": 1.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band10": {
                    "frequency": 200.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band11": {
                    "frequency": 250.0,
                    "gain": -1.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band12": {
                    "frequency": 315.0,
                    "gain": -2.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band13": {
                    "frequency": 400.0,
                    "gain": -2.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band14": {
                    "frequency": 500.0,
                    "gain": -0.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band15": {
                    "frequency": 630.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band16": {
                    "frequency": 800.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band17": {
                    "frequency": 1000.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band18": {
                    "frequency": 1250.0,
                    "gain": 0.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band19": {
                    "frequency": 1600.0,
                    "gain": 1.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band20": {
                    "frequency": 2000.0,
                    "gain": 1.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band21": {
                    "frequency": 2500.0,
                    "gain": 2.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band22": {
                    "frequency": 3150.0,
                    "gain": 3.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band23": {
                    "frequency": 4000.0,
                    "gain": 2.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band24": {
                    "frequency": 5000.0,
                    "gain": 1.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band25": {
                    "frequency": 6300.0,
                    "gain": -0.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band26": {
                    "frequency": 8000.0,
                    "gain": 1.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band27": {
                    "frequency": 10000.0,
                    "gain": 2.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band28": {
                    "frequency": 12500.0,
                    "gain": 1.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band29": {
                    "frequency": 16000.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band30": {
                    "frequency": 18000.0,
                    "gain": -2.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band31": {
                    "frequency": 20000.0,
                    "gain": -4.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                }
            },
            "mode": "IIR",
            "num-bands": 32,
            "output-gain": 0.0,
            "pitch-left": 0.0,
            "pitch-right": 0.0,
            "right": {
                "band0": {
                    "frequency": 20.0,
                    "gain": -12.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band1": {
                    "frequency": 25.0,
                    "gain": -12.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band2": {
                    "frequency": 31.5,
                    "gain": -10.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band3": {
                    "frequency": 40.0,
                    "gain": -8.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band4": {
                    "frequency": 50.0,
                    "gain": -6.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band5": {
                    "frequency": 63.0,
                    "gain": -4.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band6": {
                    "frequency": 80.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band7": {
                    "frequency": 100.0,
                    "gain": 1.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band8": {
                    "frequency": 125.0,
                    "gain": 1.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band9": {
                    "frequency": 160.0,
                    "gain": 1.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band10": {
                    "frequency": 200.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band11": {
                    "frequency": 250.0,
                    "gain": -1.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band12": {
                    "frequency": 315.0,
                    "gain": -2.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band13": {
                    "frequency": 400.0,
                    "gain": -2.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band14": {
                    "frequency": 500.0,
                    "gain": -0.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band15": {
                    "frequency": 630.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band16": {
                    "frequency": 800.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band17": {
                    "frequency": 1000.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band18": {
                    "frequency": 1250.0,
                    "gain": 0.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band19": {
                    "frequency": 1600.0,
                    "gain": 1.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band20": {
                    "frequency": 2000.0,
                    "gain": 1.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band21": {
                    "frequency": 2500.0,
                    "gain": 2.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band22": {
                    "frequency": 3150.0,
                    "gain": 3.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band23": {
                    "frequency": 4000.0,
                    "gain": 2.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band24": {
                    "frequency": 5000.0,
                    "gain": 1.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band25": {
                    "frequency": 6300.0,
                    "gain": -0.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band26": {
                    "frequency": 8000.0,
                    "gain": 1.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band27": {
                    "frequency": 10000.0,
                    "gain": 2.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band28": {
                    "frequency": 12500.0,
                    "gain": 1.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band29": {
                    "frequency": 16000.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band30": {
                    "frequency": 18000.0,
                    "gain": -2.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band31": {
                    "frequency": 20000.0,
                    "gain": -4.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                }
            },
            "split-channels": false
        },
        "compressor#0": {
            "attack": 8.0,
            "boost-amount": 6.0,
            "boost-threshold": -72.0,
            "bypass": false,
            "dry": -80.01,
            "hpf-frequency": 10.0,
            "hpf-mode": "Off",
            "input-gain": 0.0,
            "input-to-link": -80.01,
            "input-to-sidechain": -80.01,
            "knee": -6.0,
            "link-to-input": -80.01,
            "link-to-sidechain": -80.01,
            "lpf-frequency": 20000.0,
            "lpf-mode": "Off",
            "makeup": 5.0,
            "mode": "Downward",
            "output-gain": 0.0,
            "ratio": 3.5,
            "release": 100.0,
            "release-threshold": 0.0,
            "sidechain": {
                "lookahead": 0.0,
                "mode": "RMS",
                "preamp": 0.0,
                "reactivity": 10.0,
                "source": "Middle",
                "stereo-split-source": "Left/Right",
                "type": "Internal"
            },
            "sidechain-to-input": -80.01,
            "sidechain-to-link": -80.01,
            "stereo-split": false,
            "threshold": -20.0,
            "wet": 0.0
        },
        "limiter#0": {
            "alr": false,
            "alr-attack": 5.0,
            "alr-knee": 0.0,
            "alr-knee-smooth": -5.0,
            "alr-release": 50.0,
            "attack": 5.0,
            "bypass": false,
            "dithering": "None",
            "gain-boost": true,
            "input-gain": 0.0,
            "input-to-link": -80.01,
            "input-to-sidechain": -80.01,
            "link-to-input": -80.01,
            "link-to-sidechain": -80.01,
            "lookahead": 5.0,
            "mode": "Herm Thin",
            "output-gain": 0.0,
            "oversampling": "None",
            "release": 20.0,
            "sidechain-preamp": 0.0,
            "sidechain-to-input": -80.01,
            "sidechain-to-link": -80.01,
            "sidechain-type": "Internal",
            "stereo-link": 100.0,
            "threshold": -1.0
        }
    }
}
```

#### Conteudo integral: `~/.local/share/easyeffects/input/Discord-Broadcast-RNNoise.json`

```json
{
    "input": {
        "blocklist": [],
        "plugins_order": [
            "rnnoise#0",
            "filter#0",
            "gate#0",
            "deesser#0",
            "equalizer#0",
            "compressor#0",
            "limiter#0"
        ],
        "rnnoise#0": {
            "bypass": false,
            "enable-vad": true,
            "input-gain": 0.0,
            "model-name": "",
            "output-gain": 0.0,
            "release": 100.0,
            "use-standard-model": true,
            "vad-thres": 50.0,
            "wet": 0.0
        },
        "filter#0": {
            "balance": 0.0,
            "bypass": false,
            "equal-mode": "IIR",
            "frequency": 80.0,
            "gain": 0.0,
            "input-gain": 0.0,
            "mode": "APO (DR)",
            "output-gain": 0.0,
            "quality": 0.707,
            "slope": "x1",
            "type": "High-pass",
            "width": 4.0
        },
        "gate#0": {
            "attack": 5.0,
            "bypass": false,
            "curve-threshold": -38.0,
            "curve-zone": -6.0,
            "dry": -80.01,
            "hpf-frequency": 10.0,
            "hpf-mode": "Off",
            "hysteresis": false,
            "hysteresis-threshold": -12.0,
            "hysteresis-zone": -6.0,
            "input-gain": 0.0,
            "input-to-link": -80.01,
            "input-to-sidechain": -80.01,
            "link-to-input": -80.01,
            "link-to-sidechain": -80.01,
            "lpf-frequency": 20000.0,
            "lpf-mode": "Off",
            "makeup": 0.0,
            "output-gain": 0.0,
            "reduction": -24.0,
            "release": 250.0,
            "sidechain": {
                "lookahead": 0.0,
                "mode": "RMS",
                "preamp": 0.0,
                "reactivity": 10.0,
                "source": "Middle",
                "stereo-split-source": "Left/Right",
                "type": "Internal"
            },
            "sidechain-to-input": -80.01,
            "sidechain-to-link": -80.01,
            "stereo-split": false,
            "wet": 0.0
        },
        "deesser#0": {
            "bypass": false,
            "detection": "RMS",
            "f1-freq": 2000.0,
            "f1-level": 0.0,
            "f2-freq": 6000.0,
            "f2-level": 6.0,
            "f2-q": 1.0,
            "input-gain": 0.0,
            "laxity": 10,
            "makeup": 0.0,
            "mode": "Wide",
            "output-gain": 0.0,
            "ratio": 3.0,
            "sc-listen": false,
            "threshold": -20.0
        },
        "equalizer#0": {
            "balance": 0.0,
            "bypass": false,
            "input-gain": 0.0,
            "left": {
                "band0": {
                    "frequency": 20.0,
                    "gain": -12.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band1": {
                    "frequency": 25.0,
                    "gain": -12.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band2": {
                    "frequency": 31.5,
                    "gain": -10.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band3": {
                    "frequency": 40.0,
                    "gain": -8.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band4": {
                    "frequency": 50.0,
                    "gain": -6.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band5": {
                    "frequency": 63.0,
                    "gain": -4.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band6": {
                    "frequency": 80.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band7": {
                    "frequency": 100.0,
                    "gain": 1.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band8": {
                    "frequency": 125.0,
                    "gain": 1.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band9": {
                    "frequency": 160.0,
                    "gain": 1.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band10": {
                    "frequency": 200.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band11": {
                    "frequency": 250.0,
                    "gain": -1.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band12": {
                    "frequency": 315.0,
                    "gain": -2.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band13": {
                    "frequency": 400.0,
                    "gain": -2.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band14": {
                    "frequency": 500.0,
                    "gain": -0.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band15": {
                    "frequency": 630.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band16": {
                    "frequency": 800.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band17": {
                    "frequency": 1000.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band18": {
                    "frequency": 1250.0,
                    "gain": 0.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band19": {
                    "frequency": 1600.0,
                    "gain": 1.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band20": {
                    "frequency": 2000.0,
                    "gain": 1.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band21": {
                    "frequency": 2500.0,
                    "gain": 2.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band22": {
                    "frequency": 3150.0,
                    "gain": 3.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band23": {
                    "frequency": 4000.0,
                    "gain": 2.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band24": {
                    "frequency": 5000.0,
                    "gain": 1.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band25": {
                    "frequency": 6300.0,
                    "gain": -0.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band26": {
                    "frequency": 8000.0,
                    "gain": 1.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band27": {
                    "frequency": 10000.0,
                    "gain": 2.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band28": {
                    "frequency": 12500.0,
                    "gain": 1.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band29": {
                    "frequency": 16000.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band30": {
                    "frequency": 18000.0,
                    "gain": -2.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band31": {
                    "frequency": 20000.0,
                    "gain": -4.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                }
            },
            "mode": "IIR",
            "num-bands": 32,
            "output-gain": 0.0,
            "pitch-left": 0.0,
            "pitch-right": 0.0,
            "right": {
                "band0": {
                    "frequency": 20.0,
                    "gain": -12.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band1": {
                    "frequency": 25.0,
                    "gain": -12.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band2": {
                    "frequency": 31.5,
                    "gain": -10.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band3": {
                    "frequency": 40.0,
                    "gain": -8.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band4": {
                    "frequency": 50.0,
                    "gain": -6.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band5": {
                    "frequency": 63.0,
                    "gain": -4.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band6": {
                    "frequency": 80.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band7": {
                    "frequency": 100.0,
                    "gain": 1.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band8": {
                    "frequency": 125.0,
                    "gain": 1.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band9": {
                    "frequency": 160.0,
                    "gain": 1.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band10": {
                    "frequency": 200.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band11": {
                    "frequency": 250.0,
                    "gain": -1.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band12": {
                    "frequency": 315.0,
                    "gain": -2.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band13": {
                    "frequency": 400.0,
                    "gain": -2.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band14": {
                    "frequency": 500.0,
                    "gain": -0.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band15": {
                    "frequency": 630.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band16": {
                    "frequency": 800.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band17": {
                    "frequency": 1000.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band18": {
                    "frequency": 1250.0,
                    "gain": 0.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band19": {
                    "frequency": 1600.0,
                    "gain": 1.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band20": {
                    "frequency": 2000.0,
                    "gain": 1.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band21": {
                    "frequency": 2500.0,
                    "gain": 2.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band22": {
                    "frequency": 3150.0,
                    "gain": 3.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band23": {
                    "frequency": 4000.0,
                    "gain": 2.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band24": {
                    "frequency": 5000.0,
                    "gain": 1.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band25": {
                    "frequency": 6300.0,
                    "gain": -0.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band26": {
                    "frequency": 8000.0,
                    "gain": 1.5,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band27": {
                    "frequency": 10000.0,
                    "gain": 2.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band28": {
                    "frequency": 12500.0,
                    "gain": 1.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band29": {
                    "frequency": 16000.0,
                    "gain": 0.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band30": {
                    "frequency": 18000.0,
                    "gain": -2.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                },
                "band31": {
                    "frequency": 20000.0,
                    "gain": -4.0,
                    "mode": "APO (DR)",
                    "mute": false,
                    "q": 1.414,
                    "slope": "x1",
                    "solo": false,
                    "type": "Bell",
                    "width": 4.0
                }
            },
            "split-channels": false
        },
        "compressor#0": {
            "attack": 8.0,
            "boost-amount": 6.0,
            "boost-threshold": -72.0,
            "bypass": false,
            "dry": -80.01,
            "hpf-frequency": 10.0,
            "hpf-mode": "Off",
            "input-gain": 0.0,
            "input-to-link": -80.01,
            "input-to-sidechain": -80.01,
            "knee": -6.0,
            "link-to-input": -80.01,
            "link-to-sidechain": -80.01,
            "lpf-frequency": 20000.0,
            "lpf-mode": "Off",
            "makeup": 5.0,
            "mode": "Downward",
            "output-gain": 0.0,
            "ratio": 3.5,
            "release": 100.0,
            "release-threshold": 0.0,
            "sidechain": {
                "lookahead": 0.0,
                "mode": "RMS",
                "preamp": 0.0,
                "reactivity": 10.0,
                "source": "Middle",
                "stereo-split-source": "Left/Right",
                "type": "Internal"
            },
            "sidechain-to-input": -80.01,
            "sidechain-to-link": -80.01,
            "stereo-split": false,
            "threshold": -20.0,
            "wet": 0.0
        },
        "limiter#0": {
            "alr": false,
            "alr-attack": 5.0,
            "alr-knee": 0.0,
            "alr-knee-smooth": -5.0,
            "alr-release": 50.0,
            "attack": 5.0,
            "bypass": false,
            "dithering": "None",
            "gain-boost": true,
            "input-gain": 0.0,
            "input-to-link": -80.01,
            "input-to-sidechain": -80.01,
            "link-to-input": -80.01,
            "link-to-sidechain": -80.01,
            "lookahead": 5.0,
            "mode": "Herm Thin",
            "output-gain": 0.0,
            "oversampling": "None",
            "release": 20.0,
            "sidechain-preamp": 0.0,
            "sidechain-to-input": -80.01,
            "sidechain-to-link": -80.01,
            "sidechain-type": "Internal",
            "stereo-link": 100.0,
            "threshold": -1.0
        }
    }
}
```

### 4. Ativacao e carregamento no EasyEffects

- Abra o EasyEffects ou inicie em modo de servico:
  ```bash
  easyeffects --service-mode &
  ```
- No aplicativo, va na aba **Entrada (Input)**.
- Abra o menu de **Predefinicoes (Presets)** e carregue `Discord-Broadcast`.
- No painel superior, certifique-se de que o botao de bypass global esteja desligado (efeitos ativos).
- Opcional: na aba Presets > Autoloading, vincule o preset `Discord-Broadcast` ao seu microfone padrao para carregar automaticamente ao plugar.

### 5. Utilizacao nos aplicativos

Em qualquer aplicativo (OBS, Steam, jogos, Google Meet, navegadores), selecione nas configuracoes de audio:
- **Dispositivo de Entrada:** `Easy Effects Source` (ou `Default/Padrao`).

## Arquivos tocados

- `~/.local/share/easyeffects/input/Discord-Broadcast.json`
- `~/.local/share/easyeffects/input/Discord-Broadcast-RNNoise.json`

## Como verificar

1. Listar presets disponiveis no EasyEffects:
   ```bash
   easyeffects -p
   ```
   Deve exibir `Discord-Broadcast` e `Discord-Broadcast-RNNoise` sob predefinicoes de entrada.
2. Checagem de plugins instanciados no PipeWire:
   ```bash
   wpctl status
   ```
   Sob `ee_source_group`, devem constar os nos `ee_sie_deepfilternet`, `ee_sie_filter`, `ee_sie_gate`, `ee_sie_deesser`, `ee_sie_equalizer`, `ee_sie_compressor` e `ee_sie_limiter`.
3. Teste de audio com monitoramento ativo:
   - No EasyEffects, ative o icone de monitoramento de microfone (fone de ouvido ao lado do medidor de entrada).
   - Fale normalmente enquanto digita no teclado mecanico ou bate na mesa. O som dos cliques e ruidos deve desaparecer, restando apenas a voz clara e estavel.
4. Checagem de pacotes instalados:
   ```bash
   pacman -Q deepfilternet-ladspa lsp-plugins-lv2
   ```

## Como reverter

1. Para remover os presets criados:
   ```bash
   rm -f ~/.local/share/easyeffects/input/Discord-Broadcast.json ~/.local/share/easyeffects/input/Discord-Broadcast-RNNoise.json
   ```
2. Para remover os pacotes de plugins:
   ```bash
   sudo pacman -R deepfilternet-ladspa lsp-plugins-lv2
   ```
3. No EasyEffects, clique em Redefinir (Reset) ou execute:
   ```bash
   easyeffects -r
   ```

## Riscos e observacoes importantes

- **Caminho correto de presets no EasyEffects 8+:** As predefinicoes de entrada ficam em `~/.local/share/easyeffects/input/` (padrao XDG data), enquanto `~/.config/easyeffects/db/` armazena apenas arquivos INI de configuracao de interface e estado de execucao.
- **Ordem de processamento estrita:** A supressao de ruido DEVE sempre vir antes do compressor. Se o compressor atuar antes do DeepFilterNet ou RNNoise, ele amplificara os ruidos de fundo fracos, tornando o trabalho do filtro neural impreciso e gerando artefatos aquosos ou roboticos na voz.
- **Acoustic Echo Cancellation (AEC):** Para uso com fones de ouvido (headsets), nao ative o modulo Echo Canceller, pois canceladores de eco sem vazamento de caixas de som apenas reduzem a nitidez da voz sem beneficio real. O plugin so deve ser ativado se voce utilizar caixas de som abertas ao mesmo tempo em que fala no microfone.
- **Sensibilidade do Gate:** O limiar do Gate padrao e definido em -38 dB. Caso o seu microfone possua ganho de entrada de hardware muito baixo ou muito alto no `wpctl` / `pavucontrol`, ajuste o slider de Threshold do Gate para que a barra de nivel ultrapasse a linha do limiar apenas quando voce falar.

## Historico de atualizacoes

- **2026-11-03:** Correcao da especificacao dos caminhos de presets para `~/.local/share/easyeffects/input/` conforme a arquitetura XDG do EasyEffects 8+. Ajuste na documentacao para explicitar a diferenca entre o preset com DeepFilterNet (foco em IA / Krisp) e o preset com RNNoise (foco em economia de CPU).
- **2026-11-03:** Inclusao dos conteudos integrais dos arquivos JSON (`Discord-Broadcast.json` e `Discord-Broadcast-RNNoise.json`) para assegurar a autossuficiencia completa e reproducao do tweak sem depender de arquivos externos.
