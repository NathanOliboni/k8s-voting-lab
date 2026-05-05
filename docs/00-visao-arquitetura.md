# Visao e Arquitetura - Voting App Kubernetes

## Objetivo
Construir uma Voting App customizada para aprendizado de Kubernetes em ambiente local, cobrindo build, containerizacao, deploy e validacao fim a fim.

## Componentes
- Vote App (Java/Spring Boot): recebe votos e envia para o Redis.
- Redis: fila em memoria para votos.
- Worker (Java): consome votos do Redis e grava no Postgres.
- Postgres: persistencia dos votos.
- Result App (Node.js): le placar no Postgres e exibe UI customizada via ConfigMap.

## Fluxo de Dados
Usuario -> Vote App -> Redis -> Worker -> Postgres -> Result App -> UI

## Topologia (Kubernetes)
- Namespaces: default (lab local).
- Services:
  - Redis: ClusterIP.
  - Postgres: ClusterIP.
  - Vote App: NodePort.
  - Result App: NodePort.
- Configuracoes:
  - Secrets: credenciais do Postgres.
  - ConfigMap: HTML/CSS do Result App.

## Decisoes Tecnicas (resumo)
- Ambiente alvo: cluster local (Minikube/Kind).
- Exposicao externa: NodePort (simplicidade no lab).
- Configuracao: Secrets/ConfigMaps para evitar hardcode.

## Criterios de Sucesso
- Votar na UI e ver atualizacao no placar.
- Registros no Postgres confirmados via consulta.
- Deploy reproducivel com manifests.

