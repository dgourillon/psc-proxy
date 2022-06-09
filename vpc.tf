

# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "false"
  project                 = var.project_id
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-subnet"
  region        = var.proxy_region
  project       = var.project_id
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}
