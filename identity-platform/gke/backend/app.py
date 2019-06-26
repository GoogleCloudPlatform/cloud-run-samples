# Copyright 2019 Google LLC
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

from flask import Flask, jsonify


app = Flask(__name__)


@app.after_request
def set_response_headers(response):
    response.cache_control.max_age = 0
    response.cache_control.no_cache = True
    response.cache_control.no_store = True
    response.cache_control.must_revalidate = True
    response.cache_control.proxy_revalidate = True
    return response


@app.route('/api/secure.json')
def secret_message():
    return jsonify({"message": "Hello World"})


@app.route('/api/healthz')
def healthz():
    return "ok"
