# Storage isolation verified (live cluster)

Summary of CLU checks run against the Proxmox media guests on 2026-09-26. Full narrative: [guests-live.md](./guests-live.md).

## NFS export matrix (storage VM 101)

| Export path | Client | Mode | Purpose |
| --- | --- | --- | --- |
| `/srv/media/library` | 192.168.4.50 (playback) | read-only | Stream source |
| `/srv/media/stream-cache` | 192.168.4.50 (playback) | read-write | Transcode cache |
| `/srv/media/downloads` | 192.168.4.53 (ingest) | read-write | Downloader inbox |

Not exported to apps (`.52`) or the whole LAN.

## Per-guest results

### media-ingest (103)

- Downloads mount succeeds; test write visible on storage.
- Library mount **failed** (expected): NFSv4 “No such file or directory”, NFSv3 “access denied”. Left unmounted.
- tcp/8006 to Proxmox nodes: reset (~4 ms).
- No reachability to apps (`.52`) or playback (`.50`).

### media-apps (102)

- No NFS mounts configured.
- Attempts to mount library or downloads from `.51` were denied.

### media-playback (100)

- Existing VM; not recreated in this pass. Intended mounts match [media-playback.mount.example](../systemd/media-playback.mount.example).

## Systemd examples

- Playback: [media-playback.mount.example](../systemd/media-playback.mount.example)
- Ingest: [media-ingest.mount.example](../systemd/media-ingest.mount.example)

Apply on guests after `nfs-common` is installed and firewall rules allow NFS only from listed clients.
