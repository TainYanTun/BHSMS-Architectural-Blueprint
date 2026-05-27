# Bangla Hope Blueprint

**Senior Development Project 1: Orphanage Sponsorship & Student Management System**

This repository contains the initial wireframes, prototypes, and design blueprints for the **Bangla Hope** management system. The project aims to provide a comprehensive digital solution for managing student records, sponsorship details, and program-wide analytics for the Bangla Hope orphanage and its associated educational programs.

## Project Overview

Bangla Hope is a sponsorship program that supports children across multiple platforms:
- **LRC Children's Home:** A residential campus for orphans.
- **Boarding Schools:** Mixed residential facilities.
- **Village Day Schools:** Local community schools (11+ locations).

This system is designed to streamline administrative tasks, track student progress (APR - Annual Progress Reports), and manage sponsor relationships.

## Key Modules & Prototypes

The project currently includes several wireframe variants, ranging from high-fidelity UI concepts to low-fidelity functional blueprints:

### 1. Program Dashboard (`bh_dashboard.html`)
*   **Status:** High-Fidelity Prototype
*   **Features:** 
    *   Real-time statistics (Total Students, Active Sponsors, Monthly Subsidy).
    *   Program-specific enrollment tracking.
    *   Recent activity logs (Admissions, Report generation).
    *   Quick actions for administrative tasks.

### 2. Student Directory (`wireframe/bh_students_blueprint.html`)
*   **Status:** Low-Fidelity Blueprint (B&W)
*   **Features:**
    *   Master grid view of all students with unique UIDs.
    *   Tabbed interface for: Info, Case History, Sponsors, and APR Logs.
    *   Filtering system by Name, Gender, and Program.

### 3. Admission Entry (`wireframe/bh_admit_blueprint.html`)
*   **Status:** Low-Fidelity Blueprint (B&W)
*   **Features:**
    *   Standardized schema for new child admissions.
    *   Sections for Personal Identity, Program Placement, and Guardian Narratives.
    *   Operational controls for Draft Saving and Confirmation.

## 🛠️ Tech & Design Stack

- **Wireframing:** HTML5 / CSS3 (Vanilla)
- **Typography:** 
    - *System Fonts:* Courier New (Blueprints), Nunito/Lora (High-Fidelity)
- **Methodology:** Component-based UI design focusing on administrative efficiency.
- **Financial Architecture:** **Record-Keeping Only.** The system functions as a manual digital ledger for storage and tracking; it contains no logic for real-world payment processing or financial transactions.

## Directory Structure

```text
Bangal_hope_blueprint/
├── wireframe/
│   ├── bh_admit_blueprint.html     # Admission form schema
│   ├── bh_dashboard_blueprint.html # Dashboard structure
│   └── bh_students_blueprint.html  # Student management grid
├── bh_dashboard.html               # High-fidelity dashboard UI
├── bh_complete_sample.html         # Integrated sample view
└── README.md                       # Project documentation
```

## Project Status

This is currently in **Phase 1: Wireframing & Prototyping**. These files serve as the architectural foundation for the Senior Development Project 1. Future phases will include database integration, backend development, and user authentication.

---
*Developed as part of the Senior Development Project 1 curriculum.*
