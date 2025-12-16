# Kubernetes Bootstrap Ansible Role

This Ansible role bootstraps a Kubernetes cluster by deploying and configuring essential plugins and services using Helm charts and raw manifests. It sets up critical components such as `ingress-nginx`, `cert-manager`, `MinIO`, `Velero`, `Prometheus`, `Loki`, and `ArgoCD` to prepare your Kubernetes cluster for production use. The role is designed to be flexible, customizable, and production-ready.

## Features
- **Helm Chart Deployment**:
  - `ingress-nginx`: Kubernetes ingress controller for external traffic routing.
  - `cert-manager`: Automated certificate management with Let's Encrypt.
  - `kube-prometheus-stack`: Comprehensive monitoring with Prometheus, Grafana, and Alertmanager.
  - `minio`: Object storage for backups and data persistence.
  - `velero`: Backup and restore solution for Kubernetes resources.
  - `loki-stack`: Log aggregation with Loki and Promtail.
  - `argo-cd`: GitOps-based continuous delivery for Kubernetes.
- **Raw Manifest Deployment**: Applies custom Kubernetes manifests from a specified directory.
- **MinIO Configuration**: Creates a dedicated bucket, user, and policy for Velero backups.
- **TLS Support**: Configures TLS certificates via `cert-manager` for secure ingress endpoints.
- **Customizable Variables**: Supports extensive configuration for domains, resources, and credentials.

## Requirements
To use this role, ensure the following prerequisites are met:

- **Ansible**: Version 2.9 or higher.
- **Ansible Collections**:
  - `kubernetes.core`: For Helm and Kubernetes manifest management.
  - `amazon.aws`: For S3 bucket operations with MinIO.
- **Python Packages**:
  - `boto3`: For AWS-compatible S3 operations with MinIO.
  - `botocore`: Dependency for `boto3`.
  - `kubernetes`: For interacting with Kubernetes APIs.
- **Kubernetes Cluster**: A running Kubernetes cluster with a valid `kubeconfig` file.
- **Helm**: Installed on the control node for managing Helm charts.
- **Proxy Environment (Optional)**: Configure `proxy_env` if operating behind a proxy.

Install the required dependencies:
```bash
ansible-galaxy collection install kubernetes.core amazon.aws
pip3 install boto3 botocore kubernetes
```

## Installation
Install the role directly from Ansible Galaxy:
```bash
ansible-galaxy role install AhmadRafiee.kubernetes_bootstrap
```

Alternatively, clone the role from the Git repository:
```bash
git clone https://github.com/AhmadRafiee/ansible-role-kubernetes-bootstrap.git
```

## Role Variables
The role uses variables defined in `defaults/main.yml` and `vars/vault.yml` for configuration. Below is a summary of key variables:

### General Variables
| Variable                  | Description                              | Default Value                     |
|---------------------------|------------------------------------------|-----------------------------------|
| `general.main_domain`     | Main domain for service endpoints        | `dena.mecan.ir`                  |
| `general.pull_policy`     | Image pull policy for containers         | `IfNotPresent`                   |
| `general.manifest_directory` | Directory for Kubernetes manifests     | `roles/bootstrap-kubernetes/manifests` |

### Kubernetes Variables
| Variable                     | Description                              | Default Value           |
|------------------------------|------------------------------------------|-------------------------|
| `kubernetes.context`         | Kubernetes context to use                | `dena`                  |
| `kubernetes.kubeconfig_path` | Path to kubeconfig file                  | `~/.kube/config`        |

### Helm Charts
The `kubernetes_helm_charts` list defines Helm charts to deploy. Each chart includes:
- `name`: Chart name (e.g., `ingress-nginx`).
- `repository_url`: Helm repository URL.
- `chart`: Chart reference.
- `namespace`: Target namespace.
- `chart_version`: Specific chart version.
- `values_file_path_jinja`: Path to the Jinja2 template for Helm values.
- `values_file_path_yaml`: Destination for rendered Helm values file.

Example:
```yaml
kubernetes_helm_charts:
  - name: ingress-nginx
    repository_url: https://kubernetes.github.io/ingress-nginx
    chart: ingress-nginx
    namespace: ingress-nginx
    create_namespace: true
    state: present
    chart_version: "v4.13.0"
    wait: true
    update_repo_cache: true
    replace: true
    values_file_path_jinja: values-ingress.yaml.j2
    values_file_path_yaml: /tmp/values-ingress.yaml
```

### MinIO Configuration
| Variable                       | Description                              | Default Value                     |
|-------------------------------|------------------------------------------|-----------------------------------|
| `minio.image.repo`            | MinIO image repository                   | `quay.io/minio/minio`            |
| `minio.image.tag`             | MinIO image tag                          | `RELEASE.2025-09-07T16-13-09Z`   |
| `minio.endpoint.api`          | MinIO API endpoint                       | `object`                         |
| `minio.endpoint.console`      | MinIO console endpoint                   | `minio`                          |
| `minio.alias_name`            | MinIO alias name                         | `dena`                           |
| `minio_root_username`         | MinIO root username (vault)              | Sensitive (vault)                |
| `minio_root_password`         | MinIO root password (vault)              | Sensitive (vault)                |

