#!/bin/bash
set -eux pipefail

docker build -t test .

if docker run -t test | grep -q 'Starting Task'; 
then 
  echo "Output matched"; 
else
  exit 1;
fi