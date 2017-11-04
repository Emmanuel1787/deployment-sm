#!/bin/bash
. ./config.env

REVISION=$(date +_%F%T | tr -d ':-')
REV_FMT="(_[0-9]{12})"

SECRETS_PATH=./secrets
SECRETS_NEW=${SECRETS_PATH}/new
SECRETS_OLD=${SECRETS_PATH}/old
SECRETS_ENV=${SECRETS_PATH}/secrets.env

mkdir -p $SECRETS_NEW
mkdir -p $SECRETS_OLD
touch $SECRETS_ENV
truncate --size 0 $SECRETS_ENV

TMP_SECRETS=$(mktemp)
docker secret ls | tail -n +2 | grep -E "\\ ${STACK}_" | sed -Ee 's/\s+/\ /g' | cut -d' ' -f2 | sort > $TMP_SECRETS

for SECRET in $(cat "${STACK}.yml" | yq -r '.secrets[] | .external.name' | tr -d '${}' | sort)
do
  SECRET_NAME="${SECRET}${REVISION}"
  NEW_SECRET="${SECRETS_NEW}/$SECRET"
  OLD_SECRET="${SECRETS_OLD}/$SECRET"

  if [ -f $NEW_SECRET ]
  then
    echo "Creating secret: $SECRET_NAME"
    docker secret create -l "com.docker.ucp.access.label=${ACCESS_LEVEL}/${STACK}" ${SECRET_NAME} ${NEW_SECRET}
    mv $NEW_SECRET $OLD_SECRET
  else
    echo "Looking for secret: $SECRET"
    MATCH=$(grep -Pe "${SECRET}${REV_FMT}?" $TMP_SECRETS | sort -rn | head -n1)
    if [ -n "$MATCH" ]
    then
      echo "Found: $MATCH"
      SECRET_NAME="${MATCH}"
    elif [ -f $OLD_SECRET ]
    then
      echo "Creating secret: $SECRET_NAME"
      docker secret create -l "com.docker.ucp.access.label=${ACCESS_LEVEL}/${STACK}" ${SECRET_NAME} ${OLD_SECRET}
    else
      >&2 echo "No secret found or created for: $SECRET"
      exit 1
    fi
  fi
  echo $SECRET="$SECRET_NAME" >> $SECRETS_ENV
done
