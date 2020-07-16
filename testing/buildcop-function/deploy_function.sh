#!/bin/bash
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Get buildcop binary
export GOOS=linux   
export GOARCH=amd64

go get github.com/googleapis/repo-automation-bots/packages/buildcop
cp $(go env GOPATH)/bin/linux_amd64/buildcop buildcop

# Deploy function
gcloud functions deploy buildcop-worker --region=us-central1 \
--trigger-topic=cloud-builds --runtime=python37 --entry-point=send_to_buildcop \
--no-allow-unauthenticated

# Remove binary from current directory 
rm buildcop