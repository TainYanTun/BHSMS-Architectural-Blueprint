# Bangla Hope SMS - Program Paradigm

This document defines the standardized program structure and operational logic for the Bangla Hope Sponsorship Management System.

## 1. Program Matrix

| Program Name | Code | Facility Entity | Primary Logic | Financial Focus |
| :--- | :--- | :--- | :--- | :--- |
| Orphanage Residential | `LRC` | `orphanages` | Residential, Case History | Subsidy, Pocket Money |
| Boarding School | `BRD` | `orphanages` | Enrollment, APR Reports | Subsidy, Pocket Money |
| Village Schools | `VLG` | `village_sectors` | Attendance Records | Subsidy |
| Higher Study Loan | `LON` | `educational_institutions`| Loan Agreements | Disbursements, Refunds |
| ~~Employee Children~~ | ~~STF~~ | Removed — staff children tracked via `staff_parent_id` FK, not a separate program |

---

## 2. Implementation Rules

### A. Program Codes
*   All codes must be **exactly 3 characters**.
*   Codes are the unique identifiers used by the application tier for business logic branching (e.g., UI module toggling).

### B. Facility Mapping
*   **Residential/Direct Managed:** Mapped to `orphanages`.
*   **Community/Supervised:** Mapped to `village_sectors`.
*   **Higher Education:** Mapped to `educational_institutions` (external partners).

### C. Financial Tracking
*   **Subsidy/Pocket Money:** Standardized across residential/community programs.
*   **Disbursement/Refund:** Exclusive to the `LON` program within the `loan_transactions` ledger.

### D. Architectural Enforcement
*   **Query Pattern:** 
    *   `LRC`, `BRD` → Query via `orphanage_id`
    *   `VLG` → Query via `village_sector_id`
    *   `LON` → Query via `institution_id` (in `academic_records`)
*   **Consistency:** All programs share the standardized `ENROLLMENTS` table structure, ensuring a unified cross-program lifecycle view.

### E. Student Status (Lifecycle Logic)
*   **Active:** Student is currently participating in a program.
*   **Completed:** Student has successfully finished their program path.
*   **Dropped:** Student left the program prematurely.
*   *Note: `Completed` and `Dropped` statuses automatically trigger "Archived" view behavior in the application (removing them from active workspace lists).*
