#!/bin/bash

# Check if required CLI tools are installed
for cmd in gcloud kubectl helm; do
  if ! command -v $cmd &> /dev/null; then
    echo "$cmd could not be found. Please install it to proceed."
    exit 1
  fi
done

# Inform the user about the current gcloud profile
CURRENT_GCLOUD_PROFILE=$(gcloud config get-value account)
echo "You are currently operating under the gcloud profile: $CURRENT_GCLOUD_PROFILE"

# Confirm to proceed
read -p "Do you want to proceed with this profile? (y/n): " PROCEED
if [[ "$PROCEED" != "y" ]]; then
  echo "Exiting script."
  exit 1
fi

# Prompt for required variables
read -p "Enter the cluster name: " CLUSTER_NAME
read -p "Enter the disk size (in GB): " SIZE
read -p "Enter the region: " REGION
read -p "Enter the zone (optional): " ZONE
echo "Select disk type (pd-standard|pd-balanced|pd-ssd|pd-extreme): "
read -p "Disk type: " DISK_TYPE

# Create GCloud Disk
if [ -z "$ZONE" ]; then
  gcloud compute disks create --size=${SIZE}GB --region=${REGION} nfs-gke-disk --labels=ORIGIN=gke-cluster-bns-${CLUSTER_NAME} --type=${DISK_TYPE}
else
  gcloud compute disks create --size=${SIZE}GB --region=${REGION} --zone=${ZONE} nfs-gke-disk --labels=ORIGIN=gke-cluster-bns-${CLUSTER_NAME} --type=${DISK_TYPE}
fi

# Create NFS Deployment YAML
cat <<EOL > nfs-server-deployment.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nfs-server
spec:
  replicas: 1
  selector:
    matchLabels:
      role: nfs-server
  template:
    metadata:
      labels:
        role: nfs-server
    spec:
      containers:
      - name: nfs-server
        image: gcr.io/google_containers/volume-nfs:0.8
        ports:
          - name: nfs
            containerPort: 2049
          - name: mountd
            containerPort: 20048
          - name: rpcbind
            containerPort: 111
        securityContext:
          privileged: true
        volumeMounts:
          - mountPath: /nfs
            name: nfs-pvc
      volumes:
        - name: nfs-pvc
          gcePersistentDisk:
            pdName: nfs-disk
            fsType: ext4
EOL

# Apply NFS Deployment
kubectl create -f nfs-server-deployment.yaml

# Create NFS Service YAML
cat <<EOL > nfs-clusterip-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nfs-server
spec:
  ports:
    - name: nfs
      port: 2049
    - name: mountd
      port: 20048
    - name: rpcbind
      port: 111
  selector:
    role: nfs-server
EOL

# Apply NFS Service
kubectl create -f nfs-clusterip-service.yaml

# Add Helm Repo and Install NFS Subdir External Provisioner
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/

# Create Helm values file
cat <<EOL > my-values.yaml
nfs:
  mountOptions:
  - nfsvers=4.1
  - proto=tcp
  path: /nfs
  server: nfs-server.default.svc.cluster.local
storageClass:
  name: bns-network-sc
EOL

# Install Helm Chart
helm install -f my-values.yaml nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner