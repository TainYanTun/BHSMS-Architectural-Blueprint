# Role-Based Access Control (RBAC) Permission Matrix

This document defines the system-wide permissions for each user role within the Bangla Hope Sponsorship Management System.

## 1. Permission Matrix

| Module / Action                  | Secretary     | School Coordinator¹ | Program Coordinator² | HQ Staff   | Director               | Admin       | Sponsor         |
| :---------------------------------| :-------------:| :-------------------:| :--------------------:| :----------:| :----------------------:| :-----------:| :---------------:|
| **▸ Student Lifecycle**          |               |                      |                      |            |                        |             |                 |
| **Student Master Records**       | Full Access   | View / Edit¹        | Full Access²         | --         | Full Access            | --          | View (Limited)  |
| **Academic & Results**           | View / Edit   | Create / Edit¹      | Create / Edit²       | --         | Full Access            | --          | View            |
| **Attendance Records**           | View / Edit   | Create / Edit¹      | Create / Edit²       | --         | Full Access            | --          | View            |
| **Student History / Notes**      | Create / Edit | Create / Edit¹      | Create / Edit²       | --         | Full Access            | --          | --              |
| **Program Transitions**          | Request       | --                  | Request²                 | --         | **Approve / Move**     | --          | --              |
| **Drop / Complete Student**      | Request            | Request¹          | Request²                    | --         | **Approve / Move**     | --          | --              |
| **▸ Sponsorship**                |               |                      |                      |            |                        |             |                 |
| **Sponsors**                     | Create / Edit | View¹               | View                 | View       | Full Access            | --          | --              |
| **Sponsorships**                 | Create / Edit | View¹               | View                 | View       | Full Access            | --          | --              |
| **▸ Financial**                  |               |                      |                      |            |                        |             |                 |
| **Sponsorship Income (BDT)**     | Create / Edit | --                  | View                 | View       | Full Access            | --          | View (Personal) |
| **Payouts**                      | Create / Edit | --                  | Create / Edit²       | --         | Full Access            | --          | --              |
| **Higher Ed Loan Program**       | Create / Edit | --                  | --                   | --         | Full Access            | --          | --              |
| ~~Exchange Rates~~                     | (Removed)   | --                | --                   | --         | --                     | --          | --              |
| **Financial Audit Logs**         | View          | --                  | View                 | View       | View                   | Full Access | --              |
| **▸ Documents & Communications** |               |                      |                      |            |                        |             |                 |
| **Documents**                    | Create / Edit | Create / Edit¹      | Create / Edit²       | --         | Full Access            | --          | View            |
| **Communication Templates**      | --            | --                  | --                   | View       | Manage / Edit          | Full Access | --              |
| **Broadcast**                    | Create / Send | --                  | --                   | --         | Full Access            | --          | View            |
| Thank You Letters                | Create / Edit | --                  | Create / Edit²       | View / Download | Full Access       | --          | View / Download |
| Annual Progress Report (APR)     | Draft         | --                  | Draft / Edit²        | View / Download | **Approve / Sign-off** | --     | View / Download |
| Case History                     | Draft         | --                  | Draft / Edit²        | View / Download | **Approve / Sign-off** | --     | View / Download |
| General Letter                   | Create / Edit | --                  | Create / Edit²       | View / Download | Full Access            | --          | View / Download |
| **▸ Reference & System**         |               |                      |                      |            |                        |             |                 |
| **Teachers**                     | View          | Create / Edit¹      | Create / Edit²       | --         | Full Access            | --          | --              |
| **Facilities Registry**          | --            | --                  | --                   | --         | Full Access                     | Full Access | --              |
| **Site & User Registry**         | --            | --                  | --                   | --         | Full Access                     | Full Access | --              |
| **Invitations**                  | --            | --                  | --                   | --         | Full Access            | Full Access | --              |
| **Data Migration Staging**       | --            | --                  | --                   | --         | --                     | Full Access | --              |
| **System Health & Backups**      | --            | --                  | --                   | --         | --                     | Full Access | --              |

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
> **² Program Coordinator:** Scoped to a program via `user_programs`. Manages student lifecycle, academics, attendance, payouts, and reports within their assigned program. Data outside their scope is invisible.
>
> **³ Drop / Complete:** School Coordinator's request is reviewed before reaching the Director for approval.

---

## 3. Role Summary

- **Admin:** System owner. Manages user accounts, system configuration, data migration, backups. Technical authority — does not handle operational student or financial data.
- **Director:** Highest operational authority. Final approver for documents, student status changes, and financial sign-off. Oversees all programs and staff.
- **Program Coordinator:** Operational manager assigned to a specific program. Handles payouts, reports, and student lifecycle within their program scope.
- **School Coordinator:** Day-to-day operator assigned to a single school within the VLG program. Manages student lifecyle, academic records, attendance, and notes at their specific school. Cannot approve, archive, or initiate program transitions.
- **HQ Staff:** Administrative support at headquarters. Views sponsors, sponsorships, reports, and financial logs. Can access communication templates to send emails to sponsors and staff. No access to student records, financial entries, or broadcast.
- **Secretary:** Administrative support. Handles data entry, letter drafting, record updates, sponsorship creation, contributions, payouts, loan processing, and requesting program transitions.
- **Sponsor:** External stakeholder. Read-only access to their sponsored child's information and documents. Can browse unsponsored children (redacted).

---
*Last Updated: 2026-06-15 | Part of the Bangla Hope SMS Technical Blueprint*
