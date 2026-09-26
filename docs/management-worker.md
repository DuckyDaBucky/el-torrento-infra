# Management and deployment worker

Proposed boundaries only. Stage 1 does not create the token, the container, the firewall rule, or any Proxmox role.

## Placement

- A separate container on the future media-apps VM (`192.168.4.52`), Docker network `mgmt`, no published host port.
- Not on a Proxmox host.
- Not inside media-ingest.
- Not in the public dashboard container.
- Not reachable from `watch.hasnain.us` or `media.hasnain.us`.

If the apps VM does not exist yet, the worker is not started on another guest to “make admin work.” Ingest is never an acceptable host for it.

## Network

The dashboard API on the apps VM is the only client. It calls the worker by the internal DNS name `mgmt-worker`.

No Cloudflare tunnel route, no LAN port publish, and no Tailscale advertisement of this service.

Outbound from the worker is limited to:

- Proxmox API `:8006` on `192.168.4.20`, `192.168.4.109`, and `192.168.4.33`, with the mutation token.
- The deployment agent on the same apps VM.
- A scoped Docker API proxy for approved guests. Not the Proxmox host’s Docker socket. The cluster nodes do not run the media stack on the host.

The worker does not mount NFS, does not open torrent ports, and does not connect to ingest.

## Credentials

Three secrets, not one:

| Secret | Who holds it | What it can do |
| --- | --- | --- |
| Read-only Proxmox token | Dashboard collector on the apps VM | Read node, guest, and storage status |
| Mutation token | Management worker only | Allowlisted guest start and graceful shutdown. No VM create/delete, no storage allocate, no host power, no shell |
| Deploy secret | Deployment agent only | Apply a reviewed template on an approved guest. Cannot call the Proxmox mutation API |

The dashboard backend sends an operation id and parameters. It never receives the Proxmox mutation secret or the deploy secret. The browser never sees either. Git never sees either. Cloudflare does not store them.

Token files on the apps VM are mode `0600`, owned by the worker user. Rotation means create a new token in Proxmox, replace the file, restart only that worker.

Audit each call: owner, action, target, time, result, upstream task id. The worker rejects anything outside the allowlist even if the dashboard asks.

## What “before administrative controls” means

User Management, Media Management, and Services buttons stay read-only until this placement is accepted and the tokens exist. Stage 1 stops at this document.
