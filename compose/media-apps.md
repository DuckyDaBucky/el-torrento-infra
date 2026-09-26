# media-apps Compose skeleton

Target guest: VM 102 on `pve3040a` only. Do not place this file’s services on the ingest VM.

Services: one Next.js `web` image (Watch, admin, API, HLS worker), `seerr`, `sonarr`, `radarr`, `prowlarr`, and `caddy`. The app database is SQLite on the VM disk. Postgres is not used. The management worker is still design-only and is not in this file.

Not included here: qBittorrent, libtorrent, Jellyfin, FFmpeg.

Published on the VM, LAN only until DNS is ready:

- `80` and `443` — Caddy for `server.hasnain.us`, `watch.hasnain.us`, and `media.hasnain.us` (the last proxies to playback).
- No port for Proxmox. No port for the management worker.

Environment names are in `../.env.example`. Custom images are `el-torrento-web:local` and `el-torrento-engine:local` (see `scripts/publish-images.sh`). SQLite lives in the `app-data` volume. There is no `DATABASE_URL`.
