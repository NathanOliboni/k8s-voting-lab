# ADR-0001: Ambiente local e exposicao NodePort

## Contexto
O projeto tem foco em aprendizado e execucao local (lab). Precisa ser simples para rodar e acessar as UIs.

## Decisao
Usar cluster local (Minikube/Kind) e expor Vote App e Result App via NodePort.

## Alternativas Consideradas
- LoadBalancer: exige integrais especificas e pode nao funcionar localmente.
- Ingress: adiciona camadas extras (controller e DNS local).

## Impactos
- Simplicidade para acessar as UIs no lab.
- Menos configuracao de rede e dependencias externas.

## Justificativa
NodePort atende o objetivo de aprendizado com menor esforco operacional.

