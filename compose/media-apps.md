# media-apps Compose skeleton

Target guest: VM 102 on `pve3040a` only. Do not place this file’s services on the ingest VM.

Services: `watch` (Next.js), `api` (Fastify), `postgres`, `seerr`, `sonarr`, `radarr`, `prowlarr`, `caddy`, and the private `mgmt-worker` on network `mgmt` with no published port.

Not included here: qBittorrent, libtorrent, Jellyfin, FFmpeg.

Published on the VM, LAN only until DNS is ready:

- `80` and `443` — Caddy for `server.hasnain.us`, `watch.hasnain.us`, and `media.hasnain.us` (the last proxies to playback).
- No port for Proxmox. No port for the management worker.

Environment names are in `../.env.example`. Image lines stay unpinned until digests are chosen:

```yaml
# not applied
services:
  postgres:
    image: postgres@sha256:PIN_BEFORE_USE
    volumes:
      - pgdata:/var/lib/postgresql/data
  api:
    image: ghcr.io/hasnain-niazi/el-torrento-api@sha256:PIN_BEFORE_USE
    environment:
      DATABASE_URL: ${DATABASE_URL}
  mgmt-worker:
    image: ghcr.io/hasnain-niazi/el-torrento-mgmt@sha256:PIN_BEFORE_USE
    networks: [mgmt]
    # no ports:
volumes:
  pgdata: {}
networks:
  mgmt:
    internal: true
```
