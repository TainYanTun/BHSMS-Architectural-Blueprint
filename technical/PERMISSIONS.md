# Role-Based Access Control (RBAC) Permission Matrix

This document defines the system-wide permissions for each user role within the Bangla Hope Sponsorship Management System.

## 1. Permission Matrix

| Module / Action                  | Secretary     | School Coordinator¹ | Program Coordinator² | Director               | Admin       | Sponsor         |
| :---------------------------------| :-------------:| :-------------------:| :--------------------:| :----------------------:| :-----------:| :---------------:|
| **▸ Student Lifecycle**          |               |                      |                      |                        |             |                 |
| **Student Master Records**       | View / Edit   | View / Edit¹        | View / Edit²         | Full Access            | --          | View (Limited)  |
| **Academic & Results**           | View / Edit   | Create / Edit¹      | Create / Edit²       | Full Access            | --          | View            |
| **Attendance Records**           | View / Edit   | Create / Edit¹      | Create / Edit²       | Full Access            | --          | View            |
| **Student History / Notes**      | Create / Edit | Create / Edit¹      | Create / Edit²       | Full Access            | --          | --              |
| **Program Transitions**          | --            | --                  | Request²             | **Approve / Move**     | --          | --              |
| **Drop / Complete Student**      | --            | Request¹³          | Request²             | **Approve / Move**     | --          | --              |
| **▸ Sponsorship**                |               |                      |                      |                        |             |                 |
| **Sponsors**                     | Create / Edit | View¹               | View²                | Full Access            | --          | --              |
| **Sponsorships**                 | Create / Edit | View¹               | View²                | Full Access            | --          | --              |
| **▸ Financial**                  |               |                      |                      |                        |             |                 |
| **Sponsorship Income (USD)**     | Create / Edit | View¹               | View²                | Full Access            | --          | View (Personal) |
| **Payouts**                      | View          | Create / Edit¹      | Create / Edit²       | Full Access            | --          | --              |
| **Program Funding**              | --            | View¹               | Create / Edit²       | Full Access            | --          | --              |
| **Higher Ed Loan Program**       | Create / Edit | --                  | Create / Edit²       | Full Access            | --          | --              |
| **Exchange Rates (Monthly BDT→USD)** | View / Edit | View              | View²                | Full Access            | --          | --              |
| **Financial Audit Logs**         | View          | View¹               | View²                | View                   | Full Access | --              |
| **▸ Documents & Communications** |               |                      |                      |                        |             |                 |
| **Documents**                    | Create / Edit | Create / Edit¹      | Create / Edit²       | Full Access            | --          | View            |
| **Communication Templates**      | --            | --                  | --                   | Manage / Edit          | Full Access | --              |
| **Broadcast**                    | Create / Send | --                  | --                   | Full Access            | --          | View            |
| Thank You Letters                | Create / Edit | Create / Edit¹      | Create / Edit²       | Full Access            | --          | View / Download |
| Annual Progress Report (APR)     | Draft         | Draft / Edit¹       | Draft / Edit²        | **Approve / Sign-off** | --          | View / Download |
| Case History                     | Draft         | Draft / Edit¹       | Draft / Edit²        | **Approve / Sign-off** | --          | View / Download |
| General Letter             | Create / Edit | Create / Edit¹      | Create / Edit²       | Full Access            | --          | View / Download |
| **▸ Reference & System**         |               |                      |                      |                        |             |                 |
| **Teachers**                     | View          | Create / Edit¹      | Create / Edit²       | Full Access            | --          | --              |
| **Facilities Registry**          | --            | --                  | --                   | --                     | Full Access | --              |
| **Site & User Registry**         | --            | --                  | --                   | --                     | Full Access | --              |
| **Invitations**                  | --            | --                  | --                   | Full Access            | Full Access | --              |
| **Data Migration Staging**       | --            | --                  | --                   | --                     | Full Access | --              |
| **System Health & Backups**      | --            | --                  | --                   | --                     | Full Access | --              |

---

## 2. Access Level Definitions

*   **Full Access:** Can Create, Read, Update, and Delete/Archive records within that module.
*   **Create / Edit:** Can add new records and modify existing ones, but cannot Archive or Hard Delete.
*   **View / Download:** Read-only access to information and ability to export documents.
*   **Draft:** Can create and save content but cannot mark it as "Official" or "Sent."
*   **Approve / Sign-off:** High-level approval role. Content is hidden from the public/sponsor until this role approves it.
*   **Manage:** Ability to update system-wide shared assets like Letter Templates.
*   **-- (Dash):** No access allowed; module is hidden from the user's sidebar.

> **¹ School Coordinator:** Scoped to a single `village_sector` within the VLG program. Can only see and act on data for their assigned school. Assignment is managed via the `user_programs` junction table with a `village_sector_id`.
>
> **² Program Coordinator:** Scoped to the specific program(s) assigned via `user_programs`. Sees all data within their assigned program(s). Data outside their programs is invisible.
>
> **³ Drop / Complete:** School Coordinator's request is reviewed by the Program Coordinator before reaching the Director for approval.

---

## 3. Role Summary

- **Admin:** System owner. Manages user accounts, system configuration, data migration, backups. Technical authority — does not handle operational student or financial data.
- **Director:** Highest operational authority. Final approver for documents, student status changes, and financial sign-off. Oversees all programs and staff.
- **Program Coordinator:** Day-to-day operator assigned to specific program(s). Manages student lifecycle, academic records, attendance, and financial entries within their program scope. Cannot approve or archive. Oversees School Coordinators within their program.
- **School Coordinator:** Day-to-day operator assigned to a single school within the VLG program. Manages student lifecycle, academic records, attendance, and financial entries at their specific school. Reports to the Program Coordinator. Cannot approve, archive, or initiate program transitions.
- **Secretary:** Administrative support. Handles data entry, letter drafting, record updates, and logging financial transactions (donations, payouts).
- **Sponsor:** External stakeholder. Read-only access to their sponsored child's information and documents. Can browse unsponsored children (redacted).

---
*Last Updated: 2026-06-09 | Part of the Bangla Hope SMS Technical Blueprint*
