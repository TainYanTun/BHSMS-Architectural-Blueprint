# Financial System Architecture & Workflow

This document serves as the comprehensive guide to the Bangla Hope Sponsorship Management System (SMS) financial components.

## Core Philosophy: The Manual Digital Ledger
The Bangla Hope SMS is designed as a **Manual Digital Ledger**. 
*   **Purpose:** Record-keeping, tracking commitments, and student accountability.
*   **Limitation:** It is **not** a banking interface or payment gateway. It does not perform live bank transfers. All data must be verified and entered by authorized staff.

---

## 1. Income Tracking: Sponsorships
This module tracks the financial commitments made by sponsors and the acknowledgment of funds.

### Key Components
*   **`sponsorships` (The Agreement):** Defines the expected monthly support, currency (USD/BDT), and sponsorship type (Primary or Co-sponsor).
*   **`sponsorship_receipts` (Record of Arrival):** Manually entered records acknowledging that funds have arrived (via bank or check). 

### Financial Logic
1.  **Commitment Record:** Admin adds a record of the intended monthly support.
2.  **Recording Arrival:** Once a payment is confirmed via an external bank statement or physical check, staff manually "keys in" the record to acknowledge the funds have arrived.
3.  **Gap Analysis:** The system compares "Agreement" vs "Recorded Arrivals" to highlight overdue payments, which in turn triggers automated reminders or flags the sponsorship status.

---

## 2. Expenditure Tracking: Education Support
We separate support into two categories: **Repayable Loans** and **Non-Repayable Grants**.

### A. Higher Education Loan Program (Repayable)
Designed to assist students through university via a revolving fund model.

*   **`loans` (The Account):** Tracks the total owed, status (Studying/Refunding), and the student's graduation progress.
*   **`loan_disbursements` (The Outflow):** Records individual payments for tuition, books, or hostel costs. These increase the loan balance.
*   **`loan_refunds` (The Inflow):** Records payments made by graduates back to the organization. These decrease the outstanding loan balance.

### B. Internal Support/Subsidies (Non-Repayable)
For ongoing assistance (e.g., boarding school fees, pocket money, staff child aid).

*   **`financial_allocations` (The Grant):** Records fixed, non-repayable amounts allocated to a student. Because these are gifts, they do not create debt and are strictly separated from the loan ledger.

---

## 3. Governance, Integrity, & Audit

### Currency Handling
To maintain strict ledger integrity, the system applies these rules:
*   **Sponsorship Income:** Tracked strictly in **USD** for reporting consistency.
*   **Local Operations:** Disbursement and internal allocations support **USD** and **BDT** depending on the regional context of the expense.
*   **Integrity:** Reporting tools automatically distinguish between these currencies to prevent ledger errors.

### The Audit Trail (`audit_logs`)
The system follows a policy of **non-deletion**. Financial records must never be deleted. 
*   **Audit Logging:** Every single `INSERT`, `UPDATE`, or `DELETE` attempt on financial data is logged with the user ID, timestamp, and a JSON snapshot of the mutation.
*   **Accountability:** If a record is wrong, it is "corrected" by adding a new record that offsets the previous one, maintaining a perfect history of the correction for future audits.

---

## 4. Summary Table

| Category | Component | Repayable? | Tracking Method |
| :--- | :--- | :--- | :--- |
| **Income** | Sponsorships | N/A | Agreement vs. Receipt |
| **Expenditure** | Higher Education | Yes | Disbursements vs. Refunds |
| **Expenditure** | Subsidies/Grants | No | Fixed Allocation Entries |

---
*Created: 2026-05-27 | Part of the Bangla Hope SMS Technical Blueprint*
