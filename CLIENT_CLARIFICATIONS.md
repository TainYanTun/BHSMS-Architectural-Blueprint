# Client Clarifications & Business Logic Decisions

This document tracks pending questions and strategic decisions that need to be finalized with the client to ensure the system logic matches their operational needs.

---

## 1. Financial Tracking Depth (Lower Education)
**Context:** For programs like Boarding Schools and Staff Children, the system tracks "Pocket Money" and "Subsidies" (non-repayable).

- **Question:** Does the client want to track the **"Policy"** (how much the student *should* get per month) or the **"Payout History"** (a record of every time they *actually received* the money)?
- **Current implementation:** The `financial_allocations` table can support both, but the workflow needs to be defined (e.g., does an admin "Post" a payment every month?).

---

## 2. Loan Status Automation (Higher Education)
**Context:** Students move from "Studying" to "Refunding" status once they complete their course.

- **Question:** Should the `loans.status` automatically flip from **'Studying'** to **'Refunding'** once a "Target Graduation Date" passes, or should this remain a manual administrative action?
- **Implication:** Automation prevents forgetting to start the refund process, but manual control allows for cases where students extend their studies or face delays.

---

## 3. Sponsorship Currency & Tracking Mandate (Standardized)
**Context:** The system has been standardized to use **USD ($)** for all financial tracking to simplify initial implementation.

- **Status:** All Income (Sponsorships), Spending (Subsidies), and Recoveries (Loans) are recorded in USD.
- **Clarification Needed:** Does the client agree with this "USD-first" approach for all internal ledgering, or are there specific local reports that *must* remain in BDT?

---

## 4. Archive vs. Transfer Logic
**Context:** Students often move between programs (e.g., LRC to Higher Ed Loan).

- **Question:** When a student transfers, should their old Program ID (e.g., #LRC-123) be "Locked" for editing, or should it remain fully accessible alongside the new Program ID?
- **Current Plan:** Records are linked via a Universal UUID (Master ID), keeping the history accessible but marking the old ID as "Transferred/Archived."

---

## 5. Mandatory Supervisor Validation
**Context:** All documents sent to or viewed by sponsors (Case Study, ARP, Thank You Letters).

- **Rule:** No document can be "Published" or "Sent" without a digital sign-off from a **Supervisor** or **SPD**.
- **Impact:** Case Studies for "Needy Students" will only appear in the Sponsor Portal once they transition from `Draft` to `Validated`.

---

## 6. Sponsor Portal: "Needy Students" Visibility
**Context:** Potential sponsors browsing for children to support.

- **Logic:** The "Sponsor Portal" is a read-only view of the student database, filtered for students who are **Active** and have **no Primary Sponsor**.
- **Requirement:** The portal will display the **Validated Case Study** as the primary narrative to encourage sponsorship.
- **Privacy:** Sensitive fields (e.g., exact village location or full guardian contact info) will be redacted in the public-facing portal.

---

## 7. Audit Integrity & "Truthful Ledger" Schema (Simplified)
**Context:** Standardizing on USD simplifies the "Truthful Ledger" by removing exchange rate variables from the comparison.

- **Status:** The system now compares **USD Income** vs. **USD Support Value** directly.
- **Clarification Needed:** Is a direct USD comparison sufficient for the client's internal audit requirements, or do they still need to see the BDT conversion for local transparency?

---
*Last Updated: 2026-05-27*
