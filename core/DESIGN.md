# Design System Specification (DESIGN.md)

This document serves as the "Visual DNA" and single source of truth for the system's interface. It is optimized for both human developers and AI agents to ensure pixel-perfect consistency across all modules.

---

## 1. Visual Theme & Atmosphere
- **Vibe:** Professional, high-density, and technically rigorous.
- **Aesthetic:** Clean "Data-First" humanitarian style. It prioritizes utility and structural clarity over decorative elements.
- **Atmosphere:** Deep navy surfaces paired with crisp slate-white backgrounds. The interface should feel "instrument-like"—precise, reliable, and dense with information.

## 2. Color Palette & Roles

| Semantic Role | Hex Code | Purpose |
| :--- | :--- | :--- |
| `primary-navy` | `#1e3a4a` | Core branding, primary headers, and high-contrast accents. |
| `sidebar-bg` | `#0a1f35` | Background for the persistent navigation sidebar. |
| `sidebar-active` | `#1e293b` | Background for selected navigation nodes. |
| `action-teal` | `#2B7A9E` | Primary call-to-action, icons, active tab underlines, and links. |
| `signal-pink` | `#d17a8e` | Secondary accents, soft alerts, and distinct categorization tags. |
| `success-green` | `#10b981` | Approval markers and positive state indicators. |
| `bg-app` | `#f8fafc` | Global application background. |
| `surface-white` | `#ffffff` | Primary content areas, cards, and topbar background. |
| `surface-subtle`| `#f1f5f9` | Table headers, sub-sections, and hover highlights. |
| `border-neutral` | `#e2e8f0` | Standard dividers and container borders. |

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
- **Sidebar:** 252px width; nav items use 18px icons with a 12px gap.
- **Topbar:** 64px height; fixed-position breadcrumb path on the left.
- **Tabs:** Underlined style with a 2px Teal bottom border for the active state.

## 5. Layout Principles
- **Grid:** Based on an 8px/4px spacing system.
- **Padding:** 32px standard content gutter; 12px-20px internal card padding.
- **Containers:** Max-width for tables is generally `1fr`; sidebars are fixed at 310px.
- **Density:** High density is preferred over excessive whitespace.

## 6. Depth & Elevation
- **Layer 0 (Base):** `bg-app` (`#f8fafc`).
- **Layer 1 (Surface):** Cards and content areas with `0 1px 3px rgba(0,0,0,0.05)` shadow.
- **Layer 2 (Sidebar):** High-contrast Dark Navy (`#0a1f35`) with 1px right border.
- **Layer 3 (Overlay):** Topbar with 1px bottom border and subtle shadow.

## 7. Do's and Don'ts

### ✅ Do
- Use **Nunito** for all data-heavy views.
- Keep **Lora** strictly for branding and primary headers.
- Include **technical annotations** (`[SEC_XX]`) for every major UI block.
- Maintain the **monospace schema path** in the topbar at all times.

### ❌ Don't
- Never use heavy gradients or rounded corners exceeding 8px.
- Do not use project-specific business terminology (e.g., "Student," "Sponsorship") in the design spec.
- Avoid large, empty whitespace; prioritize informative dashboard-style layouts.
- Do not use serif fonts for interactive controls or data tables.

## 8. Responsive Behavior
- **Breakpoints:**
    - `Desktop`: > 1024px (Full sidebar + Main).
    - `Tablet`: 768px - 1024px (Collapsed sidebar icon-only).
    - `Mobile`: < 768px (Hidden sidebar with hamburger trigger).
- **Stacking:** Cards collapse to full-width; form `field-rows` stack vertically on mobile.

## 9. Agent Prompt Guide
*Use these snippets to guide AI generation:*

> "Generate a high-density dashboard card using the Lora/Nunito hierarchy. Ensure the header uses a subtle linear gradient and contains the [SEC_XX: MODULE_ID] technical label in Courier New."

> "Implement a data table following the high-density spec: 10px bold upper-case headers on #f1f5f9 background, with 13px Nunito text for row data and a subtle hover highlight."

> "Structure the page with a 252px sidebar (#0a1f35) and a 64px topbar. Include the monospace schema path in the topbar and use a 32px content gutter."
