#!/bin/sh
# Render compose files for docker-compose 1.29 on the target VM.
set -eu
root="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
pins="${root}/compose/image-pins.env"
merge() {
  file="$1"
  out="$2"
  if [ -f "$pins" ]; then
    # shellcheck disable=SC1090
    set -a
    . "$pins"
    set +a
  fi
  envsubst '${EL_TORRENTO_WEB_IMAGE} ${EL_TORRENTO_ENGINE_IMAGE} ${EL_TORRENTO_MEDIA_WORKER_IMAGE} ${EL_TORRENTO_MGMT_IMAGE}' \
    < "$file" > "$out" 2>/dev/null || cp "$file" "$out"
}
mkdir -p "${root}/rendered"
merge "${root}/compose/media-apps.compose.yml" "${root}/rendered/media-apps.compose.yml"
merge "${root}/compose/media-ingest.compose.yml" "${root}/rendered/media-ingest.compose.yml"
merge "${root}/compose/media-playback.compose.yml" "${root}/rendered/media-playback.compose.yml"
echo "Rendered compose files in ${root}/rendered/"
