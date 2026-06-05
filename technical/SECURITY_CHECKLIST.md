# Security Checklist

This document serves as a cross-check reference for security measures across the Bangla Hope SMS. Each item includes the current status and a reference to where it's implemented or where action is needed.

---

## 1. Authentication & Session Management

| # | Check | Status | Reference / Action |
|---|---|---|---|
| 1.1 | Passwords hashed with bcrypt | ✅ | Laravel default — `Hash::make()` uses bcrypt |
| 1.2 | Password complexity enforced (min length, mixed case) | ❌ Missing | Add validation rule to user creation: `min:8`, `mixedCase`, `letters`, `numbers` |
| 1.3 | Account lockout after failed attempts | ❌ Missing | Laravel has built-in throttle — enable `RateLimiter` on login route |
| 1.4 | Session timeout / auto-logout | ❌ Missing | Configure `session.lifetime` in Laravel config |
| 1.5 | Invitation token expires | ✅ | Schema: `invitations.expires_at` — tokens auto-pruned via scheduler |
| 1.6 | Sanctum token expiration | ⚠️ Partial | Default is eternal. Set token expiry in `config/sanctum.php` |

---

## 2. Authorization & Access Control

| # | Check | Status | Reference / Action |
|---|---|---|---|
| 2.1 | RBAC enforced at API layer | ⚠️ Partial | Matrix defined in `PERMISSIONS.md` — needs middleware implementation |
| 2.2 | Program-scoped access (Coordinator) | ✅ | `user_programs` table in schema — filter queries by assigned programs |
| 2.3 | Sponsor sees only own children | ⚠️ Partial | Logic documented — filter `sponsorships` by authenticated user's `sponsor_id` |
| 2.4 | Route protected by Sanctum middleware | ✅ | Laravel `auth:sanctum` middleware on all API routes |
| 2.5 | Sensitive fields redacted in Sponsor Portal | ❌ Missing | Define field allowlist per role (e.g., hide exact village, guardian contacts) |

---

## 3. Data in Transit

| # | Check | Status | Reference / Action |
|---|---|---|---|
| 3.1 | HTTPS enforced (Nginx) | ✅ | Nginx SSL config — Let's Encrypt auto-renewal |
| 3.2 | HSTS header set | ❌ Missing | Add `add_header Strict-Transport-Security` to Nginx config |
| 3.3 | CORS configured for Sponsor Portal | ⚠️ Partial | Laravel CORS config must whitelist the sponsor portal domain |
| 3.4 | Redirect HTTP → HTTPS | ✅ | Nginx server block redirect |

---

## 4. Data at Rest

| # | Check | Status | Reference / Action |
|---|---|---|---|
| 4.1 | Database encryption (pgcrypto) | ✅ | Extension enabled in schema — apply for sensitive columns (e.g., `password_hash` already hashed) |
| 4.2 | File storage encryption | ❌ Missing | If using S3 — enable server-side encryption. If local — encrypt sensitive uploads |
| 4.3 | Backups encrypted | ❌ Missing | `pg_dump` should pipe through `gpg` or write to encrypted volume |
| 4.4 | Database connection over TLS | ⚠️ Partial | Set `sslmode=require` in `config/database.php` if PostgreSQL allows it |

---

## 5. Input Validation & Output Encoding

| # | Check | Status | Reference / Action |
|---|---|---|---|
| 5.1 | Laravel FormRequest validation on all API endpoints | ⚠️ Partial | Standard Laravel practice — verify every store/update endpoint has a FormRequest |
| 5.2 | SQL injection prevention | ✅ | Eloquent ORM uses parameterized queries — no raw SQL |
| 5.3 | CSRF protection | ✅ | Laravel `VerifyCsrfToken` middleware on web routes / Sanctum on API |
| 5.4 | XSS protection (React) | ✅ | React JSX auto-escapes. Hardens any Blade views with `{{ }}` |
| 5.5 | File upload type validation | ❌ Missing | Validate MIME type on `documents` upload endpoint |
| 5.6 | File upload size limits | ❌ Missing | Set `upload_max_filesize` in PHP + Laravel validation |

---

## 6. Audit Logging & Tamper Evidence

| # | Check | Status | Reference / Action |
|---|---|---|---|
| 6.1 | All mutating actions logged to `audit_logs` | ⚠️ Partial | Schema exists — implement in Eloquent model events or middleware |
| 6.2 | `audit_logs` uses JSONB for mutation detail | ✅ | Schema: `mutation_detail JSONB` with GIN index |
| 6.3 | Audit logs partitioned by month | ✅ | Schema: `PARTITION BY RANGE (created_at)` — strategy in `plans/audit-log-partitioning.md` |
| 6.4 | Financial tables immutable (no UPDATE triggers) | ✅ | `contributions`, `allocation_payouts`, `loan_transactions` intentionally lack update triggers |
| 6.5 | Reversing entries used for corrections | ✅ | Design pattern — adjustments logged as new entries, not edits |
| 6.6 | Optimistic concurrency via `row_version` | ✅ | Every mutable table has `row_version` + auto-increment trigger |

