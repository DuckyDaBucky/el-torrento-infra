# Network and credential boundaries

## Addresses

LAN is `192.168.4.0/22`. Gateway `192.168.4.1`.

| Name | Address | Notes |
| --- | --- | --- |
| pve-5050 | 192.168.4.20 | Proxmox, holds VM 100 |
| pve3040a | 192.168.4.109 | Proxmox |
| pve-3040b | 192.168.4.33 | Proxmox |
| media-playback | 192.168.4.50 | VM 100, already assigned |
| media-storage | 192.168.4.51 | Proposed |
| media-apps | 192.168.4.52 | Proposed |
| media-ingest | 192.168.4.53 | Proposed |

An address that does not answer a probe is not automatically free. Stage 1 records who answered. It does not claim the silent ones.

## DNS

| Hostname | Who can open it | Path |
| --- | --- | --- |
| server.hasnain.us | Owner, Cloudflare Access or the app’s owner session | Admin UI on the apps VM. Not Proxmox `:8006` |
| watch.hasnain.us | Signed-in family | Player. Video bytes are not proxied through Cloudflare |
| media.hasnain.us | Signed-in family | Jellyfin UI. Same video-path rule |

Split DNS: inside the house these names resolve to the LAN addresses. Away from home, Watch and Jellyfin use Tailscale or direct HTTPS. Admin can use the Cloudflare tunnel because it is not the video path.

Proxmox `:8006` is not published.

## Who may talk to whom

- Apps VM may call Jellyfin and the stream gateway on the playback VM, and NFS on the storage VM.
- Playback VM may read the library and stream-cache exports. It does not get qBittorrent credentials.
- Ingest VM may write `downloads/` on the storage export and may talk to its indexers and trackers. It may not mount `library/` or `stream-cache/`, and it may not open Proxmox, Postgres, Clerk, or the management worker.
- Storage VM exports NFS to the three media VMs only, not to the whole LAN, once those addresses exist. Until the guests exist, no export is opened.
- Collectors read Proxmox with the read-only token. Mutations are not issued in stage 1.

## Secrets that must never be committed

Proxmox passwords and API tokens, Clerk keys, Jellyfin and Seerr API keys, Postgres passwords, qBittorrent passwords, indexer logins, Cloudflare API tokens, Tailscale auth keys.

`.env.example` lists names only.
