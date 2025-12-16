# OpenStack Environment Bootstrap Script

This repository provides a set of **OpenStack CLI commands** to bootstrap a basic cloud environment.  
The script covers image upload, flavor creation, networking setup (public, private, and zun networks), router configuration, keypair generation, floating IP management, and launching instances.

---

## 📋 Prerequisites

- A running OpenStack environment with admin privileges  
- `python-openstackclient` installed and configured (`source` your OpenStack RC file)  
- Local image file: `/root/tools/debian12.qcow2`  
- Public SSH key available at: `/root/tools/public_keys`  

---

## 🚀 What the script does

1. **Upload an Image**
   - Uploads Debian 12 image (`qcow2`) and makes it public.

2. **Create Flavors**
   - Defines two instance flavors:  
     - `Tiny`: 1 vCPU, 1 GB RAM, 10 GB disk  
     - `Small`: 2 vCPU, 2 GB RAM, 20 GB disk  

3. **Networking Setup**
   - **Public (External) Network**  
     - Flat network on `physnet1` with subnet range `192.168.202.0/24`  
   - **Private (Internal) Network**  
     - Subnet range `10.20.30.0/24`  
   - **Zun Network**  
     - Subnet range `20.30.40.0/24` with no DHCP  
   - **Router**  
     - Connects internal and zun networks to the external network  

4. **Keypair**
   - Imports a public SSH key (`Ahmad`) for instance access.  

5. **Floating IP**
   - Allocates floating IPs from the Public network and associates them with instances.  

6. **Instances**
   - Launches:  
     - `sample1`: Boot from image (Debian12)  
     - `sample2`: Boot from a 30GB volume created from the image  

7. **Security Rules**
   - Allows incoming SSH (port 22) from anywhere (`0.0.0.0/0`).  

---

## 🛠️ Usage

Run the script step by step or copy it into a `.sh` file and execute:

```bash
bash bootstrap-openstack.sh
```

> ⚠️ Note: Some resources may already exist. In such cases, the commands may fail with "already exists".  
> You can modify the script to check for existence before creating new resources.

---

## 🔑 Example Commands

- List images:
  ```bash
  openstack image list
  ```
- Show flavor details:
  ```bash
  openstack flavor show Small
  ```
- List servers:
  ```bash
  openstack server list
  ```
- Assign floating IP:
  ```bash
  openstack server add floating ip sample1 <FLOATING_IP>
  ```

---

## 📖 Notes

- Adjust subnet ranges, gateway addresses, and allocation pools according to your network environment.  
- Replace `physnet1` with the actual physical network in your OpenStack setup.  
- Always verify the resources after running the script using `openstack <resource> list`.  

---

## ✅ Result

After running the script, you will have:

- Debian 12 image available for new instances  
- Tiny and Small flavors ready  
- Public, Private, and Zun networks with a router  
- SSH access enabled via imported keypair  
- Two running instances (`sample1` and `sample2`) with floating IPs  
