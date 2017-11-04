#!/bin/bash
FILTER=""
EXTRA_FIELDS=""

if [ -n "$ROLE" ]
then
  FILTER="role=${ROLE},"
else
  EXTRA_FIELDS='"role":"{{.Spec.Role}}",'
fi

if [ -n "$FILTER" ]
then
  FILTER=",$FILTER"
fi

eval docker node ls -q \
  | xargs -n1 docker node inspect -f "{${EXTRA_FIELDS}\"cpu\":{{.Description.Resources.NanoCPUs}},\"mem\":{{.Description.Resources.MemoryBytes}},\"availability\":\"{{.Spec.Availability}}\"}" \
  | jq -sc 'group_by(.role) | .[] | { "role":.[0].role, "cpu": (reduce .[] as $item (0; . + $item.cpu)), "mem": (reduce .[] as $item (0; . + $item.mem))}'
