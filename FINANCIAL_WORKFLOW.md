# Financial Workflow Specification

This document outlines the logic and structure of the financial tracking system in the Bangla Hope SMS. 

> [!IMPORTANT]
> **STORAGE-ONLY ARCHITECTURE:** This system is designed strictly as a **Manual Digital Ledger** for record-keeping and storage purposes. It **does not** perform real-world financial transactions, payment gateway integrations, or bank transfers. All financial data (receipts, disbursements) must be manually verified and entered by authorized personnel.

---

## 1. Sponsorship System (Income Tracking)

Tracks the commitments made by sponsors and the fulfillment of those commitments.

### Tables
| Table | Role | Key Fields |
| :--- | :--- | :--- |
| `sponsorships` | **Agreement** | `monthly_amount`, `currency` (USD/BDT), `type` (Primary/Co-Sponsor) |
| `sponsorship_receipts` | **Fulfillment** | `received_date`, `period_month`, `period_year`, `amount` |

### Logic
- **Commitment:** Admins record the expected monthly support from a sponsor.
- **Verification:** When a payment is manually confirmed, a record is added to `sponsorship_receipts`.
- **Reporting:** Comparing `sponsorships` vs `sponsorship_receipts` identifies missing payments and triggers "Thank You Letter" reminders.

---

## 2. Higher Education Loan Program (Education Tracking)

Supports students in higher education via a "Spend now, Refund later" model.

### Tables
| Table | Role | Key Fields |
| :--- | :--- | :--- |
| `loans` | **Header** | `total_amount`, `refunded_amount`, `status`, `currency` |
| `loan_disbursements` | **Spending** | `category` (Tuition/Books/Hostel), `amount`, `date` |
| `loan_refunds` | **Recovery** | `amount`, `refund_date`, `recorded_by` |

### Logic
- **Accumulation:** As Bangla Hope pays for student expenses, each payment is logged in `loan_disbursements`. The `loans.total_amount` is the sum of these entries.
- **Recovery Phase:** Once a student graduates and begins working, they pay back the organization. Each entry is logged in `loan_refunds`.
- **Balance:** `Outstanding = total_amount - refunded_amount`.

---

## 3. Internal Support (Subsidies & Pocket Money)

Used for programs that do not require repayment (Boarding Schools, Staff Children).

### Tables
| Table | Role | Key Fields |
| :--- | :--- | :--- |
| `financial_allocations` | **Grant** | `type` (Subsidy/Pocket Money), `frequency`, `amount` |

### Logic
- **Recurring Costs:** Tracks ongoing internal financial commitments for specific students.
- **Separation:** Keeps "Grants" separate from "Loans" to ensure they are never incorrectly flagged for refunding.

---

## 4. Key Business Logic & Validations

### Currency Handling
- **Sponsorships:** All income tracking (Sponsorships and Receipts) is conducted strictly in **USD**.
- **Local Operations:** Loan disbursements and internal allocations may support **BDT** where applicable for local tracking.
- **Reporting:** Reports should clearly indicate the currency to maintain ledger integrity.

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
