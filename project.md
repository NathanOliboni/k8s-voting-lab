
# 🗺️ Plano de Voo: Projeto Kubernetes - Voting App Customizada

Este documento detalha a arquitetura, a estrutura de pastas e o passo a passo para construir, conteinerizar e orquestrar uma versão customizada da clássica *Voting App*, com foco em aprendizado de Kubernetes.

## 🏗️ Arquitetura do Projeto
1. **Vote App (Java/Spring Boot):** API e interface web para receber os votos.
2. **Fila (Redis):** Armazenamento em memória ultra-rápido para receber os votos da Vote App.
3. **Worker (Java):** Processo em background que consome do Redis e grava no banco.
4. **Banco de Dados (PostgreSQL):** Armazenamento persistente dos votos consolidados.
5. **Result App (Node.js + Custom Frontend):** Aplicação que lê o banco de dados e exibe o placar (personalizada via K8s ConfigMap).

---

## 📁 Estrutura de Pastas Recomendada

Crie uma pasta principal para o seu projeto (ex: `k8s-voting-project`). Dentro dela, estruture da seguinte forma:

```text
k8s-voting-project/
│
├── k8s/                            # ☸️ Todos os manifestos do Kubernetes
│   ├── 01-postgres.yaml            # Deployment, Service e PersistentVolume do BD
│   ├── 02-redis.yaml               # Deployment e Service do Redis
│   ├── 03-worker.yaml              # Deployment do Worker Java
│   ├── 04-vote-app.yaml            # Deployment e Service da API Java
│   ├── 05-result-app.yaml          # Deployment, Service e ConfigMap do Node.js
│   └── 06-frontend-config.yaml     # ConfigMap com o seu HTML/CSS personalizado
│
├── src/                            # 💻 Código fonte e Dockerfiles
│   ├── java-vote-app/              # Projeto Spring Boot (Votação)
│   │   ├── src/
│   │   ├── pom.xml (ou build.gradle)
│   │   └── Dockerfile
│   │
│   ├── java-worker/                # Projeto Java puro ou Spring (Processamento)
│   │   ├── src/
│   │   ├── pom.xml
│   │   └── Dockerfile
│   │
│   └── node-result-app/            # Projeto Node.js (Placar)
│       ├── package.json
│       ├── server.js
│       └── Dockerfile
│
└── README.md                       # Documentação do seu projeto
```

---

## 🚀 Roteiro de Execução (Passo a Passo)

A regra de ouro do Kubernetes é subir a infraestrutura de baixo para cima (da base de dados até as interfaces web).

### Fase 0: Preparação do Terreno
- [ ] Instalar Docker na máquina local.
- [ ] Instalar o Kubernetes local (Minikube ou Kind).
- [ ] Instalar a CLI do Kubernetes (`kubectl`).
- [ ] Garantir que o cluster local esteja rodando (ex: `minikube start`).

### Fase 1: A Camada de Dados (PostgreSQL e Redis)
**Objetivo:** Ter os bancos rodando e acessíveis para as futuras aplicações e para o DBeaver.
- [ ] Escrever `k8s/01-postgres.yaml` (Definir variáveis de ambiente para usuário e senha, e expor a porta 5432).
- [ ] Aplicar no cluster: `kubectl apply -f k8s/01-postgres.yaml`.
- [ ] Validar acesso externo via DBeaver usando Port-Forward:
      `kubectl port-forward svc/postgres-service 5432:5432`
- [ ] Escrever `k8s/02-redis.yaml` (Expor porta 6379).
- [ ] Aplicar no cluster: `kubectl apply -f k8s/02-redis.yaml`.

### Fase 2: O Motor (Java Worker)
**Objetivo:** Criar o aplicativo que conecta o Redis ao Postgres.
- [ ] Desenvolver a lógica no diretório `src/java-worker/` (ler do Redis e fazer `INSERT` no Postgres).
- [ ] Testar a aplicação localmente garantindo que se comunique com os bancos no K8s (usando os port-forwards).
- [ ] Escrever o `Dockerfile` para empacotar o Worker.
- [ ] Fazer o *build* da imagem e enviar para um Registry (ou carregar direto no Minikube/Kind).
- [ ] Escrever `k8s/03-worker.yaml` passando as URLs do banco e do Redis via `env`.
- [ ] Aplicar no cluster. Como o worker não recebe requisições externas, ele não precisa de um `Service`.

### Fase 3: A Entrada de Dados (Java Vote App)
**Objetivo:** Interface para capturar votos e jogar na fila.
- [ ] Criar a API REST em `src/java-vote-app/` para receber o voto (ex: endpoint `/votar`).
- [ ] Fazer com que o endpoint grave o voto no Redis.
- [ ] Escrever o `Dockerfile`, fazer o *build* e empacotar a imagem.
- [ ] Escrever `k8s/04-vote-app.yaml` configurando o Service como `NodePort` para que você possa acessar do seu navegador.
- [ ] Aplicar no cluster e testar se consegue enviar um voto pelo navegador.

### Fase 4: O Placar e a Customização (Node Result App + ConfigMap)
**Objetivo:** Exibir os dados do banco em uma tela com HTML/CSS injetados dinamicamente.
- [ ] Desenvolver a aplicação base em `src/node-result-app/` para ler o Postgres e servir arquivos estáticos.
- [ ] Escrever o `Dockerfile`, empacotar a imagem base do Node.js.
- [ ] Criar o seu arquivo HTML customizado e envelopar dentro do arquivo `k8s/06-frontend-config.yaml` usando a estrutura de `ConfigMap`.
- [ ] Escrever `k8s/05-result-app.yaml` mapeando (Volume Mount) o `ConfigMap` para dentro da pasta do Node.js onde o HTML deveria ficar.
- [ ] Configurar o Service como `NodePort`.
- [ ] Aplicar tudo no cluster.

### Fase 5: Teste Integrado e Validação
- [ ] Abrir a Vote App no navegador (Porta NodePort do Vote App).
- [ ] Abrir a Result App em outra aba (Porta NodePort do Result App).
- [ ] Clicar para votar e observar o fluxo: *Java Vote -> Redis -> Java Worker -> Postgres -> Node Result (Atualização da tela).*
- [ ] Abrir o DBeaver, conectar no Postgres e validar se a tabela está populando corretamente.