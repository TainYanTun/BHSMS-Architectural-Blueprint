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

## 5. Deployment & Operational Enhancements

### 5.1 Secure Connectivity (Secure Tunneling)
To bridge the gap between the on-premises secure server and remote village schools without exposing the server to the public internet, we will implement **Secure Tunneling** (e.g., Cloudflare Tunnels or Tailscale).
*   **Purpose:** Allows the secure internal server to be accessible via a dedicated subdomain (e.g., `api.banglahope.org`) without requiring port forwarding or a static IP.
*   **Security:** Traffic is encrypted and only authorized requests from the Staff and Sponsor portals are allowed through the tunnel.

### 5.2 Monitoring & Health Checks
Given the heavy reliance on background jobs and Redis for system performance, we will implement integrated monitoring.
*   **Laravel Pulse/Horizon:** Provides a real-time dashboard to monitor server vitals, queue throughput, and job failure rates.
*   **Health Check Endpoints:** Implement `/health` endpoints to monitor database connectivity and service availability, integrated with an external uptime monitoring service.

### 5.3 Image Optimization Engine
To support high-quality student documentation while respecting bandwidth constraints in remote areas, an automated image processing pipeline will be used.
*   **Logic:** Upon upload, an asynchronous background job (Image Intervention) will automatically resize and compress photos (e.g., resizing to 800px wide, converting to WebP format).
*   **Efficiency:** This reduces storage costs on MinIO and ensures fast page loads for sponsors on mobile devices.

