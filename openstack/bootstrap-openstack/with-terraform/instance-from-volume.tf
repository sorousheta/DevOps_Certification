resource "openstack_blockstorage_volume_v3" "volumes" {
  for_each = var.instances_from_volume
  name        = each.value.volumes[0].name
  size        = each.value.volumes[0].size                
  image_id    = lookup(
                      { for k, v in openstack_images_image_v2.images : k => v.id },
                      each.value.volumes[0].image_name,
                      null
                    )
}

resource "openstack_compute_instance_v2" "instances_from_volume" {
  for_each = var.instances_from_volume
  name            = each.key
  flavor_name     = each.value.flavor_name
  key_pair        = each.value.keypair
  security_groups = ["default"]
  network {
    name = each.value.networks[0]
  }

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.volumes[each.key].id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = each.value.volumes[0].boot_index
    delete_on_termination = each.value.volumes[0].delete_on_termination
  }
  depends_on = [
    openstack_compute_flavor_v2.custom_flavors,
    openstack_compute_keypair_v2.keypairs,
    openstack_networking_router_interface_v2.router_ifaces,
    openstack_images_image_v2.images,
    openstack_blockstorage_volume_v3.volumes
  ]
}