### Velero Configuration
| Variable                        | Description                              | Default Value                     |
|--------------------------------|------------------------------------------|-----------------------------------|
| `velero.minio.bucket_name`     | Bucket for Velero backups                | `velero-backup`                  |
| `velero.minio.username`        | Velero MinIO user                        | Sensitive (vault)                |
| `velero.minio.password`        | Velero MinIO password                    | Sensitive (vault)                |
| `velero.minio.policy_name`     | Velero MinIO policy name                 | `velero`                         |

### Monitoring (Prometheus, Grafana, Alertmanager)
| Variable                              | Description                              | Default Value                     |
|--------------------------------------|------------------------------------------|-----------------------------------|
| `monitoring.prometheus.endpoint`      | Prometheus endpoint                      | `prometheus`                     |
| `monitoring.prometheus.pvc_capacity`  | Prometheus PVC size                      | `25Gi`                           |
| `monitoring.grafana.endpoint`         | Grafana endpoint                         | `grafana`                        |
| `monitoring.grafana.pvc_capacity`     | Grafana PVC size                         | `15Gi`                           |
| `grafana_root_username`              | Grafana admin username (vault)           | Sensitive (vault)                |
| `grafana_root_password`              | Grafana admin password (vault)           | Sensitive (vault)                |

### ArgoCD
| Variable                    | Description                              | Default Value                     |
|----------------------------|------------------------------------------|-----------------------------------|
| `argocd.endpoint`          | ArgoCD endpoint                          | `argocd`                         |
| `argocd.image.repo`        | ArgoCD image repository                  | `quay.io/argoproj/argocd`        |
| `argocd.image.tag`         | ArgoCD image tag                         | `v2.12.13`                       |
| `argocd_admin_password`    | ArgoCD admin password (bcrypt, vault)    | Sensitive (vault)                |

### Loki
| Variable                 | Description                              | Default Value                     |
|-------------------------|------------------------------------------|-----------------------------------|
| `loki.pvc_capacity`     | Loki PVC size                            | `25Gi`                           |
| `loki.image.repo`       | Loki image repository                    | `grafana/loki`                   |
| `loki.image.tag`        | Loki image tag                           | `2.9.3`                          |

## Usage
1. **Install the Role**:
   Install the role from Ansible Galaxy or clone it from the Git repository as described above.

2. **Configure Variables**:
   Customize variables in your playbook or inventory. Sensitive data (e.g., `minio_root_username`, `grafana_root_password`) should be stored in an Ansible Vault-encrypted file.

3. **Create a Playbook**:
Example playbook to bootstrap a Kubernetes cluster:
```yaml
---
- name: bootstrap kubernetes cluster
  hosts: localhost
  become: false
  gather_facts: false
  vars:
    proxy_env:
      http_proxy: http://<Your_Proxy_address>:<Port>
      https_proxy: http://<Your_Proxy_address>:<Port>
  roles:
    - bootstrap-kubernetes
```

4. **Run the Playbook**:
   Execute the playbook with Ansible:
   ```bash
   ansible-playbook playbook.yml --vault-password-file vault_pass.txt
   ```

## Tags
Use tags to run specific tasks:
- `bootstrap_kubernetes`: Run all tasks.
- `setup_plugins`: Install and configure Helm charts.
- `add_helm_repo`: Add Helm repositories.
- `render_values_file`: Render Helm values files from templates.
- `deploy_manifest`: Deploy raw Kubernetes manifests.
- `minio_configuration`: Configure MinIO (bucket, user, policy).

Example:
```bash
ansible-playbook playbook.yml --tags "setup_plugins,minio_configuration"
```

## Notes
- **Sensitive Data**: Store sensitive variables (e.g., `minio_root_username`, `grafana_root_password`) in an Ansible Vault-encrypted file to ensure security.
- **Manifest Directory**: Ensure the `general.manifest_directory` contains valid Kubernetes manifests (e.g., `cluster-issuer.yaml`).
- **Jinja2 Templates**: All referenced templates (e.g., `values-ingress.yaml.j2`) must exist in the `templates/` directory.
- **Versioning**: Check the role's version in Ansible Galaxy to ensure you're using the desired release (e.g., `v1.0.0`).

## Contributing
Contributions are welcome! Please submit issues or pull requests to the [GitHub repository](https://github.com/ahmadrafiee/ansible-role-kubernetes-bootstrap).

## License
This role is licensed under the [MIT License](https://opensource.org/licenses/MIT).

## Support
For issues or questions, open an issue on the [GitHub repository](https://github.com/ahmadrafiee/ansible-role-kubernetes-bootstrap) or contact the author at [rafiee1001@gmail.ir](mailto:rafiee1001@gmail.ir).