# IT483 Project Report: Bangla Hope Sponsorship Management System (SMS)

## Section 1: Introduction

### 1.1 Problem Description
Bangla Hope’s current hybrid system of paper records and a legacy MS Access (2019) database has led to several critical challenges:

1.  **Manual Workflows & Technical Debt:** Disconnected systems and a lack of multi-user support in MS Access lead to frequent data conflicts and manual entry errors.
2.  **Fragmented Data Silos:** Five distinct sponsorship programs operate as independent silos, preventing a unified view of organizational impact.
3.  **Financial & Sponsorship Risks:** The lack of integration between sponsorship status and financial ledgers creates risks of funding gaps or incorrect billing.
4.  **Reporting Latency:** Generating mandatory Annual Progress Reports (APRs) is a weeks-long manual process that impacts donor transparency and trust.
5.  **Lack of Longitudinal Tracking:** Disconnected records make it difficult to track a student’s entire lifecycle as they transition between different programs.
6.  **Geographic Information Lag:** Remote field supervisors cannot access the local database, causing significant delays in data updates at the central office.
7.  **Absence of Audit Trails:** The system lacks traceability, making it impossible to audit data modifications or accidental deletions.
8.  **Inefficient Media Management:** Matching student photos and videos to records for reports is a high-risk, manual process.
9.  **Lack of Real-time Analytics:** Leadership lacks immediate access to key performance indicators (KPIs) like enrollment counts or funding shortfalls.
10. **Data Loss Vulnerabilities:** Storing all data on a single hard drive without automated backups creates a high risk of permanent data loss from hardware failure or theft.

### 1.2 Proposed Solution
The **Bangla Hope Sponsorship Management System (SMS)** is a centralized, web-based platform designed to integrate all organizational workflows:

*   **Centralized Database:** A unified PostgreSQL database to ensure data consistency across all programs and locations.
*   **Automated Document Generation:** Rapid, automated creation of APRs, case histories, and financial summaries.
*   **Role-Based Access Control (RBAC):** Secure, tiered access for Admins, Supervisors, Coordinators, and Secretaries.
*   **Lifecycle Tracking:** A robust mechanism to preserve a student’s full history across all program transitions.
*   **Responsive UI:** A modern interface designed for ease of use by non-technical staff across desktop and mobile devices.

### 1.3 Project Importance
The Bangla Hope SMS is a strategic tool to enhance the organization’s mission:

*   **Operational Efficiency:** Automating administrative tasks allows staff to focus on direct student care.
*   **Donor Retention:** Providing timely, professional reports builds trust and ensures sustained international funding.
*   **Evidence-Based Decisions:** Real-time dashboards enable leadership to make informed decisions using accurate data.
*   **Scalability:** Provides a digital foundation that supports program growth without increasing administrative overhead.

---

## Section 2: Related Works

### 2.1 Detailed Description of Similar Solutions

Several enterprise and open-source solutions exist for Non-Governmental Organizations (NGOs), each offering different strengths and trade-offs.

#### 2.1.1 CiviCRM
CiviCRM is a leading open-source Constituent Relationship Management (CRM) system designed specifically for the needs of non-profit and advocacy organizations.
*   **Key Features:** It excels at managing complex relationships (e.g., "Sponsor of," "Guardian of") and provides robust modules for fundraising, event management, and mass communication. Its open-source nature allows for deep customization without licensing fees.
*   **Limitations for Bangla Hope:** CiviCRM requires significant technical expertise for initial setup and ongoing maintenance. Its user interface is often perceived as dated and complex for non-technical users. Furthermore, mapping the specific "Student Lifecycle" and "Academic Reporting" workflows required by Bangla Hope would require extensive custom PHP development.

#### 2.1.2 Salesforce Nonprofit Cloud
Salesforce offers a comprehensive "Nonprofit Cloud" built on its world-class enterprise CRM platform.
*   **Key Features:** It provides powerful automation (Flows), advanced analytics (Tableau), and a highly professional "Experience Cloud" portal where sponsors can log in to view student updates directly. It is considered the gold standard for large-scale international NGOs.
*   **Limitations for Bangla Hope:** While the first 10 licenses are free, the cost of additional licenses, specialized consultants, and the "Experience Cloud" is prohibitively high for a mid-sized NGO. The learning curve for staff is extremely steep, often requiring a dedicated system administrator.

