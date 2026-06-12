# Plan: Database Partitioning Strategy for `audit_logs`

This document outlines the proposed partitioning strategy for the `audit_logs` table to ensure long-term performance and maintainability as the system grows.

## 1. Problem Statement
The `audit_logs` table will be the fastest-growing table in the database. Without partitioning, queries on this table will degrade in performance over time, and maintenance tasks (like vacuuming or archiving old logs) will become increasingly expensive.

## 2. Proposed Solution: Declarative Partitioning
We will implement PostgreSQL's native **Declarative Partitioning** based on the `created_at` timestamp.

### Strategy: Range Partitioning
We will partition the table by `RANGE` on the `created_at` column, creating one partition per month (e.g., `audit_logs_2026_05`, `audit_logs_2026_06`).

## 3. Implementation Plan

### Step 1: Modify Table Structure
The parent table (`audit_logs`) will be created without primary keys that include the partition key (or if included, the partition key must be part of the PK). Since our `id` is a `UUID` and not a serial, we must ensure the PK is unique across partitions (e.g., using `UUID` or `BIGINT` across all).

### Step 2: Create Partitions
Automation scripts (to be run via cron job) will create partitions for the upcoming month:
```sql
CREATE TABLE audit_logs_2026_06 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-06-01') TO ('2026-07-01');
```

### Step 3: Maintenance (Archiving)
Old partitions (e.g., older than 2 years) can be detached and archived. The storage strategy for these archives is:

1.  **Format:** Export detached partitions to a compressed format (e.g., `pg_dump` to `.sql.gz` or Apache Parquet for better analytics compatibility).
3. **Storage:** 
    *   **On-Premise (MinIO):** Self-hosted S3-compatible storage. Optionally sync cold data to external drive for long-term retention.
    *   **On-Premise (Recommended for Production):** Dedicated cold-storage server or encrypted network-attached storage (NAS).
    *   **Local Testing:** Use a local directory (e.g., `storage/app/backups/audit_archives/`) to test the export/verify/delete workflow.

3.  **Integrity:** Generate MD5 or SHA256 checksums for each archive file to verify data integrity before deleting the local detached table from the PostgreSQL database.
4.  **Metadata:** Maintain a record of archived partitions (filename, date range, storage location) in the `backups` table to ensure they remain discoverable if restoration is needed.

## 4. Risks & Considerations
- **Index Management:** Each partition must have its own indexes.
- **Application Logic:** The application must be aware that it is inserting into a partitioned table (PostgreSQL handles this transparently).
- **Initial Setup:** Partitioning an existing table with data is complex; this should ideally be implemented before the system goes live in production.
