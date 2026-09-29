# Terraria: Performance Fix e Diagnóstico

**Data**: 2026-09-28
**Status**: Aplicado

## Motivo

Terraria apresentava performance consistente entre 33 e 51 FPS, independentemente da resolução, com uso de GPU muito baixo (20%), sugerindo gargalo de CPU (thread simples).

## O que foi feito

1. **Diagnóstico do Hardware**: Identificado que a falta de bateria força a CPU ao limite mínimo por segurança do fabricante (sem Turbo). P-Cores travam em 1.3 GHz e E-Cores em 0.9 GHz.
2. **Ajuste de Escalonamento (Taskset)**: Como Terraria exige alta performance em uma thread, forçamos o jogo a rodar exclusivamente nos P-Cores (núcleos 0 a 3) para evitar que o sistema o agende nos E-Cores (0.9 GHz), o que causava as maiores quedas.
3. **Recomendação de Versão Nativa**: Recomendado ao usuário trocar o uso do Proton pela versão Nativa de Linux, que remove a camada de tradução do Wine/DXVK e alivia brutalmente o peso sobre a CPU limitada.
4. **Monitoramento**: Configurado o MangoHud com suporte a `core_load`.

## Como realizar (Passo a passo)

### 1. Fixar o Jogo nos P-Cores (Taskset) e Monitorar

Nas opções de inicialização do Terraria na Steam, ajuste para:

```text
mangohud taskset -c 0-3 %command%
```

*(Isso garante que o jogo use os núcleos mais potentes, trabalhando a 1.3 GHz e com maior IPC, em vez dos anêmicos 0.9 GHz).*

### 2. Versão Nativa vs Proton (Dependência da Bateria)

A decisão de usar o Proton ou a versão Nativa no Terraria varia de acordo com o limite físico de energia (presença ou ausência de bateria). A fixação nos P-Cores (`taskset -c 0-3`) é **obrigatória** em ambos cenários para que o jogo não caia nos núcleos fracos (E-Cores), mas a regra de compatibilidade muda:

- **Para máquinas SEM bateria (Seu Caso):**
  Como a CPU está amarrada pela placa-mãe no relógio mínimo de segurança (ex: 1.3 GHz), **você NÃO pode usar o Proton**. Tentar aplicar camada de emulação e tradução visual do DirectX via DXVK usa todos ciclos preciosos que restam.
  *Alvo:* Na Steam (Propriedades > Compatibilidade), **desmarque** a forçagem de uso de ferramentas de compatibilidade e rode estritamente a Versão Nativa.

- **Para máquinas COM bateria:**
  Tendo a bateria validada na placa, o Turbo Boost da CPU escala normalmente (atingindo ex: +3.0 GHz). Graças a esse espaço massivo de processamento bruto isolado no P-Core, **é jogar com Proton** não terá lags pesados no Terraria via Linux.
  *Ressalva Importante:* Usar a camada do Proton irá causar com que a CPU precise trabalhar forte traduzindo a lógica da engine com clock agressivo; isso gerará notavelmente **mais calor** e maior gasto elétrico prolongado do que se optarem pela Versão Nativa mais eficiente.

### 3. Evitar Câmera Lenta (In-Game)

- No jogo, vá em Configurações de Vídeo e defina **Frame Skip** para `On` ou `Subtle`. Assim, se o FPS cair para 50, o jogo não entrará em câmera lenta, apenas pulará frames visuais.

## Arquivos tocados

- `~/.config/MangoHud/MangoHud.conf` (adicionado `core_load`)
- `~/.local/share/Steam/userdata/*/config/localconfig.vdf` (ajustado LaunchOptions do Terraria para usar `taskset -c 0-3`)

## Notas Avançadas (Risk)

Laptops sem bateria costumam receber sinalização falsa de superaquecimento (`BD_PROCHOT`) via firmware. Desativar isso via registros MSR (como com a ferramenta `throttled` ou escrevendo no MSR `0x1FC`) pode desbloquear o clock. **Porém, se a fonte for fraca para suprir picos (ex.: 45W em picos de 65W), desativar essa trava causa desligamentos abruptos (blackouts/brownouts).** Não implementado por segurança.
