# Bangla Hope Blueprint

**Senior Development Project 1: Orphanage Sponsorship & Student Management System**

This repository contains the organized architectural blueprints, schemas, and prototypes for the **Bangla Hope** management system.

## 📂 Project Structure

The project has been organized into logical modules for better discoverability:

### 📁 [core/](./core/) - Project Basics
*   **[README.md](./README.md)**: This project overview.
*   **[PROPOSAL.md](./core/PROPOSAL.md)**: Original project vision and requirements.
*   **[DESIGN.md](./core/DESIGN.md)**: General design philosophy and UI guidelines.
*   **[CLIENT_CLARIFICATIONS.md](./core/CLIENT_CLARIFICATIONS.md)**: Specific rules and decisions from the client.

### 📁 [technical/](./technical/) - System Architecture
*   **[schema.sql](./technical/schema.sql)**: The complete PostgreSQL database schema.
*   **[DATA_ARCHITECTURE.md](./technical/DATA_ARCHITECTURE.md)**: High-level data flow and sync logic.
*   **[ERD.md](./technical/ERD.md)**: Entity Relationship Diagram (Mermaid).
*   **[PERMISSIONS.md](./technical/PERMISSIONS.md)**: RBAC (Role-Based Access Control) matrix.

### 📁 [financial/](./financial/) - Money & Ledger
*   **[FINANCIAL_WORKFLOW.md](./financial/FINANCIAL_WORKFLOW.md)**: Logic for Subsidies and **Simple Loan 2.0**.
*   **[FINANCIAL_GUIDE.md](./financial/FINANCIAL_GUIDE.md)**: Overall financial architecture policies.
*   **[bangla_hope_table_guide.md](./financial/bangla_hope_table_guide.md)**: Field-level guide for financial tables.

### 📁 [communication/](./communication/) - Sponsor Relations
*   **[COMMUNICATION_HUB_GUIDE.md](./communication/COMMUNICATION_HUB_GUIDE.md)**: Templates and trigger logic for sponsor comms.
*   **[CHART.md](./communication/CHART.md)**: Communication flow and reporting charts.

### 📁 [ui/](./ui/) - Prototypes & Wireframes
*   **[bh_dashboard.html](./ui/bh_dashboard.html)**: High-fidelity administrative dashboard.
*   **[prototype/](./ui/prototype/)**: Interactive HTML prototypes (including the new Financial Ledger).
*   **[wireframe/](./ui/wireframe/)**: Low-fidelity structural blueprints.

---

## 🛠️ Design Philosophy

- **Unified Ledger:** The system uses a single-stream "Battery Model" for loans to prevent data entry errors.
- **Restricted Envelopes:** Sponsor gifts are digitally tagged to specific students to ensure restricted funding integrity.
- **Record-Keeping Only:** This is a **Manual Digital Ledger**; it does not process real-world payments.

## Project Status

This is currently in **Phase 1: Wireframing & Prototyping**. These files serve as the architectural foundation for the Senior Development Project 1.

---
*Developed as part of the Senior Development Project 1 curriculum.*