#### 2.1.3 Odoo (NGO & ERP Modules)
Odoo is a modern, modular Enterprise Resource Planning (ERP) suite that includes CRM, Accounting, and Project Management apps.
*   **Key Features:** Odoo offers a highly intuitive, "app-based" user interface and a "One App Free" plan. Its subscription module is excellent for recurring sponsorship payments, and its website builder can be used to create student galleries.
*   **Limitations for Bangla Hope:** Odoo is a general-purpose business tool. While it can be adapted for NGOs, it lacks native features for tracking student academic progress, child-specific case histories, and the complex "program transition" logic essential to Bangla Hope’s operations. Customizing these features in Odoo's Python-based framework can become costly.

### 2.2 Gap Analysis and Conclusion

| Feature | CiviCRM | Salesforce | Odoo | **Bangla Hope SMS (Proposed)** |
| :--- | :--- | :--- | :--- | :--- |
| **Sponsorship Lifecycle** | Manual Mapping | Custom Objects | Subscription Focused | **Built-in Student-Sponsor Logic** |
| **Academic Tracking** | Third-party plugins | Possible but complex | Project Tasks | **Native Academic/APR Module** |
| **User Interface** | Dated/Complex | Professional/Complex | Modern/Intuitive | **Simplified for Local Staff** |
| **Total Cost** | Low (High Maintenance) | High (Licensing/Admin) | Moderate (Monthly) | **Low (One-time Dev/Local Host)** |
| **Local Offline Support**| Limited | Requires Internet | Requires Internet | **PWA/Offline Resilient Support** |

**Conclusion:**
While existing systems provide powerful CRM capabilities, they either fail to address the specific student-centric lifecycle of Bangla Hope or are too cost-prohibitive and complex for a local NGO environment. The **Bangla Hope SMS** fills this gap by providing a purpose-built, cost-effective, and user-friendly solution that prioritizes student history, academic reporting, and offline resilience in the Bangladeshi context.

---

## Section 3: Project Scopes and Constraints

### 3.1 In-Scope (Detailed)

The system is designed to be a comprehensive management tool for Bangla Hope's administrative and sponsorship operations. The scope includes the following primary modules and features:

#### 3.1.1 Core Functional Modules
*   **Student Registry & Profile Management:** Digital profiles for every child across all 5 major programs (LRC, Boarding, Village, Loan, Employee Children). This includes personal background, health records, and case history.
*   **Sponsorship Lifecycle Tracking:** Managing the one-to-one and many-to-one relationships between students and sponsors/co-sponsors. It tracks sponsorship start dates, status (Active/Waitlist/Graduated), and contribution history.
*   **Academic Progress Reporting (APR):** A dedicated module for inputting grades, teacher remarks, and uploading student photos. This module will automate the generation of the "Annual Progress Report" PDF sent to sponsors.
*   **Program Transition & Migration:** Logic to handle students moving between programs (e.g., transitioning from a Village School to a Boarding School) while maintaining a continuous historical record under a unified "Global ID."
*   **Financial Subsidy Tracking:** Tracking monthly subsidies, pocket money, and specialized funds (e.g., Loan Program refunds) at the student level.
*   **Centralized Archive & Drop Management:** A secure "Drop List" system for students who leave the program, ensuring their historical data is preserved for audit and reference purposes without cluttering active lists.
*   **Communications Hub:** Tracking thank-you letters, email notifications to sponsors, and logging all official communication related to a student.

