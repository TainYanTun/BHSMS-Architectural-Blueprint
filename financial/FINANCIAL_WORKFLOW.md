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
| `contributions` | **Flexible Gift Log**| `received_date`, `amount`, `purpose`, `payment_method`, `reference_number` |

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
| `loan_transactions` | **Repayment / Waiver / Adjustment Ledger** | `amount` (always positive — reduces debt, in BDT), `type` (repayment/waiver/adjustment), `date` |

### Logic
- **Single Source of Truth:** Loan debt is tracked by the sum of disbursed payouts linked to a repayable `payment_category` (`is_repayable = true`), while repayments, waivers, and adjustments are recorded in `loan_transactions`.
- **Debt Creation (+):** When Bangla Hope pays for student expenses, a payout is recorded with a `payment_category` having `is_repayable = true` and linked via `loan_id`. This increases the student's debt.
- **The Balance:** Outstanding Debt = `SUM(payouts where payment_category.is_repayable = true and status = 'Paid')` - `SUM(loan_transactions.amount)` (all types: repayments + waivers + adjustments). All amounts are recorded in BDT.

---

## 3. Internal Support (Direct Payouts)

Used for programs that do not require repayment (Boarding Schools, Subsidies, Pocket Money).

### Tables
| Table | Role | Key Fields |
| :--- | :--- | :--- |
| `payouts` | **Per-Student Payout Log** | `contribution_id`, `student_id`, `payment_category_id`, `subsidy_purpose`, `receipts_verified`, `amount` (BDT), `payout_date`, optional `loan_id` |

### Logic
- **Direct Link:** Each payout draws directly from a `contribution` via `contribution_id`. The student's `current_program_id` determines the program context for filtering payment categories.
- **Payout Overdraft:** A trigger enforces `SUM(payouts.amount) ≤ contribution.amount` at the contribution level.
- **Loan Consistency:** A trigger enforces that repayable payment categories require a `loan_id`; non-repayable categories reject one.

---

## 4. Key Business Logic & Controls

### Currency Handling
- **Single Currency:** All financial tracking—including Income (Contributions), Spending (Payouts), and Recoveries (Loans)—is conducted strictly in **BDT (৳)**.
- **Rationale:** Bangla Hope receives funds pre-converted to BDT from the sponsor's US office. There is no need for dual-currency tracking or exchange rate management within the system.

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
