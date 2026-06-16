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
('Higher Study Loan Program', 'LON', 'University & Higher Ed Loans');

CREATE TABLE payment_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    program_id UUID NOT NULL REFERENCES programs(id) ON DELETE RESTRICT,
    name TEXT NOT NULL,
    is_repayable BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO payment_categories (program_id, name, is_repayable) VALUES
((SELECT id FROM programs WHERE code = 'LRC'), 'Subsidy', false),
((SELECT id FROM programs WHERE code = 'LRC'), 'Pocket Money', false),
((SELECT id FROM programs WHERE code = 'BRD'), 'Subsidy', false),
((SELECT id FROM programs WHERE code = 'BRD'), 'Pocket Money', false),
((SELECT id FROM programs WHERE code = 'BRD'), 'Boarding Fee', false),
((SELECT id FROM programs WHERE code = 'BRD'), 'Tuition', false),
((SELECT id FROM programs WHERE code = 'BRD'), 'Uniform', false),
((SELECT id FROM programs WHERE code = 'VLG'), 'Tuition Subsidy', false),
((SELECT id FROM programs WHERE code = 'VLG'), 'Textbook Grant', false),
((SELECT id FROM programs WHERE code = 'VLG'), 'Uniform Allowance', false),
((SELECT id FROM programs WHERE code = 'LON'), 'Subsidy', true),
((SELECT id FROM programs WHERE code = 'LON'), 'Total Expense', true),
((SELECT id FROM programs WHERE code = 'LON'), 'University Tuition', true),
((SELECT id FROM programs WHERE code = 'LON'), 'Boarding Rent', true),
((SELECT id FROM programs WHERE code = 'LON'), 'Book Allowance', true),
((SELECT id FROM programs WHERE code = 'BRD'), 'Hostel Fee', false),
((SELECT id FROM programs WHERE code = 'LON'), 'Medical Bill', false),
((SELECT id FROM programs WHERE code = 'LON'), 'Internship Expense', false);


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
('Admin', 'System owner. Manages user accounts, system configuration, data migration, backups.'),
('Director', 'Highest operational authority. Final approver for documents, student status, and financial sign-off.'),
('Program Coordinator', 'Program-wide operator. Manages student lifecycle, academics, and financial entries within assigned program(s). Oversees School Coordinators.'),
('School Coordinator', 'Single-site operator. Manages student lifecycle, academics, and financial entries at one school. Reports to Program Coordinator.'),
('Secretary', 'Administrative support. Handles data entry, letter drafting, and logging financial transactions.'),
('Sponsor', 'External stakeholder. Restricted view of supported student(s) and documents.');

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

-- Program assignment for program-scoped and facility-scoped roles
-- Program Coordinator: (user_id, program_id, village_sector_id = NULL)
-- School Coordinator: (user_id, program_id = VLG, village_sector_id = <uuid>)
CREATE TABLE user_programs (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    program_id UUID NOT NULL REFERENCES programs(id) ON DELETE CASCADE,
    village_sector_id UUID REFERENCES village_sectors(id), -- NULL for Program Coord, set for Village Coord
    PRIMARY KEY (user_id, program_id)
);
CREATE UNIQUE INDEX idx_unique_user_scope ON user_programs(user_id, COALESCE(village_sector_id, '00000000-0000-0000-0000-000000000000'));
-- Application enforces: village_sector_id IS NOT NULL only when program_id = VLG

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
    church TEXT CHECK (length(church) <= 100),
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
    year_prefix := EXTRACT(YEAR FROM NEW.admission_date);
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

CREATE TABLE invitations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sponsor_id UUID NOT NULL REFERENCES sponsors(id) ON DELETE RESTRICT,
    email TEXT NOT NULL,
    token TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'Sponsor' REFERENCES roles(name),
    expires_at TIMESTAMPTZ NOT NULL,
    claimed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE UNIQUE INDEX idx_unique_invitation_token ON invitations(token);

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
    sponsorship_id UUID NOT NULL REFERENCES sponsorships(id) ON DELETE RESTRICT,
    student_id UUID REFERENCES students(id) ON DELETE RESTRICT,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    purpose TEXT,
    received_date DATE DEFAULT CURRENT_DATE,
    payment_method TEXT CHECK (payment_method IN ('Check', 'Wire', 'Cash', 'Online')),
    reference_number TEXT,
    notes TEXT,
    recorded_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

