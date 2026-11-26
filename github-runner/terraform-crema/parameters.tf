/**
 * Copyright 2026 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  crema_config_yaml = templatefile("${path.module}/crema/crema-config.yaml.tpl", {
    project_id                         = var.project_id
    region                             = var.region
    worker_pool_name                   = var.worker_pool_name
    github_org                         = var.github_org
    github_app_id                      = var.github_app_id
    github_app_installation_id         = var.github_app_installation_id
    github_app_private_key_secret_name = google_secret_manager_secret.github_app_private_key.secret_id
    min_replicas                       = var.min_replicas
    max_replicas                       = var.max_replicas
    cooldown_period                    = var.cooldown_period
    polling_interval                   = var.polling_interval
    target_workflow_queue_length       = var.target_workflow_queue_length
    runner_labels                      = var.runner_labels
  })
}

# Regional Parameter Manager for CREMA KEDA Scaler Configuration
resource "google_parameter_manager_regional_parameter" "crema_config" {
  parameter_id = "crema-config"
  location     = var.region
  project      = var.project_id
  format       = "YAML"

  depends_on = [google_project_service.apis["parametermanager.googleapis.com"]]
}

resource "google_parameter_manager_regional_parameter_version" "crema_config" {
  parameter            = google_parameter_manager_regional_parameter.crema_config.id
  parameter_version_id = "v-${substr(sha256(local.crema_config_yaml), 0, 8)}"
  parameter_data       = local.crema_config_yaml

  lifecycle {
    create_before_destroy = true
  }
}
