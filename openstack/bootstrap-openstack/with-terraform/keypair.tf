resource "openstack_compute_keypair_v2" "keypairs" {
    for_each   = toset(var.keypairs)
    name       = each.value
    public_key = file("${path.module}/keys/${each.value}.pub") # مسیر فایل public key
}
