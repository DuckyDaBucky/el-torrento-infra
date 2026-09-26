# Caddy skeleton

Not installed in stage 1. Intended for the apps VM.

```caddyfile
# server.hasnain.us is the admin and API process. Admin may use Cloudflare Access.
# watch.hasnain.us and media.hasnain.us are video.
# Video must not use the free Cloudflare tunnel.

server.hasnain.us {
	reverse_proxy api:3847
}

watch.hasnain.us {
	reverse_proxy watch:3847
}

media.hasnain.us {
	reverse_proxy 192.168.4.50:8096
}
```

`media.hasnain.us` to Jellyfin is the native UI. Video range requests still terminate on the playback VM or on this proxy only if the proxy is on the LAN or Tailscale. Do not put that hostname through Cloudflare’s standard proxy.

Cloudflare Access, if used, is only in front of `server.hasnain.us`. It does not replace Clerk inside the app. Both can be on: Access at the edge for the admin hostname, Clerk for the user record.
