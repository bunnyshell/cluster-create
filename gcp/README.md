# GKE Cluster Setup Script

## Introduction

This script is designed to simplify the process of setting up a Google Kubernetes Engine (GKE) cluster using the Google Cloud SDK (gcloud) command-line tools. It guides you through the configuration of your project, creation of a GKE cluster, and the setup of essential service accounts.

## Prerequisites

- **Google Cloud SDK (gcloud):** Ensure that you have the Google Cloud SDK installed on your machine. You can download and install it from [here](https://cloud.google.com/sdk/docs/install).
- **kubectl:** Make sure you have the Kubernetes command-line tool `kubectl` installed. You can install it using the instructions provided [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

## Usage

1. Clone this repository or download the script: `git clone https://github.com/your-username/gke-cluster-setup-script.git`.
2. Navigate to the script directory: `cd gke-cluster-setup-script`.
3. Make the script executable: `chmod +x gke-cluster-setup.sh`.
4. Run the script: `./gke-cluster-setup.sh`.

The script will guide you through the setup process interactively. It will prompt you for the following details:

1. Google Cloud project configuration: You can either use the preset configuration or create a new project.
2. Enabling the Containers API: If not already enabled, you'll be prompted to enable it.
3. GKE cluster details: Name, region, and node size for your GKE cluster.
4. Service Account setup: The script will create a Service Account and grant it access to your GKE cluster.
5. Additional Information: The script will display the Cloud Region, Cluster URL, Certificate, and Project ID.

## Cleanup Script

This repository also includes a cleanup script (`cleanup.sh`) that allows you to delete all the resources created by the main script:

1. Run the script `cleanup.sh`.
2. Follow the prompts to confirm the deletion of resources.

Please note that running the cleanup script will irreversibly delete the GKE cluster, Service Account, and related resources. Use it with caution.

## Additional Information

After running the script, your GKE cluster will be ready for action! The script will also provide you with essential information such as the Cloud Region, Cluster URL, Certificate, and Project ID.

Absolutely, let's document that script so even future-you will know what's going on. Here's a README section:

---

## NFS Setup Script for GKE

### Description

This Bash script automates the process of setting up an NFS server on a Google Kubernetes Engine (GKE) cluster. It performs the following tasks:

1. Checks if `gcloud`, `kubectl`, and `helm` CLI tools are installed.
2. Informs you about the current `gcloud` profile you're operating under and asks for confirmation to proceed.
3. Prompts for various parameters like cluster name, disk size, region, and zone.
4. Creates a GCloud Disk with the specified parameters.
5. Deploys an NFS server on the GKE cluster.
6. Creates a ClusterIP service for the NFS server.
7. Installs the `nfs-subdir-external-provisioner` Helm chart to manage NFS subdirectories.

### Prerequisites

- Google Cloud SDK (`gcloud`)
- Kubernetes Command-Line Tool (`kubectl`)
- Helm Package Manager (`helm`)

### Usage

1. **Download the Script**: Download `setup_nfs.sh` to your local machine.

2. **Make it Executable**: Run `chmod +x setup_nfs.sh` to make the script executable.

3. **Run the Script**: Execute the script by running `./setup_nfs.sh`.

4. **Follow the Prompts**: The script will ask you to enter various parameters. Provide the required information when prompted.

