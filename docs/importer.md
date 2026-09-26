# Importer

The importer runs only on media-storage, `192.168.4.51`. It does not run on the ingest VM, the playback VM, or the apps VM.

## Hardlink

`downloads/` and `library/` are directories on the same filesystem (`/srv/media` on `.51`). Promotion is a hardlink, not a copy and not a symlink.

After the link, record the inode of the download path and the inode of the library path. They must be equal. If they differ, the import failed. Leave the download in place and do not treat the library path as the title.

The ingest VM cannot mount the library. It only has the downloads export. It cannot see or write `library/`.

## Stream cache

The stream cache cap is 80 GiB. Do not grow it past that.

Pause new transfers when free space is below 30 GiB or below 15 percent of the filesystem, whichever is stricter. The pause line is the larger of those two floors:

`free < max(30 GiB, 15% of filesystem size)`

Examples: on a 400 GiB filesystem, 15 percent is 60 GiB, so pause below 60 GiB. On a 100 GiB filesystem, 15 percent is 15 GiB, so the 30 GiB floor is stricter and new transfers pause below 30 GiB.

## Library titles

Do not auto-delete library titles to free space. Pausing new transfers is the response. Reclaiming files under `stream-cache/` is not a license to remove a title from `library/`.
