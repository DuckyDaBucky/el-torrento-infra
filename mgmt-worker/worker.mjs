import express from "express";
import { allowedApiHosts, evaluateAction } from "./policy.mjs";

const app = express();
app.use(express.json({ limit: "16kb" }));

const PORT = Number(process.env.PORT ?? 9090);
const PVE_TOKEN = process.env.PVE_MUTATION_TOKEN ?? "";

app.use((req, res, next) => {
  const pathName = req.path.toLowerCase();
  if (pathName === "/health" || pathName === "/actions") {
    next();
    return;
  }
  res.status(404).json({ message: "No such endpoint.", taskId: null });
});

app.get("/health", (_req, res) => res.json({ ok: true }));

app.post("/actions", async (req, res) => {
  const decision = evaluateAction(req.body ?? {});
  if (!decision.ok) {
    return res.status(decision.status).json({ message: decision.message, taskId: null });
  }
  if (!PVE_TOKEN) {
    return res.status(501).json({ message: "Proxmox mutation token is not configured.", taskId: null });
  }
  const hosts = allowedApiHosts(process.env.PVE_HOSTS);
  if (hosts.length === 0) {
    return res.status(501).json({ message: "No allowlisted Proxmox API host.", taskId: null });
  }
  const idempotencyKey = String(req.body?.idempotencyKey ?? "");
  let lastError = "No Proxmox node answered.";
  for (const host of hosts) {
    const url = `https://${host}:8006/api2/json/nodes/${decision.node}/qemu/${decision.vmid}/${decision.endpoint}`;
    try {
      const response = await fetch(url, {
        method: "POST",
        headers: { Authorization: `PVEAPIToken=${PVE_TOKEN}` },
        signal: AbortSignal.timeout(8000),
      });
      if (response.ok) {
        return res.json({ message: "Accepted.", taskId: idempotencyKey || `pve-${decision.vmid}-${decision.endpoint}` });
      }
      lastError = `Proxmox HTTP ${response.status}`;
    } catch (error) {
      lastError = error instanceof Error ? error.message : lastError;
    }
  }
  return res.status(502).json({ message: lastError, taskId: null });
});

app.listen(PORT, () => console.log(`mgmt-worker listening on ${PORT}`));
