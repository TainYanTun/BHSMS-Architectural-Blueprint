# Role-Based Access Control (RBAC) Permission Matrix

This document defines the system-wide permissions for each user role within the Bangla Hope Sponsorship Management System.

## 1. Permission Matrix

| Module / Action                  | Secretary     | Coordinator¹   | Director               | Admin       | Sponsor         |
| :---------------------------------| :-------------:| :--------------:| :----------------------:| :-----------:| :---------------:|
| **▸ Student Lifecycle**          |               |                |                        |             |                 |
| **Student Master Records**       | View / Edit   | View / Edit²   | Full Access            | Full Access | View (Limited)  |
| **Academic & Results**           | View / Edit   | Create / Edit² | Full Access            | Full Access | View            |
| **Attendance Records**           | View / Edit   | Create / Edit² | Full Access            | Full Access | View            |
| **Student History / Notes**      | Create / Edit | Create / Edit² | Full Access            | Full Access | --              |
| **Program Transitions**          | --            | Request²       | **Approve / Move**     | Full Access | --              |
| **Drop / Complete Student**      | --            | Request²       | **Approve / Move**     | Full Access | --              |
| **▸ Sponsorship**                |               |                |                        |             |                 |
| **Sponsors**                     | Create / Edit | View²          | Full Access            | Full Access | --              |
| **Sponsorships**                 | Create / Edit | View²          | Full Access            | Full Access | --              |
| **▸ Financial**                  |               |                |                        |             |                 |
| **Sponsorship Income (USD)**     | Create / Edit | View²          | Full Access            | Full Access | View (Personal) |
| **Student Subsidies (USD)**      | View          | Create / Edit² | Full Access            | Full Access | --              |
| **Higher Ed Loan Program**       | Create / Edit | Create / Edit² | Full Access            | Full Access | --              |
| **Exchange Rates (Monthly BDT→USD)** | View / Edit | View²      | Full Access             | Full Access | --              |
| **Reconciliations**              | --            | --             | Full Access            | Full Access | --              |
| **Financial Audit Logs**         | View          | View²          | View                   | Full Access | --              |
| **▸ Documents & Communications** |               |                |                        |             |                 |
| **Documents**                    | Create / Edit | Create / Edit² | Full Access            | Full Access | View            |
| **Communication Templates**      | --            | --             | Manage / Edit          | Full Access | --              |
| **Communications**               | Draft         | Draft / Edit²  | **Approve / Sign-off** | Full Access | View            |
| Thank You Letters                | Create / Edit | Create / Edit² | Full Access            | Full Access | View / Download |
| Annual Progress Report (APR)     | Draft         | Draft / Edit²  | **Approve / Sign-off** | Full Access | View / Download |
| **▸ Reference & System**         |               |                |                        |             |                 |
| **Teachers**                     | View          | Create / Edit² | Full Access            | Full Access | --              |
| **Facilities Registry**          | --            | --             | --                     | Full Access | --              |
| **Site & User Registry**         | --            | --             | --                     | Full Access | --              |
| **Invitations**                  | --            | --             | Full Access            | Full Access | --              |
| **Data Migration Staging**       | --            | --             | --                     | Full Access | --              |
| **System Health & Backups**      | --            | --             | --                     | Full Access | --              |

---

## 2. Access Level Definitions

*   **Full Access:** Can Create, Read, Update, and Delete/Archive records within that module.
*   **Create / Edit:** Can add new records and modify existing ones, but cannot Archive or Hard Delete.
*   **View / Download:** Read-only access to information and ability to export documents.
*   **Draft:** Can create and save content but cannot mark it as "Official" or "Sent."
*   **Approve / Sign-off:** High-level approval role. Content is hidden from the public/sponsor until this role approves it.
*   **Manage:** Ability to update system-wide shared assets like Letter Templates.
*   **-- (Dash):** No access allowed; module is hidden from the user's sidebar.

> **¹ Coordinator:** Access is scoped to the specific program(s) the Coordinator is assigned to (e.g., a Village School Coordinator only sees Village School students, not LRC or Loan students). Assignment is managed via the `user_programs` junction table.
>
> **² Coordinator:** Operations are limited to the Coordinator's assigned program(s). Data outside their programs is invisible.

---

## 3. Role Summary

- **Admin:** System owner. Manages user accounts, system configuration, data migration, backups. Technical authority — does not handle operational student or financial data.
- **Director:** Highest operational authority. Final approver for documents, student status changes, and financial sign-off. Oversees all programs and staff.
- **Coordinator:** Day-to-day operator assigned to specific program(s). Manages student lifecycle, academic records, attendance, and financial entries within their program scope. Cannot approve or archive.
- **Secretary:** Administrative support. Handles data entry, letter drafting, record updates, and logging financial transactions (donations, payouts).
- **Sponsor:** External stakeholder. Read-only access to their sponsored child's information and documents. Can browse unsponsored children (redacted).

---
*Last Updated: 2026-06-09 | Part of the Bangla Hope SMS Technical Blueprint*
