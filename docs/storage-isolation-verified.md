# Storage isolation — verified on cluster

Summary of CLU checks on the Proxmox media guests (2026-09-26). Narrative: [guests-live.md](./guests-live.md) and [../../docs/guests-live.md](../../docs/guests-live.md).

## NFS export matrix (storage VM 101)

| Export path | Client | Mode | Purpose |
| --- | --- | --- | --- |
| `/srv/media/library` | 192.168.4.50 (playback) | read-only | Stream source |
| `/srv/media/stream-cache` | 192.168.4.50 (playback) | read-write | Transcode cache |
| `/srv/media/downloads` | 192.168.4.53 (ingest) | read-write | Downloader inbox |

Not exported to apps (`.52`) or the whole LAN.

| Check | Result |
| --- | --- |
| VM 101 storage on 3040b | Running, `.51` |
| VM 102 apps on 3040a | Running, `.52`, no NFS media mounts |
| VM 103 ingest on 3040b | Running, `.53`, separate from apps |
| VM 100 playback | Unchanged, `.50` |
| Ingest library mount | Denied (expected) |
| Ingest → Proxmox :8006 | Blocked |
| Ingest → apps `.52` | Blocked |
| Playback `.50` library + stream-cache NFS | Mounted (ro / rw) per guests-live |
| Apps `.52` Docker | Running; Compose not applied |

## Systemd mount examples

- Playback: [media-playback.mount.example](../systemd/media-playback.mount.example)
- Ingest: [media-ingest.mount.example](../systemd/media-ingest.mount.example)

Apply on guests after `nfs-common` is installed and firewall rules allow NFS only from listed clients.
