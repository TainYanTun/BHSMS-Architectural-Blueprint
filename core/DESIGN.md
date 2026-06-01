# Design System Specification (DESIGN.md)

This document serves as the "Visual DNA" and single source of truth for the system's interface. It is optimized for both human developers and AI agents to ensure pixel-perfect consistency across all modules.

---

## 1. Visual Theme & Atmosphere
- **Vibe:** Professional, high-density, and technically rigorous.
- **Aesthetic:** Clean "Data-First" humanitarian style. It prioritizes utility and structural clarity over decorative elements.
- **Atmosphere:** Deep navy surfaces paired with crisp slate-white backgrounds. The interface should feel "instrument-like"—precise, reliable, and dense with information.

## 2. Color Palette & Roles (Theming)

The system uses semantic tokens to support Light and Dark modes seamlessly.

| Semantic Token | Light Mode | Dark Mode | Primary Purpose |
| :--- | :--- | :--- | :--- |
| `primary-navy` | `#1e3a4a` | `#1e3a4a` | Core brand identity. |
| `sidebar-bg` | `#0a1f35` | `#071120` | Navigation sidebar background. |
| `action-teal` | `#2B7A9E` | `#38bdf8` | Primary CTA, links, and luminous accents. |
| `signal-pink` | `#d17a8e` | `#f472b6` | Secondary accents and soft alerts. |
| `success-green` | `#10b981` | `#10b981` | Success states and approvals. |
| `bg-app` | `#f8fafc` | `#020617` | Global application background. |
| `surface` | `#ffffff` | `#0f172a` | Main content cards and surfaces. |
| `surface-subtle`| `#f1f5f9` | `#1e293b` | Table headers, hovers, and sub-surfaces. |
| `border-neutral` | `#e2e8f0` | `#334155` | Dividers and container borders. |
| `text-main` | `#0f172a` | `#f8fafc` | Primary readable text. |
| `text-muted` | `#64748b` | `#94a3b8` | Secondary information and labels. |

## 3. Typography Rules

### 3.1 Font Families
- **Primary Sans:** `Nunito` (Interface, data, and body).
- **Brand Serif:** `Lora` (Titles and high-level headings).
- **Monospace:** `Courier New` (System identifiers, technical paths, and annotations).

### 3.2 Hierarchy Table
| Style | Font | Size | Weight | Case |
| :--- | :--- | :--- | :--- | :--- |
| **Page Title** | Lora | 28px | 600 | Mixed |
| **Section Header** | Lora | 15px | 600 | Mixed |
| **Card Label** | Courier | 10px | 800 | UPPER |
| **Sidebar Link** | Nunito | 13px | 500/600 | Mixed |
| **Sidebar Group** | Nunito | 10px | 700 | UPPER |
| **Table Header** | Nunito | 10px | 700 | UPPER |
| **Table Body** | Nunito | 13px | 400 | Mixed |
| **Path/UID** | Courier | 11px | 700 | UPPER |

## 4. Component Stylings

### 4.1 Modular Cards
- **Radius:** 8px standard.
- **Header:** Features a horizontal linear gradient from `surface-white` to `surface-subtle`.
- **Annotation:** Every card starts with a Teal, upper-case, bold label (e.g., `[SEC_01: MODULE_ID]`).

### 4.2 Data Tables
- **Layout:** High-density, compact rows (40px height).
- **Header BG:** `surface-subtle`.
- **Borders:** 1.5px neutral on headers; 1px soft on rows.
- **Interactions:** Subtle background change on row hover.

### 4.3 Action Controls
- **Standard Button:** 6px radius, 13px bold text, upper-case, `0.05em` letter spacing.
- **Inputs:** 44px height for forms; 40px for filters. `1.5px` border with `3px` focus ring.
- **Tags/Pills:** Capsule-shaped with `20px` radius; uses light backgrounds with dark text (e.g., `tag-teal`).

### 4.4 Navigation
- **Sidebar (Collapsible Icon Dock):**
    - **Expanded Width:** 252px.
    - **Collapsed Width:** 68px (Icon-only "Dock" mode).
    - **Logic:** Features a floating toggle button and workflow-based grouping. Icons are 18px with a 12px gap.
    - **Scrolling:** The middle section (`sidebar-sections`) is independently scrollable with a slim, themed scrollbar to accommodate deep workflow hierarchies.
