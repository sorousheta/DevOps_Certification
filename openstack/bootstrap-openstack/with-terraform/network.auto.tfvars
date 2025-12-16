networks = {
    "Public" = {
        external = true
        shared   = true
        provider = {
        network_type     = "flat"
        physical_network = "physnet1"
    }
    subnets = [
        {
        name        = "public-subnet"
        cidr        = "192.168.202.0/24"
        gateway_ip  = "192.168.202.1"
        enable_dhcp = true
        allocation_pools = [{ start = "192.168.202.100", end = "192.168.202.200" }]
        }]}

    "Private" = {
        external = false
        shared   = true
        subnets = [
            {
            name        = "private-subnet"
            cidr        = "10.20.30.0/24"
            gateway_ip  = "10.20.30.1"
            enable_dhcp = true
            allocation_pools = [{ start = "10.20.30.100", end = "10.20.30.200" }]
        }]}

    "zun_net" = {
        external = false
        shared   = true
        subnets = [
            {
            name        = "zun-sub"
            cidr        = "20.30.40.0/24"
            gateway_ip  = "20.30.40.1"
            enable_dhcp = false
            }
        ]}
}
