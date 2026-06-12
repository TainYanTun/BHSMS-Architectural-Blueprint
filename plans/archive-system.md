# Archive System Design

This document defines the centralized archive model for the Bangla Hope SMS. Records never leave their original tables; a PostgreSQL VIEW provides unified browsing.

---

## 1. Philosophy: Stay-in-place + Live VIEW

**Principle:** Archived records remain in their original tables with status flags and soft deletes. The `archive_index` VIEW acts as a live directory pointing to where records already live.

```
                   ┌─────────────────────────────┐
                   │       Archive UI Page       │
                   │  queries archive_index VIEW │
                   └──────────┬──────────────────┘
                              │
                    ┌─────────▼──────────┐
                    │  archive_index     │
                    │  (PostgreSQL VIEW) │
                    └─────────┬──────────┘
                              │
         ┌────────────────────┼────────────────────┐
         │                    │                    │
   students WHERE        sponsors WHERE      communications WHERE
   status IN             status =             status IN
   ('Dropped',           'Inactive'          ('Sent', 'Failed')
    'Completed')         OR deleted_at        AND older than X days
   OR deleted_at         IS NOT NULL
   IS NOT NULL
```

**Why not a dedicated archive table?**

| Concern | Stay-in-place handles it |
|---------|--------------------------|
| Two sources of truth | Original table is the only source — VIEW just reads it |
| Restore complexity | Update the status column — the VIEW reflects it instantly |
| Sync drift | No sync needed — VIEW is always live |
| Data duplication | Zero — the VIEW has no storage overhead |

---

## 2. Archive-Eligible Entities

### 2.1 Soft-Delete (`deleted_at`)

| Table | Column | Archived When | Retention |
|-------|--------|--------------|-----------|
| `users` | `deleted_at TIMESTAMPTZ` | Account deactivated and soft-deleted | Permanent (no purge) |
| `students` | `deleted_at TIMESTAMPTZ` | Record soft-deleted after status terminal | Permanent |
| `sponsors` | `deleted_at TIMESTAMPTZ` | Sponsor marked inactive then soft-deleted | Permanent |
| `communication_templates` | `deleted_at TIMESTAMPTZ` | Template deprecated and soft-deleted | Permanent |

### 2.2 Status-Based Archive

| Table | Archive State(s) | How It's Triggered | Who Can Trigger |
|-------|------------------|-------------------|-----------------|
| `students` | `'Dropped'`, `'Completed'` | Drop/Complete workflow via Coordinator request → Director approval | Coordinator (request), Director (approve) |
| `sponsors` | `'Inactive'` | Sponsor no longer participating | Director |
| `sponsorships` | `is_active = FALSE` | Student leaves program or sponsor ends support | Director |
| `enrollments` | `is_active = FALSE` | Student transfers or completes a program | Auto-set on transition |
| `student_identifiers` | `is_current = FALSE` | Student gets a new Program ID on transition | Auto-set on transition |
| `communications` | `'Sent'`, `'Failed'` | Delivery complete or permanently failed | Auto-set by queue worker |
| `reports` | `'Complete'` | Approval workflow finalized | Auto-set on Director approval |
| `payment_categories` | (not applicable) | Reference data, no status | N/A |
| `payouts` | `'Paid'`, `'Cancelled'` | Financial transaction finalized | Auto-set on record |
| `loans` | `'Complete'`, `'Expired'` | Loan lifecycle ends | Auto-set on final payment or expiry |

### 2.3 Infrastructure Cleanup (Not in Archive VIEW)

| Table | Cleanup State | Action | Who |
|-------|--------------|--------|-----|
| `job_queue` | `'Completed'`, `'Failed'`, older than 30 days | Purge by cron | Scheduler (auto) |
| `migration_staging_*` | `'Imported'`, `'Failed'` | Purge after migration batch is verified | Admin (manual) |
| `audit_logs` | Partition older than 2 years | Detach → compress → cold storage | Scheduler (auto) |
| `attendance_records` | Partition older than 2 years | Detach → compress → cold storage | Scheduler (auto) |