-- ==========================================
-- 5. PROGRESS, RECORDS & HISTORY
-- ==========================================

-- Reference table for third-party universities / colleges / vocational institutes
CREATE TABLE educational_institutions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    type TEXT, -- e.g., 'University', 'College', 'Vocational'
    location TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

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
    id UUID DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
    year INT NOT NULL CHECK (year > 1900),
    days_present INT NOT NULL CHECK (days_present >= 0),
    total_school_days INT NOT NULL CHECK (total_school_days > 0),
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1,
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

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

CREATE TABLE job_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_type TEXT NOT NULL, -- e.g., 'GENERATE_PDF'
    payload JSONB NOT NULL,   -- Contextual data (e.g., student_id, report_id)
    status TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Processing', 'Completed', 'Failed')),
    attempts INT DEFAULT 0,
    error_log TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES students(id) ON DELETE RESTRICT,
    year INT NOT NULL CHECK (year > 1900),
    type TEXT NOT NULL DEFAULT 'APR' CHECK (type IN ('APR', 'Case History', 'Incident', 'Thank You', 'Birthday', 'Financial Tracking', 'Monthly Subsidy Report')),
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

-- ==========================================
-- 6. LOAN SYSTEM (Higher Education)
-- ==========================================
CREATE TABLE loans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
    institution_id UUID REFERENCES educational_institutions(id),
    status TEXT DEFAULT 'Studying' CHECK (status IN ('Studying', 'Refunding', 'Complete', 'Overdue', 'Expired')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE loan_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    loan_id UUID NOT NULL REFERENCES loans(id) ON DELETE RESTRICT,
    transaction_date DATE DEFAULT CURRENT_DATE,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    type TEXT NOT NULL CHECK (type IN ('repayment', 'waiver', 'adjustment')),
    recorded_by UUID REFERENCES users(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE TABLE disbursements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
    contribution_id UUID NOT NULL REFERENCES contributions(id) ON DELETE RESTRICT,
    payment_category_id UUID NOT NULL REFERENCES payment_categories(id) ON DELETE RESTRICT,
    institution_id UUID REFERENCES educational_institutions(id) ON DELETE SET NULL,
    loan_id UUID REFERENCES loans(id) ON DELETE RESTRICT,

    subsidy_purpose TEXT,
    receipts_verified BOOLEAN DEFAULT FALSE,
    verified_amount NUMERIC(12, 2),

    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0), -- Amount in BDT

    disbursement_date DATE DEFAULT CURRENT_DATE,
    recorded_by UUID REFERENCES users(id) ON DELETE SET NULL,
    status TEXT DEFAULT 'Paid' CHECK (status IN ('Paid', 'Pending', 'Cancelled')),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

CREATE INDEX idx_disbursements_institution_id ON disbursements(institution_id);

CREATE TABLE migration_metadata (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name TEXT NOT NULL,
    source_id TEXT NOT NULL,
    target_uuid UUID NOT NULL,
    migration_batch TEXT,
    migrated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sandbox Import — landing zone for raw legacy data before processing
CREATE TABLE sandbox_imports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    target_table TEXT NOT NULL, -- 'students', 'sponsors', 'contributions'
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
    student_id UUID REFERENCES students(id) ON DELETE RESTRICT,
    sponsor_id UUID REFERENCES sponsors(id) ON DELETE RESTRICT,

    -- Content (captured once at creation, immutable after send)
    subject TEXT NOT NULL,
    message_body TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('Financial', 'Milestone', 'Academic', 'Manual', 'Broadcast')),

    -- Staff workflow state
    workflow_status TEXT NOT NULL DEFAULT 'Draft'
        CHECK (workflow_status IN ('Draft', 'Review', 'Approved', 'Returned', 'Sent', 'Archived', 'Deleted')),
    return_reason TEXT,
    approved_by UUID REFERENCES users(id) ON DELETE SET NULL,
    approved_at TIMESTAMPTZ,
    archived_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,

    -- Delivery snapshot (filled on send)
    channel TEXT,
    recipient TEXT,
    template_id UUID REFERENCES communication_templates(id) ON DELETE SET NULL,
    delivery_log JSONB,
    sent_at TIMESTAMPTZ,

    -- Sponsor read tracking
    read_at TIMESTAMPTZ,  -- NULL = unread

    report_id UUID REFERENCES reports(id) ON DELETE SET NULL,

    CONSTRAINT chk_comm_owner CHECK (
        (category = 'Broadcast' AND student_id IS NULL AND sponsor_id IS NULL) 
        OR 
        (category != 'Broadcast' AND student_id IS NOT NULL AND sponsor_id IS NOT NULL)
    ),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    row_version INT DEFAULT 1
);

