# Bangla Hope Blueprint

**Capstone Project: Bangla Hope Sponsorship Management System (Bangla Hope SMS)**

This repository contains the architectural blueprints, database schemas, and activity diagrams for the **Bangla Hope SMS**, a centralized web-based system designed to manage sponsorship programs for orphans, destitute children, and underprivileged women in Bangladesh.

---

## Project Overview

The Bangla Hope SMS replaces legacy MS Access and paper-based processes with a modern, scalable platform. It consolidates five distinct sponsorship programs into a single source of truth, ensuring data integrity across a student's entire lifecycle — from admission to program transition and sponsorship tracking.

### The Five Core Programs
1.  **Orphanage (Residential Campus / LRC):** Full care for children at the Love Receiving Center.
2.  **Boarding School Program:** Sponsorship for students in residential education.
3.  **Village Schools Program:** Community-based day school support for ~550 students.
4.  **Higher Study Loan Program:** University and vocational training financial support.
5.  **Employee Children Program:** Benefits management for staff members' families.

---

## Architectural Pillars

-   **Master-Relational Data Model:** Every student is assigned a unique, permanent **Master ID**. Program-specific IDs are preserved for historical context, allowing seamless transitions between programs.
-   **Immutable Financial Ledger:** A high-integrity system for tracking contributions and payouts entirely in **BDT (Bangladeshi Taka)**. Simplified single-currency ledger — no exchange rate management needed.
-   **Role-Based Access Control (RBAC):** Granular permissions for Administrators, Directors, Coordinators, Secretaries, and Sponsors to ensure data privacy and operational security. Coordinator access is scoped to their assigned program.
-   **Offline Resilience (PWA):** The Staff Portal functions as a Progressive Web App with IndexedDB caching for offline data entry and automatic sync when the network is restored.
-   **Partitioned Audit Log:** Monthly range partitions on `audit_logs` with automatic partition creation and drop-after-6-months retention. No archive schema — stale partitions are dropped directly.

---

## 📂 Project Structure & Index

### 📁 [activity-diagram/](./activity-diagram/) — Workflow Diagrams
PlantUML source files for 7 activity diagrams with swimlanes, plus rendered PNG/SVG outputs:
- **student** — Student intake, enrollment, lifecycle
- **sponsor** — Sponsor onboarding and registration
- **finance** — Contributions (income) and payouts (expenditure) in BDT
- **loan** — Loan setup, disbursement, repayment loop
- **report** — APR, Thank You letters, communications approval workflow
- **transition** — Student program transfers (including institution selection for Loan Program)
- **migration** — Legacy data ETL with sandbox preview, validation, fix-retry, and approval pipeline

### 📁 [technical/](./technical/) — System Blueprints
- **[schema.sql](./technical/schema.sql):** PostgreSQL schema — 30+ tables, triggers, audit log partition functions, BDT-only payouts, LIST-partitioned business data by status
- **[DATA_ARCHITECTURE.md](./technical/DATA_ARCHITECTURE.md):** Logical domain mapping and sync logic
- **[ERD.mmd](./technical/ERD.mmd):** Entity Relationship Diagram (Mermaid) covering all 7 domains
- **[Architecture.mmd](./technical/Architecture.mmd):** System architecture diagram (FrankenPHP + Laravel + PostgreSQL)
- **[PERMISSIONS.md](./technical/PERMISSIONS.md):** RBAC matrix mapping 5 roles to system actions
- **[schema_explain.md](./technical/schema_explain.md):** Detailed breakdown of table relationships and conventions
- **[OPTIONAL_FEATURES.md](./technical/OPTIONAL_FEATURES.md):** Future enhancement roadmap

### 📁 [financial/](./financial/) — Money & Ledger
- **[FINANCIAL_WORKFLOW.md](./financial/FINANCIAL_WORKFLOW.md):** Logic for subsidies, pocket money, and loans
- **[FINANCIAL_GUIDE.md](./financial/FINANCIAL_GUIDE.md):** Currency handling policies (BDT-only), audit trail, reconciliation
- **[bangla_hope_table_guide.md](./financial/bangla_hope_table_guide.md):** Field-level definitions for financial tables

