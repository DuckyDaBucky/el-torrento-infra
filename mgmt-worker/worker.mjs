import express from "express";

const app = express();
app.use(express.json());

const PORT = Number(process.env.PORT ?? 9090);
const PVE_HOSTS = (process.env.PVE_HOSTS ?? "192.168.4.20,192.168.4.109,192.168.4.33")
  .split(",")
  .map((item) => item.trim())
  .filter(Boolean);
const PVE_TOKEN = process.env.PVE_MUTATION_TOKEN ?? "";
const ALLOWED = new Map([
  ["media-storage", 101],
  ["media-apps", 102],
  ["media-ingest", 103],
]);

app.get("/health", (_req, res) => res.json({ ok: true }));

app.post("/actions", async (req, res) => {
  const guest = String(req.body?.guest ?? "");
  const action = String(req.body?.action ?? "");
  const idempotencyKey = String(req.body?.idempotencyKey ?? "");
  if (!ALLOWED.has(guest) || !["start", "shutdown"].includes(action)) {
    return res.status(403).json({ message: "Action is not allowlisted.", taskId: null });
  }
  if (!PVE_TOKEN) {
    return res.status(501).json({ message: "Proxmox mutation token is not configured.", taskId: null });
  }
  const vmid = ALLOWED.get(guest);
  const endpoint = action === "start" ? "status/start" : "status/shutdown";
  let lastError = "No Proxmox node answered.";
  for (const host of PVE_HOSTS) {
    const url = `https://${host}:8006/api2/json/nodes/${host.split(".")[0]}/qemu/${vmid}/${endpoint}`;
    try {
      const response = await fetch(url, {
        method: "POST",
        headers: { Authorization: `PVEAPIToken=${PVE_TOKEN}` },
        signal: AbortSignal.timeout(8000),
      });
      if (response.ok) {
        return res.json({ message: "Accepted.", taskId: idempotencyKey || `pve-${vmid}-${action}` });
      }
      lastError = `Proxmox HTTP ${response.status} on ${host}`;
    } catch (error) {
      lastError = error instanceof Error ? error.message : lastError;
    }
  }
  return res.status(502).json({ message: lastError, taskId: null });
});

app.listen(PORT, () => console.log(`mgmt-worker on ${PORT}`));
