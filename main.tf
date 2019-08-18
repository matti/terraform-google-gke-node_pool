locals {
  autoscaling = (var.node_count == null) ? [1] : []
}

resource "google_container_node_pool" "default" {
  provider = "google-beta"

  lifecycle {
    create_before_destroy = true
  }

  cluster  = var.cluster.name
  location = var.cluster.location

  node_count = var.node_count

  dynamic "autoscaling" {
    for_each = local.autoscaling
    content {
      min_node_count = var.autoscaling_minimum
      max_node_count = var.autoscaling_maximum
    }
  }

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

  management {
    auto_upgrade = var.auto_upgrade
    auto_repair  = var.auto_repair
  }
}
