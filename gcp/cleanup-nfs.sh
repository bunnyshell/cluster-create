#!/bin/bash

# Confirm to proceed
read -p "This will delete resources. Do you want to proceed? (y/n): " PROCEED
if [[ "$PROCEED" != "y" ]]; then
  echo "Exiting script."
  exit 1
fi

# Prompt for required variables
read -p "Enter the cluster name: " CLUSTER_NAME
read -p "Enter the disk name (usually nfs-gke-disk): " DISK_NAME
read -p "Enter the region: " REGION
read -p "Enter the zone (optional): " ZONE

# Delete Helm Chart
helm uninstall nfs-subdir-external-provisioner

# Delete NFS Service
kubectl delete -f nfs-clusterip-service.yaml

# Delete NFS Deployment
kubectl delete -f nfs-server-deployment.yaml

# Delete GCloud Disk
if [ -z "$ZONE" ]; then
  gcloud compute disks delete --region=${REGION} ${DISK_NAME} --quiet
else
  gcloud compute disks delete --region=${REGION} --zone=${ZONE} ${DISK_NAME} --quiet
fi

# Delete temporary files
rm -f nfs-server-deployment.yaml nfs-clusterip-service.yaml my-values.yaml

echo "Cleanup complete."
