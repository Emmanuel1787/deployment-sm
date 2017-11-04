#!/bin/bash
. ./config.env
set -o nounset
docker secret ls | tail -n +2 | sed 's/\s\+/|/g' | grep "|${STACK}_" | cut -d'|' -f1 | xargs -n1 docker secret rm
