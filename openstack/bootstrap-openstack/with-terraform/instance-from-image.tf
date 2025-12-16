resource "openstack_compute_instance_v2" "instances_from_image" {
  for_each        = var.instances_from_image
  name            = each.key
  image_id        = lookup(
                    { for k, v in openstack_images_image_v2.images : k => v.id },
                    each.value.image_name,
                    null
                  )
  flavor_name     = each.value.flavor_name
  key_pair        = each.value.keypair
  security_groups = ["default"]
  network {
    name          = each.value.networks[0]
  }
  depends_on = [
    openstack_compute_flavor_v2.custom_flavors,
    openstack_compute_keypair_v2.keypairs,
    openstack_networking_router_interface_v2.router_ifaces,
    openstack_images_image_v2.images
  ]
}