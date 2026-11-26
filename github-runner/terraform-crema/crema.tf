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

resource "google_cloud_run_v2_service" "crema_autoscaler" {
  name                = var.crema_service_name
  location            = var.region
  project             = var.project_id
  ingress             = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  deletion_protection = false

  template {
    service_account = google_service_account.crema_sa.email

    scaling {
      min_instance_count = 1
      max_instance_count = 1
    }

    containers {
      image          = var.crema_image
      base_image_uri = "${var.region}-docker.pkg.dev/serverless-runtimes/google-24/runtimes/java25"

      resources {
        cpu_idle = false
      }

      env {
        name  = "CREMA_CONFIG"
        value = google_parameter_manager_regional_parameter_version.crema_config.id
      }

      env {
        name  = "OUTPUT_SCALER_METRICS"
        value = "True"
      }

      env {
        name  = "ENABLE_CLOUD_LOGGING"
        value = "True"
      }

      env {
        name  = "LOG_FORMAT"
        value = "json"
      }
    }
  }

  depends_on = [
    google_project_service.apis["run.googleapis.com"],
    google_project_iam_member.crema_run_admin,
    google_secret_manager_secret_iam_member.crema_secret_accessor,
    google_project_iam_member.crema_parameter_accessor,
    google_project_iam_member.crema_parameter_viewer,
    google_project_iam_member.crema_metric_writer,
    google_project_iam_member.crema_sa_user,
    google_project_iam_member.crema_logging,
    google_cloud_run_v2_worker_pool.runner_pool,
  ]
}
