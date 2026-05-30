# Bangla Hope SMS - Data Architecture Map

This document visualizes the database structure, organized by logical functional domains. The system uses a **Master-Relational Model** anchored by the `STUDENTS` table.

---

## 1. High-Level Domain Map

| Domain | Primary Tables | Responsibility |
| :--- | :--- | :--- |
| **System & Auth** | `USERS`, `ROLES`, `PERMISSIONS` | Global configuration, RBAC, and system audit logs. |
| **Student Core** | `STUDENTS`, `PROGRAMS`, `INTAKE` | Bio-data, family background, and identifiers. |
| **Education** | `REPORTS`, `ACADEMIC`, `ATTENDANCE` | Document Factory (APRs, Case Histories, Letters). |
| **Facilities** | `ORPHANAGES`, `VILLAGE_SECTORS` | Logistical registry of physical locations. |
| **Sponsorship** | `SPONSORS`, `SPONSORSHIPS`, `COMMS` | Relationship tracking and communication logs. |
| **Financial** | `CONTRIBUTIONS`, `PAYOUTS`, `LOANS` | Tracking USD-only income vs. payout/loan expenditures. |
| **Logistics** | `TRANSITIONS`, `REFERENCES` | Tracking student movement and referral sources. |
| **Data Migration** | `MIGRATION_STAGING`, `METADATA` | High-integrity staging for legacy data import. |

---

## 2. Logical Entity Relationship Diagram

For the detailed, up-to-date ERD, please refer to: `BH_blueprint/technical/ERD.md`.

---

## 3. Physical Placement & Sync Logic

### A. The "Sync-Aware" Columns
Every record that needs to be synchronized between the **Main Office (Hili)** and **Remote Sites** must include:
*   `row_version`: An integer that increments on every change (managed by `fn_update_timestamp`).
*   `updated_at`: A timestamp updated by trigger on any modification.

### B. High-Traffic Partitioning
To maintain performance (Proposal 3.6.1), the following tables should be physically partitioned by **Year** or **Month**:
1.  `audit_logs`
2.  `attendance_records`

### C. The Staging Layer
The `MIGRATION_STAGING_*` tables exist outside standard relational constraints to allow for automated validation. Once a record passes checks, it is "promoted" to the Core tables and linked via `MIGRATION_METADATA`.

---

## 4. Facility Identification & Remote Operations

The system identifies operational locations via distinct facility registries:

### A. Location Types
*   **Orphanages:** Residential facilities managed directly by Bangla Hope.
*   **Village Sectors:** Community hubs/schools managed by local supervisors.

### B. Automatic Tagging
When a staff member logs in and performs an action, the application automatically tags the data with the `orphanage_id` or `village_sector_id` associated with their work assignment.

---

## 5. Financial Ledger Integrity

### A. Immutability
Financial transaction tables (`CONTRIBUTIONS`, `ALLOCATION_PAYOUTS`, `LOAN_TRANSACTIONS`) are defined as **immutable**. They do not use auto-update triggers. Changes must be made via explicit reversing entries (adjustments).

### B. Overdraft Prevention
The system uses the `fn_enforce_contribution_limits` trigger on the `RECONCILIATIONS` table. It performs a **parent-level write lock** (`FOR UPDATE`) on the `CONTRIBUTIONS` table to serialize allocation attempts, preventing phantom read race conditions.

### C. Cascading Deletion
All child relationships are defined with **`ON DELETE RESTRICT`** to prevent accidental orphan records and ensure financial/academic data trail integrity.
