ARGOCD_VERSION ?= v2.13.3
.PHONY: lint test validate ci kind-up bootstrap kind-down
lint:
	helm lint --strict charts/web-service
	helm lint --strict argocd/apps
test:
	helm unittest charts/web-service argocd/apps
validate:
	./scripts/validate.sh
ci: lint test validate
kind-up:
	kind create cluster --name gitops
	kubectl create namespace argocd
	kubectl apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/$(ARGOCD_VERSION)/manifests/install.yaml
bootstrap:
	kubectl apply -n argocd -f argocd/root-app.yaml
kind-down:
	kind delete cluster --name gitops
