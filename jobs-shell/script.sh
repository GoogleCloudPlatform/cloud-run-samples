#!/bin/bash
# Copyright 2022 Google LLC
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

# [START cloudrun_jobs_shell_script]
#!/bin/bash
set -euo pipefail

# In production, consider printing commands as they are executed. 
# This helps with debugging if things go wrong and you only 
# have the logs.
#
# Add -x:
# `set -euox pipefail`

CLOUD_RUN_TASK_INDEX=${CLOUD_RUN_TASK_INDEX:=0}
CLOUD_RUN_TASK_ATTEMPT=${CLOUD_RUN_TASK_ATTEMPT:=0}

echo "Starting Task #${CLOUD_RUN_TASK_INDEX}, Attempt #${CLOUD_RUN_TASK_ATTEMPT}..."

# SLEEP_MS and FAIL_RATE should be a decimal
# numbers. parse and format the input using 
# printf. 
#
# printf validates the input since it 
# quits on invalid input, as shown here:
#
#   $: printf '%.1f' "abc"
#   bash: printf: abc: invalid number
#
SLEEP_MS=$(printf '%.1f' "${SLEEP_MS:=0}")
FAIL_RATE=$(printf '%.1f' "${FAIL_RATE:=0}")

# Wait for a specific amount of time to simulate
# performing some work
SLEEP_SEC=$(echo print\("${SLEEP_MS}"/1000\) | perl)
sleep "$SLEEP_SEC" # sleep accepts seconds, not milliseconds

# Fail the task with a likelihood of $FAIL_RATE

# Bash does not do floating point arithmetic. Use perl 
# to convert into integer and multiply by 100.
FAIL_RATE_INT=$(echo print\("int(${FAIL_RATE:=0}*100"\)\) | perl)

# Generate a random number between 0 and 100
RAND=$(( RANDOM % 100))
if (( RAND < FAIL_RATE_INT )); then 
    echo "Task #${CLOUD_RUN_TASK_INDEX}, Attempt #${CLOUD_RUN_TASK_ATTEMPT} failed."
    exit 1
else 
    echo "Completed Task #${CLOUD_RUN_TASK_INDEX}."
fi

# [END cloudrun_jobs_shell_script]