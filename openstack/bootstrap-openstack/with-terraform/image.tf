resource "openstack_images_image_v2" "images" {
    for_each = var.images

    name             = each.key
    container_format = try(each.value.container_format, "bare")
    disk_format      = try(each.value.disk_format, "qcow2")
    local_file_path  = each.value.filename
    visibility       = try(each.value.visibility, "public")
    properties       = try(each.value.properties, {})
}
