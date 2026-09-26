# Placement

Cluster name: `homelab`. A cluster does not merge RAM or CPU. Each guest runs on one node. Disks are not pooled with Ceph; `pve-5050` has 8 GB RAM, which is not enough for Ceph.

## Guests

- **media-playback** — existing VM 100 on `pve-5050`, `192.168.4.50`. Jellyfin, the FFmpeg worker, and the stream gateway. Do not rebuild it in stage 1.
- **media-storage** — proposed VM 101 on `pve-3040b`, `192.168.4.51`. NFSv4 export of `/srv/media` with `downloads/`, `library/`, and `stream-cache/` on one filesystem so imports can hardlink. The data disk comes from that node’s thin pool, not from the Proxmox root disk. About 220 GiB for data, leaving headroom on the ~338 GiB pool.
- **media-apps** — proposed VM 102 on `pve3040a`, `192.168.4.52`. Watch UI, admin API, PostgreSQL, Seerr, Sonarr, Radarr, Prowlarr, Caddy. Postgres and app config stay on this VM’s disk, not on NFS.
- **media-ingest** — proposed VM 103 on `pve-3040b`, `192.168.4.53`. qBittorrent and the libtorrent engine only. Own VM. Not the apps VM.

## Ingest isolation (mandatory)

Ingest must be its own VM. It must not share the application VM. The old exception that allowed combining them is removed.

`pve3040a`’s thin pool is about 54 GiB and empty, so two small guest disks would fit. RAM is the limit: the host has about 13 GiB free. An apps guest at 6 GiB plus an ingest guest at 4 GiB leaves little for Proxmox. `pve-3040b` has the same RAM and a 338 GiB pool, which still has room after a ~220 GiB storage disk plus a small ingest OS disk.

Proposal for review, not applied: VM 102 apps on `pve3040a`, VM 103 ingest on `pve-3040b`. If that is rejected, the alternative is two VMs on `pve3040a` with smaller RAM, never one combined VM. If neither separate guest fits, stop.

Ingest containers are non-root, with explicit writable directories. No privileged mode, no host root, no Docker socket, no management credentials. Ingest cannot mount the library export and cannot reach Proxmox, the management worker, databases, or unrelated LAN hosts.

Playback mounts the library read-only. A missing NFS mount must not make downloads land on a VM root disk.

## Remote video

`server.hasnain.us` is the admin UI and can sit behind Cloudflare Access. Video for `watch.hasnain.us` and `media.hasnain.us` is not sent through Cloudflare’s normal proxy. Use split DNS on the LAN, and Tailscale or direct HTTPS when away from home. Tailscale does not increase the home upload speed. If upload is small, cap remote bitrate and concurrent remote streams.
