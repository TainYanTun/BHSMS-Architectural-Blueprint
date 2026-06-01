# Sponsor Communication Hub: Purpose & Logic

This document defines the purpose, frequency, and operational logic for the Sponsor Communication Hub within the Bangla Hope Sponsorship SMS.

## 1. Core Purpose
The Communication Hub is the primary bridge between the sponsor and the student. It serves four main functions:
*   **Relationship Building:** Transforms a financial or calendar milestone into a personal connection.
*   **Transparency:** Provides proof that the student is real, healthy, and attending school.
*   **Operational Receipt:** Serves as the official acknowledgement of funds received (for financial triggers).
*   **Student Development:** Encourages students to practice gratitude and communication skills.

## 2. Communication Types & Triggers

Communications are categorized by their **Trigger**, which determines when and why a task is created.

| Category | Type | Frequency | Trigger (The "Why") | Operational Logic |
| :--- | :--- | :--- | :--- | :--- |
| **Financial** | **Thank You Letter** | **Per Receipt** | Financial Donation | Triggered every time a receipt is recorded. If a sponsor gives monthly, they get 12 letters. |
| **Financial** | **Special Gift Note** | **Occasional** | Extra Donation | Triggered by "One-Time" grants (e.g., for clothing, bikes, or medical needs). |
| **Milestone** | **Birthday Greeting** | **Annual** | Student's Birthday | A personal message celebrating the child's special day. |
| **Milestone** | **Holiday Card** | **Annual** | Fixed Date | Seasonal greetings (e.g., Christmas/Eid) sent to all sponsors. |
| **Academic** | **Progress Report (APR)** | **Annual** | Scheduled Date | A comprehensive update including new photos, grades, and a case history narrative. |

## 3. Workflow & Approval

To ensure quality while maintaining efficiency, the system uses a tiered approval model:

### A. Automatic Approval (Standard Acknowledgements)
*   **Applicable to:** Standard monthly "Thank You" notes.
*   **Logic:** if the Secretary uses a **Standard Template** and does not modify the core message, the task can be marked "Sent" immediately upon generation.
*   **Goal:** Reduce supervisor workload for repetitive, low-risk communications.

### B. Required Review (Milestones & Special Gifts)
*   **Applicable to:** Birthdays, APRs, and Special Gift responses.
*   **Logic:** These require a "Submit for Review" step. A Supervisor must approve the content (and photo if applicable) before it is finalized.
*   **Goal:** Maintain high quality for the "High Impact" communications that sponsors value most.

## 4. Communication Health (The "Sponsorship Health" Metric)

A student's sponsorship status is considered **"Healthy"** if:
1.  **Recency of Support:** The student has received a financial contribution (receipt) within the last **6 months**.
2.  **Milestone Compliance:** The current year's scheduled milestones (APR/Birthday) are "Complete" or "In-Progress" within their active window.

*Note: If a student has not received a contribution in over 6 months, or is missing a Milestone (e.g., APR was due 2 months ago and is not started), the student is flagged as "Action Required" on the Master Registry.*

## 5. Dynamic Templates & Variables

To ensure consistency and speed, supervisors manage a library of dynamic templates. These templates use placeholders (variables) that the system automatically replaces with real data.

### Supported Variables
| Variable | Description | Example |
| :--- | :--- | :--- |
| `[STUDENT_NAME]` | The full name of the student. | Abdur Rahman |
| `[SPONSOR_NAME]` | The full name of the sponsor(s). | John & Sarah Miller |
| `[AMOUNT]` | The currency amount of the receipt. | $50.00 |
| `[DATE]` | The effective date of the trigger. | June 2026 |
| `[DAYS_SINCE_LAST]` | Number of days since the last contribution. | 32 days |
| `[STUDENT_AGE]` | Current age of the student. | 10 years old |
| `[GRADE]` | Current grade level of the student. | Class 4 |

### Supervisor Management
Supervisors have exclusive access to the **Template Manager** (`bh_communication_templates.html`). They can:
1.  **Create New Templates:** For seasonal events (e.g., "Holiday 2026").
2.  **Edit Global Templates:** Update the wording of standard "Thank You" notes for all users.
3.  **Deprecate Templates:** Deactivate old templates without deleting historical records.

## 6. The Communication Hub Workbench
*   **Location:** `bh_communication_hub.html`
*   **Display:** A unified list of all pending and recent communication tasks.
*   **Filters:** Users can filter by Category (Financial, Milestone, Academic) and Status (Pending, Draft, Review, Sent).
