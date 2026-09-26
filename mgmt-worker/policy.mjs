/** Allowlisted guest power. No shell, no Docker, no public Proxmox host. */

export const ACTIONS = new Set(["start", "shutdown"]);

export const GUESTS = {
  "media-storage": { vmid: 101, node: "pve-3040b" },
  "media-ingest": { vmid: 103, node: "pve-3040b" },
};

/** VM 100 (playback) and VM 102 (apps at 192.168.4.52) are never powered from here. */
export const DENIED_VMIDS = new Set([100, 102]);

export const DENIED_GUESTS = new Set(["media-playback", "media-apps", "100", "102", "192.168.4.52"]);

export const API_HOSTS = ["192.168.4.20", "192.168.4.109", "192.168.4.33"];

const POWER_OFF = new Set(["stop", "poweroff", "power-off", "reset", "reboot", "suspend", "delete"]);

const BLOCKED_FIELDS = ["command", "shell", "exec", "docker", "socket", "cmdline"];

export function allowedApiHosts(raw) {
  const requested = String(raw ?? API_HOSTS.join(","))
    .split(",")
    .map((item) => item.trim())
    .filter(Boolean);
  return requested.filter((host) => API_HOSTS.includes(host));
}

export function evaluateAction(body) {
  const guest = String(body?.guest ?? "");
  const action = String(body?.action ?? "");
  const vmidRaw = body?.vmid;
  const address = String(body?.address ?? body?.host ?? body?.ip ?? "");

  if (BLOCKED_FIELDS.some((field) => Object.prototype.hasOwnProperty.call(body ?? {}, field))) {
    return { ok: false, status: 403, message: "Shell and Docker endpoints are not available." };
  }
  if (address === "192.168.4.52" || address.endsWith(".52")) {
    return { ok: false, status: 403, message: "The apps VM .52 cannot be powered off." };
  }
  if (POWER_OFF.has(action)) {
    return {
      ok: false,
      status: 403,
      message: "Power off is not allowlisted. VM 100 and the apps VM .52 cannot be powered off.",
    };
  }
  if (!ACTIONS.has(action)) {
    return { ok: false, status: 403, message: "Only start and shutdown are allowlisted." };
  }
  if (DENIED_GUESTS.has(guest) || DENIED_VMIDS.has(Number(guest))) {
    return { ok: false, status: 403, message: "VM 100 and the apps VM .52 cannot be powered from this worker." };
  }
  const spec = GUESTS[guest];
  if (!spec) {
    return { ok: false, status: 403, message: "Guest is not allowlisted." };
  }
  if (vmidRaw != null && Number(vmidRaw) !== spec.vmid) {
    return { ok: false, status: 403, message: "VM id does not match the allowlisted guest." };
  }
  if (DENIED_VMIDS.has(spec.vmid)) {
    return { ok: false, status: 403, message: "VM 100 and the apps VM .52 cannot be powered from this worker." };
  }
  return {
    ok: true,
    status: 202,
    guest,
    vmid: spec.vmid,
    node: spec.node,
    endpoint: action === "start" ? "status/start" : "status/shutdown",
  };
}
