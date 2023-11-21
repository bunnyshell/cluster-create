#!/bin/bash

# Variables
echo "🐰 Setting up variables"
RESOURCE_GROUP_NAME="Customer"
CLUSTER_NAME="myAKSCluster"
LOCATION="eastus"
NODE_COUNT=3
NODE_VM_SIZE="Standard_DS2_v2"

# Prompt for resource group name
read -p "Enter the Resource Group name (default: Customer): " input
RESOURCE_GROUP_NAME=${input:-$RESOURCE_GROUP_NAME}

# Prompt for cluster name
read -p "Enter the Cluster name (default: myAKSCluster): " input
CLUSTER_NAME=${input:-$CLUSTER_NAME}

# Prompt for location
read -p "Enter the location (default: eastus): " input
LOCATION=${input:-$LOCATION}

# Prompt for node count
read -p "Enter the node count (default: 3): " input
NODE_COUNT=${input:-$NODE_COUNT}

# Prompt for VM size
read -p "Enter the VM size (default: Standard_DS2_v2): " input
NODE_VM_SIZE=${input:-$NODE_VM_SIZE}

# Create a resource group
echo "🐰 Creating resource group"
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create AKS cluster
echo "🐰 Creating AKS cluster"
az aks create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $CLUSTER_NAME \
  --node-count $NODE_COUNT \
  --node-vm-size $NODE_VM_SIZE \
  --kubernetes-version $KUBERNETES_VERSION \
  --generate-ssh-keys

# Get credentials to access the cluster
echo "🐰 Getting cluster credentials"
az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME

# Verify connection to the cluster
echo "🐰 Verifying connection to the cluster"
kubectl get nodes
