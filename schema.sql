-- Bangla Hope Sponsorship Management System (Bangla Hope SMS)
-- PostgreSQL Database Schema (Improved Version)
-- Generated: 2026-05-27

-- ==========================================
-- 0. EXTENSIONS & GLOBAL UTILITIES
-- ==========================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For high-performance text search

-- Trigger function to automatically update 'updated_at' timestamps
CREATE OR REPLACE FUNCTION fn_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
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
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE institutions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    type TEXT,
    location TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 2. USER MANAGEMENT (RBAC)
-- ==========================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('Admin', 'Supervisor', 'Coordinator', 'Secretary','Sponsor')),
    office_location TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ, -- Soft delete support
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 3. STUDENT MASTER RECORD
-- ==========================================
CREATE TABLE students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    master_id_number BIGINT UNIQUE NOT NULL, 
    
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
    siblings_count INT DEFAULT 0 CHECK (siblings_count >= 0),
    contact_number TEXT,
    situation_overview TEXT,
    photo_url TEXT,
    
    current_program_id UUID REFERENCES programs(id),
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
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
    updated_at TIMESTAMPTZ DEFAULT NOW()
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
    updated_at TIMESTAMPTZ DEFAULT NOW()
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
    CONSTRAINT chk_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE sponsorship_receipts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sponsorship_id UUID NOT NULL REFERENCES sponsorships(id) ON DELETE CASCADE,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    currency TEXT DEFAULT 'USD' CHECK (currency = 'USD'),
    received_date DATE DEFAULT CURRENT_DATE,
    payment_method TEXT CHECK (payment_method IN ('Check', 'Wire', 'Cash', 'Online')),
    reference_number TEXT,
    period_month INT NOT NULL CHECK (period_month BETWEEN 1 AND 12),
    period_year INT NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(sponsorship_id, period_month, period_year)
);

-- ==========================================
-- 5. PROGRESS, RECORDS & HISTORY
-- ==========================================
CREATE TABLE academic_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    institution_id UUID REFERENCES institutions(id),
    year INT NOT NULL CHECK (year > 1900),
    grade_level TEXT,
    result_summary TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    year INT NOT NULL CHECK (year > 1900),
    type TEXT NOT NULL DEFAULT 'APR',
    status TEXT NOT NULL DEFAULT 'Not Started' CHECK (status IN ('Not Started', 'Draft', 'Pending Validation', 'Validated', 'Returned', 'Complete')),
    supervisor_comments TEXT,
    validated_by UUID REFERENCES users(id),
    validated_at TIMESTAMPTZ,
    completion_date DATE,
    pdf_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE student_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    event_date DATE DEFAULT CURRENT_DATE,
    title TEXT NOT NULL,
    description TEXT,
    is_milestone BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
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
    CONSTRAINT chk_alloc_dates CHECK (end_date IS NULL OR end_date >= start_date)
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
    updated_at TIMESTAMPTZ DEFAULT NOW()
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
    trigger_id UUID, -- Links to sponsorship_receipts.id or reports.id
    
    message_body TEXT,      -- The final rendered/edited text
    message_metadata JSONB, -- Snapshot: {amount, student_grade, sponsor_address, etc.}
    
    pdf_url TEXT,
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 6. LOAN SYSTEM (Higher Education)
-- ==========================================
CREATE TABLE loans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    institution_id UUID REFERENCES institutions(id),
    currency TEXT DEFAULT 'USD' CHECK (currency = 'USD'),
    status TEXT DEFAULT 'Studying' CHECK (status IN ('Studying', 'Refunding', 'Complete', 'Expired')),
    agreement_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE loan_disbursements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    loan_id UUID NOT NULL REFERENCES loans(id) ON DELETE CASCADE,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    currency TEXT DEFAULT 'USD' CHECK (currency = 'USD'),
    disbursement_date DATE DEFAULT CURRENT_DATE,
    category TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE loan_refunds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    loan_id UUID NOT NULL REFERENCES loans(id) ON DELETE CASCADE,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    currency TEXT DEFAULT 'USD' CHECK (currency = 'USD'),
    refund_date DATE DEFAULT CURRENT_DATE,
    recorded_by UUID REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 7. AUDIT & LOGGING
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

CREATE TRIGGER trg_upd_programs BEFORE UPDATE ON programs FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_institutions BEFORE UPDATE ON institutions FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_users BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_students BEFORE UPDATE ON students FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_student_identifiers BEFORE UPDATE ON student_identifiers FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_sponsors BEFORE UPDATE ON sponsors FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_sponsorships BEFORE UPDATE ON sponsorships FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_academic_records BEFORE UPDATE ON academic_records FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_reports BEFORE UPDATE ON reports FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_student_history BEFORE UPDATE ON student_history FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_financial_allocations BEFORE UPDATE ON financial_allocations FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_communication_templates BEFORE UPDATE ON communication_templates FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_communications BEFORE UPDATE ON communications FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_loans BEFORE UPDATE ON loans FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