---

## 3. The `archive_index` VIEW

### 3.1 Definition

```sql
CREATE VIEW archive_index AS
SELECT
    'student' AS source_type,
    s.id AS source_id,
    CONCAT(s.first_name, ' ', s.last_name) AS title,
    s.status AS reason,
    s.updated_at AS archived_at,
    s.deleted_at,
    'students' AS source_table
FROM students s
WHERE s.status IN ('Dropped', 'Completed')
   OR s.deleted_at IS NOT NULL

UNION ALL

SELECT
    'sponsor',
    sp.id,
    sp.full_name,
    sp.status,
    sp.updated_at,
    sp.deleted_at,
    'sponsors'
FROM sponsors sp
WHERE sp.status = 'Inactive'
   OR sp.deleted_at IS NOT NULL

UNION ALL

SELECT
    'communication',
    c.id,
    c.subject,
    c.status,
    c.updated_at,
    NULL,
    'communications'
FROM communications c
WHERE c.status IN ('Sent', 'Failed')

UNION ALL

SELECT
    'report',
    r.id,
    CONCAT(r.type, ' — ', r.year),
    r.status,
    r.updated_at,
    NULL,
    'reports'
FROM reports r
WHERE r.status = 'Complete'

UNION ALL

SELECT
    'sponsorship',
    sh.id,
    CONCAT('Sponsorship #', sh.id),
    CASE WHEN sh.is_active THEN 'Active' ELSE 'Inactive' END,
    sh.updated_at,
    NULL,
    'sponsorships'
FROM sponsorships sh
WHERE sh.is_active = FALSE

UNION ALL

SELECT
    'enrollment',
    e.id,
    CONCAT('Enrollment #', e.id),
    CASE WHEN e.is_active THEN 'Active' ELSE 'Inactive' END,
    e.updated_at,
    NULL,
    'enrollments'
FROM enrollments e
WHERE e.is_active = FALSE

UNION ALL

SELECT
    'loan',
    l.id,
    CONCAT('Loan #', l.id),
    l.status,
    l.updated_at,
    NULL,
    'loans'
FROM loans l
WHERE l.status IN ('Complete', 'Expired');
```

### 3.2 Resulting Schema

| Column | Type | Description |
|--------|------|-------------|
| `source_type` | TEXT | Entity type: `student`, `sponsor`, `communication`, `report`, `sponsorship`, `enrollment`, `loan` |
| `source_id` | UUID | Primary key of the original record |
| `title` | TEXT | Human-readable label (student name, subject line, etc.) |
| `reason` | TEXT | Why it was archived (Dropped, Completed, Inactive, Sent, etc.) |
| `archived_at` | TIMESTAMPTZ | When the status changed (from `updated_at`) |
| `deleted_at` | TIMESTAMPTZ? | Soft-delete timestamp if applicable |
| `source_table` | TEXT | Physical table name for UI routing |

### 3.3 Usage

```sql
-- Browse all archived items
SELECT * FROM archive_index ORDER BY archived_at DESC;

-- Filter by type
SELECT * FROM archive_index WHERE source_type = 'student';

-- Filter by reason
SELECT * FROM archive_index WHERE reason = 'Dropped';

-- Count by category
SELECT source_type, COUNT(*) FROM archive_index GROUP BY source_type;
```

---

## 4. Archive UI

### 4.1 Page Layout

The existing `bh_archive.html` prototype serves as the Archive UI. It should query `archive_index` and display:

