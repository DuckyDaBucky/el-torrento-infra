# Compose skeletons

These files are not applied in stage 1. They name images and mounts so later reviews can see the split.

Rules baked in:

- Ingest is a different Compose project on a different VM from apps.
- No `latest` tags. Digests are filled when images are pinned, before any pull.
- No Docker socket mount on the dashboard.
- Ingest has no Proxmox token and no library mount.
- Postgres data is a volume on the apps VM, not an NFS path.

See `media-apps.md`, `media-ingest.md`, and `media-playback.md`.
