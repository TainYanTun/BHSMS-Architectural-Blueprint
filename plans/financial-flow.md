# Financial Data Flow Documentation

This document visualizes the flow of financial data within the Bangla Hope Sponsorship Management System, detailing how funds move for both **Subsidies** (Gifts) and **Loans** (Debt).

---

## 1. Subsidy Flow (The "Jar" Model)

This is the path for primary support where money is given as a gift. It follows a three-tier journey: **Intake**, **The Ledger**, and **Impact**.

```mermaid
graph LR
    %% Tier 1: Intake
    subgraph "1. INTAKE (The Cash)"
    Sponsor((Sponsor)) -- "Sends $50" --> Org[Bangla Hope Bank Account]
    end

    %% Tier 2: The Ledger (The Envelopes)
    subgraph "2. THE LEDGER (The Labels)"
    Org -- "Record as 'Subsidy'" --> Envelope["CONTRIBUTIONS TABLE<br/>(Restricted Envelopes)"]
    Envelope -- "Tagged to" --> StudentAcc{Student's Account}
    end

    %% Tier 3: Impact (The Payout)
    %% Tier 3: Impact (The Payout)
    StudentAcc -- "Record Disbursement" --> Payout[PAYOUTS<br/>'Tuition Paid']
    end

    %% Styling
    style Org fill:#f9f,stroke:#333
    style Envelope fill:#fff4dd,stroke:#d4a017,stroke-width:2px
    style StudentAcc fill:#d1e7dd,stroke:#0f5132
    style Payout fill:#cfe2ff,stroke:#084298
    ```

    ### Description
    *   **Intake:** Money is received by the organization.
    *   **The Ledger:** Money is placed in a **"Restricted Envelope"** (Contribution Table) labeled for a specific student.
    *   **Impact:** When a student has a need (tuition, food, etc.), money is disbursed directly and recorded in **PAYOUTS**.


---

## 2. Loan Flow (The "Battery" Model)

This is the path for Higher Education. It uses a **Unified Ledger** (a single table) to track every penny. It works like a battery that starts empty, gets charged (Debt), and is then drained (Repayment).

```mermaid
graph TD
    %% Tier 1: Unified Ledger
    subgraph "1. THE LEDGER (Single Source of Truth)"
    Ledger[("LOAN_TRANSACTIONS TABLE")]
    end

    %% Tier 2: The Flow
    Org[Org Bank Account] -- "Disbursement (+$1,000)" --> Ledger
    Sponsor((Sponsor/Student)) -- "Repayment (-$100)" --> Ledger

    %% Tier 3: The Result
    Ledger -- "SUM(amount)" --> Balance{Outstanding Debt}
    Balance -- "Balance = $0" --> Closed[Loan Complete]

    %% Styling
    style Ledger fill:#f9f,stroke:#333,stroke-width:2px
    style Balance fill:#fff,stroke:#333,stroke-dasharray: 5 5
    style Org fill:#fee,stroke:#e74c3c
    style Sponsor fill:#e8f4fd,stroke:#2980b9
```

### Description
*   **The Single Entry:** Unlike the old system, every event happens in one table: `LOAN_TRANSACTIONS`.
*   **Positive (+) is Debt:** When the organization pays for a student's fees, a **Positive** amount is recorded. This "charges" the student's debt balance.
*   **Negative (-) is Recovery:** When a payment is received (Sponsor/Student sends money), a **Negative** amount is recorded. This "drains" the debt.
*   **Simple Reporting:** To see what a student owes, the system simply adds up all rows (`SUM`) for that student. There are no complex matching rules.