-- ==========================================
-- 7. BACKUP & FINANCIAL INTEGRITY
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

-- ==========================================
-- 8. FINANCIAL INTEGRITY TRIGGERS
-- ==========================================

-- Overdraft Prevention: disbursements must not exceed their source contribution
CREATE OR REPLACE FUNCTION fn_enforce_disbursement_limits()
RETURNS TRIGGER AS $$
DECLARE
    v_total_used NUMERIC(12,2);
    v_limit NUMERIC(12,2);
BEGIN
    SELECT amount INTO v_limit FROM contributions WHERE id = NEW.contribution_id;

    SELECT COALESCE(SUM(d.amount), 0) INTO v_total_used
    FROM disbursements d
    WHERE d.contribution_id = NEW.contribution_id
      AND (TG_OP = 'INSERT' OR d.id <> NEW.id);

    IF (v_total_used + NEW.amount) > v_limit THEN
        RAISE EXCEPTION 'Disbursement Overdraft: Attempted to disburse %, but only % remains from contribution %.',
            NEW.amount, (v_limit - v_total_used), NEW.contribution_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_limit_disbursement_overdraft
BEFORE INSERT OR UPDATE ON disbursements
FOR EACH ROW EXECUTE FUNCTION fn_enforce_disbursement_limits();

-- Loan Consistency: repayable category requires loan_id; non-repayable rejects it
-- Also prevents cross-assigning debt by ensuring disbursement student matches loan student
CREATE OR REPLACE FUNCTION fn_enforce_loan_consistency()
RETURNS TRIGGER AS $$
DECLARE
    v_is_repayable BOOLEAN;
    v_loan_student_id UUID;
BEGIN
    SELECT is_repayable INTO v_is_repayable FROM payment_categories WHERE id = NEW.payment_category_id;

    IF v_is_repayable AND NEW.loan_id IS NULL THEN
        RAISE EXCEPTION 'Loan Required: Payment category % is repayable but no loan_id provided.', NEW.payment_category_id;
    END IF;

    IF NOT v_is_repayable AND NEW.loan_id IS NOT NULL THEN
        RAISE EXCEPTION 'Unexpected Loan: Payment category % is not repayable but loan_id was set.', NEW.payment_category_id;
    END IF;

    -- Cross-assignment check: disbursement student must match loan student
    IF NEW.loan_id IS NOT NULL THEN
        SELECT student_id INTO v_loan_student_id FROM loans WHERE id = NEW.loan_id;
        IF NEW.student_id != v_loan_student_id THEN
            RAISE EXCEPTION 'Cross-Assignment Denied: Disbursement student % does not match loan student %.',
                NEW.student_id, v_loan_student_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ensure_loan_consistency
BEFORE INSERT OR UPDATE ON disbursements
FOR EACH ROW EXECUTE FUNCTION fn_enforce_loan_consistency();

