variable "cluster" {}

variable "node_count" {
  default = null
}

variable "autoscaling_minimum" {
  default = 0
}

variable "autoscaling_maximum" {
  default = 333
}

variable "machine_type" {}
variable "disk_size_gb" {}
variable "disk_type" {}
variable "preemptible" {
  default = false
}
variable "labels" {
  default = {}
}
variable "taints" {
  default = []
}

variable "auto_upgrade" {
  default = true
}
variable "auto_repair" {
  default = true
}

variable "oauth_scopes" {
  default = [
    "storage-ro",
    "logging-write", # if stackdriver
    "monitoring",    # if google monitoring
  ]
}
