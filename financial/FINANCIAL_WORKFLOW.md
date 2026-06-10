# Financial Workflow Specification

This document outlines the logic and structure of the financial tracking system in the Bangla Hope SMS. 

> [!IMPORTANT]
> **STORAGE-ONLY ARCHITECTURE:** This system is designed strictly as a **Manual Digital Ledger** for record-keeping and storage purposes. It **does not** perform real-world financial transactions, payment gateway integrations, or bank transfers. All financial data (receipts, disbursements) must be manually verified and entered by authorized personnel.

---

## 1. Sponsorship System (Income Tracking)

Tracks the sponsorship relationships and the individual contribution receipts.

### Tables
| Table | Role | Key Fields |
| :--- | :--- | :--- |
| `sponsorships` | **Relationship Registry** | `type` (Primary/Co-Sponsor), `start_date`, `is_active` |
| `contributions` | **Flexible Gift Log**| `received_date`, `amount`, `payment_method`, `reference_number` |

### Logic
- **Relationship Registry:** Admins record the fact that a sponsor is supporting a student. This is used for status tracking and portal visibility.
- **Verification:** When a gift is manually confirmed, a record is added to `contributions`. It can be linked to a specific `sponsorship` agreement, or directly to a `student` (for one-time gifts), or left as a general donation.
- **Reporting:** Sponsorship health is tracked by **Recency of Support** (contributions within the last 6 months). The rigid monthly "subscription" model is replaced by a flexible gift history.

---

## 2. Higher Education Loan Program (Simple Loan 2.0)

Supports students in higher education via a **Unified Ledger** model. It tracks debt and recovery in a single stream.

### Tables
| Table | Role | Key Fields |
| :--- | :--- | :--- |
| `loans` | **Agreement Record** | `status` (Studying/Refunding/Complete), `agreement_url` |
| `loan_transactions` | **The Unified Ledger** | `amount` (+ for debt, - for repayment), `type`, `date` |

### Logic
- **Single Source of Truth:** Every penny moving in or out is recorded in `loan_transactions`. 
- **Debt Creation (+):** When Bangla Hope pays for student expenses, a **Positive** amount is logged (Type: 'Disbursement'). This increases the student's debt.
- **Debt Recovery (-):** When a repayment is received (Sponsor/Student sends money), a **Negative** amount is logged (Type: 'Repayment'). 
- **The Balance:** Outstanding Debt = `SUM(amount)` of all transactions for that loan.

---

## 3. Internal Support (Direct Payouts)

Used for programs that do not require repayment (Boarding Schools, Subsidies, Pocket Money).

### Tables
| Table | Role | Key Fields |
| :--- | :--- | :--- |
| `program_funding` | **Program Allocation Log** | `contribution_id`, `program_id`, `amount`, `period` |
| `payouts` | **Per-Student Payout Log** | `student_id`, `amount`, `payout_date`, source via `contribution_id` or `program_funding_id` |

### Logic
- **Direct Recording:** Instead of complex budgeting rules, admins simply record the actual payout when it occurs.
- **The "Jar" Principle:** For sponsored students, these payouts "draw" from the student's available balance in the `contributions` table.
- **Separation:** Keeps "Gifts" (Payouts) separate from "Debt" (Loans) to ensure they are never incorrectly flagged for repayment.

---

## 4. Key Business Logic & Controls

### Currency Handling
- **Unified Currency:** All financial tracking—including Income (Sponsorships), Spending (Subsidies/Grants), and Recoveries (Loans)—is conducted strictly in **USD ($)**.
- **Reporting:** Using a single currency simplifies the ledger and provides a clear, high-integrity overview for management. Local BDT costs are converted to USD at the point of entry based on monthly standard rates.

### Security & Integrity
- **Audit Logs:** Every financial modification (Add/Edit/Delete) is captured in `audit_logs` with a timestamp and the user ID of the admin.
- **Immutability:** Financial records should generally not be deleted; instead, mistakes should be corrected with "Adjustment" entries or documented in notes.

---

## ⚠️ Pending Client Clarification

**Loan Status Transition:** 
- **Requirement:** Clarify if `loans.status` should automatically change from `Studying` to `Refunding` based on a "Graduation Date," or if it must be a manual administrative action.
- **Current State:** Implemented as a manual action to prevent premature billing.

---
*Created: 2026-05-26 | Part of the Bangla Hope SMS Technical Blueprint*
