# Terraform Configuration for Helm Charts and MinIO Integration

This Terraform configuration automates the deployment of multiple Helm charts (e.g., `ingress-nginx`, `cert-manager`, `minio`, `velero`, `loki`, `prometheus-stack`, `argo-cd`) on a Kubernetes cluster, along with setting up a MinIO bucket and IAM resources for Velero backups. The configuration uses a modular approach to manage Helm releases, Kubernetes manifests, and MinIO resources, with variables defined in `variables.tf` for customization.

## Table of Contents
- [Terraform Configuration for Helm Charts and MinIO Integration](#terraform-configuration-for-helm-charts-and-minio-integration)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Directory Structure](#directory-structure)
  - [Configuration Details](#configuration-details)
  - [Variables](#variables)
  - [Outputs](#outputs)
  - [Usage](#usage)
  - [Verification](#verification)
  - [Troubleshooting](#troubleshooting)
  - [🔗 Stay connected with DockerMe! 🚀](#-stay-connected-with-dockerme-)

## Overview
This Terraform module:
- Deploys Helm charts specified in `charts.yml` to a Kubernetes cluster.
- Creates namespaces for each Helm chart.
- Applies Kubernetes manifests from the `manifests/` directory.
- Configures a MinIO bucket and IAM user/policy for Velero backups.
- Uses the `templatefile` function to inject variables (e.g., `main_domain`, `minio_server`, `velero_bucket_name`) into Helm values files.

The configuration is designed for a Kubernetes environment with MinIO as the S3-compatible storage for Velero backups, and it supports observability and CI/CD through tools like Prometheus, Loki, and ArgoCD.

## Prerequisites
- **Terraform**: Version `>= 1.0`.
- **Kubernetes Cluster**: A running Kubernetes cluster with `kubeconfig` configured.
- **Helm**: The Helm provider requires access to a Kubernetes cluster.
- **MinIO**: A MinIO server accessible at the specified `minio_server` endpoint (e.g., `object.dena.mecan.ir:443`).
- **kubectl**: For verifying deployments (optional).

Ensure the following tools are installed:
```bash
terraform --version
kubectl --version
```

## Directory Structure
```plaintext
├── charts.yml
├── main.tf
├── manifests
│   ├── alertmanager-webauth.yaml
│   ├── cluster-issuer.yaml
│   └── prometheus-webauth.yml
├── output.tf
├── provider.tf
├── ReadMe.md
├── values
│   ├── values-argocd.yaml
│   ├── values-certmanager.yaml
│   ├── values-ingress.yaml
│   ├── values-loki.yaml
│   ├── values-minio.yaml
│   ├── values-monitoring.yaml
│   └── values-velero.yaml
└── variables.tf
```

## Configuration Details
- **charts.yml**: Defines the Helm charts to deploy, including their repositories, versions, namespaces, and dependencies. Each chart uses a values file (e.g., `values-velero.yaml`) for customization.
- **main.tf**:
  - Reads `charts.yml` to configure Helm releases.
  - Creates Kubernetes namespaces for each chart.
  - Applies Helm charts with values rendered from `.yaml` files using `templatefile`.
  - Deploys Kubernetes manifests from the `manifests/` directory.
  - Sets up a MinIO bucket (`velero-backups`), IAM user (`velero-user`), and policy (`velero-backup-policy`) for Velero backups.
- **provider.tf**: Configures the `helm`, `kubernetes`, and `minio` providers, using variables like `minio_server` and `kube_config_path`.
- **variables.tf**: Defines input variables like `main_domain`, `minio_server`, `minio_root_username`, `velero_bucket_name`, etc.
- **output.tf**: Provides outputs for deployed Helm charts, manifests, and MinIO resources (bucket, user, policy).

## Variables
The following variables are defined in `variables.tf` and can be overridden in a `terraform.tfvars` file or via CLI arguments (`-var`):

| Variable                | Description                                    | Type   | Default Value                     |
|-------------------------|-----------------------------------------------|--------|-----------------------------------|
| `main_domain`           | Main domain for Helm values (e.g., ingress)   | string | `dena.mecan.ir`                  |
| `minio_server`          | MinIO API endpoint (hostname:port)           | string | `object.dena.mecan.ir:443`       |
| `minio_root_username`   | MinIO root access key                        | string | `fiNscYkugIx4KMI0jLr41yIP`     |
| `minio_root_password`   | MinIO root secret key                        | string | `M66IZ3u5ezjbwyocgDo3NPDxQ5cz7WIEV7Llt5G` |
| `grafana_password`      | Grafana admin password                       | string | `P25OhzpS5qL34cdtzMb4du40KgsGdhUJEOeDxIu` |
| `velero_bucket_name`    | Name of the MinIO bucket for Velero backups   | string | `velero-backups`                 |
| `velero_minio_username` | Username for Velero MinIO user               | string | `velero-user`                    |
| `velero_minio_password` | Password for Velero MinIO user               | string | `JpxUBnJnoLGDaUN3mnQ7jGLStk29MUg8LWro0QC` |
| `velero_policy_name`    | Name of the MinIO policy for Velero          | string | `velero-backup-policy`           |

**Note**: Sensitive variables (e.g., `minio_root_password`, `grafana_password`) should be managed securely, e.g., via a secrets manager or environment variables.

## Outputs
The following outputs are defined in `output.tf`:

| Output                  | Description                                    |
|-------------------------|-----------------------------------------------|
| `deployed_charts`       | Details of deployed Helm charts (name, namespace, version, status) |
| `all_manifests_metadata` | Metadata of applied Kubernetes manifests      |
| `bucket_name`           | Name of the MinIO bucket for Velero           |
| `username`              | ID of the Velero MinIO IAM user              |
| `user_status`           | Status of the Velero MinIO IAM user          |
| `policy_raw`            | Raw JSON policy for the Velero MinIO policy   |

## Usage
1. **Clone the Repository** (if applicable):
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Set Up Variables** (optional):
   Create a `terraform.tfvars` file to override default variables:
   ```hcl
   main_domain = "yourdomain.com"
   minio_server = "object.yourdomain.com:443"
   minio_root_username = "your-minio-username"
   minio_root_password = "your-minio-password"
   grafana_password = "your-grafana-password"
   velero_bucket_name = "your-velero-bucket"
   velero_minio_username = "your-velero-user"
   velero_minio_password = "your-velero-password"
   velero_policy_name = "your-velero-policy"
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Plan the Deployment**:
   ```bash
   terraform plan
   ```

5. **Apply the Configuration**:
   ```bash
   terraform apply
   ```
   Alternatively, pass variables via CLI:
   ```bash
   terraform apply -var="main_domain=yourdomain.com" -var="minio_server=object.yourdomain.com:443"
   ```

6. **Verify Outputs**:
   ```bash
   terraform output
   ```

## Verification
- **Helm Charts**:
  Check deployed Helm releases:
  ```bash
  helm list -A
  ```
  Verify specific chart deployments:
  ```bash
  kubectl get pods -n minio
  kubectl get pods -n velero
  kubectl get ingress -A
  ```

- **MinIO Bucket and IAM**:
  Verify the Velero bucket:
  ```bash
  kubectl get backupstoragelocation -n velero
  ```
  Use the MinIO CLI or UI to confirm the bucket (`velero-backups`) and user (`velero-user`) exist.

- **Ingress**:
  Check ingress resources:
  ```bash
  kubectl get ingress -A
  ```
  Ensure domains like `velero.yourdomain.com` or `argo-cd.yourdomain.com` are accessible.

## Troubleshooting
- **Error: "Endpoint url cannot have fully qualified paths"**:
  - Ensure `minio_server` in `variables.tf` or `terraform.tfvars` is set to a valid hostname and port (e.g., `object.yourdomain.com:443`), without protocol (`https://`) or paths (`/api`).
  - Example: `minio_server = "object.dena.mecan.ir:443"`.

- **MinIO Authentication Issues**:
  - Verify `minio_root_username` and `minio_root_password` match the credentials of your MinIO server.
  - Check if `minio_ssl = true` matches your MinIO server's SSL configuration.

- **Helm Chart Failures**:
  - Check Helm release status:
    ```bash
    helm status <chart-name> -n <namespace>
    ```
  - Ensure dependencies (e.g., `cert-manager`) are deployed before dependent charts.

- **Kubernetes Manifest Issues**:
  - Verify manifests in the `manifests/` directory are valid YAML.
  - Check applied manifests:
    ```bash
    kubectl get -f manifests/<manifest-file>.yaml
    ```

For further assistance, check the Terraform logs or contact the repository maintainer.

## 🔗 Stay connected with DockerMe! 🚀

**Subscribe to our channels, leave a comment, and drop a like to support our content. Your engagement helps us create more valuable DevOps and cloud content!** 🙌

[![Site](https://img.shields.io/badge/Dockerme.ir-0A66C2?style=for-the-badge&logo=docker&logoColor=white)](https://dockerme.ir/) [![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/ahmad-rafiee/) [![Telegram](https://img.shields.io/badge/telegram-0A66C2?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/dockerme) [![YouTube](https://img.shields.io/badge/youtube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtube.com/@dockerme) [![Instagram](https://img.shields.io/badge/instagram-FF0000?style=for-the-badge&logo=instagram&logoColor=white)](https://instagram.com/dockerme)

