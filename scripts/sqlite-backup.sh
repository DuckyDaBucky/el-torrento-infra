#!/bin/sh
# Consistent SQLite backup via the sqlite3 .backup API.
# Restore only to an isolated file. This script never replaces the live database.
set -eu

usage() {
  echo "usage: sqlite-backup.sh backup <live.sqlite> <dest-dir>" >&2
  echo "       sqlite-backup.sh restore-isolated <backup.sqlite> <isolated-dest> <live.sqlite>" >&2
  exit 2
}

reject_quote() {
  case "$1" in
    *\'*)
      echo "path contains a quote this script will not pass to sqlite3: $1" >&2
      exit 1
      ;;
  esac
}

command=${1:-}
shift || true

case "$command" in
  backup)
    live=${1:-}
    dest_dir=${2:-}
    [ -n "$live" ] && [ -n "$dest_dir" ] || usage
    reject_quote "$live"
    reject_quote "$dest_dir"
    [ -f "$live" ] || {
      echo "live database missing: $live" >&2
      exit 1
    }
    mkdir -p "$dest_dir"
    stamp=$(date -u +%Y%m%dT%H%M%SZ)
    out="$dest_dir/app-$stamp.sqlite"
    reject_quote "$out"
    sqlite3 "$live" ".backup '$out'"
    echo "$out"
    ;;
  restore-isolated)
    backup=${1:-}
    dest=${2:-}
    live=${3:-}
    [ -n "$backup" ] && [ -n "$dest" ] && [ -n "$live" ] || usage
    reject_quote "$backup"
    reject_quote "$dest"
    reject_quote "$live"
    [ -f "$backup" ] || {
      echo "backup missing: $backup" >&2
      exit 1
    }
    live_real=$(readlink -f "$live")
    dest_real=$(readlink -f "$dest")
    backup_real=$(readlink -f "$backup")
    if [ "$dest_real" = "$live_real" ]; then
      echo "refusing to restore over the live database" >&2
      exit 1
    fi
    if [ "$dest_real" = "$backup_real" ]; then
      echo "refusing to restore onto the backup file" >&2
      exit 1
    fi
    if [ -e "$dest" ] && [ -e "$live" ]; then
      dest_inode=$(stat -c '%d:%i' "$dest")
      live_inode=$(stat -c '%d:%i' "$live")
      if [ "$dest_inode" = "$live_inode" ]; then
        echo "refusing to restore over the live database" >&2
        exit 1
      fi
    fi
    mkdir -p "$(dirname "$dest_real")"
    sqlite3 "$backup" ".backup '$dest_real'"
    echo "$dest_real"
    ;;
  *)
    usage
    ;;
esac
