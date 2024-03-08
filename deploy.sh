#!/bin/bash
# This script deploys a tzkt

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Please install kubectl and try again."
    exit 1
else
    echo "kubectl is installed."
fi

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo "Helm is not installed. Please install Helm and try again."
    exit 1
else
    echo "helm install installed."
fi

current_context=$(kubectl config current-context)
# Check if the current context is set to Minikube
if [ "$current_context" != "minikube" ]; then
    echo "kubectl is not configured to use the Minikube cluster. Set the context to Minikube using 'kubectl config use-context minikube' and try again."
    exit 1
fi

# Check if the Bitnami repository is already added
bitnami_repo=$(helm repo list | grep "bitnami" | awk '{print $1}')
if [ "$bitnami_repo" != "bitnami" ]; then
    echo "Bitnami repository is not added. Adding Bitnami repository..."

    # Add the Bitnami Helm repository
    helm repo add bitnami https://charts.bitnami.com/bitnami

    # Update the Helm repositories
    helm repo update

    echo "Bitnami repository added successfully."
else
    echo "Bitnami repository is already added."
fi

TZKT_POSTGRES_RELEASE="tzkt-postgres"

if ! helm list -q | grep -wq "${TZKT_POSTGRES_RELEASE}"; then
  helm install --values values-postgres.yaml "${TZKT_POSTGRES_RELEASE}" bitnami/postgresql
else
  helm upgrade --values values-postgres.yaml "${TZKT_POSTGRES_RELEASE}" bitnami/postgresql
fi
