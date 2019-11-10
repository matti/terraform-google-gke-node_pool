locals {
  autoscaling = (var.node_count == null) ? [1] : []
}

resource "random_string" "random" {
  length  = 4
  upper   = false
  special = false
}

resource "google_container_node_pool" "default" {
  provider = "google-beta"

  cluster  = var.cluster.name
  location = var.cluster.location
  // zone
  // region

  dynamic "autoscaling" {
    for_each = local.autoscaling
    content {
      min_node_count = var.autoscaling_minimum
      max_node_count = var.autoscaling_maximum
    }
  }
  // initial_node_count
  management {
    auto_repair  = var.auto_repair
    auto_upgrade = var.auto_upgrade
  }

  // max_pods_per_node
  node_locations = var.node_locations == null ? null : split(var.node_locations, ",")

  name = var.name == null ? null : "${var.name}-${random_string.random.result}"

  node_config {
    machine_type = var.machine_type
    disk_type    = var.disk_type
    disk_size_gb = var.disk_size_gb

    oauth_scopes = var.oauth_scopes

    workload_metadata_config {
      node_metadata = "SECURE"
    }

    preemptible = var.preemptible

    labels = var.labels

    dynamic "taint" {
      for_each = var.taints
      content {
        key    = taint["value"]["key"]
        value  = taint["value"]["value"]
        effect = taint["value"]["effect"]
      }
    }
  }
  node_count = var.node_count
  // project
  // version

  lifecycle {
    create_before_destroy = true
  }

}
