#!/bin/bash
set -o nounset

for SERVICE in $(docker-compose -f ${FILE} config --services 2>/dev/null)
do
  SERVICE=$(echo $SERVICE | tr '-' '_')
  echo "IMAGE_${STACK^^}_${SERVICE^^}=${REGISTRY:-bl}/${SERVICE,,}:latest"
done
