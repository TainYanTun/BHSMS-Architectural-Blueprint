# Plan: System Separation Architecture (Internal Ops vs. Sponsor Portal)

This document outlines the strategic decision to architect the **Bangla Hope SMS** as two distinct frontend applications sharing a common backend infrastructure.

## 1. Objective
Decouple the **Staff Operations System** (Internal Management) from the **Sponsor Portal** (External Engagement) to maximize security, privacy, and user experience.

## 2. Structural Split

### A. Main Operations System (The "Engine")
*   **User Base:** Internal staff (Admins, Coordinators, Supervisors, Secretaries).
*   **UI Focus:** High-density data entry, complex auditing, bulk document generation, and detailed student/financial management.
*   **Privacy Level:** **Unrestricted.** Access to all PII (Personally Identifiable Information), including guardian contacts and village locations.
*   **Deployment:** Private internal server or restricted VPN-access cloud instance.

### B. Sponsor Portal (The "Storefront")
*   **User Base:** External donors and potential sponsors.
*   **UI Focus:** Emotional storytelling, mobile-friendly design, personal communication history, and tax receipt downloads.
*   **Privacy Level:** **Redacted.** Only displays supervisor-approved case studies, photos, and general student progress. All sensitive family and location data is hidden.
*   **Deployment:** Public-facing cloud environment (AWS/Vercel/DigitalOcean) for global accessibility.

## 3. Communication Strategy: Shared API
Both applications will communicate with the same **PostgreSQL database** through a **Shared API Layer**, using distinct access scopes:

1.  **Staff API Scope:** Full CRUD permissions across all tables.
2.  **Sponsor API Scope:** Read-only access to a strictly filtered "Public View" of the student and sponsorship tables.

## 4. Key Benefits

*   **Security by Isolation:** A security breach on the public Sponsor Portal cannot "spill over" into internal admin controls.
*   **Performance Optimization:** The internal system can be optimized for raw data processing speed, while the portal is optimized for media delivery (photos/videos).
*   **Independent Updates:** Features for sponsors (like new payment methods) can be updated without interrupting critical internal staff workflows.

## 5. Offline Resilience Strategy

To handle the requirement for "Offline remote operation" within our centralized architecture, the **Staff Operations System** will be implemented as a **Progressive Web App (PWA)**:

*   **Client-Side Resilience:** Data entry actions during intermittent network connectivity will be queued locally in the browser (using `IndexedDB` or `localStorage`).
*   **Automatic Synchronization:** Once network connectivity is restored, the application will automatically attempt to synchronize queued operations with the central server.
*   **No Site-Level Synchronization:** We have explicitly rejected site-level "heartbeat" or machine state tracking, as all data persistence is handled via the central server's transaction rules, ensuring simplicity and maintainability.

