# OpenStack Bootstrap with Terraform

This Terraform project automates the deployment of an OpenStack environment, provisioning resources such as networks, subnets, routers, flavors, images, keypairs, projects, users, roles, quotas, and compute instances (both from images and volumes). It provides a structured and scalable way to bootstrap an OpenStack cloud infrastructure.

## Table of Contents
- [OpenStack Bootstrap with Terraform](#openstack-bootstrap-with-terraform)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Directory Structure](#directory-structure)
  - [Configuration Details](#configuration-details)
    - [Providers](#providers)
    - [Flavors](#flavors)
    - [Images](#images)
    - [Keypairs](#keypairs)
    - [Networks and Subnets](#networks-and-subnets)
    - [Router](#router)
    - [Projects and Users](#projects-and-users)
    - [Instances](#instances)
  - [Outputs](#outputs)
  - [Usage](#usage)
  - [Variables](#variables)
  - [🔗 Stay connected with DockerMe! 🚀](#-stay-connected-with-dockerme-)

## Overview
This project uses Terraform to deploy and manage OpenStack resources. It includes:
- Creation of custom compute flavors.
- Uploading and managing disk images (e.g., Ubuntu, Debian, Cirros).
- Provisioning of keypairs for SSH access.
- Setting up public and private networks with subnets and a router.
- Defining projects, users, roles, and quotas.
- Deploying compute instances from both images and volumes.

The configuration is modular, allowing for easy customization through variable files (e.g., `.auto.tfvars`).

## Prerequisites
To use this Terraform configuration, ensure the following:
- **Terraform**: Version >= 0.14.0.
- **OpenStack Provider**: Version ~> 1.53.0.
- **OpenStack Environment**: Access to an OpenStack cloud with credentials (username, password, auth URL, tenant name, and region).
- **Public Key Files**: SSH public keys must be available in the `keys/` directory for keypair provisioning.
- **Image Files**: Disk images (e.g., `.qcow2` format) must be accessible at the specified paths in `image.auto.tfvars`.

## Directory Structure
```
├── instance-from-image.tf        # Provisions instances from images
├── instance-from-volume.tf       # Provisions instances from volumes
├── flavor.tf                     # Defines custom flavors
├── image.tf                      # Manages image uploads
├── keypair.tf                    # Manages SSH keypairs
├── network.tf                    # Configures networks and subnets
├── router.tf                     # Sets up router and interfaces
├── project.tf                    # Manages projects, users, roles, and quotas
├── providers.tf                  # Terraform provider configuration
├── output.tf                     # Output variables for resource IDs and details
├── variables.tf                  # Variable definitions
├── instance-image.auto.tfvars    # Instance configurations from images
├── instance-volume.auto.tfvars   # Instance configurations from volumes
├── image.auto.tfvars             # Image configurations
├── network.auto.tfvars           # Network and subnet configurations
├── projects.auto.tfvars          # Project, user, and quota configurations
└── keys/                         # Directory for SSH public key files
```

## Configuration Details

### Providers
The `providers.tf` file configures the OpenStack provider with the following settings:
- **Auth URL**: `https://vip.multi.mecan.ir:5000`
- **Tenant Name**: `admin`
- **Region**: `RegionOne`
- **Insecure**: Set to `false` for secure connections.

### Flavors
The `flavor.tf` file defines custom compute flavors (`Tiny`, `Small`, `Medium`, `Large`) with varying RAM, vCPUs, and disk sizes. These are configurable via the `flavors` variable in `variables.tf`.

### Images
The `image.tf` and `image.auto.tfvars` files manage the upload of disk images (e.g., Ubuntu 24.04, Debian 12, Cirros) to OpenStack. Images are specified with:
- File paths for `.qcow2` images.
- Disk format (`qcow2`) and container format (`bare`).
- Visibility (`public`) and custom properties (e.g., `os_type`, `distro`).

### Keypairs
The `keypair.tf` file provisions SSH keypairs from public key files located in the `keys/` directory. Keypairs are defined in the `keypairs` variable (e.g., `Ahmad`, `Ali`, `Mona`).

### Networks and Subnets
The `network.tf` and `network.auto.tfvars` files configure:
- **Public Network**: A flat, external network (`192.168.202.0/24`) with DHCP and an allocation pool.
- **Private Network**: An internal network (`10.20.30.0/24`) with DHCP and an allocation pool.
- **Zun Network**: A network (`20.30.40.0/24`) without DHCP for specific use cases.

### Router
The `router.tf` file creates a router (`Router`) connected to the public network and interfaces with private subnets for routing traffic.

### Projects and Users
The `project.tf` and `projects.auto.tfvars` files define:
- **Projects**: Two projects (`mecan`, `dockerme`) with descriptions and quotas.
- **Users**: Users (`amoo`, `ali`, `amir`) with passwords and roles (`admin`, `member`).
- **Roles**: Predefined (`admin`, `member`) and custom roles assigned to users.
- **Quotas**: Compute and storage quotas for each project (e.g., instances, cores, RAM, volumes).

### Instances
Instances are provisioned in two ways:
1. **From Images** (`instance-from-image.tf`, `instance-image.auto.tfvars`):
   - Instances: `Sample-Ubuntu-From-Image`, `Sample-Debian-From-Image`, `Sample-Cirros-From-Image`.
   - Configured with flavors (`Small`, `Tiny`), networks (`Public`), and keypair (`Ahmad`).
2. **From Volumes** (`instance-from-volume.tf`, `instance-volume.auto.tfvars`):
   - Instances: `Sample-Ubuntu-From-Volume`, `Sample-Debian-From-Volume`, `Sample-Cirros-From-Volume`.
   - Booted from volumes created from images, with sizes (10-20 GB) and `delete_on_termination` set to `true`.

## Outputs
The `output.tf` file provides outputs for:
- IDs and names of flavors, keypairs, networks, subnets, routers, images, volumes, and instances.
- IP addresses for instances (from both images and volumes).
- Project, user, role, and quota details.

## Usage
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/AhmadRafiee/DevOps_Certification.git
   cd DevOps_Certification/openstack/bootstrap-openstack/with-terraform
   ```

2. **Prepare SSH Keys**:
   Place public key files (e.g., `Ahmad.pub`, `Ali.pub`) in the `keys/` directory.

3. **Update Variables**:
   Modify `.auto.tfvars` files to match your OpenStack environment (e.g., image paths, network CIDRs, user credentials).

4. **Initialize Terraform**:
   ```bash
   terraform init
   ```

5. **Plan and Apply**:
   ```bash
   terraform plan
   terraform apply
   ```

6. **Verify Outputs**:
   Check the outputs for resource IDs and IP addresses:
   ```bash
   terraform output
   ```

7. **Destroy Resources** (when needed):
   ```bash
   terraform destroy
   ```

## Variables
Key variables defined in `variables.tf` include:
- `flavors`: List of flavor configurations (name, RAM, vCPUs, disk, is_public).
- `keypairs`: List of SSH keypair names.
- `networks`: Map of network configurations (external, shared, subnets, provider details).
- `images`: Map of image configurations (filename, disk_format, visibility, properties).
- `instances_from_image`: Map of instances booted from images.
- `instances_from_volume`: Map of instances booted from volumes.
- `projects`: Map of projects with quotas and user configurations.

For detailed variable definitions, refer to `variables.tf` and corresponding `.auto.tfvars` files.


## 🔗 Stay connected with DockerMe! 🚀

**Subscribe to our channels, leave a comment, and drop a like to support our content. Your engagement helps us create more valuable DevOps and cloud content!** 🙌

[![Site](https://img.shields.io/badge/Dockerme.ir-0A66C2?style=for-the-badge&logo=docker&logoColor=white)](https://dockerme.ir/) [![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/ahmad-rafiee/) [![Telegram](https://img.shields.io/badge/telegram-0A66C2?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/dockerme) [![YouTube](https://img.shields.io/badge/youtube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtube.com/@dockerme) [![Instagram](https://img.shields.io/badge/instagram-FF0000?style=for-the-badge&logo=instagram&logoColor=white)](https://instagram.com/dockerme)
