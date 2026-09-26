# Placement amendment (SQLite, single Next app)

This amends the original blueprint that listed a separate Fastify API and Postgres on VM 102.

| VM | IP | Role |
| --- | --- | --- |
| 100 | 192.168.4.50 | Jellyfin, media worker (HLS from engine), optional stream gateway |
| 101 | 192.168.4.51 | NFS: library ro, stream-cache rw, downloads rw (uid 1000) |
| 102 | 192.168.4.52 | Next.js (Watch + admin + API), SQLite on local disk, *arr stack, Seerr, Caddy |
| 103 | 192.168.4.53 | qBittorrent + libtorrent engine only |

SQLite file: `/app/data/app.sqlite` in the web container volume `app-data`. Not on NFS. Not opened by the engine or media worker.

Watch and admin are the same image with different env (admin holds PVE read token; Watch process must not receive mutation secrets).

Engine HTTP: `http://192.168.4.53:8741` from apps and from the media worker on `.50`.
