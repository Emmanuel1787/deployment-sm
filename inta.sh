#!/bin/bash
set -o pipefail
docker inspect $(./psf.sh $1) | jq -r ".[0].NetworkSettings.Networks.$2.IPAddress"
