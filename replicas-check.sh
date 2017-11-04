#!/bin/bash
set -o nounset
docker service inspect --format '{{json .Spec}}' $(docker stack services -q ${STACK}) \
  | jq -sr '.[] | select(.Mode.Replicated) | (.Name | ascii_upcase) + "_REPLICAS=" + (.Mode.Replicated.Replicas | tostring)'
