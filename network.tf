module "base_vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 5.0"

    project_id   = var.project_id
    network_name = var.network_name
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name           = "subnet-01"
            subnet_ip             = "10.168.0.0/25"
            subnet_region         = var.proxy_region
        }
    ]

    secondary_ranges = {
        subnet-01 = [
            {
                range_name    = "subnet-01-secondary-pods"
                ip_cidr_range = "10.168.50.0/22"
            },
            {
                range_name    = "subnet-01-secondary-services"
                ip_cidr_range = "10.168.50.0/27"
            },
        ]

        subnet-02 = []
    }

    routes = [
        {
            name                   = "egress-internet"
            description            = "route through IGW to access internet"
            destination_range      = "0.0.0.0/0"
            tags                   = "egress-inet"
            next_hop_internet      = "true"
        },
    ]
}

resource "google_compute_router" "psc_proxy_router" {
  name    = "proxy-router-nat"
  network = module.base_vpc.network_name
  project = var.project_id
  region = var.proxy_region
  bgp {
    asn               = 64514
    advertise_mode    = "DEFAULT"
  }
}

resource "google_compute_router_nat" "psc_proxy_router_nat" {
  name                               = "proxy-nat"
  router                             = google_compute_router.psc_proxy_router.name
  project                            = var.project_id
  region                             = var.proxy_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}