# Bangla Hope SMS - Database Table Guide

This guide provides a simple, plain-English breakdown of what every single table in the Entity Relationship Diagram (ERD) does within the system.

---

## 1. Reference & Infrastructure (The Setup)
* **`SITES`**: Stores the different office locations (like the central office or remote field offices) and tracks when they last synced their data.
* **`PROGRAMS`**: The different sponsorship programs available (e.g., "Primary School Support", "Higher Education").
* **`INSTITUTIONS`**: The schools, colleges, or universities that the students attend.

## 2. User & Security (The Staff)
* **`USERS`**: The system login accounts for staff members, tracking their names, roles, emails, and passwords.
* **`PERMISSIONS`**: A master list of specific actions a user is allowed to do in the system (e.g., "Approve Loans", "Edit Student Data").
* **`ROLE_PERMISSIONS`**: Links roles to permissions (e.g., deciding that an "Accountant" role gets the permission to "Record Payouts").
* **`AUDIT_LOGS`**: A digital paper trail. It automatically logs exactly who changed what data, when, and from what computer.

## 3. Student Core (The Children)
* **`STUDENTS`**: The main profiles of the children. It holds their personal info like names, birthdays, religion, parents' names, photos, and general life situation.
* **`STUDENT_IDENTIFIERS`**: Stores the student ID cards or numbers. Since a student might get a new ID number if they change programs, this tracks their history of IDs.
* **`DOCUMENTS`**: A digital filing cabinet for uploading birth certificates, report cards, or scanned documents.
* **`MIGRATION_METADATA`**: A backstage tracking table used only when moving old data from a previous computer system into this new one.
* **`MIGRATION_STAGING_STUDENTS`**: A temporary holding area used to double-check old student data for errors before officially saving it.

## 4. Sponsorship System (The Donors)
* **`SPONSORS`**: Profiles of the donors, keeping track of their contact info, address, and how they prefer to be contacted.
* **`SPONSORSHIPS`**: Links a specific donor to a specific student, showing when the sponsorship started and if it is currently active.
* **`CONTRIBUTIONS`**: The donation ledger. It records every time a donor sends money, the amount in BDT, and what month/year the payment is for.

## 5. Records & History (School & Life Tracking)
* **`ACADEMIC_RECORDS`**: Tracks how well a student did in school each year, their final grades, and which school they went to.
* **`ATTENDANCE_RECORDS`**: Tracks how many days a student actually showed up to school out of the total school days in a year.
* **`REPORTS`**: Annual or terminal progress reports about the student that need to be approved by managers before being sent to sponsors.
* **`STUDENT_HISTORY`**: A timeline of major life events or milestones for the student (e.g., "Moved to a new home", "Won an award").

## 6. Financial Subsidies (Regular Allowances)
* **`PAYOUTS`**: Records the exact date and amount whenever a staff member hands over cash or supplies to a specific student — funded directly from a contribution.

## 7. Loan System (Higher Education Funding)
* **`LOANS`**: Tracks higher education funding for older students. **This is structural funding that the student must pay back later.**
* **`LOAN_DISBURSEMENTS`**: Tracks the money the organization sends directly to the university or student to pay for tuition, books, or fees.
* **`LOAN_REFUNDS`**: Records the payback payments made by the student back to the organization after they graduate and start working.

## 8. Communications & Logistics (Mails & Sync)
* **`COMMUNICATION_TEMPLATES`**: Pre-written drafts for emails or letters (like a standard "Thank you for your donation" template).
* **`COMMUNICATIONS`**: Tracks every message, letter, or PDF report sent between a student and a sponsor.
* **`EMAIL_OUTBOX`**: A waiting line for emails that are scheduled to be sent out automatically by the system.
* **`SMTP_LOGS`**: Technical logs showing whether the email server successfully sent an email or if it failed.
* **`SYSTEM_HEALTH_LOGS`**: A backend dashboard monitor that checks if the overall software system is running smoothly or experiencing errors.
* **`SYNC_CONFLICTS`**: If a remote field office edits a student's file while offline, and the central office edits the same file at the same time, this table flags the conflict so an administrator can choose the correct data.
