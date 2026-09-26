#!/bin/sh
# Fail if a writer path is missing or is not an NFS mount.
# This script does not start containers. If it exits non-zero, do not start them.
set -eu

if [ "$#" -lt 1 ]; then
  echo "usage: require-nfs-mount.sh /mnt/downloads [/mnt/stream-cache ...]" >&2
  exit 2
fi

fail=0
for path in "$@"; do
  if [ ! -d "$path" ]; then
    echo "missing path: $path" >&2
    fail=1
    continue
  fi
  if ! mountpoint -q "$path"; then
    echo "not a mountpoint: $path" >&2
    fail=1
    continue
  fi
  if ! command -v findmnt >/dev/null 2>&1; then
    echo "findmnt is not available; refusing to treat $path as NFS" >&2
    fail=1
    continue
  fi
  fstype=$(findmnt -n -o FSTYPE --target "$path" || true)
  case "$fstype" in
    nfs|nfs4) ;;
    *)
      echo "not nfs (${fstype:-unknown}): $path" >&2
      fail=1
      ;;
  esac
done

if [ "$fail" -ne 0 ]; then
  echo "NFS check failed. Do not start writer containers." >&2
  exit 1
fi

echo "NFS mounts are present. This script does not start containers."
exit 0
