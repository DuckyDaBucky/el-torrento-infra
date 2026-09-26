# Compose skeletons

These files are not applied in stage 1. They name images and mounts so later reviews can see the split.

Rules baked in:

- Ingest is a different Compose project on a different VM from apps.
- No `latest` tags. Digests are filled when images are pinned, before any pull.
- No Docker socket mount on the dashboard.
- Ingest has no Proxmox token and no library mount.
- The app database is SQLite on the apps VM disk (`app-data`), not Postgres and not NFS.

See `media-apps.md`, `media-ingest.md`, and `media-playback.md`.
