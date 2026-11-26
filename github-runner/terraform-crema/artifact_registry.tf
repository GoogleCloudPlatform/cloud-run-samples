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

resource "google_artifact_registry_repository" "runner_repo" {
  repository_id = var.artifact_registry_repo_name
  location      = var.region
  format        = "DOCKER"
  description   = "Docker repository for Cloud Run GitHub Actions runners"
  project       = var.project_id

  depends_on = [google_project_service.apis["artifactregistry.googleapis.com"]]
}
