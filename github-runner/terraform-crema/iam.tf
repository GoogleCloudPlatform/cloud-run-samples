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

data "google_project" "current" {
  project_id = var.project_id
}

# 1. CREMA Autoscaler Service Account
resource "google_service_account" "crema_sa" {
  account_id   = "crema-autoscaler-sa"
  display_name = "CREMA Autoscaler Service Account"
  project      = var.project_id

  depends_on = [google_project_service.apis["iam.googleapis.com"]]
}

# 2. Worker Pool Runner Service Account
resource "google_service_account" "worker_sa" {
  account_id   = "worker-pool-sa"
  display_name = "Cloud Run Worker Pool Runner Service Account"
  project      = var.project_id

  depends_on = [google_project_service.apis["iam.googleapis.com"]]
}

# CREMA IAM Roles
# - roles/run.admin: update worker pool manualInstanceCount
resource "google_project_iam_member" "crema_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.crema_sa.email}"
}

# - roles/secretmanager.secretAccessor: scoped strictly to GitHub App private key
resource "google_secret_manager_secret_iam_member" "crema_secret_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.github_app_private_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.crema_sa.email}"
}

# - roles/parametermanager.parameterAccessor & parameterViewer: read crema-config
resource "google_project_iam_member" "crema_parameter_accessor" {
  project = var.project_id
  role    = "roles/parametermanager.parameterAccessor"
  member  = "serviceAccount:${google_service_account.crema_sa.email}"
}

resource "google_project_iam_member" "crema_parameter_viewer" {
  project = var.project_id
  role    = "roles/parametermanager.parameterViewer"
  member  = "serviceAccount:${google_service_account.crema_sa.email}"
}

# - roles/monitoring.viewer & metricWriter: emit scaler metrics
resource "google_project_iam_member" "crema_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.crema_sa.email}"
}

resource "google_project_iam_member" "crema_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.crema_sa.email}"
}

# - roles/iam.serviceAccountUser: manage worker pool instances
resource "google_project_iam_member" "crema_sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.crema_sa.email}"
}

# - roles/logging.logWriter: emit structured service logs
resource "google_project_iam_member" "crema_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.crema_sa.email}"
}

# Worker Pool IAM Roles
# - roles/secretmanager.secretAccessor: scoped strictly to mount GitHub App private key
resource "google_secret_manager_secret_iam_member" "worker_secret_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.github_app_private_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.worker_sa.email}"
}

# - roles/logging.logWriter: write runner logs to Cloud Logging
resource "google_project_iam_member" "worker_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.worker_sa.email}"
}

# Cloud Build Service Account Permissions (for building and pushing runner images)
locals {
  cloudbuild_sa = "${data.google_project.current.number}-compute@developer.gserviceaccount.com"
  cloudbuild_roles = [
    "roles/logging.logWriter",
    "roles/storage.admin",
    "roles/artifactregistry.writer",
  ]
}

resource "google_project_iam_member" "cloudbuild_roles" {
  for_each = toset(local.cloudbuild_roles)
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${local.cloudbuild_sa}"

  depends_on = [
    google_project_service.apis["cloudbuild.googleapis.com"],
    google_project_service.apis["compute.googleapis.com"],
  ]
}
