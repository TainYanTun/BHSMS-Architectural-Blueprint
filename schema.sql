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

-- ==========================================
-- 1. REFERENCE TABLES
-- ==========================================
CREATE TABLE programs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE sites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    program_id UUID REFERENCES programs(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    type TEXT,
    location TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE teachers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_id UUID REFERENCES sites(id) ON DELETE SET NULL,
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
    row_version INT DEFAULT 1
);

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('Admin', 'Supervisor', 'Coordinator', 'Secretary','Sponsor')),
    office_location TEXT, -- Specific room/desk info
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ, -- Soft delete support
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE role_permissions (
    role TEXT NOT NULL,
    permission_id UUID REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role, permission_id)
);

-- ==========================================
-- 3. STUDENT MASTER RECORD
-- ==========================================
CREATE TABLE students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    master_id_number BIGINT UNIQUE NOT NULL, 
    legacy_id TEXT, -- For tracking original MS Access / Paper ID
    
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    gender TEXT CHECK (gender IN ('Male', 'Female')),
    dob DATE NOT NULL,
    religion TEXT,
    admission_date DATE DEFAULT CURRENT_DATE,
    status TEXT NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Archived', 'Dropped', 'Graduated')),
    
    father_name TEXT,
    mother_name TEXT,
    primary_guardian TEXT,
    staff_parent_id UUID REFERENCES users(id), -- For Employee Worker Children Program
    siblings_count INT DEFAULT 0 CHECK (siblings_count >= 0),
    contact_number TEXT,
    situation_overview TEXT,
    photo_url TEXT,
    
    current_program_id UUID REFERENCES programs(id),
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

-- Master ID Generation Logic
CREATE OR REPLACE FUNCTION generate_student_master_id()
RETURNS TRIGGER AS $$
DECLARE
    year_prefix BIGINT;
    next_seq INT;
BEGIN
    year_prefix := EXTRACT(YEAR FROM CURRENT_DATE);
    IF NEW.master_id_number IS NULL THEN
        SELECT COALESCE(MAX(master_id_number % 100000), 0) + 1 
        INTO next_seq 
        FROM students 
        WHERE master_id_number / 100000 = year_prefix;
        
        NEW.master_id_number := (year_prefix * 100000) + next_seq;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_assign_student_id
BEFORE INSERT ON students
FOR EACH ROW EXECUTE FUNCTION generate_student_master_id();

CREATE TABLE student_identifiers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
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
CREATE TABLE sponsors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sponsor_id_code TEXT UNIQUE NOT NULL,
    user_id UUID REFERENCES users(id),
    full_name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone TEXT,
    address_line1 TEXT,
    city TEXT,
    postal_code TEXT,
    country TEXT DEFAULT 'USA',
    preferred_communication TEXT DEFAULT 'Email' CHECK (preferred_communication IN ('Email', 'Postal Mail', 'Both')),
    internal_notes TEXT,
    status TEXT DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive')),
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE sponsorships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    sponsor_id UUID NOT NULL REFERENCES sponsors(id) ON DELETE CASCADE,
    type TEXT CHECK (type IN ('Primary', 'Co-Sponsor')),
    start_date DATE NOT NULL,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1,
    CONSTRAINT chk_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE contributions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sponsor_id UUID NOT NULL REFERENCES sponsors(id) ON DELETE CASCADE,
    student_id UUID REFERENCES students(id) ON DELETE SET NULL, -- Optional: Can be a general donation
    sponsorship_id UUID REFERENCES sponsorships(id) ON DELETE SET NULL, -- Optional: Link to a specific agreement if it exists
    
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    currency TEXT DEFAULT 'USD' CHECK (currency = 'USD'),
    received_date DATE DEFAULT CURRENT_DATE,
    payment_method TEXT CHECK (payment_method IN ('Check', 'Wire', 'Cash', 'Online')),
    reference_number TEXT,
    
    -- Optional fields for when a gift is intended for a specific billing period
    period_month INT CHECK (period_month BETWEEN 1 AND 12),
    period_year INT,
    
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

-- ==========================================
-- 5. PROGRESS, RECORDS & HISTORY
-- ==========================================
CREATE TABLE academic_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    site_id UUID REFERENCES sites(id),
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
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
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
    student_id UUID REFERENCES students(id) ON DELETE CASCADE,
    sponsor_id UUID REFERENCES sponsors(id) ON DELETE CASCADE,
    CONSTRAINT chk_document_owner CHECK (student_id IS NOT NULL OR sponsor_id IS NOT NULL),
    name TEXT NOT NULL,
    type TEXT NOT NULL, -- e.g., 'Birth Certificate', 'Agreement', 'ID Scan'
    file_url TEXT NOT NULL,
    metadata JSONB,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    year INT NOT NULL CHECK (year > 1900),
    type TEXT NOT NULL DEFAULT 'APR',
    status TEXT NOT NULL DEFAULT 'Not Started' CHECK (status IN ('Not Started', 'Draft', 'Pending', 'Approved', 'Returned', 'Complete')),
    supervisor_comments TEXT,
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMPTZ,
    completion_date DATE,
    pdf_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE student_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    event_date DATE DEFAULT CURRENT_DATE,
    title TEXT NOT NULL,
    description TEXT,
    is_milestone BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE financial_allocations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('Subsidy', 'Pocket Money', 'Stipend', 'One-time Grant')),
    amount NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
    currency TEXT DEFAULT 'USD' CHECK (currency = 'USD'),
    frequency TEXT DEFAULT 'Monthly' CHECK (frequency IN ('Monthly', 'Yearly', 'One-time')),
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1,
    CONSTRAINT chk_alloc_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE allocation_payouts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    allocation_id UUID NOT NULL REFERENCES financial_allocations(id) ON DELETE CASCADE,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    currency TEXT DEFAULT 'USD' CHECK (currency = 'USD'),
    payout_date DATE DEFAULT CURRENT_DATE,
    recorded_by UUID REFERENCES users(id),
    status TEXT DEFAULT 'Paid' CHECK (status IN ('Paid', 'Pending', 'Cancelled')),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
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

