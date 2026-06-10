# Bangla Hope Sponsorship Management System (Bangla Hope SMS)
## Architectural Database Schema Explanation
**Generated/Verified:** May 30, 2026  
**Database Engine:** PostgreSQL

---

## 0. Core Database Mechanics & Automation
To ensure data integrity, maintain audit histories, and handle concurrent operations gracefully, the schema utilizes a set of foundational database mechanics:

* **`uuid-ossp` & `pgcrypto` Extensions:** Power secure, decentralized, and unpredictable unique identifiers (UUIDv4) across all tables, minimizing sequential enumeration risks.
* **`pg_trgm` Extension:** Provides high-performance text-searching capabilities utilizing trigram matching, enabling fast wildcard searches across large text fields like student and sponsor names.
* **`student_master_id_seq`:** A thread-safe, native database sequence dedicated to generating immutable, human-readable primary identification numbers for children entering the system without risking race conditions.
* **`fn_update_timestamp()` Trigger Function:** An automated quality control function applied system-wide. Whenever an existing row is edited via an `UPDATE` statement, this trigger automatically forces `updated_at` to the current timestamp (`NOW()`) and increments `row_version` by `1`. This provides out-of-the-box infrastructure for **Optimistic Concurrency Control (OCC)** to prevent accidental overwrites during multi-user operations.

---

## 1. Structural Directories & Reference Tables
These tables establish the core corporate and geographic infrastructure of Bangla Hope's administrative footprints, serving as standardized reference records.

### `programs`
* **Purpose:** Houses the distinct sponsorship verticals managed by the organization (e.g., Residential Care, Day Boarding, Higher Ed Loans).
* **Key Detail:** Uses a mandatory, unique 3-letter alphanumeric code (`code`) to facilitate clean operational routing, system lookups, and standardized identifier prefixes.

### `orphanages`
* **Purpose:** Formally registers structural brick-and-mortar housing campuses and institutional residential centers.

### `village_sectors`
* **Purpose:** Catalogs physical boundaries and designations for community-based, non-residential field operations and localized village school networks.

### `teachers`
* **Purpose:** Directory of academic personnel and field educators.
* **Key Detail:** Employs polymorphic routing keys (`orphanage_id`, `village_sector_id`) to map instructors directly to their exact base of operations.

### `educational_institutions`
* **Purpose:** A registry of third-party external universities, trade colleges, and technical vocational institutes where older students matriculate upon entering the advanced study track.

---

## 2. Authentication, Users & Role-Based Access Control (RBAC)
Handles system security clearance, data segregation, accountability logging, and internal communication lifecycles.

### `roles`
* **Purpose:** Defines structural system personas with specific operational scopes (e.g., Admin, Supervisor, Coordinator, Secretary, Sponsor).

### `permissions`
* **Purpose:** Acts as a fine-grained registry mapping atomic actions or security checkpoints across the system (e.g., `STUDENT_CREATE`, `FINANCE_APPROVE`).

### `role_permissions`
* **Purpose:** A strict, restrictive many-to-many junction table linking granular access authorizations directly back to their designated role buckets.

### `users`
* **Purpose:** Primary identity database for employees, case workers, administrators, and portal users.
* **Key Design:**
    * Implements data protection and archival support using a soft-delete column (`deleted_at`).
    * Employs partial unique indexing (`idx_unique_active_username` and `idx_unique_active_email`) to guarantee string uniqueness across *active* accounts only. This elegant mechanism allows a previously soft-deleted email address or username to be recycled without breaking constraints or wiping historical logs.

### `invitations`
* **Purpose:** Governs corporate user onboarding and secure platform registration pipelines using single-use cryptographic tokens bound to a rigid expiration horizon (`expires_at`).

---

## 3. Student Lifecycle & Directory Records
The functional core of the application. These entities store comprehensive medical, social, tracking, and relational profiles for every child admitted to Bangla Hope.

### `students`
* **Purpose:** The single source of truth for the master student directory.
* **Key Design:**
    * **Safe ID Composite Generation:** Features an explicit database trigger (`trg_assign_student_id`) executing a safe mathematical prefix formula: `(CurrentYear * 100000000) + SequenceValue`. This creates clean, predictable, non-truncating identification numbers (e.g., `202600000001`) that prevent integer overflow while tracking admission years natively inside the index.
    * Tracks structural status categories (`Active`, `Archived`, `Dropped`, `Graduated`) while ensuring historical retention profiles stay uncorrupted via soft deletes.

### `guardians`
* **Purpose:** Maps immediate family structures and biological or legal guardian profiles directly back to the child, logging contact details, relationships, and identity photos.

### `student_intake_details`
* **Purpose:** A clean 1-to-1 extensions table mapping vital indicators captured precisely at the moment of intake (admission weight, foundational health assessments, baseline immunization checks). Separating these massive narrative blobs keeps performance on the primary `students` index highly optimized.

### `student_references`
* **Purpose:** Logs external human assets, local village pastors, community headers, or civic organizations that vetted, verified, or recommended the child for assistance.

### `enrollments`
* **Purpose:** A physical timeline ledger capturing exactly where a child was deployed, which program they were bound to, and what residential/day sector handled their care over their lifetime.

