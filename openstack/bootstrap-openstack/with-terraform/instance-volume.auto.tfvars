instances_from_volume = {
    "Sample-Ubuntu-From-Volume" = {
        flavor_name  = "Small"
        networks     = ["Public"]
        keypair      = "Ahmad"
        volumes = [
        {
            image_name   = "Ubuntu24.04"
            name   = "Sample-Ubuntu-root"
            size   = 20
            boot_index = 0
            delete_on_termination = true
        }]}
    "Sample-Debian-From-Volume" = {
        flavor_name  = "Small"
        networks     = ["Public"]
        keypair      = "Ahmad"
        volumes = [
        {
            name   = "Sample-Debian-root"
            image_name   = "Debian12"
            size   = 20
            boot_index = 0
            delete_on_termination = true
        }]}
    "Sample-Cirros-From-Volume" = {
        flavor_name  = "Tiny"
        networks     = ["Public"]
        keypair      = "Ahmad"
        volumes = [
        {
            name   = "Sample-Cirros-root"
            image_name   = "Cirros"
            size   = 10
            boot_index = 0
            delete_on_termination = true
        }]}
}