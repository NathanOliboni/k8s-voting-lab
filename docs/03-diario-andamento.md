# Diario de Andamento

Registro cronologico das principais entregas e decisoes do projeto.

## Entradas

| Data | Atividade | Decisao | Motivo | Evidencia |
| --- | --- | --- | --- | --- |
| 2026-04-30 | Estruturada base do projeto e docs iniciais | Criar templates de visao, OKRs e ADRs | Facilitar rastreio do que foi feito e por que | Pastas `docs/` e `adrs/` criadas |
| 2026-04-30 | Criados manifests de Postgres e Redis | Usar Secret e PVC no Postgres | Padrao de configuracao e persistencia local | `k8s/01-postgres.yaml` e `k8s/02-redis.yaml` (validacao pendente) |
| 2026-04-30 | Implementado Worker Java e manifest | Usar Jedis + JDBC com tabela criada no startup | Simplicidade para demo e persistencia imediata | `src/java-worker` e `k8s/03-worker.yaml` |
| 2026-04-30 | Implementado Vote App e manifest | Usar Spring Boot + Jedis com UI simples | Rapidez para expor API e pagina de voto | `src/java-vote-app` e `k8s/04-vote-app.yaml` |
| 2026-04-30 | Implementado Result App e ConfigMap | Usar Express + pg com HTML customizavel | Facilitar UI e troca via ConfigMap | `src/node-result-app`, `k8s/05-result-app.yaml`, `k8s/06-frontend-config.yaml` |
| 2026-04-30 | Criado guia de validacao manual | Documentar passos de build/deploy/teste | Facilitar reproducao do fluxo fim a fim | `docs/04-validacao.md` |
| 2026-05-05 | Ajustado botao de resultados na Vote App + manual de update de imagem | Redirecionar para Result App por porta e padronizar atualizacao de imagem no Kind | Integracao local entre apps em portas diferentes e operacao mais simples de deploy | `src/java-vote-app/src/main/resources/static/index.html` e `docs/05-manual-atualizacao-imagem-k8s.md` |
| 2026-05-05 | Criado script de release/deploy com port-forward automatico | Unificar build, load no Kind, rollout e port-forward em uma execucao | Eliminar abertura manual de 3 terminais e reduzir erros operacionais | `scripts/release-and-port-forward.sh` |
| 2026-05-05 | Refinada convencao de branches/commits/PR | Padrao final `#REFS:NNNNN descricao` no commit final e no titulo do PR, com numero vinculado a branch | Garantir rastreabilidade por chamado e padronizacao para validacoes locais e no Actions | `README.md` |
| 2026-05-05 | Configurado CODEOWNERS com owner unico | Definir revisao centralizada para `main` com `@NathanOliboni` como responsavel | Reforcar governanca de merge e consistencia de aprovacao | `.github/CODEOWNERS` e `README.md` |

