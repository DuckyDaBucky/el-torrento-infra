# media-ingest Compose skeleton

Target: its own VM (proposed vmid 103, `192.168.4.53`). Never the apps VM.

Services: qBittorrent and the libtorrent progressive engine only.

Mounts: `downloads/` read-write on the storage export. No `library/` mount. No `stream-cache/` mount. No Docker socket. No privileged mode. No host network.

Incomplete files stay in `downloads/`. Promotion into `library/` is an import on the storage side, not a process inside this VM that can see the library tree.

The service file is `media-ingest.compose.yml`. Image tags are the ones in that file. There is no digest placeholder.

Writers use `/mnt/downloads`. Before any `docker-compose up`, run `../scripts/require-nfs-mount.sh /mnt/downloads`. If that command exits non-zero, do not start containers. The script does not start them. A missing mount must not turn into an empty directory on the VM disk.

The engine reads verified bytes from the download directory. It does not get a path that could see sparse holes as real media. The stream gateway on the playback VM is what clients talk to; this VM does not serve family HTTP.
