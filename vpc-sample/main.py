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

# This file holds functions for testing VPC ingress/egress with Cloud Functions

# [START run_egress_hello_world]
import os
import urllib

import google.auth.transport.requests
import google.oauth2.id_token


def get_hello_world(request):
    try:
        url = os.environ.get("URL")
        req = urllib.request.Request(url)

        auth_req = google.auth.transport.requests.Request()
        id_token = google.oauth2.id_token.fetch_id_token(auth_req, url)
        req.add_header("Authorization", f"Bearer {id_token}")

        response = urllib.request.urlopen(req)
        return response.read()

    except Exception as e:
        print(e)
        return str(e)
# [END run_egress_hello_world]

# [START functions_ingress_hello_world]
def hello_world(request):
    return "Hello World!"
# [END functions_ingress_hello_world]
