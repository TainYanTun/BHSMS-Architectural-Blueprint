# Bangla Hope Blueprint

**Senior Development Project: Orphanage Sponsorship & Student Management System**

This repository contains the architectural blueprints, database schemas, and high-fidelity prototypes for the **Bangla Hope SMS**, a centralized system designed to manage sponsorship programs for orphans, destitute children, and vulnerable families in Bangladesh.

---

## Project Overview

The Bangla Hope Management System is designed to replace legacy MS Access workflows with a modern, scalable, and secure platform. It consolidates six distinct humanitarian programs into a single source of truth, ensuring data integrity across a student's entire lifecycle—from admission to higher education.

### The Six Core Programs
1.  **Residential Program (LRC):** Full care for children at the Love Receiving Center.
2.  **Boarding School Program:** Sponsorship for students in residential education.
3.  **Village Schools Program:** Community-based day school support for ~550 students.
4.  **Higher Study Loan Program:** University and vocational training financial support.
5.  **Employee Children Program:** Benefits management for staff members' families.
6.  **Archive / Drop System:** Permanent historical records for all former program participants.

---

## Architectural Pillars

-   **Master-Relational Data Model:** Every student is assigned a unique, permanent **Master ID**. Program-specific IDs are preserved for historical context, allowing seamless transitions between programs.
-   **Immutable Financial Ledger:** A high-integrity "Battery Model" for tracking USD contributions. The system uses immutable transaction logs and reversing entries to ensure financial transparency without full accounting complexity.
-   **High-Density Design System:** Optimized for "Data-First" humanitarian work. The UI (detailed in `DESIGN.md`) prioritizes information density, structural clarity, and professional utility using a Navy/Teal professional palette.
-   **Role-Based Access Control (RBAC):** Granular permissions for Admins, Supervisors, Coordinators, and Secretaries to ensure data privacy and operational security.

---

## 📂 Project Structure & Index

### 📁 [core/](./core/) - Project Strategy
*   **[PROPOSAL.md](./core/PROPOSAL.md)**: Original vision, current limitations, and system requirements.
*   **[DESIGN.md](./core/DESIGN.md)**: Visual DNA, typography, color palettes, and component standards.
*   **[CLIENT_CLARIFICATIONS.md](./core/CLIENT_CLARIFICATIONS.md)**: Business rules and edge-case decisions.
*   **[PROGRAM_PARADIGM.md](./core/PROGRAM_PARADIGM.md)**: The underlying logic of the program structures.
*   **[IT483_REPORT.md](./core/IT483_REPORT.md)**: Academic project report and formal documentation.

### 📁 [technical/](./technical/) - System Blueprints
*   **[schema.sql](./technical/schema.sql)**: Production-ready PostgreSQL schema including triggers for auto-ID generation.
*   **[DATA_ARCHITECTURE.md](./technical/DATA_ARCHITECTURE.md)**: Logical domain mapping and sync logic.
*   **[ERD.mmd](./technical/ERD.mmd)**: Entity Relationship Diagram (Mermaid).
*   **[Architecture.mmd](./technical/Architecture.mmd)**: High-level system architecture diagram.
*   **[PERMISSIONS.md](./technical/PERMISSIONS.md)**: RBAC matrix mapping roles to system actions.
*   **[schema_explain.md](./technical/schema_explain.md)**: Detailed breakdown of table relationships.
*   **[OPTIONAL_FEATURES.md](./technical/OPTIONAL_FEATURES.md)**: Roadmap for future system enhancements.

### 📁 [financial/](./financial/) - Money & Ledger
*   **[FINANCIAL_WORKFLOW.md](./financial/FINANCIAL_WORKFLOW.md)**: Logic for subsidies, pocket money, and loans.
*   **[FINANCIAL_GUIDE.md](./financial/FINANCIAL_GUIDE.md)**: Strategic financial management policies.
*   **[bangla_hope_table_guide.md](./financial/bangla_hope_table_guide.md)**: Field-level definitions for financial tables.

### 📁 [communication/](./communication/) - Sponsor Relations
*   **[COMMUNICATION_HUB_GUIDE.md](./communication/COMMUNICATION_HUB_GUIDE.md)**: Templates and trigger logic for comms.
*   **[CHART.md](./communication/CHART.md)**: Communication flow and reporting charts.
*   **[COMMUNICATION_DECISION_MATRIX.md](./communication/COMMUNICATION_DECISION_MATRIX.md)**: Routing logic for different message types.

### 📁 [findings/](./findings/) - Research & Analysis
*   **[ui_ux_standards.md](./findings/ui_ux_standards.md)**: Research on humanitarian UI best practices.
*   **[student_transition.md](./findings/student_transition.md)**: Analysis of student movement between programs.
*   **[higher_education_tracking.md](./findings/higher_education_tracking.md)**: Research on long-term loan tracking.

### 📁 [plans/](./plans/) - Implementation Roadmap
*   **[technical-architecture.md](./plans/technical-architecture.md)**: Detailed server and network strategy.
*   **[system-separation-architecture.md](./plans/system-separation-architecture.md)**: Logic for multi-site operations.
*   **[automation-paradigm.md](./plans/automation-paradigm.md)**: Strategy for automated reports and alerts.
*   **[financial-flow.md](./plans/financial-flow.md)**: Detailed breakdown of the transaction lifecycle.
*   **[job_queue.md](./plans/job_queue.md)**: Background processing and task scheduling design.
*   **[queue-prioritization.md](./plans/queue-prioritization.md)**: Handling high-volume report generation.
*   **[audit-log-partitioning.md](./plans/audit-log-partitioning.md)**: Performance strategy for large-scale logging.

### 📁 [ui/](./ui/) - Interface Prototypes
*   **[prototype/](./ui/prototype/)**: Interactive HTML/CSS/JS prototypes (Admin Dashboard, Ledger, etc.).
*   **[wireframe/](./ui/wireframe/)**: Low-fidelity structural blueprints for all system screens.
*   **[assets/](./assets/)**: SVG patterns and visual elements.

---

## 🛠️ Technical Stack (Blueprint Phase)

*   **Database:** PostgreSQL 15+ (with GIN indexing and UUID support).
*   **Front-end Style:** Vanilla CSS (Themed with CSS Variables).
*   **Design Framework:** Nunito (Sans) for data, Lora (Serif) for branding.
*   **Diagramming:** Mermaid.js (`.mmd`).

---

## 📈 Project Status

This repository represents the **Architectural Completion Phase**. All schemas, data models, and high-fidelity interface prototypes have been finalized to serve as the foundation for full-scale development.

---
*Developed as part of the Senior Development Project curriculum.*
