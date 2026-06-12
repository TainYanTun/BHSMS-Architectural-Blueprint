# Security Cross-Reference Checklist

This document lists security considerations for the Bangla Hope SMS. Use it during development to verify each area is addressed — cross-reference against the schema, architecture, and config files listed in each item.

---

## 1. Authentication & Session Management

| # | Check | Blueprint Reference |
|---|---|---|
| 1.1 | Password hashing (bcrypt) | Laravel default — `Hash::make()` |
| 1.2 | Password complexity rules | Add validation: `min:8`, `mixedCase`, `letters`, `numbers` |
| 1.3 | Account lockout on failed attempts | Laravel `RateLimiter` on login route |
| 1.4 | Session timeout / auto-logout | `config/session.php` — `lifetime` setting |
| 1.5 | Invitation token expiry | `schema.sql` → `invitations.expires_at` |
| 1.6 | Sanctum token expiration | `config/sanctum.php` — set `expiration` |

---

## 2. Authorization & Access Control

| # | Check | Blueprint Reference |
|---|---|---|
| 2.1 | RBAC middleware at API layer | `PERMISSIONS.md` — full matrix. Implement as Laravel middleware |
| 2.2 | Program-scoped Coordinator access | `schema.sql` → `user_programs` table. Filter queries by assigned programs |
| 2.3 | Sponsor sees only own children | Filter `sponsorships` by authenticated user's `sponsor_id` |
| 2.4 | API routes protected by Sanctum | Laravel `auth:sanctum` middleware on all API routes |
| 2.5 | Sensitive field redaction (Sponsor Portal) | Define field allowlist per role — hide exact village, guardian contacts |

---

## 3. Data in Transit

| # | Check | Blueprint Reference |
|---|---|---|
| 3.1 | HTTPS enforcement | `Architecture.mmd` → Nginx SSL config. Let's Encrypt auto-renewal |
| 3.2 | HSTS header | Add `add_header Strict-Transport-Security` to Nginx config |
| 3.3 | CORS configuration | `config/cors.php` — whitelist Sponsor Portal domain |
| 3.4 | HTTP → HTTPS redirect | Nginx server block redirect |

---

## 4. Data at Rest

| # | Check | Blueprint Reference |
|---|---|---|
| 4.1 | Sensitive column encryption | `schema.sql` → `pgcrypto` extension loaded. Apply to sensitive columns |
| 4.2 | File storage encryption | MinIO server-side encryption or local filesystem encryption |
| 4.3 | Encrypted backups | Pipe `pg_dump` through `gpg` or write to encrypted volume |
| 4.4 | PostgreSQL connection over TLS | `config/database.php` → `sslmode=require` |

---

## 5. Input Validation & Output Encoding

| # | Check | Blueprint Reference |
|---|---|---|
| 5.1 | FormRequest validation on all store/update endpoints | Laravel standard — verify each endpoint |
| 5.2 | SQL injection prevention | Eloquent ORM (parameterized queries) — avoid raw SQL |
| 5.3 | CSRF protection | Laravel `VerifyCsrfToken` middleware (web) / Sanctum (API) |
| 5.4 | XSS prevention | React JSX auto-escapes. Blade views must use `{{ }}` not `{!! !!}` |
| 5.5 | File upload MIME validation | Validate on `documents` upload endpoint |
| 5.6 | File upload size limits | `upload_max_filesize` (PHP) + Laravel `max:` validation |

---

## 6. Audit Logging & Tamper Evidence

| # | Check | Blueprint Reference |
|---|---|---|
| 6.1 | All mutating actions logged to `audit_logs` | `schema.sql` → `audit_logs` table. Implement via Eloquent events |
| 6.2 | JSONB mutation details with GIN index | `schema.sql` → `mutation_detail JSONB` + `idx_audit_details` |
| 6.3 | Audit logs partitioned by month | `schema.sql` → `PARTITION BY RANGE (created_at)`. Strategy in `plans/audit-log-partitioning.md` |
| 6.4 | Financial tables are immutable | `schema.sql` → `contributions`, `payouts`, `loan_transactions` have no update triggers. Reference table `payment_categories` follows mutable pattern. |
| 6.5 | Corrections use reversing entries | Design pattern — adjustments logged as new entries, not edits |
| 6.6 | Optimistic concurrency via `row_version` | `schema.sql` → `fn_update_timestamp()` trigger on all mutable tables |

