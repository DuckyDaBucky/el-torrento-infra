#!/bin/sh
# Build the custom images. Push only when GHCR_OWNER is set and docker is logged in.
set -eu
root="$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)"
docker build -t el-torrento-engine:local "$root/el-torrento/engine"
docker build -t el-torrento-web:local "$root/el-torrento"
docker image inspect el-torrento-engine:local --format 'el-torrento-engine:local {{.Id}}'
docker image inspect el-torrento-web:local --format 'el-torrento-web:local {{.Id}}'
if [ -n "${GHCR_OWNER:-}" ]; then
  docker tag el-torrento-engine:local "ghcr.io/${GHCR_OWNER}/el-torrento-engine:local"
  docker tag el-torrento-web:local "ghcr.io/${GHCR_OWNER}/el-torrento-web:local"
  docker push "ghcr.io/${GHCR_OWNER}/el-torrento-engine:local"
  docker push "ghcr.io/${GHCR_OWNER}/el-torrento-web:local"
else
  echo "GHCR_OWNER is unset. Images are local only; nothing was pushed."
fi
