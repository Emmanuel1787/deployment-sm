#!/bin/bash
docker service ls -q |
  xargs -n1 docker service inspect \
  | jq -c '.[0].Spec.TaskTemplate | { "res": (.Resources?.Reservations? // {}), "cond": ((.Placement?.Constraints? // []) | join(","))}' \
  | jq -cs 'group_by(.cond)' \
  | jq -c '.[] | {"cond": .[0].cond, "cpu":(reduce .[] as $item (0; . + $item.res.NanoCPUs)), "mem":(reduce .[] as $item (0; . + $item.res.MemoryBytes))}'
