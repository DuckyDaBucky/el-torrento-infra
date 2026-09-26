# media-ingest Compose skeleton

Target: its own VM (proposed vmid 103, `192.168.4.53`). Never the apps VM.

Services: qBittorrent and the libtorrent progressive engine only.

Mounts: `downloads/` read-write on the storage export. No `library/` mount. No `stream-cache/` mount. No Docker socket. No privileged mode. No host network.

Incomplete files stay in `downloads/`. Promotion into `library/` is an import on the storage side, not a process inside this VM that can see the library tree.

```yaml
# not applied
services:
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent@sha256:PIN_BEFORE_USE
    # user: non-root uid matched to the NFS export
    volumes:
      - /mnt/downloads:/downloads
    # no network_mode: host
  libtorrent-engine:
    image: ghcr.io/hasnain-niazi/el-torrento-engine@sha256:PIN_BEFORE_USE
    volumes:
      - /mnt/downloads:/downloads:ro
```

The engine reads verified bytes from the download directory. It does not get a path that could see sparse holes as real media. The stream gateway on the playback VM is what clients talk to; this VM does not serve family HTTP.
