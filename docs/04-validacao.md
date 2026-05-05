## Validacao do Fluxo Fim a Fim (Kind, manual)

Este guia mostra como fazer build, deploy e teste local usando Kind.

### 0) Pre-requisitos
- Docker em execucao.
- Kind instalado.
- kubectl instalado.
- Evite misturar `sudo kubectl` com `kubectl` sem sudo (isso cria kubeconfigs diferentes).

### 1) Criar cluster Kind
No diretorio raiz do projeto:

```bash
kind create cluster --name voto-lab
kubectl config use-context kind-voto-lab
kubectl cluster-info
```

### 2) Build das imagens
```bash
docker build -t vote-app:local ./src/java-vote-app
docker build -t worker:local ./src/java-worker
docker build -t result-app:local ./src/node-result-app
```

> Se a imagem Node falhar em `npm ci`, gere lockfile em `src/node-result-app`:
>
> ```bash
> cd src/node-result-app
> npm install
> cd ../..
> ```

### 3) Carregar imagens no Kind
```bash
kind load docker-image vote-app:local --name voto-lab
kind load docker-image worker:local --name voto-lab
kind load docker-image result-app:local --name voto-lab
```

### 4) Aplicar manifests
```bash
kubectl apply -f k8s/01-postgres.yaml -f k8s/02-redis.yaml -f k8s/03-worker.yaml -f k8s/06-frontend-config.yaml -f k8s/05-result-app.yaml -f k8s/04-vote-app.yaml
```

Alternativa:

```bash
kubectl apply -f k8s/
```

### 5) Verificar deploy
```bash
kubectl get pods -o wide
kubectl get svc
kubectl get endpoints
```

Esperado: pods `Running` e endpoints preenchidos para `vote-app-service`, `result-app-service` e `postgres-service`.

### 6) Acesso via port-forward (Kind)
Abra 3 terminais e rode um comando em cada:

```bash
kubectl port-forward --address 0.0.0.0 svc/vote-app-service 18080:8080
kubectl port-forward --address 0.0.0.0 svc/result-app-service 13000:3000
kubectl port-forward --address 0.0.0.0 svc/postgres-service 15432:5432
```

URLs:
- Vote App: `http://localhost:18080`
- Result App: `http://localhost:13000`

### 7) Validacao funcional
Enviar voto:

```bash
curl -i -X POST http://127.0.0.1:18080/votar \
  -H "Content-Type: application/json" \
  -d '{"vote":"cats"}'
```

Conferir placar:

```bash
curl -i http://127.0.0.1:13000/results
```

Conferir no Postgres:

```sql
SELECT vote, COUNT(*) FROM votes GROUP BY vote;
```

### 8) Troubleshooting rapido
- `error: no context exists with the name kind-voto-lab`  
  Confira contextos com `kubectl config get-contexts` e recrie o cluster sem sudo.
- `flag needs an argument: 'f' in -f`  
  O comando `kubectl apply` foi quebrado em linha. Rode em uma unica linha.
- `port-forward` falha  
  Verifique `kubectl get endpoints`; se estiver `<none>`, o pod da app nao esta pronto.
- `address already in use`  
  Troque apenas a porta local (lado esquerdo), ex.: `28080:8080`.