- **Topbar:** 64px height; fixed-position breadcrumb path on the left.
- **Tabs:** Underlined style with a 2px Teal bottom border for the active state.

### 4.5 Loading States (Skeleton Loading)
- **Visual Style:** Pulsing "Shimmer" animation.
- **Color:** Base color `surface-subtle` (#f1f5f9) with a linear-gradient shimmer.
- **Logic:** Skeleton shapes must match the exact geometry of the final component (e.g., circular for avatars, rectangular for card headers, multi-row for tables).
- **Implementation:** Prefer CSS-only skeletons to minimize layout shift during data hydration.

## 5. Layout Principles
- **Grid:** Based on an 8px/4px spacing system.
- **Padding:** 32px standard content gutter; 12px-20px internal card padding.
- **Containers:** Main content area transitions its margin dynamically (`252px` or `68px`) based on the sidebar state.
- **Density:** High density is preferred over excessive whitespace.

## 6. Depth & Elevation

| Layer | Light Mode Logic | Dark Mode Logic |
| :--- | :--- | :--- |
| **Layer 0 (Base)** | `#f8fafc` | `#020617` |
| **Layer 1 (Surface)** | Shadow: `0 1px 3px rgba(0,0,0,0.05)` | Border: `1px solid #334155` |
| **Layer 2 (Sidebar)** | Right Border: `1px solid #e2e8f0` | Right Border: `1px solid #334155` |
| **Layer 3 (Overlay)** | Shadow: `0 4px 6px -1px rgba(0,0,0,0.1)` | Subtle Glow: `0 0 15px rgba(56, 189, 248, 0.05)` |

## 7. Do's and Don'ts

### ✅ Do
- Use **Nunito** for all data-heavy views.
- Keep **Lora** strictly for branding and primary headers.
- Include **technical annotations** (`[SEC_XX]`) for every major UI block.
- Maintain the **monospace schema path** in the topbar at all times.
- Implement **Skeleton Loaders** for all async data containers to prevent layout shift.

### ❌ Don't
- Never use heavy gradients or rounded corners exceeding 8px.
- Do not use project-specific business terminology (e.g., "Student," "Sponsorship") in the design spec.
- Avoid large, empty whitespace; prioritize informative dashboard-style layouts.
- Do not use serif fonts for interactive controls or data tables.

## 8. Responsive Behavior
- **Breakpoints:**
    - `Desktop`: > 1024px (Expanded sidebar by default; user-collapsible).
    - `Tablet`: 768px - 1024px (Auto-collapsed "Icon Dock" mode).
    - `Mobile`: < 768px (Hidden sidebar with hamburger trigger).
- **Stacking:** Cards collapse to full-width; form `field-rows` stack vertically on mobile.

## 9. Agent Prompt Guide
*Use these snippets to guide AI generation:*

> "Generate a high-density dashboard card using the Lora/Nunito hierarchy. Ensure the header uses a subtle linear gradient and contains the [SEC_XX: MODULE_ID] technical label in Courier New."

> "Implement the Collapsible Icon Dock sidebar (252px/68px) with scrollable navigation sections. Ensure the profile footer and logo remain pinned."

> "Structure the page using the workflow-oriented sidebar sections: Overview, Programs, Student Lifecycle, Sponsorship, Communications, Finance, and System."

> "Implement a Skeleton Loader for this data table. Ensure the shimmer effect pulses against the #f1f5f9 background and matches the exact row heights and column widths of the final UI."

## 10. Technical Implementation Standards (React)

### 10.1 Iconography
- **Library:** `lucide-react` (successor to Feather).
- **Style:** Stroke-based, minimalist geometry.
- **Stroke Weight:** 2px default; use 1.5px for high-density dashboard areas to maintain a "precise" feel.
- **Size:** 18px for sidebar/navigation; 16px for inline table actions.

### 10.2 State Management & UI
- **Sidebar State:** Persist the `collapsed` boolean in `localStorage` or a global state (e.g., Zustand/Redux) to ensure the UI feels stable across sessions.
- **Dynamic Margins:** Use a global CSS variable or a styled-component theme provider to manage the `main` content margin transition when the sidebar state changes.

