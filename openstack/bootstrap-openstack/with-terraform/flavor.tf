resource "openstack_compute_flavor_v2" "custom_flavors" {
  for_each = { for flavor in var.flavors : flavor.name => flavor }
  name      = each.value.name
  ram       = each.value.ram
  vcpus     = each.value.vcpus
  disk      = each.value.disk
  is_public = each.value.is_public
}