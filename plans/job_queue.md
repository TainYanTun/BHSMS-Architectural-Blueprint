# Background Job Queue Specification (job_queue.md)

This document outlines the design for the background job processing system. This architecture offloads resource-intensive tasks to ensure the main interface remains fast and responsive for daily operations.

---

## 1. Purpose
The system handles tasks that take longer than 1–3 seconds to complete, specifically:
- PDF Generation for APRs and Case Histories.
- Bulk Email Notifications to sponsors.
- Automated Data Validation during migrations.

## 2. Database Schema
A centralized table to track job state across the entire system.

```sql
CREATE TABLE job_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_type TEXT NOT NULL, -- e.g., 'GENERATE_PDF', 'SEND_EMAIL'
    payload JSONB NOT NULL,   -- Contextual data (e.g., student_id, report_id)
    status TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Processing', 'Completed', 'Failed')),
    attempts INT DEFAULT 0,
    error_log TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

## 3. Operational Workflow

### A. The Producer (Main System)
When the Secretary triggers a report/email:
1.  System validates the request.
2.  System inserts a row into `job_queue` with `status = 'Pending'`.
3.  UI shows: "Job Submitted: You will be notified when finished."

### B. The Worker (Background Process)
A separate background service runs independently:
1.  **Polls:** Periodically queries the `job_queue` for `Pending` jobs.
2.  **Locks:** Sets status to `Processing` (prevents double-processing).
3.  **Executes:** Performs the heavy computation (e.g., PDF generation).
4.  **Finalizes:** Updates status to `Completed` or `Failed` (with `error_log` details).

## 4. Why this is necessary
- **Responsiveness:** Staff can keep working on data entry while the system handles background work.
- **Reliability:** If the PDF generator crashes due to a memory spike, the job remains in the queue with a `Failed` status for the Admin to inspect and retry.
- **Scalability:** During heavy reporting periods (e.g., end of term), the background worker ensures the database remains stable.
