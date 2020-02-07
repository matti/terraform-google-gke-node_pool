locals {
  autoscaling_enabled = var.node_count == null ? [1] : []

  management = {
    auto_repair  = lookup(var.management, "auto_repair", true)
    auto_upgrade = lookup(var.management, "auto_repair", true)
  }

  autoscaling = {
    min_node_count = lookup(var.autoscaling, "min_node_count", null)
    max_node_count = lookup(var.autoscaling, "max_node_count", null)
  }

  node_config = {
    disk_size_gb      = lookup(var.node_config, "disk_size_gb", 10)
    disk_type         = lookup(var.node_config, "disk_type", "pd-standard")
    guest_accelerator = lookup(var.node_config, "guest_accelerator", null)
    image_type        = lookup(var.node_config, "image_type", null)
    labels            = lookup(var.node_config, "labels", null)
    local_ssd_count   = lookup(var.node_config, "local_ssd_count", null)
    machine_type      = lookup(var.node_config, "machine_type", "g1-small")
    metadata          = lookup(var.node_config, "metadata", null)
    min_cpu_platform  = lookup(var.node_config, "min_cpu_platform", null)
    oauth_scopes      = lookup(var.node_config, "oauth_scopes", ["storage-ro", "logging-write", "monitoring", "compute-rw"])

    preemptible              = lookup(var.node_config, "preemptible", null)
    sandbox_config           = lookup(var.node_config, "sandbox_config", null)
    service_account          = lookup(var.node_config, "service_account", null)
    shielded_instance_config = lookup(var.node_config, "shielded_instance_config", null)
    tags                     = lookup(var.node_config, "tags", null)
    taint                    = lookup(var.node_config, "taint", null)
    workload_metadata_config = lookup(var.node_config, "workload_metadata_config", null)
  }

  upgrade_settings = {
    max_surge       = lookup(var.upgrade_settings, "max_surge", 1)
    max_unavailable = lookup(var.upgrade_settings, "max_unavailable", 1)
  }
}

resource "random_string" "name" {
  count = var.name == null ? 1 : 0

  length  = 3
  upper   = false
  special = false
  number  = false
}

resource "google_container_node_pool" "default" {
  provider = google-beta

  lifecycle {
    ignore_changes = [
      node_config[0].taint
    ]
  }

  count    = var.amount
  cluster  = var.cluster.name
  location = var.cluster.location

  dynamic "autoscaling" {
    for_each = local.autoscaling_enabled
    content {
      min_node_count = local.autoscaling["min_node_count"]
      max_node_count = local.autoscaling["max_node_count"]
    }
  }

  initial_node_count = var.initial_node_count

  management {
    auto_repair  = local.management["auto_repair"]
    auto_upgrade = local.management["auto_upgrade"]
  }

  max_pods_per_node = var.max_pods_per_node

  node_locations = var.node_locations

  name = var.name == null ? "${random_string.name.*.result[0]}" : var.name

  node_config {
    disk_size_gb      = local.node_config["disk_size_gb"]
    disk_type         = local.node_config["disk_type"]
    guest_accelerator = local.node_config["guest_accelerator"]
    image_type        = local.node_config["image_type"]
    labels            = local.node_config["labels"]
    local_ssd_count   = local.node_config["local_ssd_count"]
    machine_type      = local.node_config["machine_type"]
    metadata          = local.node_config["metadata"]
    min_cpu_platform  = local.node_config["min_cpu_platform"]
    oauth_scopes      = local.node_config["oauth_scopes"]
    preemptible       = local.node_config["preemptible"]
    dynamic "sandbox_config" {
      for_each = local.node_config["sandbox_config"] == null ? [] : [1]
      content {
        sandbox_type = local.node_config["sandbox_config"]["sandbox_type"]
      }
    }

    service_account = local.node_config["service_account"]

    dynamic "shielded_instance_config" {
      for_each = local.node_config["shielded_instance_config"] == null ? [] : [1]
      content {
        enable_secure_boot = local.node_config["shielded_instance_config"]["enable_secure_boot"]
      }
    }

    tags  = local.node_config["tags"]
    taint = local.node_config["taint"]

    dynamic "workload_metadata_config" {
      for_each = local.node_config["workload_metadata_config"] == null ? [] : [1]
      content {
        node_metadata = local.node_config["workload_metadata_config"]["node_metadata"]
      }
    }
  }
  node_count = var.node_count
  project    = var.project
  dynamic "upgrade_settings" {
    for_each = local.upgrade_settings == null ? [] : [1]
    content {
      max_surge       = local.upgrade_settings["max_surge"]
      max_unavailable = local.upgrade_settings["max_unavailable"]
    }
  }

  version = var.ver
}
