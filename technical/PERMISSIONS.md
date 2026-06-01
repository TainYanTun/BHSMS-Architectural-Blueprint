# Role-Based Access Control (RBAC) Permission Matrix

This document defines the system-wide permissions for each user role within the Bangla Hope Sponsorship Management System.

## 1. Permission Matrix

| Module / Action | Secretary | Coordinator | Supervisor | Admin | Sponsor |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Student Master Records** | View / Edit | View / Edit | Create / Edit | Full Access | View (Limited) |
| **Academic & Results** | Edit | Full Access | Full Access | Full Access | View |
| **Attendance Records** | Edit | Full Access | Full Access | Full Access | View |
| **Sponsorship Income (USD)** | View | Create / Edit | Full Access | Full Access | View (Personal) |
| **Student Subsidies (USD)** | View | Create / Edit | Full Access | Full Access | -- |
| **Higher Ed Loan Program** | -- | Create / Edit | Full Access | Full Access | -- |
| **Financial Audit Logs** | -- | View | View | Full Access | -- |
| **Communication Templates** | -- | -- | Manage / Edit | Full Access | -- |
| Thank You Letters / APR | Draft | Draft / Edit | **Approve / Sign-off** | Full Access | View / Download |
| **Archive / Drop Student** | -- | Request | **Approve / Move** | Full Access | -- |
| **Site & User Registry** | -- | -- | -- | Full Access | -- |
| **Data Migration Staging** | -- | -- | -- | Full Access | -- |
| **System Health & Backups** | -- | -- | -- | Full Access | -- |

---

## 2. Access Level Definitions

*   **Full Access:** Can Create, Read, Update, and Delete/Archive records within that module.
*   **Create / Edit:** Can add new records and modify existing ones, but cannot Archive or Hard Delete.
*   **View / Download:** Read-only access to information and ability to export documents.
*   **Draft:** Can create and save content but cannot mark it as "Official" or "Sent."
*   **Approve / Sign-off:** High-level approval role. Content is hidden from the public/sponsor until this role approves it.
*   **Manage:** Ability to update system-wide shared assets like Letter Templates.
*   **-- (Dash):** No access allowed; module is hidden from the user's sidebar.

---

## 3. Role Summary

- **Admin:** System owner with override powers and account management.
- **Supervisor:** Quality control and compliance officer; final gatekeeper for official documents and student status changes.
- **Coordinator:** Primary program operator; manages student lifecycle and daily financial entries.
- **Secretary:** Administrative support; handles general data entry and letter drafting.
- **Sponsor:** External stakeholder; restricted view of supported student(s) only.

---
*Last Updated: 2026-05-27 | Part of the Bangla Hope SMS Technical Blueprint*
