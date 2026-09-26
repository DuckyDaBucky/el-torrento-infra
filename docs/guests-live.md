# Live media guests (2026-09-26)

Created by [Isolated media guests](bc-906873d5-abc7-5f57-9540-541d0a6d358b). VM **100** was not edited, rebooted, or recreated.

## Running guests

| VMID | Name | Node | IP | Role |
| --- | --- | --- | --- | --- |
| 100 | media-docker | pve-5050 | 192.168.4.50 | Playback (existing) |
| 101 | media-storage | pve-3040b | 192.168.4.51 | NFS `/srv/media` |
| 102 | media-apps | pve3040a | 192.168.4.52 | Apps (empty; no stack yet) |
| 103 | media-ingest | pve-3040b | 192.168.4.53 | Downloader only (no qBit yet) |

SSH on `.51`, `.52`, and `.53` answers from the LAN. Use your deploy key on the Mac (`~/.ssh/el-torrento-deploy`), not the Proxmox password in git.

## NFS exports (101)

On one filesystem under `/srv/media`: `downloads/`, `library/`, `stream-cache/`.

| Export | Client | Access |
| --- | --- | --- |
| `/srv/media/library` | 192.168.4.50 | read-only |
| `/srv/media/stream-cache` | 192.168.4.50 | read-write |
| `/srv/media/downloads` | 192.168.4.53 | read-write |

Not exported to `.52` or the whole LAN.

## Isolation checks (103)

- Downloads mount works; write test file visible on storage.
- Library mount **failed** (expected): NFSv4 “No such file or directory”, NFSv3 “access denied”. Not left mounted.
- tcp/8006 to Proxmox nodes from ingest: reset (~4 ms).
- No reachability to apps (`.52`) or playback (`.50`) from ingest.

## Apps VM (102)

No NFS mounts. Attempts to mount library or downloads from `.51` were denied.

## Next (not done here)

- Mount NFS on **192.168.4.50** (VM 100) for playback.
- Docker Compose on **192.168.4.52** and ingest stack on **192.168.4.53** per [el-torrento-infra/compose/](../el-torrento-infra/compose/).
- Stage 1 read-only numbers remain in [preflight](../el-torrento-infra/docs/preflight.md) for capacity baseline.
