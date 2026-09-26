# Live preflight

Read-only SSH from the Mac on the LAN, 2026-09-26. No guests were created or changed. VM 100 was not rebuilt. No firewall, DNS, or cluster changes.

## Quorum

Cluster `homelab` is quorate: 3 votes, quorum 2. All three nodes are members. Each reports PVE 9.2.20, kernel 7.0.14-19-pve. Clocks are synced, timezone America/Chicago.

| Node | Address | FQDN |
| --- | --- | --- |
| pve-5050 | 192.168.4.20 | pve-5050.homelab.local |
| pve3040a | 192.168.4.109 | pve3040a.homelab.local |
| pve-3040b | 192.168.4.33 | pve-3040b.homelab.local |

PC-speaker modules `pcspkr` and `snd_pcsp` were not loaded on any node.

## Capacity

| Node | RAM available | Root `/` | Thin pool | data% / meta% | Disk |
| --- | --- | --- | --- | --- | --- |
| pve-5050 | 5.0 GiB of 7.6 GiB | 59G free of 68G | 141.49 GiB, about 1.6 GiB used | 1.14 / 1.16 | 256G Hynix SSD |
| pve3040a | 13 GiB of 15 GiB | 32G free of 39G | 53.93 GiB, empty | 0.00 / 1.59 | 128G SanDisk SSD |
| pve-3040b | 13 GiB of 15 GiB | 84G free of 94G | 337.86 GiB, empty | 0.00 / 0.50 | 500G Samsung 850 EVO |

No second disk and no spinning disk on any node. Root filesystems are not the media library.

## Guests and addresses

Only one guest exists: VM **100** `media-docker` on `pve-5050`, status running. No other VMs. No containers.

Proposed vmids **101**, **102**, and **103** are not in use. No vmid conflict with the proposal.

| Address | tcp/22 | tcp/8006 |
| --- | --- | --- |
| 192.168.4.50 | answered | no answer |
| 192.168.4.51 | no answer in 2s | no answer in 2s |
| 192.168.4.52 | no answer in 2s | no answer in 2s |
| 192.168.4.53 | no answer in 2s | no answer in 2s |

`.50` is VM 100. Silence on `.51`–`.53` does **not** prove those addresses are unused. Something without SSH or Proxmox could still hold them. That remains unresolved until a DHCP reservation check on the router.

## VM 100 (preserved)

- Name: `media-docker` (the playback role is the plan; the name was not changed)
- Node: `pve-5050`
- 4 cores, 4096 MB RAM
- NIC on `vmbr0`, cloud-init `ipconfig0` `192.168.4.50/22` gateway `192.168.4.1`
- 32G disk `scsi0` on `local-lvm`
- Guest agent enabled
- No `hostpci` device in the config that was read, so the iGPU is not passed through

## iGPU

Present on the hosts, not attached to VM 100:

- pve-5050: Intel HD Graphics 630 `[8086:5912]`
- pve3040a and pve-3040b: Intel HD Graphics 530 `[8086:1912]`

Hardware transcode is not available inside VM 100 until a later, reviewed passthrough change. Software transcode stays gated.

## What the numbers allow

- Storage VM on `pve-3040b`: not blocked. Empty 338 GiB pool can take a ~220 GiB data disk and still leave room.
- Apps VM on `pve3040a`: not blocked for a single modest guest.
- Ingest on the apps VM: not allowed, regardless of space.
- Ingest as its own VM on `pve3040a` beside apps: disks can fit (the pool is 54 GiB), RAM is tight if both guests are several gigabytes.
- Ingest as its own VM on `pve-3040b` beside storage: after a ~220 GiB storage data disk, the thin pool still has on the order of ~118 GiB for a small ingest OS disk. RAM on 3040b is the same constraint as for storage. Keeping apps on 3040a preserves RAM there for the management worker.

Proposed for review, not created: VM 101 storage and VM 103 ingest on `pve-3040b`, VM 102 apps on `pve3040a`, VM 100 left as the playback guest.

`pve-5050` has about 5 GiB RAM free while VM 100 is using 4 GiB. Do not add another guest there.

## Remote-access prerequisites

Observed from the Mac (`en0` `192.168.4.39`):

- IPv4 egress via `https://ifconfig.me`: `47.162.201.222` (this is the source address of an outbound request, not a test that inbound 443 works)
- `tailscale` not on PATH
- `cloudflared` not on PATH
- `CLOUDFLARE_API_TOKEN` not set in that environment

Not done, on purpose: no DNS edits, no tunnel, no Tailscale install, no port forward.

## Blockers before any infrastructure change

1. Review this placement. Ingest stays a separate VM; the suggested node is `pve-3040b`.
2. Confirm `.51`, `.52`, and `.53` are free in the router, not only silent on SSH.
3. Remote admin and remote video are not set up. Need a Cloudflare token or an interactive tunnel login for `server.hasnain.us`, and Tailscale or another non-proxied path for `watch.hasnain.us` and `media.hasnain.us`.
4. VM 100 has 4 GiB RAM, a 32 GiB disk, and no iGPU. Playback and transcode sizing is a later change, not a rebuild in this stage.
5. Two remotes were not created. GitHub CLI is not logged in, and the Origin token cannot create repositories (it can only push this existing project repo). Both trees are committed here as `el-torrento/` and `el-torrento-infra/` until a token that can create repos is available.
6. Clerk, Jellyfin, and indexer credentials do not exist yet. They are not created in this stage.
