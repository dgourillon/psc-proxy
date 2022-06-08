
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

variable "org_id" {
  description = "The organization id for the associated services"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate this project with"
  type        = string
}

variable "default_region" {
  description = "Default region for resources."
  type        = string
}