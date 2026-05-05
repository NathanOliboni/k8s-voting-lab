# k8s-voting-lab

Lab pratico de Kubernetes com aplicacao de votacao distribuida (Java, Redis, PostgreSQL e Node.js), incluindo automacao de deploy local e base para CI/CD com GitHub Actions.

## Arquitetura

1. **Vote App (Java/Spring Boot):** recebe votos pela interface web/API.
2. **Redis:** fila de votos.
3. **Worker (Java):** consome a fila e persiste no banco.
4. **PostgreSQL:** armazenamento de votos.
5. **Result App (Node.js):** exibe resultado agregado.

Fluxo: `Vote App -> Redis -> Worker -> PostgreSQL -> Result App`

## Estrutura do projeto

```text
k8s/
src/
docs/
scripts/
```

## Pre-requisitos

- Docker
- Kind (ou Minikube)
- kubectl

## Como executar localmente (Kind)

1. Criar cluster:

```bash
kind create cluster --name voto-lab
kubectl config use-context kind-voto-lab
```

2. Rodar release/deploy + port-forward automatico:

```bash
./scripts/release-and-port-forward.sh
```

3. Acessos:
- Vote App: `http://localhost:18080`
- Result App: `http://localhost:13000`
- Postgres: `localhost:15432`

## Documentacao

- `docs/03-diario-andamento.md` - historico do projeto
- `docs/04-validacao.md` - validacao fim a fim
- `docs/05-manual-atualizacao-imagem-k8s.md` - atualizacao de imagens

## Convencao de commits

### Branches

- Prefixos permitidos: `feature`, `fix`, `hotfix`, `chore`
- Formato obrigatorio: `<prefixo>/NNNNN` (5 digitos)
- Exemplo: `feature/01234`

#### Quando usar cada prefixo

- `feature`: nova funcionalidade ou melhoria funcional.
- `fix`: correcao de bug em fluxo normal de desenvolvimento.
- `hotfix`: correcao urgente de problema critico em producao/homologacao.
- `chore`: manutencao tecnica (scripts, docs, CI/CD, configuracoes), sem nova regra de negocio.

### Commit final (merge/squash)

- Deve iniciar com `#REFS:NNNNN` (formato estrito e case-sensitive)
- `NNNNN` deve ser igual ao numero da branch
- Descricao obrigatoria apos o identificador, sem tipo no commit
- Regra validada localmente e no GitHub Actions

Exemplo valido:

```bash
#REFS:01234 integra fluxo de deploy automatizado
```

### Titulo do Pull Request

- Deve seguir o mesmo padrao do commit final: `#REFS:NNNNN descricao`

Exemplo valido:

```text
#REFS:01234 integra fluxo de deploy automatizado
```

### Politica da branch `main`

- Push direto na `main` deve ser bloqueado.
- Alteracoes entram apenas via Pull Request aprovado e validado.

