variable "instance_name" {
  type        = string
  description = "Name for the Compute Instance."
}

variable "gcp_project" {
  type        = string
  description = "GCP Project name."
}

variable "gcp_zone" {
  type        = string
  description = "GCP Zone in which resources will be created."
}

variable "network" {
  type        = string
  description = "Network for Compute Instance and Firewall."
  default     = "default"
}

variable "firewall" {
  type = object({
    name  = string
    cidrs = list(string)
    ports = list(number)
  })
  description = "Firewall ingress configurations."
  default = {
    name  = "allow-http"
    cidrs = ["0.0.0.0/0"]
    ports = [8080]
  }
}
