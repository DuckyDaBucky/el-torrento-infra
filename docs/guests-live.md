# Live media guests (2026-09-26)

Created by [Isolated media guests](bc-906873d5-abc7-5f57-9540-541d0a6d358b). VM **100** was not edited, rebooted, or recreated.

## Running guests

| VMID | Name | Node | IP | Role |
| --- | --- | --- | --- | --- |
| 100 | media-docker | pve-5050 | 192.168.4.50 | Playback — NFS library ro + stream-cache rw ([NFS mounts and Compose prep](bc-32f35821-4eb2-5d85-ade8-28924f5f3dc4)) |
| 101 | media-storage | pve-3040b | 192.168.4.51 | NFS `/srv/media` |
| 102 | media-apps | pve3040a | 192.168.4.52 | Docker 20.10 + compose 1.29; app stack not deployed |
| 103 | media-ingest | pve-3040b | 192.168.4.53 | Downloads NFS up; qBit not installed |

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

## Playback VM (100)

Configured by [NFS mounts and Compose prep](bc-32f35821-4eb2-5d85-ade8-28924f5f3dc4). `qm config 100` was not changed.

- `/mnt/library` ← `192.168.4.51:/srv/media/library` (NFSv4.2, **ro**, `_netdev,noauto,x-systemd.automount`)
- `/mnt/stream-cache` ← `192.168.4.51:/srv/media/stream-cache` (NFSv4.2, **rw**, same automount options)
- Read and stream-cache write verified on the guest.
- SSH: `debian@192.168.4.50` with `~/.ssh/el-torrento-deploy`.

## Apps VM (102)

No NFS mounts (exports deny `.52`). Docker **20.10.24** is running; `hello-world` succeeded. **docker-compose 1.29.2** is installed (Compose v2 plugin not in default apt). Use `sudo docker` until `debian` is in the `docker` group.

## Ingest VM (103)

`/mnt/downloads` remains mounted (NFSv4.2 rw). With **root_squash**, unprivileged writes fail; `sudo touch` on the mount works. Plan qBittorrent UID/`nogroup` alignment before running the engine unprivileged.

## Next

- Deploy Compose on **`.52`** and **`.53`** from [el-torrento-infra/compose/](../el-torrento-infra/compose/).
- Optional: Compose v2 plugin on `.52`; Docker group for `debian`.
- Jellyfin / stream gateway on **`.50`** (still no playback stack containers).
