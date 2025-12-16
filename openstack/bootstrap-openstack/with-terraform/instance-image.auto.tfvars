instances_from_image = {
    "Sample-Ubuntu-From-Image" = {
        flavor_name  = "Small"
        networks     = ["Public"]
        keypair      = "Ahmad"
        image_name   = "Ubuntu24.04"
    }
    "Sample-Debian-From-Image" = {
        flavor_name  = "Small"
        networks     = ["Public"]
        keypair      = "Ahmad"
        image_name   = "Debian12"
    }
    "Sample-Cirros-From-Image" = {
        flavor_name  = "Tiny"
        networks     = ["Public"]
        keypair      = "Ahmad"
        image_name   = "Cirros"
    }
}