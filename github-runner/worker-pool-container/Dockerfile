# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# [START run_github_worker_pool_dockerfile]
FROM ghcr.io/actions/actions-runner:2.326.0

# Add scripts with right permissions.
USER root
COPY start.sh start.sh
RUN chmod +x start.sh

# Add start entrypoint with right permissions.
USER runner
ENTRYPOINT ["./start.sh"]
# [END run_github_worker_pool_dockerfile]
