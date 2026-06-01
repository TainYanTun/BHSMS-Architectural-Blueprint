-- Bangla Hope Sponsorship Management System (Bangla Hope SMS)
-- PostgreSQL Database Schema (Improved Version)
-- Generated: 2026-05-27

-- ==========================================
-- 0. EXTENSIONS & GLOBAL UTILITIES
-- ==========================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For high-performance text search
CREATE EXTENSION IF NOT EXISTS "pgcrypto"; -- For data encryption at rest (Proposal 3.6.1)

-- Trigger function to automatically update 'updated_at' timestamps
CREATE OR REPLACE FUNCTION fn_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    NEW.row_version = NEW.row_version + 1; -- Auto-increment version
    RETURN NEW;   
END;
$$ LANGUAGE plpgsql;

-- Native sequence for student master IDs to prevent race conditions
CREATE SEQUENCE student_master_id_seq START WITH 1;

-- ==========================================
-- 1. REFERENCE TABLES
-- ==========================================
-- ==========================================
-- 1. REFERENCE TABLES
-- ==========================================
CREATE TABLE programs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL, -- 3-Letter Code
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

INSERT INTO programs (name, code, description) VALUES
('Orphanage Residential Program', 'LRC', 'Love Receiving Center'),
('Boarding School Program', 'BRD', 'Boarding School Sponsorship'),
('Village Schools Program', 'VLG', 'Community-based Day Schools'),
('Higher Study Loan Program', 'LON', 'University & Higher Ed Loans'),
('Employee Children Program', 'STF', 'Bangla Hope Employee Children');


CREATE TABLE orphanages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    location TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE village_sectors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    location TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE teachers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    orphanage_id UUID REFERENCES orphanages(id) ON DELETE SET NULL,
    village_sector_id UUID REFERENCES village_sectors(id) ON DELETE SET NULL,
    full_name TEXT NOT NULL,
    contact_number TEXT,
    email TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code TEXT UNIQUE NOT NULL, -- e.g., 'STUDENT_CREATE', 'FINANCE_APPROVE'
    name TEXT NOT NULL,
    module TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(), -- Fix: Added for trigger support
    row_version INT DEFAULT 1 -- Fix: Added for trigger support
);

CREATE TABLE roles (
    name TEXT PRIMARY KEY,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO roles (name, description) VALUES
('Admin', 'System owner with override powers and account management'),
('Supervisor', 'Quality control and compliance officer; final gatekeeper'),
('Coordinator', 'Primary program operator; manages student lifecycle'),
('Secretary', 'Administrative support; handles data entry and drafting'),
('Sponsor', 'External stakeholder; restricted view of supported students');

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username TEXT NOT NULL,
    email TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL REFERENCES roles(name),
    office_location TEXT, -- Specific room/desk info
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ, -- Soft delete support
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1,
    CONSTRAINT chk_user_email_format CHECK (email LIKE '%@%.%') -- Fix: More inclusive regex
);

-- Support for unique constraints with soft deletes
CREATE UNIQUE INDEX idx_unique_active_username ON users(username) WHERE (deleted_at IS NULL);
CREATE UNIQUE INDEX idx_unique_active_email ON users(email) WHERE (deleted_at IS NULL);

CREATE TABLE role_permissions (
    role TEXT NOT NULL REFERENCES roles(name) ON DELETE RESTRICT,
    permission_id UUID REFERENCES permissions(id) ON DELETE RESTRICT,
    PRIMARY KEY (role, permission_id)
);

-- ==========================================
-- 3. STUDENT MASTER RECORD
-- ==========================================
CREATE TABLE students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    master_id_number BIGINT NOT NULL, 
    legacy_id TEXT, -- For tracking original MS Access / Paper ID
    
    first_name TEXT NOT NULL CHECK (length(first_name) <= 100),
    last_name TEXT NOT NULL CHECK (length(last_name) <= 100),
    gender TEXT CHECK (gender IN ('Male', 'Female')),
    dob DATE NOT NULL,
    religion TEXT CHECK (length(religion) <= 50),
    admission_date DATE DEFAULT CURRENT_DATE,
    status TEXT NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Dropped', 'Completed')),
    
    father_name TEXT CHECK (length(father_name) <= 200),
    mother_name TEXT CHECK (length(mother_name) <= 200),
    staff_parent_id UUID REFERENCES users(id) ON DELETE SET NULL, -- Fix: Handle user deletion
    siblings_count INT DEFAULT 0 CHECK (siblings_count >= 0),
    contact_number TEXT CHECK (contact_number IS NULL OR (length(contact_number) >= 7 AND length(contact_number) <= 20)),
    
    -- Exit / Archive Tracking
    status_change_reason TEXT, -- e.g., 'Returned to family', 'Ineligible due to age'
    exit_destination TEXT,     -- e.g., 'Local Village', 'Govt Training Center'
    
    current_program_id UUID REFERENCES programs(id),
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

