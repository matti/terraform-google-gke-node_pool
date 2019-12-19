locals {
  autoscaling = (var.node_count == null) ? [1] : []
}

resource "random_string" "random" {
  count = var.enabled == true ? 1 : 0

  keepers = {
    cluster_name        = var.create_before_destroy ? var.cluster.name : ""
    name                = var.create_before_destroy ? var.name : ""
    node_count          = var.create_before_destroy ? var.node_count : ""
    node_locations      = var.create_before_destroy ? var.node_locations : ""
    autoscaling_minimum = var.create_before_destroy ? var.autoscaling_minimum : ""
    autoscaling_maximum = var.create_before_destroy ? var.autoscaling_maximum : ""
    machine_type        = var.create_before_destroy ? var.machine_type : ""
    disk_size_gb        = var.create_before_destroy ? var.disk_size_gb : ""
    disk_type           = var.create_before_destroy ? var.disk_type : ""
    preemptible         = var.create_before_destroy ? var.preemptible : ""
    labels              = var.create_before_destroy ? join(",", values(var.labels)) : ""
    taints              = var.create_before_destroy ? join(",", var.taints) : ""
    auto_upgrade        = var.create_before_destroy ? var.auto_upgrade : ""
    auto_repair         = var.create_before_destroy ? var.auto_repair : ""
    oauth_scopes        = var.create_before_destroy ? join(",", var.oauth_scopes) : ""
  }

  length  = 4
  upper   = false
  special = false
}

resource "google_container_node_pool" "bluegreen" {
  count = var.enabled == true && var.create_before_destroy == true ? 1 : 0

  lifecycle {
    create_before_destroy = true
  }

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
  initial_node_count = var.initial_node_count == null ? null : var.initial_node_count
  management {
    auto_repair  = var.auto_repair
    auto_upgrade = var.auto_upgrade
  }

  // max_pods_per_node
  node_locations = var.node_locations == null ? null : split(var.node_locations, ",")

  name = var.name == null ? null : "${var.name}-${random_string.random.*.result[0]}"

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
}

resource "google_container_node_pool" "inplace" {
  count = var.enabled == true && var.create_before_destroy == false ? 1 : 0

  lifecycle {
    create_before_destroy = false
  }

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
  initial_node_count = var.initial_node_count == null ? null : var.initial_node_count
  management {
    auto_repair  = var.auto_repair
    auto_upgrade = var.auto_upgrade
  }

  // max_pods_per_node
  node_locations = var.node_locations == null ? null : split(var.node_locations, ",")

  name = var.name == null ? null : "${var.name}-${random_string.random.*.result[0]}"

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
}
