#!/bin/bash
set -o nounset

for SERVICE in $(docker service ls --filter label=com.docker.stack.namespace=${STACK} --format 'IMAGE_{{.Name}}={{.Image}}')
do
  IFS='=' read VARNAME IMAGE <<< "${SERVICE}"
  VARNAME=$(echo $VARNAME | tr '-' '_')
  echo "${VARNAME^^}=${IMAGE}"
done
