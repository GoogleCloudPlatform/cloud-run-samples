# Copyright 2025 Google, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


import hashlib
import hmac
import logging
import os

import google.auth
import requests
from flask import Request
from google.auth.transport.requests import Request as GoogleRequest


CREDENTIALS, PROJECT_ID = google.auth.default()
# --- Configuration (Mandatory values) ---
CLOUD_RUN_WORKER_POOL_NAME = os.environ["WORKER_POOL_NAME"]
CLOUD_RUN_WORKER_POOL_LOCATION = os.environ["WORKER_POOL_LOCATION"]
GITHUB_REPO = os.environ["GITHUB_REPO"]
GITHUB_WEBHOOK_SECRET = os.environ["WEBHOOK_SECRET"]

# Cloud Run API for checking/updating
CLOUDRUN_URI = f"https://run.googleapis.com/v2/projects/{PROJECT_ID}/locations/{CLOUD_RUN_WORKER_POOL_LOCATION}/workerPools/{CLOUD_RUN_WORKER_POOL_NAME}"

## Autoscaling parameters
# Max number of concurrent runners
MAX_RUNNERS = int(os.getenv("MAX_RUNNERS", 5))
# How long to wait before scaling down idle runners
IDLE_TIMEOUT_MINUTES = int(os.getenv("IDLE_TIMEOUT_MINUTES", 15))


def _call_cloudrun_api(method, url=CLOUDRUN_URI, payload=None):
    # TODO: this method should be replaced with google-cloud-run SDK
    # when functionality available

    # Get Authenticated URL
    scoped_credentials = CREDENTIALS.with_scopes(
        ["https://www.googleapis.com/auth/cloud-platform"]
    )
    auth_req = GoogleRequest()

    scoped_credentials.refresh(auth_req)
    access_token = scoped_credentials.token

    if not access_token:
        logging.error("Failed to retrieve Google Cloud access token.")

    # Setup Call
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {access_token}",
    }

    # Make Call
    try:
        response = auth_req.session.request(method, url, headers=headers, json=payload)
        response.raise_for_status()

        return response.status_code, response.json()

    except requests.exceptions.RequestException as e:
        if response:
            raise ValueError(f"API Error: {response.status_code} - {response.text}")
        else:
            raise ValueError(f"API Error: {e}")


def get_current_worker_pool_instance_count():
    """
    Retrieves the current manualInstanceCount of the Cloud Run worker pool.
    """

    try:
        _, response = _call_cloudrun_api("GET")

        current_instance_count = response.get("scaling", {}).get(
            "manualInstanceCount", -1
        )
        print(f"Current worker pool instance count: {current_instance_count}")
        return current_instance_count
    except ValueError:
        raise


def update_runner_instance_count(instance_count: int):
    """
    Updates a Cloud Run worker pool with the specified instance count.
    """

    url = f"{CLOUDRUN_URI}?updateMask=scaling.manualInstanceCount"
    payload = {
        "scaling": {"scalingMode": "MANUAL", "manualInstanceCount": instance_count}
    }

    try:
        _call_cloudrun_api("PATCH", url=url, payload=payload)
    except ValueError:
        raise


def validate_signature(request):
    """
    Checks the validity of the webhook, using GitHub's suggested implementation.

    https://docs.github.com/en/webhooks/using-webhooks/validating-webhook-deliveries#python-example
    """
    signature_header = request.headers.get("x-hub-signature-256")
    payload_body = request.data

    if not signature_header:
        logging.error("x-hub-signature-256 header is missing!")
        return False

    hash_object = hmac.new(
        GITHUB_WEBHOOK_SECRET.encode("utf-8"),
        msg=payload_body,
        digestmod=hashlib.sha256,
    )
    expected_signature = "sha256=" + hash_object.hexdigest()
    if not hmac.compare_digest(expected_signature, signature_header):
        logging.error("Request signatures didn't match!")
        return False

    return True


# --- Main Webhook Handler ---
def github_webhook_handler(request: Request):
    """
    HTTP Cloud Function that handles GitHub workflow_job events for autoscaling.
    """

    # 0. Log invocation.
    event_type = request.headers.get("X-GitHub-Event")
    print(f"Received event type '{event_type}'")

    # 1. Validate Webhook Signature
    if not validate_signature(request):
        return ("Invalid signature", 403)

    # 2. Parse Event
    if event_type != "workflow_job":
        print(f"Ignoring event type '{event_type}'")
        return ("OK", 200)

    try:
        payload = request.get_json()
    except Exception as e:
        return (f"Error parsing JSON payload: {e}", 400)

    action = payload.get("action")
    job = payload.get("workflow_job")

    if not job:
        return ("No 'workflow_job' found in payload.", 200)

    job_id = job.get("id")
    job_name = job.get("name")
    job_status = job.get("status")  # 'queued', 'in_progress', 'completed'
    print(
        f"Received workflow_job event: Job ID {job_id}, Name '{job_name}', "
        f"Status '{job_status}', Action '{action}'"
    )

    # 3. Handle Scaling Logic
    # [START run_github_worker_pool_scaling_logic]
    try:
        current_instance_count = get_current_worker_pool_instance_count()
    except ValueError as e:
        return f"Could not retrieve instance count: {e}", 500

    # Scale Up: If a job is queued and we have available capacity
    if action == "queued" and job_status == "queued":
        print(f"Job '{job_name}' is queued.")

        if current_instance_count < MAX_RUNNERS:
            new_instance_count = current_instance_count + 1
            try:
                update_runner_instance_count(new_instance_count)
                print(f"Successfully scaled up to {new_instance_count} instances")
            except ValueError as e:
                return f"Error scaling up instances: {e}", 500
        else:
            print(f"Max runners ({MAX_RUNNERS}) reached.")

    # Scale Down: If a job is completed, find the corresponding runner and consider terminating it
    elif action == "completed" and job_status == "completed":
        print(f"Job '{job_name}' completed.")

        # TODO(developer): You might want more sophisticated logic here to
        # determine which runner to shut down, especially if you have multiple
        # runners and want to only shut down idle ones. For simplicity, this
        # example scales down by one, ensuring it doesn't go below zero.

        if current_instance_count > 0:
            new_instance_count = current_instance_count - 1
            try:
                update_runner_instance_count(new_instance_count)
                print(f"Successfully scaled down to {new_instance_count} instances")
            except ValueError as e:
                return f"Error scaling down instances: {e}", 500
        else:
            print(f"No runners are currently active to scale down.")

    else:
        print(
            f"Workflow job event for '{job_name}' with action '{action}' and "
            f"status '{job_status}' did not trigger a scaling action."
        )
    return ("OK", 200)


# [END run_github_worker_pool_scaling_logic]
