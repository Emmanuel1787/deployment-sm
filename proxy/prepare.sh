DIR="$(dirname $0)"

pushd ${DIR} >/dev/null

set -a
source ../.env
set +a

docker run -i --rm vfarcic/docker-flow-proxy:${PROXY_TAG} cat /cfg/tmpl/haproxy.tmpl > haproxy.tmpl.ori
cat Dockerfile.tmpl | envsubst > Dockerfile

popd >/dev/null

echo 'Now modify `haproxy.tmpl` as needed'
