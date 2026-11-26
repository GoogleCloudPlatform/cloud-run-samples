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

# Secret container for GitHub App Private Key (.pem content).
# Populate the secret version out-of-band (never commit private keys to Terraform state):
#   gcloud secrets versions add github-app-private-key --data-file=/path/to/app.private-key.pem
resource "google_secret_manager_secret" "github_app_private_key" {
  secret_id = "github-app-private-key"
  project   = var.project_id

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [google_project_service.apis["secretmanager.googleapis.com"]]
}

# Secret for GitHub App ID
resource "google_secret_manager_secret" "github_app_id" {
  secret_id = "github-app-id"
  project   = var.project_id

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [google_project_service.apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret_version" "github_app_id_version" {
  secret      = google_secret_manager_secret.github_app_id.id
  secret_data = var.github_app_id
}

# Secret for GitHub App Installation ID
resource "google_secret_manager_secret" "github_app_installation_id" {
  secret_id = "github-app-installation-id"
  project   = var.project_id

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [google_project_service.apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret_version" "github_app_installation_id_version" {
  secret      = google_secret_manager_secret.github_app_installation_id.id
  secret_data = var.github_app_installation_id
}
