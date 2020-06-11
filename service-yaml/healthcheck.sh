#!/bin/sh -eu
#
# Copyright 2019 Google LLC
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

# retries, interval,keyword may be passed as arguments
# retries: -r
# interval (in seconds): -i
# keyword: -k
# url: -u

## Defaults
content="Hello, World!"
retries=5
interval=5
url="http://localhost:3000"

while getopts r:i:k:u:a: option
do
    case "${option}"
    in
        r) retries=$OPTARG;;
        i) interval=$OPTARG;;
        k) content=$OPTARG;;
        u) url=$OPTARG;;
        a) auth=$OPTARG;
    esac
done

echo "START CONTENT TEST"
echo "retries: "$retries
echo "interval: "$interval
echo "content: "$content
echo "url: "$url

gcurl() {
    if [ -n "$auth" ]; then
      curl -H "Authorization: Bearer $auth" "$@"
    else
      curl "$@"
    fi
}

for i in $(seq 0 $retries); do
    
    html="$(gcurl -si $url)" || html=""
    
    if echo "$html" | grep -q "$content"
    then
        echo "Content found -- site is up"
        echo "END CONTENT TEST: Success! ✅"
        exit 0
    else
        echo "content not found. retrying in $interval sec..."
        sleep $interval
    fi
done

echo "Error! Expected content not found."
echo "Was looking for '$content'; not found in:"
echo "$html"
echo "END CONTENT TEST: Fail! ❌"

exit 1