```
┌─────────────────────────────────────────────────────────────────┐
│  [SEC_14: ARCHIVE_INDEX]  Drop List & Archive System            │
├─────────────────────────────────────────────────────────────────┤
│  [All] [Students] [Sponsors] [Communications] [Reports] [Loans] │
├─────────────────────────────────────────────────────────────────┤
│  Search...  |  Reason: All  |  Order: Newest First              │
├─────────────────────────────────────────────────────────────────┤
│  Type     │ Item                  │ Reason      │ Date         │
│  ─────────────────────────────────────────────────────────────── │
│  Student  │ Abdur Rahman          │ Completed   │ 2026-06-09   │  [View] [Restore]
│  Sponsor  │ John & Sarah Miller   │ Inactive    │ 2026-05-27   │  [View] [Restore]
│  Comm     │ Thank you — Apr 2026  │ Sent        │ 2026-04-20   │  [View]
│  Report   │ APR 2025 — Arif       │ Complete    │ 2026-01-15   │  [View]
│  Loan     │ Loan #550e8400        │ Complete    │ 2026-03-01   │  [View]
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Interaction

| Action | Behaviour |
|--------|-----------|
| **Click row / [View]** | Navigates to the original record's detail page (e.g., `bh_student_details.html?id=UUID`) |
| **[Restore]** | Changes status back to Active (students/sponsors) or the appropriate pre-archive state. Confirmation modal required. Only visible for student and sponsor records. |
| **Filter pills** | Filters `archive_index` by `source_type` |
| **Search** | Searches `title` and `reason` columns |
| **Reason filter** | Dropdown of distinct `reason` values |

### 4.3 Access Control

| Role | Archive Access |
|------|----------------|
| Admin | Full Access — view, restore, purge (infrastructure cleanup) |
| Director | View all, Restore students/sponsors |
| Coordinator | View within assigned program(s) only |
| Secretary | View communications/reports they drafted |
| Sponsor | No access — Archive is internal only |

---

## 5. Restore Logic

Restoring an archived record means reverting its status to the active state:

| Entity | Current State | Restore Action |
|--------|--------------|----------------|
| `students` | `status = 'Dropped'` | Set `status = 'Active'`, clear `deleted_at` |
| `students` | `status = 'Completed'` | Set `status = 'Active'`, clear `deleted_at` |
| `sponsors` | `status = 'Inactive'` | Set `status = 'Active'`, clear `deleted_at` |
| `sponsorships` | `is_active = FALSE` | Set `is_active = TRUE` |
| `enrollments` | `is_active = FALSE` | Set `is_active = TRUE` |

Restore must be logged in `audit_logs`:
```json
{
  "action": "RESTORE",
  "target_table": "students",
  "target_id": "UUID",
  "previous_status": "Dropped",
  "new_status": "Active"
}
```

---

## 6. Audit Trail Linking

All archive actions (Drop, Complete, Restore) are recorded in `audit_logs` with:

- `module`: `'Archive'`
- `action`: `'DROP'`, `'COMPLETE'`, `'RESTORE'`
- `target_id`: UUID of the archived record
- `target_type`: Table name (`students`, `sponsors`, etc.)
- `mutation_detail`: JSONB snapshot of the status change

This ensures the archive history is always traceable.

---

## 7. Retention & Purge Policy

| Data | Retention | Action After Retention |
|------|-----------|----------------------|
| Archived students | Permanent | Keep in `students` table with status flag |
| Archived sponsors | Permanent | Keep in `sponsors` table with status flag |
| Sent communications | Permanent | Keep in `communications` table |
| Completed reports | Permanent | Keep in `reports` table |
| Audit log partitions | 2 years | Detach, compress, store in cold storage |
| Job queue (Completed) | 30 days | Purge by cron |
| Job queue (Failed) | 90 days | Purge by cron after failed attempts exhausted |
| Migration staging | After batch verified | Purge by admin |
| Soft-deleted records | Permanent | No hard delete (partial unique indexes prevent conflicts) |

> **Note:** A formal data purge policy (item 10.4 in SECURITY_CHECKLIST.md) is not yet defined. The above retention periods are recommendations for client confirmation.

---

## 8. Open Items

| Item | Status |
|------|--------|
| Coordinator archive scope — Can they view archived records from other programs? | Needs decision |
| Secretary restore permission — Can a Secretary restore a dropped student? | Needs decision |
| Purge policy — Formalize retention durations for each entity | Needs client confirmation |
| Archive notification — Should an email notification fire when a student is dropped/archived? | Not designed |
| Bulk archive — Should the UI support batch-selecting and archiving multiple students? | Not designed |
