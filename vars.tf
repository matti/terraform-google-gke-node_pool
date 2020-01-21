
variable "cluster" {}

variable "autoscaling" {
  default = {}
}

variable "initial_node_count" {
  default = null
}

variable "management" {
  default = {}
}

variable "max_pods_per_node" {
  default = null
}

variable "node_locations" {
  default = null
}

variable "name" {
  default = null
}

variable "node_config" {
  default = {}
}

variable "node_count" {
  default = null
}

variable "project" {
  default = null
}

variable "upgrade_settings" {
  default = {}
}

variable "ver" {
  default = null
}
