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

## 3. Sponsorship Currency Handling
**Context:** The system now supports both **USD** and **BDT**.

- **Question:** For international sponsors paying in USD, does the client need to see the conversion to BDT in reports, or should the ledger remain purely in the currency it was received?
- **Implication:** If conversion is needed, we may need to track exchange rates or add a "Value in BDT" field to receipt records.

---

## 4. Archive vs. Transfer Logic
**Context:** Students often move between programs (e.g., LRC to Higher Ed Loan).

- **Question:** When a student transfers, should their old Program ID (e.g., #LRC-123) be "Locked" for editing, or should it remain fully accessible alongside the new Program ID?
- **Current Plan:** Records are linked via a Universal UUID (Master ID), keeping the history accessible but marking the old ID as "Transferred/Archived."

---
*Last Updated: 2026-05-26*
