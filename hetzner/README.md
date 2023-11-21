# Hetzner Cloud Kubernetes Setup Guide

Get your Kubernetes cluster up and running on Hetzner Cloud with these quick steps.

## Prerequisites

Before starting, make sure you have:

- A Hetzner Cloud account. [Sign up here](https://www.hetzner.com/).
- Terraform, Packer (for initial setup), kubectl CLI, and hcloud installed. Install them using Homebrew:

  ```bash
  brew install terraform packer kubectl hcloud
  ```

## Initial Setup

1. **Create a Hetzner Cloud Project**: In your Hetzner Cloud Console, go to Security > API Tokens and create a Read &
   Write API key.

2. **Generate an SSH Key Pair**: Create an ed25519 SSH key pair without a passphrase. Note down the file paths of your
   keys.

3. **Setup Project Directory**: Run this command to set up your project directory. It creates a new folder with
   necessary files and starts the MicroOS snapshot creation:

   ```bash
   tmp_script=$(mktemp) && curl -sSL -o "${tmp_script}" https://raw.githubusercontent.com/kube-hetzner/terraform-hcloud-kube-hetzner/master/scripts/create.sh && chmod +x "${tmp_script}" && "${tmp_script}" && rm "${tmp_script}"
   ```

   Optionally, save this as an alias in your shell for future use:

   ```bash
   alias createkh='tmp_script=$(mktemp) && curl -sSL -o "${tmp_script}" https://raw.githubusercontent.com/kube-hetzner/terraform-hcloud-kube-hetzner/master/scripts/create.sh && chmod +x "${tmp_script}" && "${tmp_script}" && rm "${tmp_script}"'
   ```

Alright, let's append the Kubernetes cluster creation steps using k3s to the README:

## Creating the Kubernetes Cluster with k3s

This section guides you through setting up a Kubernetes cluster using k3s.

### Prerequisite

Ignore the `kube.tf` file generated in Step 3 of the Initial Setup.

### Step 1: Create `secrets.tfvars`

1. **Create a `secrets.tfvars` File**: This file will store your sensitive data. Create a file named `secrets.tfvars`
   with the following content. Be sure to update the values with your own:

   ```hcl
   hcloud_token = ""
   ssh_private_key = <<EOF
   -----BEGIN OPENSSH PRIVATE KEY-----
   b3BlbnNza...cy1NQlAB
   -----END OPENSSH PRIVATE KEY-----
   EOF
   ssh_public_key = "ssh-ed25519 AAA..."
   cluster_name = "k8s-cluster"
   control_plane_server_type = ""
   control_plane_location = ""
   workloads_server_type = ""
   workloads_location = ""
   workloads_min_nodes = 2
   workloads_max_nodes = 5
   ```

### Step 2: Initialize and Apply Terraform

2. **Run Terraform Commands**: In the root folder of your project, execute the following Terraform commands. This will
   set up your Kubernetes cluster:

   ```bash
   terraform init
   terraform plan # Optional, to preview changes
   terraform apply --var-file=secrets.tfvars
   ```

### Step 3: Set Up Persistent Storage

3. **Configure Persistent Storage**:
   - Navigate to the `bns_volume_sc` folder.
   - Start by renaming `secrets.tfvars.example` to `secrets.tfvars` and update it with your specific values from the
     kube config file generated during setup.

   Here's an example structure for `secrets.tfvars`:

   ```hcl
   host="<insert your value here>"
   cluster_ca_certificate="<insert your value here>"
   client_key="<insert your value here>"
   client_certificate="<insert your value here>"
   namespace="By default this is set to the default namespace, if you wish to create a separation please create the bunnyshell namespace and set this value to bunnyshell."
   ```

   Replace the placeholder text with your actual data.

   - After setting up your `secrets.tfvars`, run the following Terraform commands in the `bns_volume_sc` folder to
     initialize and apply your configuration:

     ```bash
     terraform init
     terraform plan # Optional, to preview changes
     terraform apply --var-file=secrets.tfvars
     ```

   This will set up the necessary persistent storage for your Kubernetes cluster.

---

That's it! Your Kubernetes cluster setup on Hetzner Cloud is ready to go. 🚀

