# RBAC Logic & Role Design

This document captures the thought process, open questions, and design decisions around role-based access control for the Bangla Hope SMS.

---

## 1. Role Hierarchy

```
Admin ─── System owner, account management, full override
  │
Director ─── Highest operational authority, final approver
  │
Coordinator ─── Program-specific, daily operations
  │
Secretary ─── Data entry, letter drafting
  │
Sponsor ─── External, read-only (sponsored children only)
```

### Decision: Supervisor → Director

The name "Supervisor" was misleading — it connotes middle-management, but the role is the **highest operational authority** (final approver for documents, student status changes, financial sign-off). Renamed to **Director**.

> **Status:** ✅ **Resolved.** Updated in `PERMISSIONS.md` accordingly.

---

## 2. Role Boundary Issues

### Secretary vs Coordinator — where is the line?

| Module | Secretary | Coordinator |
|---|---|---|
| Student Master Records | View / Edit | View / Edit |
| Academic & Results | Edit | Full Access |
| Attendance | Edit | Full Access |
| Sponsorship Income | View | Create / Edit |
| Higher Ed Loan | -- | Create / Edit |
| Archive / Drop | -- | Request |

**Problem:** Both have "View / Edit" on Student Records. The matrix doesn't distinguish who can *create* vs merely *edit*. If Secretary can't add new students, the matrix should say "Edit (no Create)".

**Questions:**
- Can a Secretary register a new student, or only update existing ones?
- Can a Secretary record a financial payout, or only view what Coordinators entered?
- Is there a workflow where Secretary drafts → Coordinator reviews → Director approves?

> **Status:** Needs definition.

### Director segregation of duties

Director has **Full Access** on financial modules (Sponsorship Income, Subsidies, Loans) AND is the approver for documents and archives. This means they can enter data and also approve it.

**Question:** In a small NGO with ~5 staff, is this acceptable, or should there be a rule like *"Director cannot approve their own entries"*?

> **Status:** Needs decision.

---

## 3. Program Scoping — Coordinator is Program-Specific

### Decision: Coordinators are scoped by program

A Coordinator is assigned to one or more specific programs. Their access is restricted to data within their assigned programs only.

**Model:** A `user_programs` junction table links a Coordinator to specific programs (LRC, BRD, VLG, LON, STF). Every query is filtered by `WHERE program_id IN (user's assigned programs)`.

### Open questions:
- Can a Coordinator be assigned to multiple programs? (e.g., manages both LRC and Boarding)
- Can a Coordinator be scoped further — to a specific facility within a program? (e.g., one person manages 3 of the 11 village schools, not all 11)
- Does program scoping apply to **all** modules? (Student Records, Academics, Attendance, Finance — all scoped)
- How do cross-program transitions work? If a student moves from VLG → LON, which Coordinator handles them at each stage?

> **Status:** ✅ **Program-specific is decided.** Facility-level granularity within a program is still open.

---

## 4. Sponsor Portal Access Logic

"View (Limited)" and "View (Personal)" are business rules, not just RBAC. The proposed logic:

1. **My Sponsored Children** — Sponsor sees students linked to their `sponsor_id` via `sponsorships`. Financial data limited to their own contributions.
2. **Needy Students (Browse)** — Any logged-in sponsor can browse unsponsored children, but sensitive fields are redacted (exact village, guardian contacts).
3. **Case Studies** — Only visible if a Supervisor has marked them `Approved`.

**Question:** Is there a **Public Visitor** role (unauthenticated browsing) for the Sponsor Portal, or must everyone log in first?

> **Status:** Needs clarification.

---

## 5. Approval Workflows

### Currently defined:
| Workflow | Drafted by | Reviewed by | Approved by |
|---|---|---|---|
| Thank You Letters / APR | Secretary (Draft) | Coordinator (Edit) | **Director** |
| Archive / Drop Student | Coordinator (Request) | -- | **Director** |

### Not yet defined:
| Workflow | Who initiates? | Who approves? |
|---|---|---|
| Loan disbursement | Coordinator? | ? |
| Large subsidy payout (threshold?) | ? | ? |
| Sponsor communication (manual) | Secretary? | ? |
| Student transfer between programs | ? | ? |
| Write-off / adjustment of financial records | ? | ? |

### Questions:
- Should all financial outflows require **two-person approval** (initiator + approver)?
- Is there a dollar threshold where approval is required?
- Can a Secretary send a Thank You letter using an approved template without additional sign-off?

> **Status:** Needs definition.

---

## 6. Admin Role — Tech vs Org Authority

### Current boundary:
- **Admin** — Exclusive access to Site & User Registry, Data Migration, System Health, Backups
- **Director** — Highest operational authority, approves documents & financial sign-off

The intent is:
- **Admin** = Technical system owner (server, users, migration, backups)
- **Director** = Organizational authority (student lifecycle, finance, approvals)

They are **separate roles** — Admin handles the system, Director runs the operations. Admin should not be editing student records or approving finance, and Director should not be managing user accounts or migrations.

> **Status:** ✅ **Resolved.** Admin is technical, Director is operational. Boundary stays.

---

## 7. Open Decisions Summary

| # | Decision | Status | Notes |
|---|---|---|---|
| 1 | Supervisor → Director rename | ✅ **Done** | Updated throughout |
| 2 | Secretary create permission | ❌ Open | Can Secretary create students or edit only? |
| 3 | Program-level scoping | ✅ **Decided** | Coordinator is program-specific via `user_programs` |
| 4 | Facility-level granularity within a program | ❌ Open | e.g., one coordinator covers 3 of 11 village schools |
| 5 | Director self-approval | ❌ Open | Allowed or blocked? |
| 6 | Sponsor portal auth | ❌ Open | Login required or public visitor allowed? |
| 7 | Financial approval thresholds | ❌ Open | None / Dollar threshold / Two-person rule |
| 8 | Admin vs Director boundary | ✅ **Decided** | Admin = tech, Director = operational |
| 9 | Secretary financial permissions | ✅ **Resolved** | Create/Edit on income & subsidies |
| 10 | Cross-program transitions | ❌ Open | Which Coordinator handles a moving student? |

*This document is a working draft. Each decision should be moved to `CLIENT_CLARIFICATIONS.md` once finalized and reflected in `technical/PERMISSIONS.md` (the permission matrix) and `technical/schema.sql` (the `user_programs` table if applicable).*