CREATE TABLE audit_logs (
    id UUID DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- Fix: Handle user deletion
    module TEXT NOT NULL,
    action TEXT NOT NULL,
    target_id UUID,
    target_type TEXT,
    mutation_detail JSONB,
    ip_address INET,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

-- Audit log lifecycle:
--   - Monthly partition auto-created by fn_create_audit_partition()
--   - Partitions older than 6 months dropped by fn_drop_audit_partitions()
-- Both scheduled via Laravel artisan command.

CREATE OR REPLACE FUNCTION fn_create_audit_partition()
RETURNS void AS $$
DECLARE
    partition_name TEXT;
    start_date TEXT;
    end_date TEXT;
BEGIN
    partition_name := 'audit_logs_' || TO_CHAR(NOW(), 'YYYY_MM');
    start_date := DATE_TRUNC('month', NOW())::TEXT;
    end_date := (DATE_TRUNC('month', NOW()) + INTERVAL '1 month')::TEXT;

    IF NOT EXISTS (
        SELECT 1 FROM pg_class WHERE relname = partition_name
    ) THEN
        EXECUTE format(
            'CREATE TABLE %I PARTITION OF audit_logs
             FOR VALUES FROM (%L) TO (%L)',
            partition_name, start_date, end_date
        );
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_drop_audit_partitions()
RETURNS void AS $$
DECLARE
    part RECORD;
BEGIN
    FOR part IN
        SELECT inhrelid::regclass::text AS partition_name
        FROM pg_inherits
        WHERE inhparent = 'audit_logs'::regclass
    LOOP
        IF part.partition_name ~ '^audit_logs_\d{4}_\d{2}$'
           AND TO_DATE(SPLIT_PART(part.partition_name, '_', 3) || '_01', 'YYYY_MM_DD')
               < DATE_TRUNC('month', NOW()) - INTERVAL '6 months'
        THEN
            EXECUTE format('DROP TABLE IF EXISTS %I', part.partition_name);
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Create the first partition for the current month
SELECT fn_create_audit_partition();

-- ==========================================
-- 10. VIEWS FOR REPORTING
-- ==========================================
CREATE VIEW view_student_disbursements AS
SELECT 
    d.id AS disbursement_id,
    d.student_id,
    (s.first_name || ' ' || s.last_name) AS student_name,
    s.master_id_number,
    d.contribution_id AS source_contribution_id,
    s.current_program_id AS program_id,
    pg.name AS program_name,
    pc.name AS payment_category,
    pc.is_repayable,
    d.loan_id,
    d.amount,
    d.subsidy_purpose,
    d.receipts_verified,
    d.verified_amount,
    d.disbursement_date,
    d.status
FROM disbursements d
INNER JOIN students s ON d.student_id = s.id
LEFT JOIN programs pg ON s.current_program_id = pg.id
INNER JOIN payment_categories pc ON d.payment_category_id = pc.id;

CREATE VIEW view_loan_balances AS
SELECT 
    l.id AS loan_id,
    l.student_id,
    COALESCE(p.total_disbursed, 0) AS total_disbursed,
    COALESCE(lt.total_credits, 0) AS total_credits,
    COALESCE(lt.total_repayments, 0) AS total_repayments,
    COALESCE(lt.total_waivers, 0) AS total_waivers,
    COALESCE(lt.total_adjustments, 0) AS total_adjustments,
    COALESCE(p.total_disbursed, 0) - COALESCE(lt.total_credits, 0) AS outstanding_balance,
    CASE 
        WHEN p.total_disbursed IS NULL THEN 'Pending Disbursement'
        WHEN COALESCE(p.total_disbursed, 0) - COALESCE(lt.total_credits, 0) <= 0 THEN 'Complete'
        ELSE l.status
    END AS effective_status
FROM loans l
LEFT JOIN (
    SELECT p.loan_id, SUM(p.amount) AS total_disbursed
    FROM disbursements p
    INNER JOIN payment_categories pc ON p.payment_category_id = pc.id
    WHERE pc.is_repayable = true AND p.status = 'Paid'
    GROUP BY p.loan_id
) p ON l.id = p.loan_id
LEFT JOIN (
    SELECT 
        loan_id,
        SUM(amount) AS total_credits,
        SUM(CASE WHEN type = 'repayment' THEN amount ELSE 0 END) AS total_repayments,
        SUM(CASE WHEN type = 'waiver' THEN amount ELSE 0 END) AS total_waivers,
        SUM(CASE WHEN type = 'adjustment' THEN amount ELSE 0 END) AS total_adjustments
    FROM loan_transactions
    GROUP BY loan_id
) lt ON l.id = lt.loan_id;

-- ==========================================
-- 11. INDEXES & TRIGGERS
-- ==========================================
CREATE INDEX idx_student_names ON students USING gin (first_name gin_trgm_ops, last_name gin_trgm_ops);
CREATE INDEX idx_sponsor_names ON sponsors USING gin (full_name gin_trgm_ops);
CREATE INDEX idx_audit_details ON audit_logs USING gin (mutation_detail jsonb_path_ops);
CREATE INDEX idx_student_master_id ON students(master_id_number);
CREATE INDEX idx_contribution_sponsor ON contributions(sponsor_id);
-- Performance Indexes
CREATE INDEX idx_sponsorships_student_id ON sponsorships(student_id);
CREATE INDEX idx_sponsorships_sponsor_id ON sponsorships(sponsor_id);
CREATE INDEX idx_academic_records_orphanage_id ON academic_records(orphanage_id);
CREATE INDEX idx_academic_records_village_sector_id ON academic_records(village_sector_id);
CREATE INDEX idx_loans_institution_id ON loans(institution_id);
CREATE INDEX idx_payment_categories_program_id ON payment_categories(program_id);

-- Fix: Additional Foreign Key Indexes for Reporting Performance
CREATE INDEX idx_loan_transactions_loan_id ON loan_transactions(loan_id);
CREATE INDEX idx_enrollments_student_id ON enrollments(student_id);
CREATE INDEX idx_guardians_student_id ON guardians(student_id);
CREATE INDEX idx_communications_student_sponsor ON communications(student_id, sponsor_id);
CREATE INDEX idx_communications_wf_status ON communications(workflow_status);
CREATE INDEX idx_communications_deleted ON communications(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_communications_read ON communications(sponsor_id, read_at) WHERE read_at IS NULL;
CREATE INDEX idx_loans_student_id ON loans(student_id);
CREATE INDEX idx_disbursements_student_id ON disbursements(student_id);
CREATE INDEX idx_disbursements_contribution_id ON disbursements(contribution_id);
CREATE INDEX idx_disbursements_payment_category_id ON disbursements(payment_category_id);
CREATE INDEX idx_disbursements_loan_id ON disbursements(loan_id);
CREATE INDEX idx_reports_student_id ON reports(student_id);

CREATE TRIGGER trg_upd_programs BEFORE UPDATE ON programs FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_orphanages BEFORE UPDATE ON orphanages FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_village_sectors BEFORE UPDATE ON village_sectors FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_users BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_students BEFORE UPDATE ON students FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_student_identifiers BEFORE UPDATE ON student_identifiers FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_sponsors BEFORE UPDATE ON sponsors FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_sponsorships BEFORE UPDATE ON sponsorships FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
-- Financial ledgers (contributions, disbursements, loan_transactions) are immutable; no update trigger.
CREATE TRIGGER trg_upd_academic_records BEFORE UPDATE ON academic_records FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_attendance_records BEFORE UPDATE ON attendance_records FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_documents BEFORE UPDATE ON documents FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_reports BEFORE UPDATE ON reports FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_upd_student_history BEFORE UPDATE ON student_history FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
-- disbursements is immutable
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
CREATE TRIGGER trg_upd_payment_categories BEFORE UPDATE ON payment_categories FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
