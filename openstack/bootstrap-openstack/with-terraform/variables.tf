variable "flavors" {
    type = list(object({
        name      = string
        ram       = number
        vcpus     = number
        disk      = number
        is_public = bool  
    }))
    default = [
    {
        name      = "Tiny"
        ram       = 1024
        vcpus     = 1
        disk      = 10
        is_public = true
    },
    {
        name      = "Small"
        ram       = 2048
        vcpus     = 2
        disk      = 20
        is_public = true
    },
    {
        name      = "Medium"
        ram       = 4096
        vcpus     = 4
        disk      = 40
        is_public = true
    },
    {
        name      = "Large"
        ram       = 8192
        vcpus     = 8
        disk      = 80
        is_public = true
    }
    ]
}

variable "keypairs" {
    type    = list(string)
    default = ["Ahmad", "Ali", "Mona"]
}

variable "networks" {
    type = map(object({
        external    = bool
        shared      = optional(bool, false)
        provider    = optional(object({
            network_type     = string
            physical_network = optional(string)
            segmentation_id  = optional(number)
    }))
    subnets = list(object({
        name            = string
        cidr            = string
        gateway_ip      = optional(string)
        enable_dhcp     = bool
        allocation_pools = optional(list(object({
            start = string
            end   = string
            })), [])
        }))
    }))
}

variable "images" {
    type = map(object({
        filename   = string
        container_format = optional(string, "bare")
        disk_format      = optional(string, "qcow2")
        visibility       = optional(string, "public")
        properties       = optional(map(string), {})
    }))
}

variable "instances_from_image" {
    type = map(object({
        flavor_name  = string
        networks     = list(string)
        keypair      = string
        security_groups = optional(list(string), ["default"])
        user_data    = optional(string)
        image_name   = string
    }))
}


variable "instances_from_volume" {
    type = map(object({
        flavor_name  = string
        networks     = list(string)
        keypair      = string
        security_groups = optional(list(string), ["default"])
        user_data    = optional(string)
        volumes = optional(list(object({
            name        = string
            size        = number
            image_name  = string
            boot_index  = optional(number, null)
            delete_on_termination = optional(bool, true)
        })))
    }))
}

variable "projects" {
    type = map(object({
        description = string
        quota = object({
            instances               = number
            cores                   = number
            ram                     = number
            volumes                 = number
            gigabytes               = number
            snapshots               = number
            floating_ips            = number
            ports                   = number
            security_groups         = number
            security_groups_rules   = number
            key_pairs               = number
        })
    users = map(object({
        password                    = string
        role                        = string
        }))
    }))
}
