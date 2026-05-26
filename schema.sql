-- Bangla Hope Sponsorship Management System (Bangla Hope SMS)
-- PostgreSQL Database Schema
-- Generated: 2026-05-17

-- Setup: Enable UUID support for technical primary keys
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- 1. REFERENCE TABLES (Programs & Places)
-- ==========================================
CREATE TABLE programs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL, -- e.g., 'Love Receiving Center', 'Village Schools'
    code TEXT UNIQUE NOT NULL, -- e.g., 'LRC', 'VLG', 'LON', 'BRD'
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE institutions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL, -- e.g., 'Dhaka University', 'Hili Village School'
    type TEXT, -- e.g., 'University', 'Boarding School', 'Village School'
    location TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
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
    role TEXT NOT NULL CHECK (role IN ('Admin', 'Supervisor', 'Coordinator', 'Secetary','Sponsor')),
    office_location TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 3. STUDENT MASTER RECORD
-- ==========================================
CREATE TABLE students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), -- Technical DB ID
    
    -- BUSINESS ID: Numeric 9-digits (e.g., 202600134)
    -- Format: [YEAR(4)][SEQUENCE(5)]
    master_id_number BIGINT UNIQUE NOT NULL, 
    
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    gender TEXT CHECK (gender IN ('Male', 'Female')),
    dob DATE NOT NULL,
    religion TEXT,
    admission_date DATE DEFAULT CURRENT_DATE,
    status TEXT NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Archived', 'Dropped', 'Graduated')),
    
    -- Background Info
    father_name TEXT,
    mother_name TEXT,
    primary_guardian TEXT,
    siblings_count INT DEFAULT 0,
    contact_number TEXT,
    situation_overview TEXT, -- For Case History Narrative
    photo_url TEXT,
    
    current_program_id UUID REFERENCES programs(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- AUTO-GENERATION LOGIC FOR MASTER_ID_NUMBER
CREATE OR REPLACE FUNCTION generate_student_master_id()
RETURNS TRIGGER AS $$
DECLARE
    year_prefix BIGINT;
    next_seq INT;
BEGIN
    -- 1. Get the current year
    year_prefix := EXTRACT(YEAR FROM CURRENT_DATE);
    
    -- 2. Calculate next sequence for this year (Year * 100000 + next)
    -- Only auto-generate if the field is NULL (allows manual migration IDs)
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
FOR EACH ROW
EXECUTE FUNCTION generate_student_master_id();

-- ==========================================
-- 4. ALIASES (Program-Specific IDs like #LRC-0124)
-- ==========================================
CREATE TABLE student_identifiers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    id_value TEXT NOT NULL, -- Alphanumeric string e.g., #LRC-0124
    program_id UUID REFERENCES programs(id),
    is_current BOOLEAN DEFAULT TRUE,
    assigned_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 5. SPONSORSHIP SYSTEM
-- ==========================================
CREATE TABLE sponsors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sponsor_id_code TEXT UNIQUE NOT NULL, -- e.g., #SP-001
    user_id UUID REFERENCES users(id), -- Link to account if they log in
    full_name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone TEXT,
    address TEXT,
    preferred_communication TEXT DEFAULT 'Email' CHECK (preferred_communication IN ('Email', 'Postal Mail', 'Both')),
    internal_notes TEXT,
    status TEXT DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE sponsorships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    sponsor_id UUID NOT NULL REFERENCES sponsors(id) ON DELETE CASCADE,
    type TEXT CHECK (type IN ('Primary', 'Co-Sponsor')),
    monthly_amount NUMERIC(12, 2) DEFAULT 0,
    currency TEXT DEFAULT 'USD' CHECK (currency IN ('USD', 'BDT')),
    start_date DATE NOT NULL,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 6. PROGRESS, RECORDS & HISTORY
-- ==========================================
CREATE TABLE academic_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    institution_id UUID REFERENCES institutions(id),
    year INT NOT NULL,
    grade_level TEXT,
    result_summary TEXT, -- e.g., '82%'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    year INT NOT NULL,
    type TEXT NOT NULL DEFAULT 'APR', -- Annual Progress Report
    status TEXT NOT NULL DEFAULT 'Not Started' CHECK (status IN ('Not Started', 'Draft', 'Pending', 'Complete')),
    completion_date DATE,
    pdf_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE student_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    event_date DATE DEFAULT CURRENT_DATE,
    title TEXT NOT NULL, -- e.g., 'Transitioned to LRC', 'Admission'
    description TEXT,
    is_milestone BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 7. LOAN PROGRAM (Higher Education)
-- ==========================================
CREATE TABLE loans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    institution_id UUID REFERENCES institutions(id),
    total_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
    refunded_amount NUMERIC(12, 2) DEFAULT 0,
    currency TEXT DEFAULT 'USD' CHECK (currency IN ('USD', 'BDT')),
    
    -- PENDING CLIENT DECISION: Should status auto-flip from 'Studying' to 'Refunding' 
    -- based on a target date, or remain a manual administrative action?
    status TEXT DEFAULT 'Studying' CHECK (status IN ('Studying', 'Refunding', 'Complete', 'Expired')),
    
    agreement_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE loan_refunds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    loan_id UUID NOT NULL REFERENCES loans(id) ON DELETE CASCADE,
    amount NUMERIC(12, 2) NOT NULL,
    currency TEXT DEFAULT 'USD' CHECK (currency IN ('USD', 'BDT')),
    refund_date DATE DEFAULT CURRENT_DATE,
    recorded_by UUID REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 8. FINANCIAL ADDITIONS (Disbursements & Receipts)
-- ==========================================
CREATE TABLE financial_allocations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('Subsidy', 'Pocket Money', 'Stipend', 'One-time Grant')),
    amount NUMERIC(12, 2) NOT NULL,
    currency TEXT DEFAULT 'USD' CHECK (currency IN ('USD', 'BDT')),
    frequency TEXT DEFAULT 'Monthly' CHECK (frequency IN ('Monthly', 'Yearly', 'One-time')),
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE loan_disbursements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    loan_id UUID NOT NULL REFERENCES loans(id) ON DELETE CASCADE,
    amount NUMERIC(12, 2) NOT NULL,
    currency TEXT DEFAULT 'USD' CHECK (currency IN ('USD', 'BDT')),
    disbursement_date DATE DEFAULT CURRENT_DATE,
    category TEXT NOT NULL, -- e.g., 'Tuition', 'Admission Fee', 'Books', 'Hostel'
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE sponsorship_receipts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sponsorship_id UUID NOT NULL REFERENCES sponsorships(id) ON DELETE CASCADE,
    amount NUMERIC(12, 2) NOT NULL,
    currency TEXT DEFAULT 'USD' CHECK (currency IN ('USD', 'BDT')),
    received_date DATE DEFAULT CURRENT_DATE,
    period_month INT CHECK (period_month BETWEEN 1 AND 12),
    period_year INT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 9. SYSTEM AUDIT & SECURITY
-- ==========================================
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    module TEXT NOT NULL, -- e.g., 'STUDENT', 'LOAN', 'SPONSOR'
    action TEXT NOT NULL, -- e.g., 'ADD_REC', 'EDIT_VAL', 'ARCHIVE'
    target_ref TEXT, -- The master_id_number or Code affected
    mutation_detail TEXT, -- JSON or Text description of changes
    ip_address TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 10. OPTIMIZATION INDEXES
-- ==========================================
CREATE INDEX idx_student_master_id ON students(master_id_number);
CREATE INDEX idx_student_status ON students(status);
CREATE INDEX idx_sponsorships_active ON sponsorships(is_active) WHERE is_active IS TRUE;
CREATE INDEX idx_audit_log_time ON audit_logs(created_at DESC);
CREATE INDEX idx_identifiers_value ON student_identifiers(id_value);
