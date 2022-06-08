
variable "project_id" {
  description = "Project name for the PSC pproxy"
  type        = string
  default     = "prj"
}

variable "network_name" {
  description = "Project name for the PSC pproxy"
  type        = string
  default     = "proxy-network"
}

variable "proxy_region" {
  description = "default region to use"
  type        = string
  default     = "us-central1"
}