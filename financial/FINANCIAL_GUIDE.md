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
*   **`sponsorships` (Relationship Registry):** Defines the connection between a sponsor and a student for status tracking and portal visibility.
*   **`contributions` (Flexible Gift Log):** Manually entered records acknowledging that funds have arrived. These can be linked to a specific sponsorship agreement or recorded as direct one-time student gifts. Each record includes the payment method and reference number for tracking.

### Financial Logic
1.  **Registry Entry:** Admin records the sponsorship link for relationship management.
2.  **Recording Gifts:** When a contribution is confirmed (via bank statement or check), staff manually "keys in" the record. This can fulfill a monthly commitment or be a flexible, one-time donation.
3.  **Recency Analysis:** The system monitors the date of the most recent gift. If no support is recorded within **6 months**, the student is flagged as "Action Required" on the master registry.

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

*   **`program_funding` (Program Allocation):** Records that a contribution has been allocated to fund a program (e.g., BDT 420,000 yearly subsidy for VLG).
*   **`payouts` (Per-Student):** Records every individual payout to a student — whether from a direct contribution or a program funding pool. Because these are gifts, they do not create debt.

---

## 3. Governance, Integrity, & Audit

### Currency Handling
To maintain strict ledger integrity while supporting accurate local accounting, the system applies these rules:
*   **Income (Sponsorship Contributions):** Tracked strictly in **USD ($)** — the currency used by international sponsors.
*   **Expenditure (Payouts):** Recorded with dual currency — the actual **BDT** amount disbursed and its **USD equivalent** calculated using a standard monthly exchange rate.
*   **Exchange Rates:** A monthly `exchange_rates` table stores the BDT→USD rate for each month. Rates are auto-fetched daily by a Laravel scheduled command (`php artisan exchange-rates:fetch`). Each successful fetch **UPSERTs** the row for the current month — if a row exists, the `rate` and `last_fetched_at` are updated; if not, a new row is created. This means each payout uses the most recent rate available, and the rate can change within the month if the market moves.
*   **Fallback Behavior:** If the API fails, the cron retries the next day. The existing row (from the last successful fetch) remains in place — the Coordinator always has a rate to use. Only if no row exists at all (e.g., API has been down since month start) does the system block with "Rate unavailable — contact IT".
*   **Manual Override:** If the auto-fetched rate is incorrect (e.g., outdated FX market rate vs Bangladesh Bank official rate), a Secretary or Director can edit the rate directly. The `auto_fetched` flag is set to `false` to indicate manual intervention. Overrides are logged in the audit trail.
*   **Local Accuracy:** Each `payout` stores `local_amount`, `local_currency` (BDT), `exchange_rate`, and `amount` (USD equivalent). This preserves accurate local accounting while enabling sponsor-facing USD reports.

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
| **Expenditure** | Payouts (Per-Student) | **BDT / USD ($)** | Dual-currency (monthly exchange rate) |
| **Allocation** | Program Funding | **USD ($)** | Allocates contribution amount to a program |
| **Reference** | Exchange Rates | **BDT → USD** | Auto-fetched daily (cron), UPSERTs current-month row |

---
*Last Updated: 2026-06-09 | Part of the Bangla Hope SMS Technical Blueprint*
