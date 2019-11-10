provider "google" {}
provider "google-beta" {}

variable "cluster_name" {
}

locals {
  cluster = {
    name     = var.cluster_name
    location = "europe-north1"
  }
}
module "test" {
  source = "../"

  cluster = local.cluster

  machine_type = "g1-small"
  disk_type    = "pd-standard"
  disk_size_gb = 10

  node_count = 1
}

module "autoscaling" {
  source = "../"

  cluster = local.cluster

  machine_type = "g1-small"
  disk_type    = "pd-standard"
  disk_size_gb = 10

  autoscaling_minimum = 0
  autoscaling_maximum = 1
}
