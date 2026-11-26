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

output "project_id" {
  description = "Google Cloud project ID."
  value       = var.project_id
}

output "region" {
  description = "Deployment region."
  value       = var.region
}

output "runner_image_uri" {
  description = "Full Artifact Registry image URI for the GitHub Actions runner."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.runner_repo.name}/${var.runner_image_name}:${var.runner_image_tag}"
}

output "worker_pool_id" {
  description = "ID of the Cloud Run Worker Pool."
  value       = google_cloud_run_v2_worker_pool.runner_pool.id
}

output "crema_service_id" {
  description = "ID of the CREMA Cloud Run autoscaler service."
  value       = google_cloud_run_v2_service.crema_autoscaler.id
}

output "crema_service_account" {
  description = "Email of the CREMA autoscaler service account."
  value       = google_service_account.crema_sa.email
}

output "worker_service_account" {
  description = "Email of the Cloud Run Worker Pool service account."
  value       = google_service_account.worker_sa.email
}

output "github_app_private_key_secret_id" {
  description = "Secret Manager secret ID for the GitHub App private key."
  value       = google_secret_manager_secret.github_app_private_key.secret_id
}

output "crema_config_parameter_version" {
  description = "Active Regional Parameter Manager version ID for CREMA configuration."
  value       = google_parameter_manager_regional_parameter_version.crema_config.id
}