---

## 7. Financial Security

| # | Check | Blueprint Reference |
|---|---|---|
| 7.1 | Anti-overdraft on allocations | `schema.sql` → `fn_enforce_allocation_limits()` with `SELECT ... FOR UPDATE` |
| 7.2 | Anti-overdraft on payouts | `schema.sql` → `fn_enforce_payout_limits()` with `SELECT ... FOR UPDATE` |
| 7.3 | Financial approval workflow | Not designed — define who approves large subsidies / loan disbursements |
| 7.4 | Two-person rule for financial operations | Not designed — separate initiator and approver roles |

---

## 8. API Security

| # | Check | Blueprint Reference |
|---|---|---|
| 8.1 | Rate limiting | Nginx `limit_req` + Laravel `throttle` middleware |
| 8.2 | Sanctum auth on all API routes | Laravel `auth:sanctum` — verify no unprotected routes |
| 8.3 | No stack traces in production | `APP_DEBUG=false` in `.env` |
| 8.4 | Pagination limits on list endpoints | Enforce max per-page on all index routes |

---

## 9. Infrastructure Security

| # | Check | Blueprint Reference |
|---|---|---|
| 9.1 | Physical server in locked room | Office policy — document location |
| 9.2 | Firewall only exposes ports 443, 22 | Configure `ufw` or `iptables` |
| 9.3 | SSH key-only authentication | `/etc/ssh/sshd_config` → disable `PasswordAuthentication` |
| 9.4 | OS and package auto-updates | `unattended-upgrades` (Ubuntu) or equivalent |
| 9.5 | PostgreSQL bound to localhost | `postgresql.conf` → `listen_addresses = 'localhost'` |
| 9.6 | Regular backup schedule | `schema.sql` → `backups` table. Implement cron for `pg_dump` |
| 9.7 | Off-site backup storage | Admin manually downloads backup to local computer and saves a copy to a separate disk on the hardware server |

---

## 10. Data Privacy

| # | Check | Blueprint Reference |
|---|---|---|
| 10.1 | Soft deletes on student/sponsor/user records | `schema.sql` → `deleted_at` column + partial unique indexes |
| 10.2 | Student data redacted for public browse | Not designed — define rules (hide village, guardian contacts) |
| 10.3 | Director approval for published documents | `PERMISSIONS.md` → APR requires Approve/Sign-off |
| 10.4 | Data retention / purge policy | Not designed — define how long audit logs, staging, archives are kept |

---

## 11. ETL / Migration Security

| # | Check | Blueprint Reference |
|---|---|---|
| 11.1 | Staging tables isolated from production | `schema.sql` → `migration_staging_*` tables are separate |
| 11.2 | Human-in-the-loop gatekeeper | `Architecture.mmd` → Sandbox Preview UI approval step |
| 11.3 | Validation errors captured | `schema.sql` → `validation_errors TEXT[]` in staging tables |
| 11.4 | Rollback capability per batch | Not designed — `migration_metadata` batch tracking could support it |

---

## 12. Monitoring

| # | Check | Blueprint Reference |
|---|---|---|
| 12.1 | Error logging | Laravel `storage/logs/` — monitor disk space |
| 12.2 | Failed login alerts | Not designed — notify admin on brute-force attempts |
| 12.3 | Backup failure alerts | Not designed — cron should email on `pg_dump` failure |
| 12.4 | Disk space monitoring | Not designed — essential for on-premise |
| 12.5 | Incident response plan | Not designed — basic steps for breach, failure, data loss |

---

*Use this checklist during each build phase to verify no security area is overlooked.*
