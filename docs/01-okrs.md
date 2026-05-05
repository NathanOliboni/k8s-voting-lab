# OKRs do Projeto

## Objetivo 1: Ter a arquitetura base funcionando no cluster local
Resultados-chave:
- KR1: Postgres e Redis implantados com manifests e validacao via port-forward.
- KR2: Worker consumindo do Redis e gravando no Postgres.
- KR3: Vote App e Result App acessiveis via NodePort.

Status: Em andamento (manifests e apps criados; deploy pendente)

## Objetivo 2: Fluxo fim a fim validado
Resultados-chave:
- KR1: Voto enviado aparece no placar em menos de 3 segundos.
- KR2: Tabela de votos no Postgres atualiza a cada voto.
- KR3: Evidencias registradas no Diario de Andamento.

Status: Pendente validacao manual

## Objetivo 3: Documentacao tecnica e de decisoes completa
Resultados-chave:
- KR1: Visao/Arquitetura publicada.
- KR2: ADRs registrados para decisoes chave.
- KR3: Diario de andamento atualizado a cada fase.

Status: Em andamento (templates criados e diario atualizado)

