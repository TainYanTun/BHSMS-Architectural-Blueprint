# Sponsor Communication Hub: Purpose & Logic

This document defines the purpose and operational logic for the Sponsor Communication Hub within the Bangla Hope Sponsorship SMS.

> **Note:** Student-specific report delivery (APRs, Thank You letters, Birthday greetings) is handled **outside the system** — staff generate PDF reports via the Reports module and email them manually. The Communication Hub is used exclusively for **broadcast messages** to sponsors about organizational updates.

## 1. Core Purpose
The Communication Hub serves as a broadcast tool for Bangla Hope to send general announcements to sponsors:
*   **Organizational Updates:** News about Bangla Hope's programs, achievements, or changes.
*   **Seasonal Greetings:** Holiday messages (Christmas/Eid) sent to all sponsors.
*   **Urgent Notices:** Important information that needs to reach all sponsors.

## 2. Communication Types

| Type | Purpose | Frequency | Audience |
| :--- | :--- | :--- | :--- |
| **Broadcast** | Organizational announcements | As needed | All sponsors |
| **Holiday Card** | Seasonal greetings | Annual | All sponsors |
| **Manual Note** | Ad-hoc messages to specific sponsors | As needed | Individual sponsors |

## 3. Workflow

Broadcast communications follow a simple workflow:
1. Staff drafts the message
2. Supervisor reviews and approves
3. Staff exports the recipient list for manual emailing outside the system

The system tracks what was sent, when, and to whom via the `communications` table, but actual email delivery is handled externally by staff.

## 4. Template Management

Supervisors can maintain a library of broadcast message templates:
1.  **Create New Templates:** For seasonal events (e.g., "Holiday 2026").
2.  **Edit Global Templates:** Update the wording of standard announcements.
3.  **Deprecate Templates:** Deactivate old templates without deleting historical records.

### Supported Variables (Broadcast Only)
| Variable | Description | Example |
| :--- | :--- | :--- |
| `[SPONSOR_NAME]` | The full name of the sponsor. | John & Sarah Miller |
| `[DATE]` | Current date. | June 2026 |

## 5. The Communication Hub Workbench
*   **Location:** `bh_communication_hub.html`
*   **Display:** A list of broadcast communications and their delivery status.
*   **Filters:** Users can filter by Status (Draft, Approved, Sent).
