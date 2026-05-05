#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Erro: comando obrigatorio nao encontrado: $1" >&2
    exit 1
  fi
}

for cmd in docker kind kubectl; do
  require_cmd "$cmd"
done

read -r -p "Nome do cluster Kind [voto-lab]: " KIND_CLUSTER
KIND_CLUSTER="${KIND_CLUSTER:-voto-lab}"

CURRENT_CONTEXT="$(kubectl config current-context 2>/dev/null || true)"
if [[ -z "$CURRENT_CONTEXT" ]]; then
  echo "Erro: nenhum contexto kubectl ativo." >&2
  exit 1
fi

echo "Contexto atual: $CURRENT_CONTEXT"
read -r -p "Versao (ex: v2) ou Enter para manter a mesma tag dos deployments: " VERSION_INPUT

declare -A BUILD_CONTEXTS=(
  [vote-app]="./src/java-vote-app"
  [worker]="./src/java-worker"
  [result-app]="./src/node-result-app"
)

declare -A DEPLOYMENTS=(
  [vote-app]="vote-app"
  [worker]="worker"
  [result-app]="result-app"
)

declare -A CONTAINERS=(
  [vote-app]="vote-app"
  [worker]="worker"
  [result-app]="result-app"
)

get_current_image() {
  local deploy_name="$1"
  kubectl get deployment "$deploy_name" -o jsonpath='{.spec.template.spec.containers[0].image}'
}

get_image_tag() {
  local image_ref="$1"
  if [[ "$image_ref" == *":"* ]]; then
    echo "${image_ref##*:}"
  else
    echo "local"
  fi
}

declare -A TARGET_IMAGES

for app in vote-app worker result-app; do
  if [[ -n "$VERSION_INPUT" ]]; then
    TARGET_IMAGES["$app"]="${app}:${VERSION_INPUT}"
  else
    current_image="$(get_current_image "${DEPLOYMENTS[$app]}")"
    current_tag="$(get_image_tag "$current_image")"
    TARGET_IMAGES["$app"]="${app}:${current_tag}"
  fi
done

echo
echo "Imagens alvo:"
for app in vote-app worker result-app; do
  echo "  - $app -> ${TARGET_IMAGES[$app]}"
done
echo

for app in vote-app worker result-app; do
  echo "Buildando ${TARGET_IMAGES[$app]}..."
  docker build -t "${TARGET_IMAGES[$app]}" "${BUILD_CONTEXTS[$app]}"
done

for app in vote-app worker result-app; do
  echo "Carregando ${TARGET_IMAGES[$app]} no Kind (${KIND_CLUSTER})..."
  kind load docker-image "${TARGET_IMAGES[$app]}" --name "$KIND_CLUSTER"
done

echo "Aplicando manifests..."
kubectl apply -f k8s/

if [[ -n "$VERSION_INPUT" ]]; then
  for app in vote-app worker result-app; do
    echo "Atualizando deployment/${DEPLOYMENTS[$app]} para ${TARGET_IMAGES[$app]}..."
    kubectl set image "deployment/${DEPLOYMENTS[$app]}" \
      "${CONTAINERS[$app]}=${TARGET_IMAGES[$app]}"
  done
else
  echo "Mantendo mesma tag: forçando novo rollout dos deployments..."
  kubectl rollout restart deployment/vote-app deployment/worker deployment/result-app
fi

for deploy in vote-app worker result-app; do
  echo "Aguardando rollout de deployment/$deploy..."
  kubectl rollout status "deployment/$deploy"
done

echo
echo "Subindo port-forwards em background..."
kubectl port-forward --address 0.0.0.0 svc/vote-app-service 18080:8080 >/tmp/pf-vote-app.log 2>&1 &
PF_VOTE_PID=$!
kubectl port-forward --address 0.0.0.0 svc/result-app-service 13000:3000 >/tmp/pf-result-app.log 2>&1 &
PF_RESULT_PID=$!
kubectl port-forward --address 0.0.0.0 svc/postgres-service 15432:5432 >/tmp/pf-postgres.log 2>&1 &
PF_PG_PID=$!

cleanup() {
  echo
  echo "Encerrando port-forwards..."
  for pid in "$PF_VOTE_PID" "$PF_RESULT_PID" "$PF_PG_PID"; do
    if kill -0 "$pid" >/dev/null 2>&1; then
      kill "$pid"
    fi
  done
}

trap cleanup EXIT INT TERM

sleep 2
for pid in "$PF_VOTE_PID" "$PF_RESULT_PID" "$PF_PG_PID"; do
  if ! kill -0 "$pid" >/dev/null 2>&1; then
    echo "Erro: um ou mais port-forwards falharam ao iniciar." >&2
    echo "Logs:"
    echo "  - /tmp/pf-vote-app.log"
    echo "  - /tmp/pf-result-app.log"
    echo "  - /tmp/pf-postgres.log"
    exit 1
  fi
done

echo "Port-forwards ativos:"
echo "  - Vote App   -> http://localhost:18080"
echo "  - Result App -> http://localhost:13000"
echo "  - Postgres   -> localhost:15432"
echo
echo "Pressione Ctrl+C para encerrar os port-forwards."
wait

