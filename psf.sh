#!/bin/bash
set -o pipefail
docker ps -qf "name=${1-?}" | sed -n "${2:-1}p"
