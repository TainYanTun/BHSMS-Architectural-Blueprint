# Finding: Student Transition & Identification Logic

This document details the architecture and UI workflows for tracking students as they move between different programs at Bangla Hope.

---

## 1. Master-Relational Model (Master ID vs. Program ID)

To ensure the system "knows" a student's history across different modules, we implement a dual-ID system.

### A. The Global Master ID (Internal - UUID)
- **Concept:** Every student is assigned a **UUID (Universally Unique Identifier)** (e.g., `550e8400-e29b-41d4...`) upon their first admission.
- **Why UUID:** 
    - **Collision-free:** Practically zero probability of duplicates ($2^{128}$ combinations). Even at massive scale, collisions are statistically impossible.
    - **Security:** Prevents guessing student counts or sequence.
    - **Permanent Anchor:** Provides a life-long link for a student regardless of program changes.
- **Function:** This ID is hidden from the user but acts as the primary key that links all program-specific records in the database.

### B. Program-Specific IDs (External)
- **Concept:** Each program (LRC, Boarding, Village, etc.) assigns its own `Program_ID` (e.g., `VLG-102`, `BRD-505`).
- **Function:** These IDs are used for daily operations and match the organizational filing system.

---

## 2. Program ID Generation Logic

The system handles ID generation automatically based on the selected program to prevent duplicates and gaps:

1.  **Prefix Assignment:**
    - `LRC-` : Love Receiving Center (Orphanage)
    - `BRD-` : Boarding Schools
    - `VLG-` : Village Day Schools
    - `LN-`  : Higher Study Loans
    - Removed: Staff Children was not a distinct program — tracked via `staff_parent_id` FK instead

2.  **Auto-Incrementing Sequences:**
    - Upon selecting a program in the Admission form, the system queries the database for the highest existing number in that program category.
    - **Example:** If the last Village student was `VLG-550`, the system suggests `VLG-551`.

3.  **Approval & Override:**
    - The ID field is **read-only by default**.
    - An **"Unlock"** icon allows admins to manually enter an ID for legacy data migration (with immediate duplicate-check approval).

---

## 3. Student Transition UI Workflow (Smart Admission)

The system implements a **"Smart Admission"** flow to handle transitions without re-entering bio-data:

1.  **Initial Choice:**
    - `[+] New Admission`: Generates a new UUID and requires full data entry.
    - `[⇄] Transition Existing`: Used for students moving between programs.

2.  **Transition Process:**
    - **Search Step:** Admin searches the "Global Database" (Active + Archived) by Name or old Program ID.
    - **Contextual Link:** Once selected, the system "links" the existing UUID to the new program.
    - **Data Inheritance:** Bio-data (DOB, Case History, Photos) is automatically pulled into the new form.
    - **Program Entry:** Admin only enters program-specific data (New ID, School Name, Monthly Subsidy).

3.  **State Change:**
    - The old `Program_ID` is marked as `TRANSFERRED` in the database.
    - The new `Program_ID` is marked as `ACTIVE`.
    - Both records remain linked via the same `Master_ID (UUID)`.

---

## 5. Relationship with the Archive (Drop List) System

Transitioning is a specialized form of "Archiving." When a student moves between programs, their status is updated to ensure data integrity.

### A. Record Statuses
- **ACTIVE:** The student is currently enrolled and receiving benefits in this program.
- **TRANSITIONED (Archived):** The student has moved to another Bangla Hope program. The record is preserved for history but is no longer "Active" for billing or APR reports.
- **DROPPED (Archived):** The student has left Bangla Hope (e.g., moved, left school).
- **GRADUATED (Archived):** The student has successfully completed their journey (usually from Higher Study).

### B. The "Universal Archive"
The **Archive Module** (Module VI) acts as a central repository for all non-active records. 
- When a transition occurs, the **Old Program ID** is sent to the Archive with a "Transitioned" flag.
- This allows admins to see a full "Drop List" while distinguishing between students who left the organization and those who simply moved to a new program.

---

## 6. History Tab (Student Profile)
Every student profile will feature a **"Journey"** or **"History"** tab that displays:
- **Timeline:** (e.g., 2022: Admitted VLG-102 [ACTIVE] -> 2026: Transitioned VLG-102 [ARCHIVED] -> 2026: Admitted BRD-505 [ACTIVE]).
- **Archived Records:** One-click access to view reports/APR from the previous program.
