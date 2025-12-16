# Create Router
resource "openstack_networking_router_v2" "router" {
    name                = "Router"
    admin_state_up      = true
    external_network_id = openstack_networking_network_v2.networks["Public"].id
    depends_on = [openstack_networking_subnet_v2.subnets]
}

# Router add interface
resource "openstack_networking_router_interface_v2" "router_ifaces" {
    for_each  = { for k, s in openstack_networking_subnet_v2.subnets : k => s if !startswith(k, "Public/") }
    router_id = openstack_networking_router_v2.router.id
    subnet_id = each.value.id
    depends_on = [openstack_networking_router_v2.router]
}
