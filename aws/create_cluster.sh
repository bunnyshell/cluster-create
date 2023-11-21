#!/bin/bash

set -e

# Initialize the script
echo "Initializing EFS setup script."

# Function to check if a command is installed
check_command() {
  echo "Verifying if $1 is installed."
  command -v "$1" >/dev/null 2>&1
}

# Check if watch is installed
if check_command "watch"; then
  echo "'watch' is installed."
else
  echo "'watch' is not installed. Please install it using your package manager."
fi

# Check if jq is installed
if check_command "jq"; then
  echo "'jq' is installed."
else
  echo "'jq' is not installed. Please install it using your package manager."
fi

# Create EFS file system
echo "Creating EFS file system."
export FILE_SYSTEM_ID=$(aws efs create-file-system --out json| jq --raw-output '.FileSystemId')

# Check the LifeCycleState
echo "Verifying LifeCycleState of the EFS."
aws efs describe-file-systems --file-system-id $FILE_SYSTEM_ID

# Extract the DNS name of the EFS
echo "Extracting DNS name of the EFS."
export EFS_DNS_NAME=$FILE_SYSTEM_ID.efs.$AWS_REGION.amazonaws.com

# Fetch VPC and CIDR information
echo "Fetching VPC and CIDR information."
export VPC_ID=$(aws eks describe-cluster --name $EKS_CLUSTER_NAME --query "cluster.resourcesVpcConfig.vpcId" --output text)
export CIDR_BLOCK=$(aws ec2 describe-vpcs --vpc-ids $VPC_ID --query "Vpcs[].CidrBlock" --output text)

# Create a security group for the EFS mount targets
echo "Creating security group for EFS mount targets."
MOUNT_TARGET_GROUP_NAME="eks-efs-group-${EKS_CLUSTER_NAME}"
MOUNT_TARGET_GROUP_DESC="NFS access to EFS from EKS worker nodes"
MOUNT_TARGET_GROUP_ID=$(aws ec2 create-security-group --group-name $MOUNT_TARGET_GROUP_NAME --description "$MOUNT_TARGET_GROUP_DESC" --vpc-id $VPC_ID --out json | jq --raw-output '.GroupId')
aws ec2 authorize-security-group-ingress --group-id $MOUNT_TARGET_GROUP_ID --protocol tcp --port 2049 --cidr $CIDR_BLOCK

# Create mount targets in public subnets
echo "Creating mount targets in public subnets."
TAG1=tag:alpha.eksctl.io/cluster-name
TAG2=tag:kubernetes.io/role/elb
subnets=($(aws ec2 describe-subnets --filters "Name=$TAG1,Values=$EKS_CLUSTER_NAME" "Name=$TAG2,Values=1" --out json | jq --raw-output '.Subnets[].SubnetId'))
for subnet in ${subnets[@]}
do
    echo "Creating mount target in subnet: $subnet."
    aws efs create-mount-target --file-system-id $FILE_SYSTEM_ID --subnet-id $subnet --security-groups $MOUNT_TARGET_GROUP_ID --no-cli-pager
done

# Wait for mount targets to become available
echo "Waiting for mount targets to become available."
while true; do
    output=$(aws efs describe-mount-targets --file-system-id $FILE_SYSTEM_ID --out json | jq --raw-output '.MountTargets[].LifeCycleState')
    if [[ $output == *"available"* ]]; then
        echo "All mount targets are now available."
        break
    fi
    echo "Mount targets are not yet available. Retrying in 2 seconds."
    sleep 2
done

# Add Helm repository
echo "Adding Helm repository."
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/

# Install Helm chart
echo "Installing Helm chart."
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=$EFS_DNS_NAME \
    --set nfs.path=/ \
    --set storageClass.name=bns-network-sc

