# Storage isolation — verified on cluster

See also [guests-live.md](../../docs/guests-live.md) in the Project repo.

| Check | Result |
| --- | --- |
| VM 101 storage on 3040b | Running, `.51` |
| VM 102 apps on 3040a | Running, `.52`, no NFS media mounts |
| VM 103 ingest on 3040b | Running, `.53`, separate from apps |
| VM 100 playback | Unchanged, `.50` |
| Library export to `.50` | ro |
| Stream-cache to `.50` | rw |
| Downloads to `.53` only | rw |
| Ingest library mount | Denied (expected) |
| Ingest → Proxmox :8006 | Blocked |
| Ingest → apps `.52` | Blocked |

Systemd mount examples: `../systemd/*.mount.example`.