-- Migration Staging for Bulk Imports (Proposal 3.6.1)
CREATE TABLE migration_staging_students (
    id SERIAL PRIMARY KEY,
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
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE communications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    sponsor_id UUID NOT NULL REFERENCES sponsors(id) ON DELETE CASCADE,
    template_id UUID REFERENCES communication_templates(id), -- Historical reference
    category TEXT NOT NULL CHECK (category IN ('Financial', 'Milestone', 'Academic')),
    type TEXT NOT NULL, -- e.g., 'Thank You', 'Birthday', 'APR'
    status TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Draft', 'In Review', 'Sent', 'Returned')),
    
    trigger_type TEXT CHECK (trigger_type IN ('Receipt', 'Calendar', 'Report', 'Manual')),
    trigger_id UUID, -- Links to contributions.id or reports.id
    
    message_body TEXT,      -- The final rendered/edited text
    message_metadata JSONB, -- Snapshot: {amount, student_grade, sponsor_address, etc.}
    
    pdf_url TEXT,
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

-- ==========================================
-- 6. LOAN SYSTEM (Higher Education)
-- ==========================================
CREATE TABLE loans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    site_id UUID REFERENCES sites(id),
    currency TEXT DEFAULT 'USD' CHECK (currency = 'USD'),
    status TEXT DEFAULT 'Studying' CHECK (status IN ('Studying', 'Refunding', 'Complete', 'Expired')),
    agreement_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE loan_disbursements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    loan_id UUID NOT NULL REFERENCES loans(id) ON DELETE CASCADE,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    currency TEXT DEFAULT 'USD' CHECK (currency = 'USD'),
    disbursement_date DATE DEFAULT CURRENT_DATE,
    category TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE loan_refunds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    loan_id UUID NOT NULL REFERENCES loans(id) ON DELETE CASCADE,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    currency TEXT DEFAULT 'USD' CHECK (currency = 'USD'),
    refund_date DATE DEFAULT CURRENT_DATE,
    recorded_by UUID REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
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
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

CREATE TABLE reconciliations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contribution_id UUID NOT NULL REFERENCES contributions(id) ON DELETE CASCADE,
    allocation_payout_id UUID NOT NULL REFERENCES allocation_payouts(id) ON DELETE CASCADE,
    reconciled_at TIMESTAMPTZ DEFAULT NOW(),
    reconciled_by UUID REFERENCES users(id),
    notes TEXT
);

-- ==========================================
-- 8. AUDIT & LOGGING
-- ==========================================
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
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
CREATE VIEW view_loan_balances AS
SELECT 
    l.id AS loan_id,
    l.student_id,
    l.status,
    COALESCE(SUM(d.amount), 0) AS total_disbursed,
    COALESCE(SUM(r.amount), 0) AS total_refunded,
    COALESCE(SUM(d.amount), 0) - COALESCE(SUM(r.amount), 0) AS outstanding_balance,
    l.currency
FROM loans l
LEFT JOIN loan_disbursements d ON l.id = d.loan_id
LEFT JOIN loan_refunds r ON l.id = r.loan_id
GROUP BY l.id, l.student_id, l.status, l.currency;

-- ==========================================
-- 9. INDEXES & TRIGGERS
-- ==========================================
CREATE INDEX idx_student_names ON students USING gin (first_name gin_trgm_ops, last_name gin_trgm_ops);
CREATE INDEX idx_sponsor_names ON sponsors USING gin (full_name gin_trgm_ops);
CREATE INDEX idx_audit_details ON audit_logs USING gin (mutation_detail);
CREATE INDEX idx_student_master_id ON students(master_id_number);
CREATE INDEX idx_contribution_sponsor ON contributions(sponsor_id);
CREATE INDEX idx_contribution_student ON contributions(student_id);

CREATE TRIGGER trg_upd_programs BEFORE UPDATE ON programs FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_sites BEFORE UPDATE ON sites FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_users BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_students BEFORE UPDATE ON students FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_student_identifiers BEFORE UPDATE ON student_identifiers FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_sponsors BEFORE UPDATE ON sponsors FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_sponsorships BEFORE UPDATE ON sponsorships FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_contributions BEFORE UPDATE ON contributions FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_academic_records BEFORE UPDATE ON academic_records FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_attendance_records BEFORE UPDATE ON attendance_records FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_documents BEFORE UPDATE ON documents FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_reports BEFORE UPDATE ON reports FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_student_history BEFORE UPDATE ON student_history FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_financial_allocations BEFORE UPDATE ON financial_allocations FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_allocation_payouts BEFORE UPDATE ON allocation_payouts FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_communication_templates BEFORE UPDATE ON communication_templates FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_communications BEFORE UPDATE ON communications FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_loans BEFORE UPDATE ON loans FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_loan_disbursements BEFORE UPDATE ON loan_disbursements FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_loan_refunds BEFORE UPDATE ON loan_refunds FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_backups BEFORE UPDATE ON backups FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_teachers BEFORE UPDATE ON teachers FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_permissions BEFORE UPDATE ON permissions FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
