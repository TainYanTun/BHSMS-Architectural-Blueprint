# Optional Future Features & Security Upgrades

This document preserves technical designs for advanced features that are currently deferred to ensure a "Zero-Trust" and "Zero-Configuration" workflow for non-technical field staff.

---

## 1. Advanced Site Authorization (The Handshake)

**Status:** Deferred  
**Current Alternative:** Sites are keyed in by admins at HQ and users are linked to sites. The system relies on standard **User Login** for security.

### Proposed Upgrade: Permanent Site Tokens
To prevent unauthorized devices from connecting to the Central HQ Server even if a user's password is stolen.
1.  **Handshake:** HQ generates a secret **Access Token** for each site.
2.  **Configuration:** Token is entered once into the remote device.
3.  **Proof:** HQ only accepts sync packets that present a valid Site Token.

---

## 2. Hardware-Bound Security

**Status:** Deferred (Considered Overkill)  
**Risk:** High administrative overhead if hardware fails.

### Proposed Upgrade: Motherboard Binding
To ensure a Site Token cannot be copied from one laptop to another.
1.  **Locking:** During the initial handshake, the HQ server captures and stores the remote device's **Motherboard UUID** or **MAC Address**.
2.  **Verification:** Every sync checks both the Token AND the Hardware ID.
3.  **Impact:** Theft of the laptop results in an immediate block that cannot be bypassed by copying files to a new machine.

---

## 3. Real-Time Integration (API Push)

**Status:** Deferred  
**Current Alternative:** Periodic Sync (Delta-Sync) via `row_version`.

### Proposed Upgrade: Webhook Notifications
1.  **Trigger:** When a student status changes to "Dropped" or "Transferred," the central server immediately pushes a notification to a specific site or external service.
2.  **Use Case:** Instant updates for time-sensitive logistics.

---

## 4. Multi-Currency Support (Local Ledgering)

**Status:** Resolved (June 2026)  
**Current Setup:** BDT-only tracking. No dual-currency or exchange rate system needed — Bangla Hope receives funds pre-converted to BDT from the sponsor's US office.

### Proposed Upgrade: Real-Time BDT Tracking (No longer applicable)
1.  **~~Dual Ledger:~~** Not needed — all accounting is BDT-only.
2.  **~~Live Conversion:~~** Not needed — no exchange rate tracking required.
