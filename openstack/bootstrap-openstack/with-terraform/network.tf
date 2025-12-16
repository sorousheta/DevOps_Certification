# Create networks
resource "openstack_networking_network_v2" "networks" {
    for_each = var.networks

    name     = each.key
    external = each.value.external
    shared   = try(each.value.shared, false)

    dynamic "segments" {
        for_each = try(each.value.provider, null) == null ? [] : [each.value.provider]
        content {
            network_type     = segments.value.network_type
            physical_network = try(segments.value.physical_network, null)
            segmentation_id  = try(segments.value.segmentation_id, null)
        }
    }
}

# Create Subnets
resource "openstack_networking_subnet_v2" "subnets" {
    for_each = {
        for pair in flatten([
            for net_key, net in var.networks : [
                for s in net.subnets : {
                    key     = "${net_key}/${s.name}"
                    net_key = net_key
                    subnet  = s
                }
            ]
        ]) : pair.key => pair
    }

    name       = each.value.subnet.name
    network_id = openstack_networking_network_v2.networks[each.value.net_key].id

    cidr        = each.value.subnet.cidr
    gateway_ip  = try(each.value.subnet.gateway_ip, null)
    enable_dhcp = each.value.subnet.enable_dhcp

    dynamic "allocation_pool" {
        for_each = try(each.value.subnet.allocation_pools, [])
        content {
            start = allocation_pool.value.start
            end   = allocation_pool.value.end
            }
        }
}
