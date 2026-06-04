# Automation & Queuing Paradigm

This document outlines the standard operational paradigm for leveraging automation (Scheduler) and asynchronous processing (Queues) within the Bangla Hope SMS.

## 1. Core Paradigm: "Offload-and-Notify"

To ensure a highly responsive interface (the Staff and Sponsor portals), all time-consuming or heavy tasks MUST be offloaded from the main HTTP request cycle.

*   **Request/Response Cycle:** Must always remain fast (sub-second).
*   **Background Tasks:** Dispatched to the `job_queue` table for processing by background workers.
*   **User Feedback:** The UI provides an "Initiated" state and polls the database for completion updates.

---

## 2. Implementation Rules

### A. Heavy Processing (Queue Triggered)
Any action that involves I/O, file generation, or data heavy-lifting MUST be queued.

*   **Trigger:** User clicks a "Generate" or "Export" button.
*   **Paradigm:**
    1.  **Queue:** The system dispatches a job to the `job_queue` table with status `Pending`.
    2.  **Immediate Response:** The UI immediately informs the user: "Processing initiated."
    3.  **Worker:** A background worker picks up the job, performs the task (e.g., PDF generation), updates the relevant record, and marks the job `Completed`.

### B. Routine Maintenance (Scheduler Triggered)
Scheduled tasks are used for organizational automation that does not require direct user interaction.

*   **Paradigm:** Use the `Laravel Automation Engine` (Artisan Scheduler) to trigger tasks at specific intervals.
*   **Use Cases:**
    *   Daily pruning of expired `invitations` or temporary files.
    *   Pre-caching of dashboard data for high-traffic views.
    *   Generating standard, recurring organizational summaries.

### C. Reliability & Retry (The Worker Strategy)
Background tasks must be resilient to failure.

*   **Paradigm:** If a background task fails, the `job_queue` status is updated to `Failed` and the `error_log` is populated. The system should implement automatic exponential backoff retries for transient errors (e.g., SMTP timeout).

---

## 3. Standard Queue/Automation Mapping

| Task Category | Trigger Mechanism | Implementation Layer | Priority |
| :--- | :--- | :--- | :--- |
| **Manual Backups** | User-Initiated | Queue (`job_queue`) | Required |
| **Bulk PDF (APR) Generation** | User-Initiated | Queue (`job_queue`) | Required |
| **Mass Communications** | User-Initiated | Queue (`job_queue`) | Required |
| **Maintenance/Cleanup** | Time-Based | Scheduler (`Artisan`) | Optional |
| **Pre-caching Reports** | Time-Based | Scheduler + Queue | Optional |

---

## 5. Automated System Maintenance

To ensure long-term stability and security without human intervention, the `Laravel Automation Engine` handles the following tasks:

### 1. Security & Compliance (Non-Negotiable)
*   **Invitation Pruning:** Automatically deletes expired sponsorship invitation tokens to maintain a strict security posture.
*   **Audit Log Maintenance:** Ensures old, non-partitioned temporary audit data is periodically processed to prevent database bloat.

### 2. Data Integrity (Preventing Rot)
*   **Failed Job Cleanup:** Automatically removes stale, failed entries from the `job_queue` to keep the system view focused on active errors.
*   **Orphaned File Cleanup:** Detects and deletes "orphaned" files in S3 that lack corresponding database records (e.g., failed uploads), preventing storage waste.

### 3. System "Self-Healing"
*   **Heartbeat Checks:** Periodically verifies connectivity to critical dependencies (PostgreSQL, S3) and dispatches alerts if any service is unresponsive, enabling proactive recovery.
