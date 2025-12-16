# OpenStack Bootstrap with Ansible

This Ansible role, `AhmadRafiee.openstack-bootstrap`, automates the deployment of an OpenStack environment, provisioning resources such as flavors, networks, subnets, routers, keypairs, images, and compute instances. It provides a streamlined way to bootstrap an OpenStack cloud infrastructure using best practices.

## Table of Contents
- [OpenStack Bootstrap with Ansible](#openstack-bootstrap-with-ansible)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Playbook Structure](#playbook-structure)
  - [Configuration Details](#configuration-details)
    - [Flavors](#flavors)
    - [Networks and Subnets](#networks-and-subnets)
    - [Router](#router)
    - [Keypairs](#keypairs)
    - [Images](#images)
    - [Instances](#instances)
  - [Usage](#usage)
  - [Variables](#variables)
  - [Tags](#tags)
  - [🔗 Stay connected with DockerMe! 🚀](#-stay-connected-with-dockerme-)

## Overview
The `AhmadRafiee.openstack-bootstrap` role simplifies OpenStack setup by automating the creation of:
- Custom compute flavors (e.g., Tiny, Small, Medium, Large).
- Public and private networks with subnets.
- A router with external gateway and interfaces.
- SSH keypairs for secure access.
- Disk images (e.g., Cirros, Ubuntu 24.04, Debian 12).
- Compute instances with cloud-init configurations.

This role is available on [Ansible Galaxy](https://galaxy.ansible.com/AhmadRafiee/openstack-bootstrap) and is ideal for initializing OpenStack environments for development, testing, or production.

## Prerequisites
Before using this role, ensure the following are installed and configured:

- **Ansible**: Version 2.9 or higher.
  ```bash
  pip install --upgrade ansible
  ```
- **openstack.cloud Collection**: Required for OpenStack interactions. Install it using:
  ```bash
  ansible-galaxy collection install openstack.cloud
  ```
  Alternatively, use the provided `requirements.yml`:
  ```bash
  ansible-galaxy install -r requirements.yml
  ```
- **Python Dependencies**: Install the `openstacksdk` package:
  ```bash
  pip install openstacksdk
  ```
- **OpenStack Environment**: Access to an OpenStack cloud with valid admin credentials (e.g., `auth_url`, `username`, `password`).
- **SSH Public Keys**: Required for keypair provisioning.
- **Image Download Access**: URLs for images (e.g., Ubuntu, Cirros) must be accessible.

## Installation
Install the role from Ansible Galaxy:
```bash
ansible-galaxy role install AhmadRafiee.openstack-bootstrap
```

Install dependencies using the provided `requirements.yml`:
```bash
ansible-galaxy install -r requirements.yml
```

The `requirements.yml` file includes:
```yaml
collections:
  - name: openstack.cloud
    source: https://galaxy.ansible.com
    version: ">=2.0.0"
```

## Playbook Structure
The role is organized into modular tasks:
```
├── defaults/
│   └── main/main.yml       # Default variables (flavors, networks, etc.)
├── tasks/
│   ├── main.yml           # Main playbook importing all tasks
│   ├── create-flavor.yml  # Creates custom flavors
│   ├── create-network.yml # Creates networks and subnets
│   ├── create-router.yml  # Creates router and interfaces
│   ├── create-keypair.yml # Adds SSH keypairs
│   ├── create-image.yml   # Downloads and uploads images
│   ├── create-instance.yml # Creates compute instances
│   └── delete-instance.yml # Deletes instances
├── meta/
│   └── main.yml           # Role metadata
├── requirements.yml        # Dependency definitions
└── README.md              # Documentation
```

## Configuration Details

### Flavors
Defines compute flavors (e.g., Tiny: 1GB RAM, 1 vCPU, 10GB disk) configurable via the `flavors` variable.

### Networks and Subnets
Provisions:
- **Public Network**: External flat network (`192.168.202.0/24`) with DHCP.
- **Private Network**: Internal network (`10.20.30.0/24`) with DHCP.
- **Zun Network**: Non-DHCP network (`20.30.40.0/24`) for specific use cases.

### Router
Creates a router connected to the public network with interfaces to private subnets.

### Keypairs
Uploads SSH public keys to OpenStack for secure instance access.

### Images
Downloads and uploads images (e.g., Cirros, Ubuntu 24.04, Debian 12) to OpenStack with `qcow2` format and public visibility.

### Instances
Deploys instances with:
- Boot-from-volume support.
- Cloud-init for configuring hostname, users, packages (e.g., nginx), and services.
- Custom security groups and networks.

## Usage
1. **Set Up Authentication**:
   Configure OpenStack credentials in a `clouds.yaml` file or as playbook variables:
   ```yaml
   openstack_auth:
     auth_url: "https://your-openstack-auth-url:5000/v3"
     username: "admin"
     password: "your-password"
     project_name: "admin"
     user_domain_name: "Default"
     project_domain_name: "Default"
   ```

2. **Create a Playbook**:
   Example playbook (`playbook.yml`):
   ```yaml
   - name: Bootstrap OpenStack with AhmadRafiee.openstack-bootstrap
     hosts: localhost
     connection: local
     vars:
       openstack_auth:
         auth_url: "https://your-openstack-auth-url:5000/v3"
         username: "admin"
         password: "your-password"
         project_name: "admin"
         user_domain_name: "Default"
         project_domain_name: "Default"
       image_path: "/tmp/openstack-images"
       ssh_keys:
         - name: "test-key"
           public_key: "ssh-rsa AAAAB3NzaC1yc2E... your-public-key"
       router:
         name: "test-router"
         external_network: "Public"
     roles:
       - AhmadRafiee.openstack-bootstrap
   ```

3. **Run the Playbook**:
   ```bash
   ansible-playbook playbook.yml -v
   ```
   Use tags to run specific tasks (e.g., `--tags create_instance`).

4. **Delete Resources** (if needed):
   ```bash
   ansible-playbook playbook.yml --tags delete_instance -v
   ```

## Variables
Key variables defined in `defaults/main/main.yml`:
- `flavors`: List of flavor specs (name, ram, vcpus, disk, is_public).
- `networks`: Network configurations (name, external, subnet_name, cidr, gateway_ip, etc.).
- `router`: Router name and external network.
- `ssh_keys`: List of SSH keypairs (name, public_key).
- `image_path`: Directory for downloaded images.
- `images_to_upload`: Image details (name, url, container_format, disk_format).
- `instance`: Instance details (image_name, flavor_name, network_name, etc.).

See `defaults/main/main.yml` for full variable definitions.

## Tags
Run specific tasks using tags:
- `preparing_openstack`: Creates flavors, networks, router, keypairs, and images.
- `create_flavor`, `create_network`, `create_router`, `create_keypair`, `create_image`: Individual setup tasks.
- `create_instance`: Creates an instance.
- `delete_instance`: Deletes an instance.

Example:
```bash
ansible-playbook playbook.yml --tags create_instance
```


## 🔗 Stay connected with DockerMe! 🚀

**Subscribe to our channels, leave a comment, and drop a like to support our content. Your engagement helps us create more valuable DevOps and cloud content!** 🙌

[![Site](https://img.shields.io/badge/Dockerme.ir-0A66C2?style=for-the-badge&logo=docker&logoColor=white)](https://dockerme.ir/) [![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/ahmad-rafiee/) [![Telegram](https://img.shields.io/badge/telegram-0A66C2?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/dockerme) [![YouTube](https://img.shields.io/badge/youtube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtube.com/@dockerme) [![Instagram](https://img.shields.io/badge/instagram-FF0000?style=for-the-badge&logo=instagram&logoColor=white)](https://instagram.com/dockerme)
