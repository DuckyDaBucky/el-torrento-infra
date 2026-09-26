# Caddy skeleton

Not installed in stage 1. Intended for the apps VM.

```caddyfile
# LAN split-horizon names point here directly.
# Away from home, watch and media use Tailscale or a direct HTTPS listener.
# They are not orange-cloud proxied. server.hasnain.us may use a Cloudflare tunnel
# to this same Caddy, because it is HTML and API, not video.

server.hasnain.us {
	reverse_proxy api:3001
}

watch.hasnain.us {
	reverse_proxy watch:3000
}

media.hasnain.us {
	reverse_proxy 192.168.4.50:8096
}
```

`media.hasnain.us` to Jellyfin is the native UI. Video range requests still terminate on the playback VM or on this proxy only if the proxy is on the LAN or Tailscale. Do not put that hostname through Cloudflare’s standard proxy.

Cloudflare Access, if used, is only in front of `server.hasnain.us`. It does not replace Clerk inside the app. Both can be on: Access at the edge for the admin hostname, Clerk for the user record.