#### 3.1.2 Technical Scope
*   **Data Migration Engine:** A specialized tool/script to migrate legacy data from multiple Microsoft Access (.accdb) databases and semi-structured Excel sheets into the new PostgreSQL schema. This includes data cleaning and validation logic.
*   **Offline-First Capabilities (PWA):** Given the intermittent internet connectivity in villages, the system will be built as a Progressive Web App (PWA) with client-side caching for critical student lists and basic data entry.
*   **Role-Based Access Control (RBAC):** Implementation of a multi-tiered security model to protect sensitive data:
    *   *Admin:* System owner with full override powers, account management, and database configuration.
    *   *Supervisor:* Quality control and compliance officer, final gatekeeper for official documents (APRs, Case Histories) and student status changes.
    *   *Coordinator:* Primary program operator responsible for student lifecycle management and daily financial entries.
    *   *Secretary:* Administrative support focused on general data entry, letter drafting, and record maintenance.
    *   *Sponsor:* External stakeholders with restricted, read-only access to their specifically supported student(s).
*   **Responsive Web Interface:** A UI optimized for both desktop (office staff) and tablet/mobile (field supervisors) using modern web technologies.

### 3.2 Out-of-Scope
*   **Full Accounting Suite:** The system tracks sponsorship-related finances but will not replace a professional accounting software like QuickBooks for payroll or general ledger management.
*   **Public-Facing Website:** The project focuses on the internal management system, not the public promotional website for Bangla Hope.
*   **Mobile App Stores:** While the system is mobile-friendly (PWA), it will not be published on the Apple App Store or Google Play Store.
*   **Payment Gateway Integration:** Direct processing of credit card/bank transfers is excluded. The system records successful payments but does not initiate them.

### 3.3 Quantitative Performance Requirements
*   **Concurrency:** Support for 30–50 concurrent users without performance degradation.
*   **Response Time:** Page load times under 2 seconds for standard data views and under 5 seconds for complex search queries across thousands of records.
*   **Report Generation:** PDF generation for individual student reports (APR) in under 3 seconds with bulk generation for an entire school in under 1 minute.
*   **Data Volume:** Capable of managing records for up to 10,000 students (active and archived) and 5,000 sponsors.
*   **Availability:** Targeted 99% uptime when deployed on a stable local network or private cloud.

### 3.4 Constraints and Limitations
*   **Time Constraint:** The project must be fully functional and tested within the two-semester Capstone timeline (SDP1 and SDP2).
*   **Technical Environment:** The solution must operate effectively in a low-bandwidth environment. High-definition media or heavy cloud dependencies must be avoided or handled via lazy-loading.
*   **Data Integrity of Legacy Records:** Much of the historical data in MS Access is inconsistent or incomplete. The migration process is limited by the quality of these original sources.
*   **Resource Limitations:** The development team consists of two senior students. Complex features (like AI-driven analytics) are deprioritized in favor of core stability and accuracy.
*   **Security & Privacy:** As the system handles sensitive data of minors, it must adhere to strict internal privacy standards, which may limit certain "convenience" features like public sharing links.

---

## Section 4: Analysis and Design

### 4.1 Introduction
The Analysis and Design phase is the critical bridge between understanding the organizational problems of Bangla Hope and building a robust, scalable technical solution. This section details the systematic process of decomposing the organization's requirements into functional specifications and architectural blueprints. 

Following a structured **Iterative Development Model**, this phase focuses on:
1.  **Business Analysis:** Identifying the exact workflows for each of the five sponsorship programs.
2.  **User Requirements:** Defining the specific needs of Admins, Supervisors, Coordinators, and Secretaries.
3.  **System Design:** Mapping out the database schema, API contracts, and user interface components that will realize the proposed solution.

The goal of this phase is to ensure that every technical decision—from the choice of PostgreSQL for data integrity to the React-based PWA for offline resilience is directly grounded in the analyzed needs of Bangla Hope.

#### 4.1.1 Software Process Model: Iterative Development
The Bangla Hope SMS is developed using an **Iterative and Incremental Model**. This approach was selected over a traditional Waterfall model for several strategic reasons:
*   **Early Delivery of Core Value:** By focusing on the "Student Registry" and "Admission" modules in the first iteration, we can provide immediate utility to the staff while more complex logic (e.g., Higher Study Loans) is refined.
*   **Stakeholder Feedback Loop:** Developing in cycles allows us to present UI prototypes to the supervisor early and often. This is critical for ensuring that the final interface is intuitive and requires minimal training.
*   **Risk Management:** Technical challenges, such as MS Access data migration and offline caching, are addressed in early iterations, preventing them from becoming bottlenecks at the end of the project timeline.

