
all: argocd/install.yaml

argocd/install.yaml:
	curl -sSL https://raw.githubusercontent.com/argoproj/argo-cd/v1.5.0/manifests/install.yaml > argocd/install.yaml

install:
	kubectl create namespace argocd
	kubectl apply -n argocd -f argocd/install.yaml
	kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd
	kubectl port-forward svc/argocd-server -n argocd 8080:443

destroy:
	kubectl delete namespace argocd

projects:
	kubectl create namespace development
	kubectl create namespace production
