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

variable "project_id" {
  description = "Google Cloud project ID where the runner infrastructure will be deployed."
  type        = string
}

variable "region" {
  description = "Google Cloud region for Cloud Run, Artifact Registry, Secret Manager, and Parameter Manager."
  type        = string
  default     = "us-central1"
}

variable "github_org" {
  description = "GitHub organization name where the self-hosted runners will register."
  type        = string
}

variable "github_app_id" {
  description = "GitHub App ID used for runner authentication and CREMA queue polling."
  type        = string
}

variable "github_app_installation_id" {
  description = "GitHub App Installation ID for the target organization."
  type        = string
}

variable "worker_pool_name" {
  description = "Name of the Cloud Run Worker Pool."
  type        = string
  default     = "github-runner-pool"
}

variable "crema_service_name" {
  description = "Name of the Cloud Run CREMA autoscaler service."
  type        = string
  default     = "crema-github-autoscaler"
}

variable "artifact_registry_repo_name" {
  description = "Name of the Artifact Registry Docker repository."
  type        = string
  default     = "github-runner-repo"
}

variable "runner_image_name" {
  description = "Container image name for the GitHub Actions runner."
  type        = string
  default     = "github-actions-runner"
}

variable "runner_image_tag" {
  description = "Container image tag for the GitHub Actions runner."
  type        = string
  default     = "latest"
}

variable "runner_cpu" {
  description = "CPU limit for runner container instances (e.g. 2, 4, 8)."
  type        = string
  default     = "2"
}

variable "runner_memory" {
  description = "Memory limit for runner container instances (e.g. 2Gi, 4Gi, 8Gi)."
  type        = string
  default     = "2Gi"
}

variable "min_replicas" {
  description = "Minimum runner replicas (0 enables scale-to-zero)."
  type        = number
  default     = 0
}

variable "max_replicas" {
  description = "Maximum runner replicas allowed during autoscaling."
  type        = number
  default     = 5
}

variable "cooldown_period" {
  description = "Cooldown period in seconds before scaling down."
  type        = number
  default     = 300
}

variable "polling_interval" {
  description = "Polling interval in seconds for CREMA to check the GitHub Actions queue."
  type        = number
  default     = 15
}

variable "target_workflow_queue_length" {
  description = "Target queued workflows per runner instance."
  type        = number
  default     = 1
}

variable "runner_labels" {
  description = "Comma-separated labels to assign to the self-hosted runner."
  type        = string
  default     = "self-hosted,cloud-run,linux"
}

variable "runner_group_id" {
  description = "GitHub runner group ID to register into (1 is the default organization group)."
  type        = number
  default     = 1
}

variable "crema_image" {
  description = "Container image URI for the CREMA autoscaler service."
  type        = string
  default     = "us-central1-docker.pkg.dev/cloud-run-oss-images/crema-v1/autoscaler:1.2"
}
