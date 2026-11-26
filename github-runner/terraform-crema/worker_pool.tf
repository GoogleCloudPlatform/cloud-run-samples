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

resource "google_cloud_run_v2_worker_pool" "runner_pool" {
  name     = var.worker_pool_name
  location = var.region
  project  = var.project_id

  template {
    service_account = google_service_account.worker_sa.email

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.runner_repo.name}/${var.runner_image_name}:${var.runner_image_tag}"

      resources {
        limits = {
          cpu    = var.runner_cpu
          memory = var.runner_memory
        }
      }

      env {
        name  = "GITHUB_ORG"
        value = var.github_org
      }

      env {
        name  = "GITHUB_APP_ID"
        value = var.github_app_id
      }

      env {
        name  = "GITHUB_APP_INSTALLATION_ID"
        value = var.github_app_installation_id
      }

      env {
        name  = "RUNNER_LABELS"
        value = var.runner_labels
      }

      env {
        name  = "RUNNER_GROUP_ID"
        value = tostring(var.runner_group_id)
      }

      env {
        name  = "GITHUB_APP_PRIVATE_KEY_PATH"
        value = "/secrets/github-app-private-key"
      }

      env {
        name  = "PROJECT_ID"
        value = var.project_id
      }

      volume_mounts {
        name       = "github-app-key-volume"
        mount_path = "/secrets"
      }
    }

    volumes {
      name = "github-app-key-volume"
      secret {
        secret = google_secret_manager_secret.github_app_private_key.secret_id
        items {
          version = "latest"
          path    = "github-app-private-key"
        }
      }
    }
  }

  scaling {
    scaling_mode          = "MANUAL"
    manual_instance_count = var.min_replicas
  }

  # CREMA dynamically adjusts manual_instance_count between 0 and max_replicas.
  lifecycle {
    ignore_changes = [
      scaling[0].manual_instance_count,
    ]
  }

  depends_on = [
    google_project_service.apis["run.googleapis.com"],
    google_secret_manager_secret_iam_member.worker_secret_accessor,
  ]
}
