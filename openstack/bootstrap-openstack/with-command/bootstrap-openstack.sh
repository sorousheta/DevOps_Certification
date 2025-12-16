# create image from local file
openstack image create "Debian12" \
  --file /root/tools/debian12.qcow2 \
  --disk-format qcow2 \
  --container-format bare \
  --public

# Get Debain12 image id
openstack image show Debian12 -f value -c id

# create flavor 
openstack flavor create Tiny \
  --ram 1024 \
  --disk 10 \
  --vcpus 1

openstack flavor create Small \
  --ram 2048 \
  --disk 20 \
  --vcpus 2

# Get flavor id
openstack flavor show Tiny -f value -c id
openstack flavor show Small -f value -c id


# Create external network
openstack network create Public \
  --share \
  --external \
  --provider-network-type flat \
  --provider-physical-network physnet1

# Create external subnet
openstack subnet create Public-Subnet \
  --network Public \
  --subnet-range 192.168.202.0/24 \
  --allocation-pool start=192.168.202.100,end=192.168.202.200 \
  --gateway 192.168.202.1 \
  --dns-nameserver 8.8.8.8 \
  --dns-nameserver 8.8.4.4

# Get external network id
openstack network show Public -f value -c id


# Create internal network and subnet
openstack network create Private --share

# Create internal subnet
openstack subnet create Private-Subnet \
  --network Private \
  --subnet-range 10.20.30.0/24 \
  --gateway 10.20.30.1 \
  --allocation-pool start=10.20.30.100,end=10.20.30.200 \
  --dns-nameserver 8.8.8.8 \
  --dns-nameserver 8.8.4.4 

# Create zun network and subnet
openstack network create zun_net --share

# Create zun subnet
openstack subnet create zunnet_subnet \
  --network zun_net \
  --subnet-range 20.30.40.0/24 \
  --gateway 20.30.40.1 \
  --no-dhcp

# Create the router
openstack router create Router

# Set the router's external gateway to the public network
openstack router set Router --external-gateway Public

# Add the private subnet interface to the router
openstack router add subnet Router Private-Subnet

# Add the zun subnet interface to the router
openstack router add subnet Router zunnet_subnet

# download public key ans add on openstack
wget https://dockerme.ir/learn/tools/Software/public_keys

# Create keypair from file
openstack keypair create --type ssh --public-key /root/tools/public_keys Ahmad

# Check instance
openstack server list

# Allocate a floating IP from the public network
openstack floating ip create Public
openstack floating ip list

# create and boot from image
openstack server create \
  --flavor $(openstack flavor show Small -f value -c ID) \
  --image $(openstack image show Debian12 -f value -c ID) \
  --network $(openstack network show Public -f value -c ID) \
  --security-group $(openstack security group list --project admin -f value -c ID) \
  --key-name Ahmad \
  sample1

# create and boot from volume
openstack server create \
  --flavor $(openstack flavor show Small -f value -c ID) \
  --image $(openstack image show Debian12 -f value -c ID) \
  --network $(openstack network show Public -f value -c ID) \
  --security-group $(openstack security group list --project admin -f value -c ID) \
  --boot-from-volume 30 \
  --key-name Ahmad \
  sample2

# Associate floating IP with the instance
openstack server add floating ip sample1 $(openstack floating ip list -f value -c 'Floating IP Address')

# Allow incoming SSH (port 22) from anywhere
openstack security group rule create \
  $(openstack security group list --project admin -f value -c 'ID') \
  --protocol tcp \
  --dst-port 22 \
  --remote-ip 0.0.0.0/0