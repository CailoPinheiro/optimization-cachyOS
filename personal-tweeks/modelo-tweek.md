# YYYY-MM-DD - [Título Descritivo da Tweak / Correção / Feature]

**Data:** YYYY-MM-DD  
**Status:** [Aplicado e consolidado | Aplicado — aguardando teste | Aplicado (Provisório) | etc.]

> **Instruções para o autor ou IA:**
> Este arquivo serve como MOLDE OFICIAL para qualquer documentação em `tweek-details/` ou `updated-tweeks/`.
> 1. Consulte este modelo ANTES de redigir ou atualizar qualquer tweak.
> 2. Preencha todas as seções obrigatórias. Não omita arquivos, scripts ou blocos de configuração.
> 3. Ao finalizar a documentação, realize a checagem cruzada contra a seção "Checklist de Qualidade (Quality Gate)" ao final deste modelo.
> 4. NUNCA utilize emojis em nenhuma seção ou explicação.

---

## Motivo

Explique de forma objetiva o contexto do problema ou da necessidade:
- Sintomas observados no sistema antes da tweak (erros, avisos em logs, comportamento inconsistente, travamentos ou ausência de funcionalidade);
- Comportamento indesejado vs. comportamento esperado;
- Em caso de configuração de hardware/áudio/vídeo: qual é a deficiência original e o que se pretende alcançar.

---

## Causa Raiz (opcional para features, obrigatório para correções de bugs)

Caso a tweak seja uma correção de erro ou contorno de conflito de sistema:
- Onde estava a falha original (arquivo, biblioteca, serviço, race condition, parâmetros incompatíveis entre versões);
- Diagnóstico técnico do mecanismo da falha.

---

## O que foi feito

Visão geral da solução implementada:
- Resumo das decisões de engenharia adotadas;
- Ordem lógica e arquitetura da cadeia de modificações;
- Justificativa das escolhas (ex.: uso de determinado plugin, serviço systemd em nível de usuário, regras de compilação ou flags de inicialização).

---

## Passo a passo (reprodução / re-aplicação)

Esta seção DEVE ser 100% autossuficiente. Qualquer usuário ou IA deve ser capaz de reproduzir exatamente o mesmo estado a partir de um sistema limpo, executando apenas o que está contido aqui.

### 1. Dependências e pacotes

Liste os comandos exatos de instalação (usando `pacman` ou `yay` conforme o caso):
```bash
sudo pacman -Sy --needed pacote1 pacote2
# ou yay -S --needed pacote-aur
```

### 2. Criação de diretórios necessários

```bash
mkdir -p ~/.config/exemplo ~/.local/share/exemplo
```

### 3. Conteúdo integral de todos os arquivos criados ou modificados

> **REGRA CRÍTICA DE AUTOSSUFICIÊNCIA:**
> NUNCA resuma com comentários como `// ... resto do código` ou `<!-- adicione as regras aqui -->`.
> É obrigatório expor o arquivo de configuração, script, unit systemd ou JSON em sua totalidade.

#### Arquivo: `~/.caminho/completo/arquivo.ext`

```ini
# Conteúdo completo do arquivo sem omissões
[Config]
opcao=valor
```

#### Script auxiliar (se aplicável): `~/.local/bin/nome-script`

```bash
#!/usr/bin/env bash
set -euo pipefail

# Conteúdo completo do script
```
Garantir permissão de execução:
```bash
chmod +x ~/.local/bin/nome-script
```

### 4. Ativação de serviços ou componentes (se aplicável)

```bash
systemctl --user daemon-reload
systemctl --user enable --now servico-exemplo.service
```

---

## Arquivos tocados

Lista consolidada de todos os caminhos absolutos ou relativos à home (`~`) tocados pela tweak:
- `~/.config/...`
- `~/.local/share/...`
- `~/dots-hyprland/...` (caso envolva alterações copiada via `./setup install-files`)

---

## Como verificar

Apresente comandos e testes práticos objetivos para validar se a tweak está funcionando como deveria:
1. Verificação de status via CLI ou serviços:
   ```bash
   systemctl --user status servico-exemplo.service
   # ou comando específico de validação
   ```
2. Verificação de pacotes instalados:
   ```bash
   pacman -Q pacote1 pacote2
   ```
3. Teste funcional prático (ex.: comportamento visual esperado, monitoramento de áudio, atalho de teclado).

---

## Como reverter

Passo a passo exato para desfazer completamente a alteração, garantindo que o sistema retorne ao estado anterior sem arquivos órfãos:
1. Parar e desativar serviços criados:
   ```bash
   systemctl --user disable --now servico-exemplo.service
   ```
2. Remover arquivos gerados:
   ```bash
   rm -f ~/.caminho/completo/arquivo.ext
   ```
3. Remover pacotes adicionados (caso não sejam mais necessários):
   ```bash
   sudo pacman -R pacote1 pacote2
   ```
4. Restaurar backup (se tiver sido feito em `bkp/`):
   ```bash
   cp bkp/arquivo.orig ~/.caminho/completo/arquivo
   ```

---

## Riscos e observações importantes

- Efeitos colaterais conhecidos ou premissas que não podem ser violadas;
- Se houver impacto em decisões imutáveis, registrar a necessidade de adicionar a regra correspondente em `lista.md`;
- Conflitos conhecidos com atualizações de pacotes upstream ou regras de dotfiles (`~/dots-hyprland`).

---

## Histórico de atualizações

- **YYYY-MM-DD:** Criação da tweak inicial e documentação.
- **YYYY-MM-DD:** [Se houver evolução/correção, registre a data e o que mudou, mantendo o Princípio da Finalidade Única].

---

## Checklist de Qualidade (Quality Gate)

Antes de finalizar qualquer documento de tweak, compare o arquivo gerado com esta lista:

- [ ] O nome do arquivo segue o padrão `YYYY-MM-DD-slug-curto.md` em `tweek-details/` (ou `updated-tweeks/`)?
- [ ] A entrada correspondente foi inserida ou atualizada na tabela de `lista.md`?
- [ ] Se a alteração introduzir uma decisão que não deve ser revertida sem autorização do usuário, ela foi descrita na seção "Decisoes que nao devem ser revertidas sem o usuario pedir" em `lista.md`?
- [ ] Não há emojis no arquivo?
- [ ] Todos os arquivos criados ou modificados têm seu **conteúdo integral** exposto no documento (sem reticências ou supressões)?
- [ ] Os caminhos de arquivos estão explícitos e corretos (ex.: distinção entre `~/.config/` e `~/.local/share/`)?
- [ ] O passo a passo de reversão está completo e funcional?
- [ ] Os comandos de verificação foram listados e testados?
