#!/bin/sh
# Build the custom images. Push only when GHCR_OWNER is set and docker is logged in.
set -eu
root="$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)"
docker build -t el-torrento-engine:local "$root/el-torrento/engine"
docker build -t el-torrento-web:local "$root/el-torrento"
docker build -t el-torrento-media-worker:local "$root/el-torrento/media-worker"
docker build -t el-torrento-mgmt-worker:local "$root/el-torrento-infra/mgmt-worker"
docker image inspect el-torrento-engine:local --format 'el-torrento-engine:local {{.Id}}'
docker image inspect el-torrento-web:local --format 'el-torrento-web:local {{.Id}}'
docker image inspect el-torrento-media-worker:local --format 'el-torrento-media-worker:local {{.Id}}'
docker image inspect el-torrento-mgmt-worker:local --format 'el-torrento-mgmt-worker:local {{.Id}}'
if [ -n "${GHCR_OWNER:-}" ]; then
  docker tag el-torrento-engine:local "ghcr.io/${GHCR_OWNER}/el-torrento-engine:local"
  docker tag el-torrento-web:local "ghcr.io/${GHCR_OWNER}/el-torrento-web:local"
  docker push "ghcr.io/${GHCR_OWNER}/el-torrento-engine:local"
  docker push "ghcr.io/${GHCR_OWNER}/el-torrento-web:local"
else
  echo "GHCR_OWNER is unset. Images are local only; nothing was pushed."
fi
