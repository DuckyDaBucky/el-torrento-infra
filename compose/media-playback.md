# media-playback Compose skeleton

Target: existing VM 100 on `pve-5050`, `192.168.4.50`. Stage 1 does not install Docker here and does not rebuild the VM.

Services later: Jellyfin, FFmpeg worker, stream gateway.

Mounts: library and stream-cache read-only from NFS. Transcode temp on the VM’s own disk. No ingest credentials. No qBittorrent port.

iGPU passthrough is not assumed. `docs/preflight.md` records whether the host even shows an Intel VGA device. Software transcode stays off until a benchmark on this VM says a given quality holds realtime.

The service file is `media-playback.compose.yml`. Image tags are the ones in that file. There is no digest placeholder.

Before starting it, run `../scripts/require-nfs-mount.sh /mnt/library`. If that check fails, do not start containers. The script does not start them.
