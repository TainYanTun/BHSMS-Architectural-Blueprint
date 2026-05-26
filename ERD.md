# Bangla Hope SMS - ER Diagram

Below is the live-rendered Entity Relationship Diagram (ERD) for the PostgreSQL database schema.

```mermaid
erDiagram
    %% ==========================================
    %% REFERENCE TABLES
    %% ==========================================
    PROGRAMS {
        uuid id PK
        text name
        text code UK
        text description
        timestamptz created_at
    }

    INSTITUTIONS {
        uuid id PK
        text name
        text type
        text location
        timestamptz created_at
    }

    %% ==========================================
    %% USER & AUDIT
    %% ==========================================
    USERS {
        uuid id PK
        text username UK
        text email UK
        text password_hash
        text full_name
        text role
        text office_location
        boolean is_active
        timestamptz last_login
        timestamptz created_at
    }

    AUDIT_LOGS {
        uuid id PK
        uuid user_id FK
        text module
        text action
        text target_ref
        text mutation_detail
        text ip_address
        timestamptz created_at
    }

    %% ==========================================
    %% STUDENT CORE
    %% ==========================================
    STUDENTS {
        uuid id PK
        bigint master_id_number UK
        text first_name
        text last_name
        text gender
        date dob
        text religion
        date admission_date
        text status
        text father_name
        text mother_name
        text primary_guardian
        int siblings_count
        text contact_number
        text situation_overview
        text photo_url
        uuid current_program_id FK
        timestamptz created_at
    }

    STUDENT_IDENTIFIERS {
        uuid id PK
        uuid student_id FK
        text id_value
        uuid program_id FK
        boolean is_current
        timestamptz assigned_at
    }

    %% ==========================================
    %% SPONSORSHIP SYSTEM
    %% ==========================================
    SPONSORS {
        uuid id PK
        text sponsor_id_code UK
        uuid user_id FK
        text full_name
        text email UK
        text phone
        text address
        text preferred_communication
        text internal_notes
        text status
        timestamptz created_at
    }

    SPONSORSHIPS {
        uuid id PK
        uuid student_id FK
        uuid sponsor_id FK
        text type
        numeric monthly_amount
        text currency
        date start_date
        date end_date
        boolean is_active
        timestamptz created_at
    }

    SPONSORSHIP_RECEIPTS {
        uuid id PK
        uuid sponsorship_id FK
        numeric amount
        text currency
        date received_date
        int period_month
        int period_year
        text notes
        timestamptz created_at
    }

    %% ==========================================
    %% RECORDS & HISTORY
    %% ==========================================
    ACADEMIC_RECORDS {
        uuid id PK
        uuid student_id FK
        uuid institution_id FK
        int year
        text grade_level
        text result_summary
        timestamptz created_at
    }

    REPORTS {
        uuid id PK
        uuid student_id FK
        int year
        text type
        text status
        date completion_date
        text pdf_url
        timestamptz created_at
    }

    STUDENT_HISTORY {
        uuid id PK
        uuid student_id FK
        date event_date
        text title
        text description
        boolean is_milestone
        timestamptz created_at
    }

    FINANCIAL_ALLOCATIONS {
        uuid id PK
        uuid student_id FK
        text type
        numeric amount
        text currency
        text frequency
        date start_date
        date end_date
        boolean is_active
        text notes
        timestamptz created_at
    }

    %% ==========================================
    %% LOAN SYSTEM
    %% ==========================================
    LOANS {
        uuid id PK
        uuid student_id FK
        uuid institution_id FK
        numeric total_amount
        numeric refunded_amount
        text currency
        text status
        text agreement_url
        timestamptz created_at
    }

    LOAN_DISBURSEMENTS {
        uuid id PK
        uuid loan_id FK
        numeric amount
        text currency
        date disbursement_date
        text category
        text notes
        timestamptz created_at
    }

    LOAN_REFUNDS {
        uuid id PK
        uuid loan_id FK
        numeric amount
        text currency
        date refund_date
        uuid recorded_by FK
        text notes
        timestamptz created_at
    }

    %% ==========================================
    %% RELATIONSHIPS
    %% ==========================================
    USERS ||--o| SPONSORS : "links to account"
    USERS ||--o{ AUDIT_LOGS : "generates"
    USERS ||--o{ LOAN_REFUNDS : "records"

    PROGRAMS ||--o{ STUDENTS : "tracks current"
    PROGRAMS ||--o{ STUDENT_IDENTIFIERS : "categorizes"
    
    STUDENTS ||--o{ STUDENT_IDENTIFIERS : "possesses"
    STUDENTS ||--o{ ACADEMIC_RECORDS : "earns"
    STUDENTS ||--o{ REPORTS : "generates"
    STUDENTS ||--o{ STUDENT_HISTORY : "undergoes"
    STUDENTS ||--o{ FINANCIAL_ALLOCATIONS : "receives"
    STUDENTS ||--o{ SPONSORSHIPS : "benefits from"
    STUDENTS ||--o{ LOANS : "holds"

    INSTITUTIONS ||--o{ ACADEMIC_RECORDS : "hosts"
    INSTITUTIONS ||--o{ LOANS : "receives funds at"

    SPONSORS ||--o{ SPONSORSHIPS : "funds"
    SPONSORSHIPS ||--o{ SPONSORSHIP_RECEIPTS : "collects"

    LOANS ||--o{ LOAN_DISBURSEMENTS : "pays out"
    LOANS ||--o{ LOAN_REFUNDS : "recovers"