#!/bin/bash
cd ..
AKS_PRINCIPAL_ID=$(terraform output -raw aks_principal_id)
RESOURCE_GROUP_NAME=$(terraform output -raw resource_group_name)
AKS_CLUSTER_NAME=$(terraform output -raw aks_cluster_name)

get_context() {
	az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $AKS_CLUSTER_NAME --overwrite-existing
	if [ $? -ne 0 ]; then
		echo "failed to get creds"
		exit 1
	else
		kubectl get pods -A
		exit 0
	fi
}
get_context