### 📁 [core/](./core/) — Project Strategy
- **[PROPOSAL.md](./core/PROPOSAL.md):** Original vision, current limitations, and system requirements
- **[DESIGN.md](./core/DESIGN.md):** Visual DNA, typography, color palettes, component standards
- **[CLIENT_CLARIFICATIONS.md](./core/CLIENT_CLARIFICATIONS.md):** Business rules and edge-case decisions
- **[PROGRAM_PARADIGM.md](./core/PROGRAM_PARADIGM.md):** The underlying logic of the program structures

### 📁 [communication/](./communication/) — Sponsor Relations
- **[COMMUNICATION_HUB_GUIDE.md](./communication/COMMUNICATION_HUB_GUIDE.md):** Templates, trigger logic, and delivery rules
- **[CHART.md](./communication/CHART.md):** Communication flow and reporting charts
- **[COMMUNICATION_DECISION_MATRIX.md](./communication/COMMUNICATION_DECISION_MATRIX.md):** Routing logic for different message types

### 📁 [findings/](./findings/) — Research & Analysis
- **[ui_ux_standards.md](./findings/ui_ux_standards.md):** Research on humanitarian UI best practices
- **[student_transition.md](./findings/student_transition.md):** Analysis of student movement between programs
- **[higher_education_tracking.md](./findings/higher_education_tracking.md):** Research on long-term loan tracking

### 📁 [plans/](./plans/) — Implementation Architecture
- **[audit-log-partitioning.md](./plans/audit-log-partitioning.md):** Monthly partition strategy with 6-month drop retention
- **[job_queue.md](./plans/job_queue.md):** Background processing and task scheduling design
- **[queue-prioritization.md](./plans/queue-prioritization.md):** Handling high-volume report generation
- **[technical-architecture.md](./plans/technical-architecture.md):** Server, network, and deployment strategy (FrankenPHP)
- **[system-separation-architecture.md](./plans/system-separation-architecture.md):** Multi-site operations logic
- **[automation-paradigm.md](./plans/automation-paradigm.md):** Automated reports and alerts strategy
- **[financial-flow.md](./plans/financial-flow.md):** Transaction lifecycle breakdown

### 📁 [ui/](./ui/) — Interface Prototypes
- **[prototype/](./ui/prototype/):** Interactive HTML/CSS/JS prototypes (Admin Dashboard, Ledger, etc.)
- **[wireframe/](./ui/wireframe/):** Low-fidelity structural blueprints for all system screens
- **[assets/](./assets/):** SVG patterns and visual elements

---

## 🛠️ Technical Stack (Blueprint Phase)

| Component | Technology |
|-----------|-----------|
| **Frontend** | React + Vite (TypeScript, TailwindCSS) |
| **Backend** | Laravel 11 (PHP) |
| **Application Server** | FrankenPHP (Caddy-based, auto-TLS) |
| **Database** | PostgreSQL 15+ (UUID, GIN indexing, partitioning) |
| **Authentication** | Laravel Sanctum (Token-based) |
| **Offline Storage** | IndexedDB (PWA Staff Portal) |
| **Object Storage** | MinIO (Photos, PDFs, Documents) |
| **Diagramming** | PlantUML (activity diagrams), Mermaid.js (ERD, architecture) |

---

## Key Design Decisions

- **FrankenPHP** replaces Nginx + PHP-FPM — single binary, auto HTTPS, HTTP/2/3
- **BDT-only payouts** — All financial tracking in Bangladeshi Taka. Simplified single-currency ledger. No exchange rate management.
- **Exchange rates** — Not used. The sponsor's US office handles USD/BDT conversion externally.
- **Audit logs** — Monthly range partitions, dropped after 6 months, no archive schema
- **Business data** — LIST partition by status (Active vs Inactive) — no cold storage at ~10k rows
- **Migration pipeline** — ETL with sandbox preview, batch validation, fix-retry before approval commit

---

## Project Status

Active development. Blueprint phase covers schema, workflows, architecture, and interface prototypes as the foundation for full-scale implementation.

---

*Developed as part of Capstone Project 1 — Bangla Hope SMS*
