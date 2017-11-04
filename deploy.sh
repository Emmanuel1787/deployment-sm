#!/bin/bash
set -e
pushd "${BASH_SOURCE%/*}" > /dev/null

CONFIG_FILE="./config.env"
SECRETS_FILE="./secrets/secrets.env"

if [ "$#" -lt 1 ]
then
  echo "Usage: deploy.sh STACK_FILE [STACK_NAME]"
  exit 1
fi

FILE_NAME=${1%.yml} # remove suffix if supplied
export FILE=${FILE_NAME}.yml
export STACK=${STACK:-$FILE_NAME}

if [ ! -f ${FILE} ]
then
  echo "Stack file '${FILE}' does not exist"
  exit 1
fi

if [ ! -f ${CONFIG_FILE} ]
then
  echo "Configuration file does not exist"
  exit 1
fi

./secret-check.sh

set -a
source config.env
set +a

cat \
  <(./env.defaults.sh) \
  <(./env.current.sh) \
  ${SECRETS_FILE} \
  ${CONFIG_FILE} \
  <(./replicas-check.sh) \
> .env

cat ${FILE} | env $(cat .env | grep -vE '^#' | xargs) envsubst > .docker-compose.yml

if [ -n "$DEBUG" ]
then
  docker-compose -f .docker-compose.yml ${2:-config}
else
  docker stack deploy -c <(docker-compose -f .docker-compose.yml config 2>/dev/null | sed "s#$(pwd)#.#g" | sed 's/:rw//') ${STACK}
fi

popd > /dev/null
