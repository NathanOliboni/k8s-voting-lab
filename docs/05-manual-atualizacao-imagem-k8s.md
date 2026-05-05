## Manual de Atualizacao de Imagens no Kubernetes (contexto deste projeto)

Este guia cobre o fluxo para atualizar as imagens `vote-app`, `worker` e `result-app` no cluster local usado neste repositorio.

### Premissas
- Contexto Kubernetes ativo (ex.: `kind-voto-lab`).
- Deploys existentes com nomes:
  - `vote-app`
  - `worker`
  - `result-app`

### 1) Atualizar codigo
Faça as alteracoes no app desejado em `src/`.

### 2) Gerar nova imagem local com tag versionada
Use tag nova a cada release local para evitar cache:

```bash
docker build -t vote-app:v2 ./src/java-vote-app
docker build -t worker:v2 ./src/java-worker
docker build -t result-app:v2 ./src/node-result-app
```

### 3) Carregar imagens no Kind
```bash
kind load docker-image vote-app:v2 --name voto-lab
kind load docker-image worker:v2 --name voto-lab
kind load docker-image result-app:v2 --name voto-lab
```

### 4) Atualizar Deployments para a nova tag
```bash
kubectl set image deployment/vote-app vote-app=vote-app:v2
kubectl set image deployment/worker worker=worker:v2
kubectl set image deployment/result-app result-app=result-app:v2
```

### 5) Acompanhar rollout
```bash
kubectl rollout status deployment/vote-app
kubectl rollout status deployment/worker
kubectl rollout status deployment/result-app
```

### 6) Conferir versao em execucao
```bash
kubectl get deploy vote-app worker result-app -o=jsonpath='{range .items[*]}{.metadata.name}{" => "}{.spec.template.spec.containers[0].image}{"\n"}{end}'
```

### Fluxo rapido (quando mantiver a tag `:local`)
Se optar por rebuild com a mesma tag (ex.: `vote-app:local`), faca:

```bash
docker build -t vote-app:local ./src/java-vote-app
kind load docker-image vote-app:local --name voto-lab
kubectl rollout restart deployment/vote-app
kubectl rollout status deployment/vote-app
```

> Com a mesma tag, o restart do deployment e necessario para forcar novo pod com a imagem recarregada no node do Kind.

### Automacao com script (recomendado)
Para reduzir passos manuais e subir os 3 port-forwards sem abrir 3 terminais:

```bash
./scripts/release-and-port-forward.sh
```

O script:
- pergunta o nome do cluster Kind (default `voto-lab`);
- pergunta a versao (ex.: `v3`) ou permite manter a mesma tag atual;
- builda as 3 imagens, carrega no Kind e atualiza os deployments;
- aguarda o rollout;
- sobe automaticamente os port-forwards:
  - `18080 -> vote-app-service:8080`
  - `13000 -> result-app-service:3000`
  - `15432 -> postgres-service:5432`

Para encerrar os port-forwards, pressione `Ctrl+C`.