-- Support for unique constraints with soft deletes
CREATE UNIQUE INDEX idx_unique_active_master_id ON students(master_id_number) WHERE (deleted_at IS NULL);

CREATE TABLE guardians (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
    full_name TEXT NOT NULL,
    relationship TEXT NOT NULL, -- e.g., 'Father', 'Mother', 'Uncle', 'Aunt'
    phone TEXT,
    email TEXT,
    photo_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE enrollments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
    orphanage_id UUID REFERENCES orphanages(id) ON DELETE SET NULL,
    village_sector_id UUID REFERENCES village_sectors(id) ON DELETE SET NULL,
    program_id UUID REFERENCES programs(id) ON DELETE SET NULL,
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

-- Master ID Generation Logic (Improved with safe, non-truncating formula)
CREATE OR REPLACE FUNCTION generate_student_master_id()
RETURNS TRIGGER AS $$
DECLARE
    year_prefix BIGINT;
    seq_val BIGINT;
BEGIN
    year_prefix := EXTRACT(YEAR FROM CURRENT_DATE);
    IF NEW.master_id_number IS NULL THEN
        seq_val := nextval('student_master_id_seq');
        -- Using 100,000,000 as a safer multiplier to allow for massive sequence growth 
        -- within a single year without collisions. 
        -- Formula: YYYY + seq_val
        NEW.master_id_number := (year_prefix * 100000000) + seq_val;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_assign_student_id
BEFORE INSERT ON students
FOR EACH ROW EXECUTE FUNCTION generate_student_master_id();

CREATE TABLE student_intake_details (
    student_id UUID PRIMARY KEY REFERENCES students(id) ON DELETE RESTRICT,
    admission_weight_kg NUMERIC(5,2),
    health_at_admission TEXT,
    is_immunized BOOLEAN DEFAULT FALSE,
    referral_narrative TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE student_references (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
    full_name TEXT NOT NULL,
    relationship TEXT, -- e.g., 'Village Leader', 'Pastor'
    contact_info TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE program_transitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
    from_program_id UUID REFERENCES programs(id) ON DELETE SET NULL,
    to_program_id UUID REFERENCES programs(id) ON DELETE SET NULL,
    transition_date DATE DEFAULT CURRENT_DATE,
    reason TEXT,
    recorded_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE student_identifiers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
    id_value TEXT NOT NULL, -- e.g., #LRC-0124
    program_id UUID REFERENCES programs(id),
    is_current BOOLEAN DEFAULT TRUE,
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

-- ==========================================
-- 4. SPONSORSHIP SYSTEM
-- ==========================================
CREATE TABLE invitations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT NOT NULL,
    token TEXT NOT NULL, -- Used in the registration URL
    role TEXT NOT NULL DEFAULT 'Sponsor' REFERENCES roles(name),
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

-- Support for unique constraints with soft deletes (invitations might not have deleted_at, but good for consistency if added)
CREATE UNIQUE INDEX idx_unique_invitation_email ON invitations(email);
CREATE UNIQUE INDEX idx_unique_invitation_token ON invitations(token);

CREATE TABLE sponsors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sponsor_id_code TEXT NOT NULL, -- Unique index handled below
    user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- Fix: Handle user deletion
    full_name TEXT NOT NULL CHECK (length(full_name) <= 200),
    email TEXT, -- Unique index handled below
    phone TEXT CHECK (length(phone) <= 30),
    address_line1 TEXT,
    address_line2 TEXT, -- Fix: Added for completeness
    city TEXT CHECK (length(city) <= 100),
    postal_code TEXT CHECK (length(postal_code) <= 20),
    country TEXT DEFAULT 'USA' CHECK (length(country) <= 100),
    preferred_communication TEXT DEFAULT 'Email' CHECK (preferred_communication IN ('Email', 'Postal Mail', 'Both')),
    internal_notes TEXT,
    status TEXT DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive')),
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1,
    CONSTRAINT chk_sponsor_email_format CHECK (email IS NULL OR email LIKE '%@%.%') -- Fix: More inclusive regex
);

-- Support for unique constraints with soft deletes
CREATE UNIQUE INDEX idx_unique_active_sponsor_code ON sponsors(sponsor_id_code) WHERE (deleted_at IS NULL);
CREATE UNIQUE INDEX idx_unique_active_sponsor_email ON sponsors(email) WHERE (deleted_at IS NULL AND email IS NOT NULL);

CREATE TABLE sponsorships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
    sponsor_id UUID NOT NULL REFERENCES sponsors(id) ON DELETE RESTRICT,
    type TEXT CHECK (type IN ('Primary', 'Co-Sponsor')),
    start_date DATE NOT NULL,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1,
    CONSTRAINT chk_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

-- Fix: Uniqueness constraint for active sponsorships
CREATE UNIQUE INDEX idx_unique_active_sponsorship 
ON sponsorships(student_id, sponsor_id) 
WHERE (is_active = TRUE);

CREATE TABLE contributions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sponsor_id UUID NOT NULL REFERENCES sponsors(id) ON DELETE RESTRICT,
    student_id UUID REFERENCES students(id) ON DELETE RESTRICT, -- Fix: Lock historical ties
    sponsorship_id UUID REFERENCES sponsorships(id) ON DELETE RESTRICT, -- Fix: Lock historical ties
    
    type TEXT NOT NULL DEFAULT 'Subsidy' CHECK (type IN ('Repayment', 'Subsidy', 'Grant', 'General')),
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    currency CHAR(3) DEFAULT 'USD', -- Fix: Added currency context
    received_date DATE DEFAULT CURRENT_DATE,
    payment_method TEXT CHECK (payment_method IN ('Check', 'Wire', 'Cash', 'Online')),
    reference_number TEXT,
    
    -- Optional fields for when a gift is intended for a specific billing period
    period_month INT CHECK (period_month BETWEEN 1 AND 12),
    period_year INT,
    
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1,
    CONSTRAINT chk_contribution_target CHECK (
        (sponsorship_id IS NOT NULL AND student_id IS NULL) OR 
        (sponsorship_id IS NULL AND student_id IS NOT NULL) OR
        (sponsorship_id IS NULL AND student_id IS NULL) -- Truly general donation
    )
);

-- ==========================================
-- 5. PROGRESS, RECORDS & HISTORY
-- ==========================================
CREATE TABLE academic_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
    program_id UUID REFERENCES programs(id) ON DELETE SET NULL, -- Vertical context
    orphanage_id UUID REFERENCES orphanages(id), -- Specific residential location
    village_sector_id UUID REFERENCES village_sectors(id), -- Specific village school location
    institution_id UUID REFERENCES educational_institutions(id), -- Higher Ed institution
    year INT NOT NULL CHECK (year > 1900),
    grade_level TEXT,
    result_summary TEXT,
    attendance_percentage NUMERIC(5, 2) CHECK (attendance_percentage >= 0 AND attendance_percentage <= 100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE attendance_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
    year INT NOT NULL CHECK (year > 1900),
    days_present INT NOT NULL CHECK (days_present >= 0),
    total_school_days INT NOT NULL CHECK (total_school_days > 0),
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1,
    UNIQUE(student_id, year)
);

CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES students(id) ON DELETE RESTRICT,
    sponsor_id UUID REFERENCES sponsors(id) ON DELETE RESTRICT,
    CONSTRAINT chk_document_owner CHECK (student_id IS NOT NULL OR sponsor_id IS NOT NULL),
    name TEXT NOT NULL,
    type TEXT NOT NULL, -- e.g., 'Birth Certificate', 'Agreement', 'ID Scan'
    file_url TEXT NOT NULL,
    metadata JSONB,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL, -- Fix: Handle user deletion
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
    year INT NOT NULL CHECK (year > 1900),
    type TEXT NOT NULL DEFAULT 'APR' CHECK (type IN ('APR', 'Case History', 'Incident', 'Thank You', 'Birthday', 'Special Gift')),
    status TEXT NOT NULL DEFAULT 'Not Started' CHECK (status IN ('Not Started', 'Draft', 'Pending', 'Approved', 'Returned', 'Complete')),
    
    narrative TEXT, -- The core content of the document (Letter body or Case Narrative)
    supervisor_comments TEXT,
    
    -- Links for relational reports
    contribution_id UUID REFERENCES contributions(id) ON DELETE SET NULL, 
    
    approved_by UUID REFERENCES users(id) ON DELETE SET NULL,
    approved_at TIMESTAMPTZ,
    completion_date DATE,
    pdf_url TEXT, -- The final generated document
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE student_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
    event_date DATE DEFAULT CURRENT_DATE,
    title TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE allocation_payouts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
    type TEXT NOT NULL CHECK (type IN ('Subsidy', 'Pocket Money', 'Stipend', 'One-time Grant')),
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    currency CHAR(3) DEFAULT 'USD', -- Fix: Added currency context
    payout_date DATE DEFAULT CURRENT_DATE,
    recorded_by UUID REFERENCES users(id) ON DELETE SET NULL, -- Fix: Handle user deletion
    status TEXT DEFAULT 'Paid' CHECK (status IN ('Paid', 'Pending', 'Cancelled')),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE migration_metadata (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name TEXT NOT NULL,
    source_id TEXT NOT NULL,
    target_uuid UUID NOT NULL,
    migration_batch TEXT,
    migrated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Migration Staging for Bulk Imports
CREATE TABLE migration_staging_students (
    id BIGSERIAL PRIMARY KEY,
    raw_data JSONB NOT NULL,
    validation_errors TEXT[],
    status TEXT DEFAULT 'Pending' CHECK (status IN ('Pending', 'Validated', 'Imported', 'Failed')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE migration_staging_sponsors (
    id BIGSERIAL PRIMARY KEY,
    raw_data JSONB NOT NULL,
    validation_errors TEXT[],
    status TEXT DEFAULT 'Pending' CHECK (status IN ('Pending', 'Validated', 'Imported', 'Failed')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE migration_staging_contributions (
    id BIGSERIAL PRIMARY KEY,
    raw_data JSONB NOT NULL,
    validation_errors TEXT[],
    status TEXT DEFAULT 'Pending' CHECK (status IN ('Pending', 'Validated', 'Imported', 'Failed')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE communication_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code TEXT UNIQUE NOT NULL, -- e.g., 'T-01', 'B-02'
    name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('Financial', 'Milestone', 'Academic')),
    subject_line TEXT,
    body_content TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    deleted_at TIMESTAMPTZ, -- Soft delete support
    created_by UUID REFERENCES users(id) ON DELETE SET NULL, -- Fix: Handle user deletion
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE communications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
    sponsor_id UUID NOT NULL REFERENCES sponsors(id) ON DELETE RESTRICT,
    report_id UUID REFERENCES reports(id) ON DELETE SET NULL, -- The document being delivered

    -- Delivery Details
    channel TEXT DEFAULT 'Email' CHECK (channel IN ('Email', 'Postal Mail', 'SMS')),
    recipient_email TEXT, -- Snapshot of the email address used
    subject TEXT, -- Snapshot of the subject line

    template_id UUID REFERENCES communication_templates(id), -- Formatting logic
    category TEXT NOT NULL CHECK (category IN ('Financial', 'Milestone', 'Academic', 'Manual')),
    status TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Sent', 'Failed')),

    -- Manual notifications or captured snapshot of the final body
    message_body TEXT,

    -- Technical Audit Trail
    delivery_log JSONB, -- Stores SMTP responses, message IDs, or error details

    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE educational_institutions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    type TEXT, -- e.g., 'University', 'College', 'Vocational'
    location TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

-- ==========================================
-- 6. LOAN SYSTEM (Higher Education)
-- ==========================================
CREATE TABLE loans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
    institution_id UUID REFERENCES educational_institutions(id),
    status TEXT DEFAULT 'Studying' CHECK (status IN ('Studying', 'Refunding', 'Complete', 'Expired')),
    agreement_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE loan_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    loan_id UUID NOT NULL REFERENCES loans(id) ON DELETE RESTRICT,
    transaction_date DATE DEFAULT CURRENT_DATE,
    amount NUMERIC(12, 2) NOT NULL, -- Positive for disbursement (Debt), Negative for repayment (Refund)
    type TEXT NOT NULL CHECK (type IN ('Disbursement', 'Repayment', 'Adjustment')),
    recorded_by UUID REFERENCES users(id) ON DELETE SET NULL, -- Fix: Handle user deletion
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1,
    CONSTRAINT chk_loan_transaction_sign CHECK (
        (type = 'Disbursement' AND amount > 0) OR
        (type = 'Repayment' AND amount < 0) OR
        (type = 'Adjustment') -- Can be positive or negative
    )
);

-- ==========================================
-- 7. BACKUP & FINANCIAL RECONCILIATION
-- ==========================================
CREATE TABLE backups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    filename TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    size_bytes BIGINT,
    status TEXT NOT NULL DEFAULT 'Started' CHECK (status IN ('Started', 'Completed', 'Failed')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(), -- Fix: Added for trigger support
    completed_at TIMESTAMPTZ,
    row_version INT DEFAULT 1 -- Fix: Added for trigger support
);

CREATE TABLE reconciliations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contribution_id UUID NOT NULL REFERENCES contributions(id) ON DELETE RESTRICT,
    allocation_payout_id UUID NOT NULL REFERENCES allocation_payouts(id) ON DELETE RESTRICT,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0), -- Specifying how much of the gift was used
    reconciled_at TIMESTAMPTZ DEFAULT NOW(),
    reconciled_by UUID REFERENCES users(id) ON DELETE SET NULL, -- Fix: Handle user deletion
    notes TEXT
);

-- Overdraft Prevention Logic
CREATE OR REPLACE FUNCTION fn_enforce_contribution_limits()
RETURNS TRIGGER AS $$
DECLARE
    v_total_allocated NUMERIC(12,2);
    v_original_limit NUMERIC(12,2);
BEGIN
    -- Force incoming concurrent requests targeting the same parent contribution to queue sequentially.
    -- Locking the parent record serializes all child inserts/updates, guaranteeing consistency.
    PERFORM 1 
    FROM contributions 
    WHERE id = NEW.contribution_id 
    FOR UPDATE;
    
    SELECT amount INTO v_original_limit 
    FROM contributions 
    WHERE id = NEW.contribution_id;
    
    SELECT COALESCE(SUM(amount), 0) INTO v_total_allocated 
    FROM reconciliations 
    WHERE contribution_id = NEW.contribution_id 
      AND (TG_OP = 'INSERT' OR id <> NEW.id);

    IF (v_total_allocated + NEW.amount) > v_original_limit THEN
        RAISE EXCEPTION 'Allocation Overdraft: Attempted to allocate %, but only % remains available.', 
            NEW.amount, (v_original_limit - v_total_allocated);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_limit_reconciliation_overdraft
BEFORE INSERT OR UPDATE ON reconciliations
FOR EACH ROW EXECUTE FUNCTION fn_enforce_contribution_limits();

-- ==========================================
-- 8. AUDIT & LOGGING
-- ==========================================
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- Fix: Handle user deletion
    module TEXT NOT NULL,
    action TEXT NOT NULL,
    target_id UUID,
    target_type TEXT,
    mutation_detail JSONB,
    ip_address INET,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 8. VIEWS FOR REPORTING
-- ==========================================
CREATE VIEW view_contribution_balances AS
SELECT 
    c.id AS contribution_id,
    c.student_id,
    c.sponsor_id,
    c.amount AS original_amount,
    COALESCE(SUM(r.amount), 0) AS amount_used,
    c.amount - COALESCE(SUM(r.amount), 0) AS remaining_balance
FROM contributions c
LEFT JOIN reconciliations r ON c.id = r.contribution_id
GROUP BY c.id, c.student_id, c.sponsor_id, c.amount;

CREATE VIEW view_loan_balances AS
SELECT 
    l.id AS loan_id,
    l.student_id,
    COALESCE(SUM(CASE WHEN t.amount > 0 THEN t.amount ELSE 0 END), 0) AS total_disbursed,
    COALESCE(SUM(CASE WHEN t.amount < 0 THEN ABS(t.amount) ELSE 0 END), 0) AS total_refunded,
    COALESCE(SUM(t.amount), 0) AS outstanding_balance,
    CASE 
        WHEN COUNT(t.id) = 0 THEN 'Pending Disbursement'
        WHEN COALESCE(SUM(t.amount), 0) <= 0 THEN 'Complete'
        ELSE l.status
    END AS effective_status
FROM loans l
LEFT JOIN loan_transactions t ON l.id = t.loan_id
GROUP BY l.id, l.student_id, l.status;

-- ==========================================
-- 9. INDEXES & TRIGGERS
-- ==========================================
CREATE INDEX idx_student_names ON students USING gin (first_name gin_trgm_ops, last_name gin_trgm_ops);
CREATE INDEX idx_sponsor_names ON sponsors USING gin (full_name gin_trgm_ops);
CREATE INDEX idx_audit_details ON audit_logs USING gin (mutation_detail jsonb_path_ops);
CREATE INDEX idx_student_master_id ON students(master_id_number);
CREATE INDEX idx_contribution_sponsor ON contributions(sponsor_id);
CREATE INDEX idx_contribution_student ON contributions(student_id);

-- Performance Indexes
CREATE INDEX idx_sponsorships_student_id ON sponsorships(student_id);
CREATE INDEX idx_sponsorships_sponsor_id ON sponsorships(sponsor_id);
CREATE INDEX idx_academic_records_orphanage_id ON academic_records(orphanage_id);
CREATE INDEX idx_academic_records_village_sector_id ON academic_records(village_sector_id);
CREATE INDEX idx_loans_institution_id ON loans(institution_id);

-- Fix: Additional Foreign Key Indexes for Reporting Performance
CREATE INDEX idx_reconciliations_contribution_id ON reconciliations(contribution_id);
CREATE INDEX idx_reconciliations_allocation_payout_id ON reconciliations(allocation_payout_id);
CREATE INDEX idx_loan_transactions_loan_id ON loan_transactions(loan_id);
CREATE INDEX idx_enrollments_student_id ON enrollments(student_id);
CREATE INDEX idx_guardians_student_id ON guardians(student_id);
CREATE INDEX idx_communications_student_sponsor ON communications(student_id, sponsor_id);
CREATE INDEX idx_loans_student_id ON loans(student_id);
CREATE INDEX idx_allocation_payouts_student_id ON allocation_payouts(student_id);
CREATE INDEX idx_reports_student_id ON reports(student_id);

CREATE TRIGGER trg_upd_programs BEFORE UPDATE ON programs FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_orphanages BEFORE UPDATE ON orphanages FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_village_sectors BEFORE UPDATE ON village_sectors FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_users BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_students BEFORE UPDATE ON students FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_student_identifiers BEFORE UPDATE ON student_identifiers FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_sponsors BEFORE UPDATE ON sponsors FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_sponsorships BEFORE UPDATE ON sponsorships FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
-- Financial ledgers (contributions, payouts, loan_transactions) are immutable; no update trigger.
CREATE TRIGGER trg_upd_academic_records BEFORE UPDATE ON academic_records FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_attendance_records BEFORE UPDATE ON attendance_records FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_documents BEFORE UPDATE ON documents FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_reports BEFORE UPDATE ON reports FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_student_history BEFORE UPDATE ON student_history FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
-- allocation_payouts is immutable
CREATE TRIGGER trg_upd_communication_templates BEFORE UPDATE ON communication_templates FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_communications BEFORE UPDATE ON communications FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_loans BEFORE UPDATE ON loans FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
-- loan_transactions is immutable
CREATE TRIGGER trg_upd_backups BEFORE UPDATE ON backups FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_educational_institutions BEFORE UPDATE ON educational_institutions FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_teachers BEFORE UPDATE ON teachers FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_guardians BEFORE UPDATE ON guardians FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_invitations BEFORE UPDATE ON invitations FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_permissions BEFORE UPDATE ON permissions FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_student_intake_details BEFORE UPDATE ON student_intake_details FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_student_references BEFORE UPDATE ON student_references FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_program_transitions BEFORE UPDATE ON program_transitions FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
