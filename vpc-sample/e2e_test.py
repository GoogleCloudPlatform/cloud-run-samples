# Copyright 2020 Google, LLC.
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

# Requires VPC API, Cloud Functions API, Cloud Build API, Cloud Resource Manager
# and requires Cloud Build to have Cloud Functions Developer enabled

import os
import subprocess
from urllib import request
import uuid

import pytest


@pytest.fixture()
def services():
    # Unique suffix to create distinct service names
    suffix = uuid.uuid4().hex[0:5]
    project = os.environ['GOOGLE_CLOUD_PROJECT']

    # Build and Deploy Cloud Functions
    subprocess.run(
        [
            "gcloud",
            "builds",
            "submit",
            "--project",
            project,
            "--substitutions",
            f"_SUFFIX={suffix}",
            "--config",
            "e2e_test_setup.yaml",
            "--quiet",
        ], check=True
    )

    # Get the URL for the service and the token
    restricted_url = f"https://us-central1-{project}.cloudfunctions.net/restricted-{suffix}"
    
    allow_url = subprocess.run(
        [
            "gcloud",
            "run",
            "--project",
            project,
            "--platform=managed",
            "--region=us-central1",
            "services",
            "describe",
            f"allow-{suffix}",
            "--format=value(status.url)",
        ],
        stdout=subprocess.PIPE,
        check=True
    ).stdout.strip().decode()

    token = subprocess.run(
        ["gcloud", "auth", "print-identity-token"], stdout=subprocess.PIPE,
        check=True
    ).stdout.strip().decode()

    yield token, restricted_url, allow_url

    # Tear down resources
    subprocess.run(
        ["gcloud", "functions", "delete", f"restricted-{suffix}", "--quiet", "--project", project],
        check=True
    )



def test_vpc_access(services):
    # Test access to `restricted` is blocked outside of the network
    token = services[0]
    url = services[1]
    req = request.Request(url, headers={"Authorization": f"Bearer {token}"})
    with pytest.raises(Exception) as e:
        request.urlopen(req)
        assert "403" in str(e)

    # Test access to `restricted` is allowed with VPC connector
    url = services[2]
    req = request.Request(url, headers={"Authorization": f"Bearer {token}"})
    response = request.urlopen(req)
    body = response.read()

    assert "Hello World!" in body.decode()
