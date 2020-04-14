
all: argocd/install.yaml

argocd/install.yaml:
	curl -sSL https://raw.githubusercontent.com/argoproj/argo-cd/v1.5.0/manifests/install.yaml > argocd/install.yaml

install:
	kubectl create namespace argocd
	kubectl apply -n argocd -f argocd/install.yaml
	kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd

	kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2

	kubectl port-forward svc/argocd-server -n argocd 8080:443

sync:
	argocd login localhost:8080 \
		--insecure \
		--username admin \
		--password $$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)

	argocd app create app \
		--dest-namespace argocd \
		--dest-server https://kubernetes.default.svc \
		--repo https://github.com/nokamoto/poc-argocd-git.git \
		--revision app-of-apps \
		--path argocd/app

	argocd app sync apps  

destroy:
	kubectl delete namespace argocd
	kubectl delete namespace development
	kubectl delete namespace production
