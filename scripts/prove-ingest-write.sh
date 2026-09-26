#!/bin/sh
# Prove the downloads directory is writable by the container uid.
# root_squash maps UID 0 to anonymous. It does not remap UID 1000.
# Run this script AS the container uid (1000). Do not wrap the write in sudo.
set -eu
dir="${1:-/mnt/downloads}"
uid="$(id -u)"
gid="$(id -g)"
if [ "$uid" -eq 0 ]; then
  echo "This shell is root. A root write is not evidence (root_squash maps it to nobody)."
  echo "Run again as uid 1000, without sudo."
  exit 2
fi
probe="$dir/.el-torrento-write-test"
printf 'uid=%s gid=%s\n' "$uid" "$gid" > "$probe"
echo "wrote $probe as ${uid}:${gid}"
