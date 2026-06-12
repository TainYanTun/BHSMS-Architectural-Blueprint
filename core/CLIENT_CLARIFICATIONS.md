# Client Clarifications & Business Logic Decisions

This document tracks pending questions and strategic decisions that need to be finalized with the client to ensure the system logic matches their operational needs.

---

## 1. Financial Tracking Depth (Lower Education)
**Context:** For programs like Boarding Schools and Staff Children, the system tracks "Pocket Money" and "Subsidies" (non-repayable).

- **Question:** Does the client want to track the **"Policy"** (how much the student *should* get per month) or the **"Payout History"** (a record of every time they *actually received* the money)?
- **Current implementation:** `payouts` records actual disbursements. The workflow needs to be defined (e.g., does an admin "Post" a payment every month?).

---

## 2. Loan Status Automation (Higher Education)
**Context:** Students move from "Studying" to "Refunding" status once they complete their course.

- **Question:** Should the `loans.status` automatically flip from **'Studying'** to **'Refunding'** once a "Target Graduation Date" passes, or should this remain a manual administrative action?
- **Implication:** Automation prevents forgetting to start the refund process, but manual control allows for cases where students extend their studies or face delays.

---

## 3. Sponsorship Currency & Tracking Mandate (Standardized)
**Context:** The system has been standardized to use **USD ($)** for all financial tracking to simplify initial implementation and remove exchange rate variables.

- **Status:** **FINALIZED.** All Income (Sponsorships), Spending (Subsidies), and Recoveries (Loans) are recorded strictly in USD.
- **Decision:** Direct USD comparison is the primary audit method. Local BDT conversions for operational transparency are handled externally.

---

## 4. Archive vs. Transfer Logic
**Context:** Students often move between programs (e.g., LRC to Higher Ed Loan).

- **Question:** When a student transfers, should their old Program ID (e.g., #LRC-123) be "Locked" for editing, or should it remain fully accessible alongside the new Program ID?
- **Current Plan:** Records are linked via a Universal UUID (Master ID), keeping the history accessible but marking the old ID as "Transferred/Archived."

---

## 5. Mandatory Supervisor Approval
**Context:** All documents sent to or viewed by sponsors (Case Study, ARP, Thank You Letters).

- **Rule:** No document can be "Published" or "Sent" without a digital sign-off from a **Supervisor** or **SPD**.
- **Impact:** Case Studies for "Needy Students" will only appear in the Sponsor Portal once they transition from `Draft` to `Approved`.

---

## 6. Sponsor Portal: "Needy Students" Visibility
**Context:** Potential sponsors browsing for children to support.

- **Logic:** The "Sponsor Portal" is a read-only view of the student database, filtered for students who are **Active** and have **no Primary Sponsor**.
- **Requirement:** The portal will display the **Approved Case Study** as the primary narrative to encourage sponsorship.
- **Privacy:** Sensitive fields (e.g., exact village location or full guardian contact info) will be redacted in the public-facing portal.

---

## 7. Audit Integrity & "Truthful Ledger" Schema (Standardized)
**Context:** Standardizing on USD simplifies the "Truthful Ledger" by removing exchange rate variables from the comparison.

- **Status:** **FINALIZED.** The system now compares **USD Income** vs. **USD Support Value** directly.
- Decision: A direct USD comparison is sufficient for the internal audit requirements.

---

## 8. Currency Standardization (Revised — BDT Only)

**Context:** The system was initially designed with dual-currency support (contributions in USD, payouts in BDT+USD with exchange rates).

- **Decision (June 2026):** The system is now **BDT-only**. All financial records (contributions, payouts, loan transactions) use Bangladeshi Taka (৳) exclusively.
- **Rationale:** The sponsor has a US office that handles USD conversion. Bangla Hope receives and operates entirely in BDT. No exchange rate tracking or dual-currency logic is required.
- **Changes:** Removed `exchange_rates` table. Removed `local_amount`, `exchange_rate` columns from `payouts` and `loan_transactions`.

---

## 9. Report Workflow & Delivery

**Context:** The system was designed with automated report delivery to sponsors via email.

- **Decision (June 2026):** Reports follow the internal workflow (Draft → Pending → Approved → Complete) for governance but are **not automatically sent** to sponsors or the US office. Staff generate PDF reports and email them manually outside the system.
- **US Office Reporting:** Staff present reports to the US office via manual PDF export and external email. No automated report push.
- **Sponsor Communications:** The `communications` module is retained for **broadcast messages** (organizational announcements, updates about Bangla Hope) but not for student-specific report delivery.

---

## 10. Communication & Letter Workflow
**Context:** The system generates student-to-sponsor documents including Thank You letters (financial triggers), Birthday greetings (milestones), and APRs.

- **Question A (Frequency):** When a sponsor pays monthly (Subsidy), should the system trigger a unique "Thank You" task **every month** (12/year), or should these be **consolidated** into a quarterly or bi-annual update?
- **Question B (Approval Tiers):** Should standard monthly "Thank You" notes require **Supervisor approval** before sending, or can they be sent immediately by the **Secretary** using a verified template? (Note: APRs and Case Histories always require approval).
- **Question C (Format):** Should all communications (including simple birthday greetings) be generated as **Official PDF documents** with the child's photo and saved to their permanent record, or should some remain as **plain-text emails** only?
- **Question D (Manual Notifications):** Does the office need to track non-report communications (e.g., "Your student is traveling for holiday" or "Payment method expiring") in the student's historical timeline?

---
*Last Updated: 2026-05-29*

