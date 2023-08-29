# Create AWS Cluster using eksctl

The repository serves as a comprehensive toolkit for automating the deployment and configuration of a Kubernetes cluster on AWS via eksctl. This repository contains a series of scripts and configuration files that are engineered to provide a seamless, efficient way to get a Kubernetes cluster up and running. It is tailored to meet the needs of professionals across the spectrum—from DevOps engineers responsible for maintaining large-scale infrastructures, to backend developers looking to deploy microservices in a Kubernetes environment.

## How to Use

### Export AWS and EKS Variables

Kick things off by setting up your AWS and EKS environment variables. This ensures that the scripts know which AWS profile and region to use, as well as the desired cluster name and Kubernetes version.

```bash
export AWS_PROFILE=<aws-cli-profile-name>
export AWS_REGION=<aws-region-here>
export EKS_CLUSTER_NAME=<cluster-name-here>
export EKS_KUBE_VERSION=<kubernetes-version>
```

### Tweak eksctl_template.yaml

Before you proceed, you might want to customize the `eksctl_template.yaml` file. This YAML file allows you to specify configurations for managed node groups, add extra addons, and more.

### Generate the eksctl Config File

Once you've made your tweaks, generate the final eksctl configuration file by substituting the environment variables from the template.

```bash
envsubst < eksctl_template.yaml > eksctl_final.yaml
```

### Create the Cluster

Now, it's time to create your Kubernetes cluster. This step will take approximately 10 minutes, so it's a good time for a coffee break.

```bash
eksctl create cluster -f eksctl_final.yaml
```

### Add Cluster to your kubectl Configuration

After the cluster is up and running, integrate it into your `kubectl` configuration by downloading the config from AWS.

```bash
aws eks update-kubeconfig --region $AWS_REGION --name $EKS_CLUSTER_NAME
```

### Create the Disk (EBS) Storage Class

Set up the EBS storage class for your cluster using the following command:

```bash
kubectl create -f k8s/sc_disk.yaml
```

To test the storage class:

```bash
kubectl create -f k8s/test_ebs.yaml
kubectl get pvc
```

### Configure EFS Storage with `create_cluster.sh`

The `create_cluster.sh` script is a comprehensive utility that automates the creation of an EFS file system, configures the necessary security groups and mount targets, and installs the nfs-subdir-external-provisioner via Helm.

To execute the script:

```bash
chmod +x create_cluster.sh
sudo ./create_cluster.sh
```

### Finally, Test EFS is Working

To validate that your EFS storage is properly configured:

```bash
kubectl create -f k8s/test_efs.yaml
kubectl get pvc
```

---

Feel free to add this enhanced README to your repository. Let me know if you need further refinements.