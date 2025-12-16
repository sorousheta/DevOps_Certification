projects = {
    mecan = {
        description = "MeCan Project"
        quota = {
            instances       = 5
            cores           = 10
            ram             = 10240
            volumes         = 10
            gigabytes       = 100
            floating_ips    = 5
            snapshots       = 5
            ports           = 20
            security_groups = 5
            security_groups_rules = 50
            key_pairs       = 20

        }
    users = {
        amoo = {
            password = "9GxuH8h4uIxAK6Stn165zNcs2rBotCjAEXANc00"
            role     = "admin"
            }
        ali = {
            password = "Hsetuc4anZhyOhfC8RY4MQtVxFkai0ss3isY0fj"
            role     = "member"
            }
        }
    }

    dockerme = {
        description = "DockerMe Project"
        quota = {
            instances       = 4
            cores           = 4
            ram             = 8192
            volumes         = 5
            gigabytes       = 50
            floating_ips    = 2
            snapshots       = 3
            ports           = 20
            security_groups = 5
            security_groups_rules = 50
            key_pairs       = 20
            }
    users = {
        amir = {
            password = "Y5eKagCFAat38YbwaQmH1bsO91cP3TJkHEDJd4N"
            role     = "member"
            }
        }
    }
}
