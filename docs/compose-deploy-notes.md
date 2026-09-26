# Compose deploy notes (apps VM 102)

From [NFS mounts and Compose prep](bc-32f35821-4eb2-5d85-ade8-28924f5f3dc4).

- Docker **20.10.24+dfsg1** is installed and active on `192.168.4.52`.
- **docker-compose 1.29.2** is available (`docker-compose` command). The v2 plugin is not in default Debian apt on this guest yet.
- Run containers with **`sudo docker`** until user `debian` is added to group `docker`.
- Pin image digests in `compose/*.compose.yml` before `docker-compose up`.
- Postgres and app data stay on the VM disk, not NFS.

Ingest VM **103**: downloads mount uses root_squash; match container `PUID`/`PGID` to the export (`nobody`/`nogroup` on storage) or use a documented root-only qBit template until UIDs are aligned.