### 4.2 Risk Analysis
In alignment with our iterative process model, we have identified several high-impact risks that could affect the project's success. These risks are categorized into Technical, Operational, and Schedule domains, with corresponding mitigation strategies.

#### 4.2.1 Risk Assessment Criteria
To ensure a rigorous and objective analysis, we have defined the following criteria for our risk ratings:

**Impact Levels:**
*   **Critical:** Potential loss of sensitive minor data, security breach, or total system failure.
*   **High:** Failure of a core module (e.g., Sponsorship Tracking) or significant disruption to organizational workflows.
*   **Medium:** Delays in non-critical features or requirement for significant manual workarounds.
*   **Low:** Minor aesthetic issues or workflow inconveniences that do not stop administrative tasks.

**Probability Levels:**
*   **High:** 80%+ chance of occurrence based on historical data or known environmental factors (e.g., local power outages).
*   **Medium:** 30–79% chance of occurrence; represents a realistic threat that requires active monitoring.
*   **Low:** <30% chance of occurrence; represents a possible but unlikely event.

| Risk ID | Risk Category | Description | Impact | Probability | Mitigation Strategy |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **R-01** | **Technical** | **Data Migration Complexity:** Legacy records in MS Access are fragmented and inconsistent. | High | High | Develop a custom migration script with built-in validation rules and data-cleaning passes before final import. |
| **R-02** | **Operational**| **Infrastructure Constraints:** Unreliable internet connectivity in some village schools. | High | Medium | Implement Progressive Web App (PWA) features for client-side caching and offline data entry. |
| **R-03** | **Technical** | **Security of Minor Data:** Sensitive records of orphans and vulnerable children. | Critical | Low | Implement strict Role-Based Access Control (RBAC) and ensure all data is encrypted at rest and in transit. |
| **R-04** | **Schedule**  | **Scope Creep:** Managing five distinct sponsorship programs with unique logic. | Medium | High | Strictly adhere to the "Bounded Scope" defined in Section 3 and prioritize core features over secondary enhancements. |
| **R-05** | **Operational**| **User Adoption:** Non-technical staff may find the transition from MS Access difficult. | Medium | Medium | Design a user-friendly UI that mirrors familiar workflows and provide comprehensive user documentation and training. |
| **R-06** | **Schedule**  | **Team Resource Constraints:** Project is handled by a small team of two developers under 8 months to deliever complete product. | High | Medium | Use a monorepo structure and shared UI components to maximize code reuse and development speed. |
| **R-07** | **Operational**| **Sustainability & Maintenance:** Post-handover support after the developers graduate. | High | High | Provide extensive developer documentation, a clean codebase, and a training session for the organization's IT staff. |
| **R-08** | **Technical** | **Hardware Vulnerability:** Local server failure due to environmental factors (heat/dust) or power surges. | High | Medium | Implement a primary local backup strategy on a secondary machine. Recommend hardware protection (UPS) and investigate off-site/cloud backups is also an avaliable second option. |
| **R-09** | **Legal**      | **Data Privacy Compliance:** International sponsors (USA/Europe) may be subject to GDPR or similar data laws. | Medium | Low | Ensure the system follows "Privacy by Design" principles, including data minimization and secure deletion protocols. |
| **R-10** | **Operational**| **Language Barriers:** Staff may struggle with English-only technical interfaces. | Low | Low | Use intuitive iconography and clear labels. Consider future support for a dual-language (English/Bangla) interface. |
| **R-11** | **Financial**  | **Currency Volatility:** While the system uses USD, local operational costs are in BDT. | Low | High | Standardize all core reporting in USD as per client clarification to maintain a "Truthful Ledger" independent of local rates. |


By identifying these risks early in the Analysis and Design phase, we can integrate preventative measures into the system's architecture, such as the offline-first design (R-02) and a unified validation layer (R-01).

