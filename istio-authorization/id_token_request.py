#!/usr/bin/env python3
#
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START cloudrun_gke_invoker_id_token_request]
# [START run_gke_invoker_id_token_request]
import os
import sys
from google.auth.transport.requests import AuthorizedSession
from google.oauth2 import service_account


def request(method, url, target_audience=None, service_account_file=None,
            data=None, headers=None, **kwargs):
    """Obtains a Google-issued ID token and uses it to make a HTTP request.

    Args:
      method (str): The HTTP request method to use
            ('GET', 'OPTIONS', 'HEAD', 'POST', 'PUT', 'PATCH', 'DELETE')
      url: The URL where the HTTP request will be sent.
      target_audience (str): Optional, the value to use in the audience
            ('aud') claim of the ID token. Defaults to the value of 'url'
            if not provided.
      service_account_file (str): Optional, the full path to the service
            account credentials JSON file. Defaults to
            '<working directory>/service-account.json'.
      data: Optional dictionary, list of tuples, bytes, or file-like object
            to send in the body of the request.
      headers (dict): Optional dictionary of HTTP headers to send with the
            request.
      **kwargs: Any of the parameters defined for the request function:
            https://github.com/requests/requests/blob/master/requests/api.py
            If no timeout is provided, it is set to 90 seconds.

    Returns:
      The page body, or raises an exception if the HTTP request failed.
    """
    # Set target_audience, if missing
    if not target_audience:
        target_audience = url

    # Set service_account_file, if missing
    if not service_account_file:
        service_account_file = os.path.join(os.getcwd(),
                                            'service-account.json')

    # Set the default timeout, if missing
    if 'timeout' not in kwargs:
        kwargs['timeout'] = 90  # seconds

    # Obtain ID token credentials for the specified audience
    creds = service_account.IDTokenCredentials.from_service_account_file(
        service_account_file, target_audience=target_audience)

    # Create a session for sending requests with the ID token credentials
    session = AuthorizedSession(creds)

    # Send a HTTP request to the provided URL using the Google-issued ID token
    resp = session.request(method, url, data=data, headers=headers, **kwargs)
    if resp.status_code == 403:
        raise Exception('Service account {} does not have permission to '
                        'access the application.'.format(
                            creds.service_account_email))
    elif resp.status_code != 200:
        raise Exception(
            'Bad response from application: {!r} / {!r} / {!r}'.format(
                resp.status_code, resp.headers, resp.text))
    else:
        return resp.text
# [END run_gke_invoker_id_token_request]
# [END cloudrun_gke_invoker_id_token_request]


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python id_token_request.py <url> <audience> [headers]")
        sys.exit(1)
    url = sys.argv[1]
    target_audience = sys.argv[2]
    headers = dict(arg.split(":", 1) for arg in sys.argv[3:])
    out = request('GET', url, target_audience=target_audience, headers=headers)
    print(out)
