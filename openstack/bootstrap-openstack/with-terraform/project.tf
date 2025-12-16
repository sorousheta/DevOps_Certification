# Create project
resource "openstack_identity_project_v3" "projects" {
    for_each    = var.projects
    name        = each.key
    description = each.value.description
    enabled     = true
}

# Create user
resource "openstack_identity_user_v3" "users" {
    for_each = {
        for assignment in flatten([
            for proj, pdata in var.projects : [
                for uname, udata in pdata.users : {
                    key      = "${proj}-${uname}"
                    project  = proj
                    name     = uname
                    password = udata.password
                }
            ]
        ]) : assignment.key => assignment
    }
    name               = each.value.name
    password           = each.value.password
    default_project_id = openstack_identity_project_v3.projects[each.value.project].id
    enabled            = true
}

data "openstack_identity_role_v3" "admin" {
    name = "admin"
}

data "openstack_identity_role_v3" "member" {
    name = "member"
}

# Define roles (unique set of all roles across projects/users)
resource "openstack_identity_role_v3" "custom_roles" {
    for_each = {
        for r in toset(flatten([
            for proj, pdata in var.projects : [
                for uname, udata in pdata.users : udata.role
                ]
            ])) : r => r
        if !(r == "admin" || r == "member") # فقط نقش‌های جدید
    }

    name = each.value
}

# Assign role to user
resource "openstack_identity_role_assignment_v3" "user_roles" {
    for_each = {
        for assignment in flatten([
            for proj, pdata in var.projects : [
                for uname, udata in pdata.users : {
                    key     = "${proj}-${uname}"
                    user    = "${proj}-${uname}"
                    role    = udata.role
                    project = proj
                }
            ]
        ]) : assignment.key => assignment
    }
    user_id    = openstack_identity_user_v3.users[each.value.user].id
    project_id = openstack_identity_project_v3.projects[each.value.project].id
    role_id = (
        each.value.role == "admin"  ? data.openstack_identity_role_v3.admin.id :
        each.value.role == "member" ? data.openstack_identity_role_v3.member.id :
        openstack_identity_role_v3.custom_roles[each.value.role].id)
}

# Create quota
resource "openstack_compute_quotaset_v2" "quotas" {
    for_each = var.projects
    project_id           = openstack_identity_project_v3.projects[each.key].id
    instances            = each.value.quota.instances
    cores                = each.value.quota.cores
    ram                  = each.value.quota.ram
    floating_ips         = each.value.quota.floating_ips
    security_groups      = each.value.quota.security_groups
    security_group_rules = each.value.quota.security_groups_rules
    key_pairs            = each.value.quota.key_pairs
}


resource "openstack_blockstorage_quotaset_v3" "quotas" {
    for_each = var.projects
    project_id = openstack_identity_project_v3.projects[each.key].id
    volumes    = each.value.quota.volumes
    gigabytes  = each.value.quota.gigabytes
    snapshots  = each.value.quota.snapshots
}