---

## 7. Financial Security

| # | Check | Status | Reference / Action |
|---|---|---|---|
| 7.1 | Anti-overdraft trigger on reconciliations | ✅ | `fn_enforce_contribution_limits()` with `SELECT ... FOR UPDATE` |
| 7.2 | Reconciliation links contributions to payouts | ✅ | `reconciliations` table with FK to both |
| 7.3 | Financial approval workflow | ❌ Missing | No approval step defined for large subsidies or loan disbursements |
| 7.4 | Two-person rule for financial operations | ❌ Missing | No mechanism to require separate initiator and approver |

---

## 8. API Security

| # | Check | Status | Reference / Action |
|---|---|---|---|
| 8.1 | Rate limiting enabled | ⚠️ Partial | Nginx `limit_req` configured — add Laravel `throttle` middleware |
| 8.2 | Sanctum token auth on all API routes | ✅ | `auth:sanctum` middleware — verify no unprotected routes |
| 8.3 | No stack traces in production | ✅ | `APP_DEBUG=false` in production — Laravel returns generic 500 |
| 8.4 | Pagination limits on list endpoints | ❌ Missing | Enforce max per-page on all index routes (e.g., `max(100)`) |

---

## 9. Infrastructure Security

| # | Check | Status | Reference / Action |
|---|---|---|---|
| 9.1 | Server in locked / access-controlled room | ❌ Missing | Physical security — document the office server location policy |
| 9.2 | Firewall only exposes port 443 (and 22 for admin) | ❌ Missing | Configure `ufw` or `iptables` — deny all inbound except ports 443, 22 |
| 9.3 | SSH key-only authentication (no passwords) | ❌ Missing | Disable `PasswordAuthentication yes` in `/etc/ssh/sshd_config` |
| 9.4 | OS and package auto-updates | ❌ Missing | Configure `unattended-upgrades` on Ubuntu / cron for `yum update` |
| 9.5 | PostgreSQL access restricted to localhost | ❌ Missing | Set `listen_addresses = 'localhost'` in `postgresql.conf` |
| 9.6 | Regular backup schedule | ⚠️ Partial | `backups` table in schema — needs cron job to perform `pg_dump` |
| 9.7 | Backup stored off-site | ❌ Missing | Copy encrypted backups to S3 or external drive |

---

## 10. Data Privacy & Protection

| # | Check | Status | Reference / Action |
|---|---|---|---|
| 10.1 | Soft deletes on student, sponsor, user records | ✅ | `deleted_at` column with partial unique indexes |
| 10.2 | Student data redacted for public/browse views | ❌ Missing | Define redaction rules (hide exact village, guardian contacts) |
| 10.3 | Approver gate for sensitive documents | ✅ | APR requires Director approval before publishing |
| 10.4 | Access logged for sensitive data views | ❌ Missing | Consider adding read-event logging for financial or student records |
| 10.5 | Data retention / purge policy | ❌ Missing | Define how long audit logs, staging data, and archived records are kept |

---

## 11. ETL / Migration Security

| # | Check | Status | Reference / Action |
|---|---|---|---|
| 11.1 | Staging tables isolated from production | ✅ | `migration_staging_*` tables separate from core tables |
| 11.2 | Validation gatekeeper (human approval) | ✅ | Sandbox Preview UI — staged records need manual release |
| 11.3 | Validation errors captured for audit | ✅ | `validation_errors TEXT[]` in staging tables |
| 11.4 | Rollback capability for failed migrations | ❌ Missing | Migration batch metadata — allow reverting a batch |

---

## 12. Monitoring & Incident Response

| # | Check | Status | Reference / Action |
|---|---|---|---|
| 12.1 | Error logging to files or external service | ⚠️ Partial | Laravel writes to `storage/logs/` — should monitor disk space |
| 12.2 | Failed login attempt alerts | ❌ Missing | No mechanism to notify admin of brute-force attempts |
| 12.3 | Backup failure alerts | ❌ Missing | Cron job should email on `pg_dump` failure |
| 12.4 | Disk space monitoring | ❌ Missing | Essential for on-premise — set up `df` alert cron |
| 12.5 | Incident response plan | ❌ Missing | Document basic steps for data breach, server failure, lost backups |

---

## Status Legend

| Icon | Meaning |
|---|---|
| ✅ | Implemented — verified in schema or config |
| ⚠️ Partial | Partially implemented or needs verification |
| ❌ Missing | Not implemented — action required |
| N/A | Not applicable to this system |

---

*Last Updated: 2026-06-04 | Part of the Bangla Hope SMS Technical Blueprint*
