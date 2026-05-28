# Technical Architecture Plan: Bangla Hope SMS

This document defines the technical architecture for the Bangla Hope Sponsorship Management System.

## 1. Monorepo Structure
We will adopt a monorepo structure to facilitate shared development, consistent configuration, and simplified CI/CD.

```text
/
├── api/             # Laravel API Backend
├── staff-portal/    # React + Vite Staff Operational UI
├── sponsor-portal/  # React + Vite Sponsor UI
└── README.md
```

## 2. Technology Stack

### 2.1 Backend
*   **Framework:** Laravel (latest stable version)
*   **Database:** PostgreSQL (Schema defined in `BH_blueprint/schema.sql`)
*   **Authentication:** Laravel Sanctum (Token-based SPA authentication)
*   **Queueing:** Laravel Queues (Database driver)

### 2.2 Frontend
*   **Framework:** React (TypeScript)
*   **Build Tool:** Vite
*   **Offline Resilience:** PWA (Service Workers + IndexedDB/localStorage)
*   **State Management:** TanStack Query (React Query) for server-side state

## 3. Communication Architecture
*   **API Protocol:** RESTful API with JSON data exchange.
*   **Versioning:** All routes prefixed with `/api/v1/`.
*   **Shared Logic:** All validation rules and business logic will reside in the Laravel backend to ensure consistency. Frontends will rely on API-driven validation feedback.

## 4. Key Architectural Decisions
*   **Centralized Auth:** The Laravel backend acts as the Single Source of Truth for authentication. Both the Staff and Sponsor frontends will authenticate against the same `/api/v1/login` endpoints using Sanctum tokens.
*   **Separated Frontends:** Maintaining two distinct frontend projects ensures the Staff portal is not cluttered with Sponsor-specific features and vice versa, while maintaining a lean codebase.
*   **Offline First:** The Staff portal will prioritize PWA features to meet the "Offline Resilient Operation" requirement.
