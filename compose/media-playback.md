# media-playback Compose skeleton

Target: existing VM 100 on `pve-5050`, `192.168.4.50`. Stage 1 does not install Docker here and does not rebuild the VM.

Services later: Jellyfin, FFmpeg worker, stream gateway.

Mounts: library and stream-cache read-only from NFS. Transcode temp on the VM’s own disk. No ingest credentials. No qBittorrent port.

iGPU passthrough is not assumed. `docs/preflight.md` records whether the host even shows an Intel VGA device. Software transcode stays off until a benchmark on this VM says a given quality holds realtime.

```yaml
# not applied
services:
  jellyfin:
    image: jellyfin/jellyfin@sha256:PIN_BEFORE_USE
    volumes:
      - /mnt/library:/media:ro
      - jellyfin-config:/config
  stream-gateway:
    image: ghcr.io/hasnain-niazi/el-torrento-gateway@sha256:PIN_BEFORE_USE
    volumes:
      - /mnt/library:/data/library:ro
      - /mnt/stream-cache:/data/stream-cache:ro
volumes:
  jellyfin-config: {}
```
