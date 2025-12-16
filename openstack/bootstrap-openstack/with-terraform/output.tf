output "flavor_ids" {
    value = { for k, v in openstack_compute_flavor_v2.custom_flavors : k => v.id }
}

output "keypairs_ids" {
    value = { for k, v in openstack_compute_keypair_v2.keypairs : k => v.id }
}

output "network_ids" {
    description = "IDs of created networks"
    value       = { for k, v in openstack_networking_network_v2.networks : k => v.id }
}

output "subnet_ids" {
    description = "IDs of created subnets"
    value       = { for k, v in openstack_networking_subnet_v2.subnets : k => v.id }
}

output "subnet_cidr" {
    description = "cidr of created subnets"
    value       = { for k, v in openstack_networking_subnet_v2.subnets : k => v.cidr }
}

output "router_id" {
    description = "ID of the created router"
    value       = openstack_networking_router_v2.router.id
}

output "image_id" {
    description = "ID of the created image"
    value       = { for k, v in openstack_images_image_v2.images : k => v.id }

}

output "image_name" {
    description = "Name of the created image"
    value       = { for k, v in openstack_images_image_v2.images : k => v.name }
}


output "volume_name" {
    description = "Name of the created volumes"
    value       = { for k, v in openstack_blockstorage_volume_v3.volumes : k => v.name }
}


output "instance_from_image" {
    description = "Name of the created instance from image"
    value       = { for k, v in openstack_compute_instance_v2.instances_from_image : k => v.name }
}

output "instance_from_volume" {
    description = "Name of the created instance from volume"
    value       = { for k, v in openstack_compute_instance_v2.instances_from_volume : k => v.name }
}

output "IPs_instance_from_volume" {
    description = "IPv4 addresses of all instances from their first network"
    value = {
        for vm_name, vm in openstack_compute_instance_v2.instances_from_volume :
        vm_name => vm.network[0].fixed_ip_v4
    }
}

output "IPs_instance_from_image" {
    description = "IPv4 addresses of all instances from their first network"
    value = {
        for vm_name, vm in openstack_compute_instance_v2.instances_from_image :
        vm_name => vm.network[0].fixed_ip_v4
    }
}


output "projects" {
    value = {
        for k, v in openstack_identity_project_v3.projects :
        k => {
            id          = v.id
            description = v.description
            enabled     = v.enabled
        }
    }
}

output "users" {
    value = {
        for k, v in openstack_identity_user_v3.users :
        k => {
            id        = v.id
            name      = v.name
            project   = v.default_project_id
            enabled   = v.enabled
        }
    }
}

output "roles" {
    value = merge(
        {
        admin  = {
            id   = data.openstack_identity_role_v3.admin.id
            name = "admin"
        }
        member = {
            id   = data.openstack_identity_role_v3.member.id
            name = "member"
        }
    },
    {
        for k, v in openstack_identity_role_v3.custom_roles :
        k => {
            id   = v.id
            name = v.name
            }
        }
    )
}

output "user_roles" {
    value = {
        for k, v in openstack_identity_role_assignment_v3.user_roles :
        k => {
        user_id    = v.user_id
        project_id = v.project_id
        role_id    = v.role_id
        }
    }
}

output "quotas_compute" {
    value = {
        for k, v in openstack_compute_quotaset_v2.quotas :
        k => {
            instances    = v.instances
            cores        = v.cores
            ram          = v.ram
            floating_ips = v.floating_ips
        }
    }
}

output "quotas_storage" {
    value = {
        for k, v in openstack_blockstorage_quotaset_v3.quotas :
        k => {
            volumes   = v.volumes
            gigabytes = v.gigabytes
        }
    }
}
