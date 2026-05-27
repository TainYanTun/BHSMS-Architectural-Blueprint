# Financial System Architecture & Workflow

This document serves as the comprehensive guide to the Bangla Hope Sponsorship Management System (SMS) financial components.

## Core Philosophy: The Manual Digital Ledger
The Bangla Hope SMS is designed as a **Manual Digital Ledger**. 
*   **Purpose:** Record-keeping, tracking commitments, and student accountability.
*   **Limitation:** It is **not** a banking interface or payment gateway. It does not perform live bank transfers. All data must be verified and entered by authorized staff.

---

## 1. Income Tracking: Sponsorships
This module tracks the sponsorship relationships and the acknowledgment of individual donor contributions.

### Key Components
*   **`sponsorships` (The Relationship):** Defines the active connection between a sponsor and a student.
*   **`sponsorship_receipts` (Record of Support):** Manually entered records acknowledging that funds have arrived. Each receipt includes the payment method and reference number for tracking.

### Financial Logic
1.  **Relationship Record:** Admin records the sponsorship link.
2.  **Recording Support:** When a contribution is confirmed (via bank statement or check), staff manually "keys in" the record for the specific student supported.
3.  **Recency Analysis:** The system monitors the date of the most recent receipt. If no support is recorded within **6 months**, the student is flagged as "Action Required" on the master registry.

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
To maintain strict ledger integrity and simplify reporting, the system applies these rules:
*   **Unified Tracking:** All financial components—including Sponsorship Income, Subsidies, and Loans—are tracked strictly in **USD ($)**.
*   **Integrity:** By using a single currency for the digital ledger, the system avoids exchange rate volatility in its internal reporting. Any local BDT payments are converted to USD at the time of entry based on the organization's monthly standard rate.

### The Audit Trail (`audit_logs`)
The system follows a policy of **non-deletion**. Financial records must never be deleted. 
*   **Audit Logging:** Every single `INSERT`, `UPDATE`, or `DELETE` attempt on financial data is logged with the user ID, timestamp, and a JSON snapshot of the mutation.
*   **Accountability:** If a record is wrong, it is "corrected" by adding a new record that offsets the previous one, maintaining a perfect history of the correction for future audits.

---

## 4. Summary Table

| Category | Component | Currency | Tracking Method |
| :--- | :--- | :--- | :--- |
| **Income** | Sponsorships | **USD ($)** | Recency of Support |
| **Expenditure** | Higher Education | **USD ($)** | Disbursements vs. Refunds |
| **Expenditure** | Subsidies/Grants | **USD ($)** | Fixed Allocation Entries |

---
*Created: 2026-05-27 | Part of the Bangla Hope SMS Technical Blueprint*
