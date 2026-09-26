# El Torrento infra

Guest layout, Compose skeletons, Caddy, NFS, and firewall notes for the homelab cluster `homelab`.

Nothing in this repo is applied by committing it. Stage 1 is documentation plus a read-only preflight. VM 100 stays as it is.

Application code lives in `el-torrento`.

## Proposed guests

| Guest | vmid | Node | Address | Role |
| --- | --- | --- | --- | --- |
| media-playback (live name `media-docker`) | 100 (existing, kept) | pve-5050 | 192.168.4.50 | Jellyfin, FFmpeg worker, stream gateway |
| media-storage | 101 | pve-3040b | 192.168.4.51 | NFSv4 `/srv/media` |
| media-apps | 102 | pve3040a | 192.168.4.52 | Watch, admin API, Postgres, Seerr, Sonarr, Radarr, Prowlarr, Caddy |
| media-ingest | 103 | pve-3040b (proposed) | 192.168.4.53 | qBittorrent and libtorrent only |

Ingest isolation is mandatory. Ingest never shares the application VM. There is no fallback that puts qBittorrent on the apps guest.

Preflight (see `docs/preflight.md`) shows `pve3040a` can technically hold two small disks, but RAM is the tight resource. The proposal for review is: apps stay on `pve3040a`, and ingest is its own VM on `pve-3040b` next to storage. That is still two VMs. It is not a shared application VM.

Vmids 101–103 are unused. `.51`–`.53` did not answer SSH, which does not prove the addresses are free. See `docs/preflight.md`.