### `student_identifiers`
* **Purpose:** Captures custom formatted human-readable system tags (e.g., `#LRC-0124`) that vary across departments and programmatic moves while keeping historical codes safely indexable.

### `program_transitions`
* **Purpose:** A critical milestone ledger tracking the lifecycle movement of children shifting between organizational paths (e.g., aging out of a boarding school environment and transitioning into higher education study programs).

---

## 4. Donor Management & Sponsorship Financials
Manages external stakeholders, contract configurations, incoming revenue ledgers, and contribution boundaries.

### `sponsors`
* **Purpose:** Stores detailed donor profiles, structural communication flags, primary languages, and delivery configurations. Employs soft-delete logic paired with partial unique indexes for robust validation.

### `sponsorships`
* **Purpose:** The central transactional business junction mapping active, contractually binding relations between a donor and a child.
* **Key Design:** Employs a strict partial unique index (`idx_unique_active_sponsorship`) ensuring that a sponsor cannot be registered as an *active* concurrent duplicate primary or co-sponsor for the exact same child twice.

### `contributions`
* **Purpose:** The unalterable general accounting ledger for all incoming donor revenue.
* **Key Design:** This ledger is designed as completely **immutable** (no update trigger exists). It implements an explicit conditional database constraint (`chk_contribution_target`) that enforces structural destination logic: a payment must be bound cleanly to a specific active sponsorship contract, routed directly to an unlinked student as a special gift, or left open as a general organizational grant.

---

## 5. Communications, Academic Progress & Auditing
Tracks child development matrices, automated document compilation pipelines, and security logging.

### `academic_records` & `attendance_records`
* **Purpose:** Evaluates yearly school metrics, performance indicators, grade evaluations, and strict ratios of classroom attendance measurements (`days_present` / `total_school_days`).
* **Key Design:**
    * **Program-Aware Tracking:** Explicitly links to `program_id` and structural identifiers (`orphanage_id`, `village_sector_id`, or `institution_id`). This ensures that as a child moves from a Village School to a Residential Center (or eventually to a University Loan), their academic history remains a continuous, searchable timeline bound to the specific programmatic context of that year.
    * **Standardized Attendance:** Captures `attendance_percentage` as a normalized metric across all program types.

### `documents`
* **Purpose:** Decentralized asset management table tracking secure physical verification files, birth certifications, and signed legal agreements stored via remote cloud storage links (`file_url`).

### `reports`
* **Purpose:** Manages the drafting, approval states, and completion workflows for case histories, special donor notes, and Annual Progress Reports (APRs) before they are rendered into flat PDF links for export.

### `communications`
* **Purpose:** The delivery outbox and audit pipeline. Tracks execution histories, delivery states, and communication snapshots.
* **Key Design:**
    * **Multi-Channel Support:** Uses a `channel` field to manage Email, Postal Mail, and SMS routing.
    * **Audit Snapshotting:** Captures `recipient_email` and `subject` at the moment of dispatch, ensuring the record remains accurate even if the sponsor's profile is updated later.
    * **Laravel Integration:** Includes a `delivery_log` JSONB column specifically designed to store SMTP response headers, unique Message-IDs, and detailed failure exceptions for technical debugging.
    * Tracks delivery states (`Pending`, `Sent`, `Failed`) for both automated reports and manual messages.

### `communication_templates`
* **Purpose:** Central repository housing pre-formatted messaging templates, dynamic placeholder keys, and transactional formatting rules.

### `student_history`
* **Purpose:** A chronological timeline engine logging minor milestones, field notes, health crises, or notable updates in a child's journey.

---

## 6. Higher Education Loan Trackers
Dedicated accounting instruments optimized for tracking long-term repayable financing arrangements.

### `loans`
* **Purpose:** Central tracking agreement records for advanced students moving away from standard sponsorship models into repayable loan funding accounts.

### `loan_transactions`
* **Purpose:** An immutable financial ledger detailing the balance sheet of an active student loan. Disbursements to third-party institutions enter the system as positive debt metrics, while student payment installments are logged as negative balances.

---

## 7. Safeguards & Staging Engines
Guarantees financial integrity and safely manages bulk old data migrations.

### `program_funding`
* **Purpose:** Allocates a portion of a contribution to fund a program (e.g., sponsor X's $5,000 goes to VLG school). Individual student payouts draw from this pool.

### `payouts`
* **Purpose:** Records every individual payout to a student, whether funded directly from a contribution or through a program funding pool. Provides a complete per-student expenditure trail.

### `backups`

### `backups`
* **Purpose:** An administrative execution log detailing internal snapshot states, sizing weights, and file storage locations.

### `audit_logs`
* **Purpose:** The tamper-proof system black box. Captures mutating structural events, origin user IDs, module paths, client IP addresses, and exact structural object changes inside searchable, index-optimized PostgreSQL `JSONB` data blocks.

### `migration_staging_*` (`students`, `sponsors`, `contributions`)
* **Purpose:** Isolated landing zones for legacy data normalization. Raw files extracted from legacy platforms (MS Access / paper spreadsheets) are dropped here into schematic-free `JSONB` containers. Internal processing scripts scrub, parse, and append schema errors into a text array (`validation_errors`), allowing database engineers to debug data anomalies safely before committing records to the production database.