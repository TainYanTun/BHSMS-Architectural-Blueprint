# Swimlane Activity Diagram Guidelines

This document defines the standard for all `.puml` swimlane diagrams in this project. All diagrams must follow these conventions.

---

## 1. Actor Names (Swimlane Labels)

Use only these roles. Match the exact casing.

| Label | Used in | Notes |
|---|---|---|
| `Secretary` | student, sponsor | |
| `School Coordinator / Program Coordinator` | student | Slash for joint role |
| `Program Coordinator` | transition | |
| `Director` | student, sponsor, transition | |
| `Sponsor` | sponsor | External actor |
| `System` | sponsor, transition | Automated behavior |

**Rules:**
- Do not invent roles (e.g. "Staff", "Admin", "Coordinator" alone).
- Do not add detail in the label (e.g. `|Director / Admin|` is OK if both apply).
- System is for automated steps only.

---

## 2. Action Boxes

**Format:** `:Action phrase;`

**Rules:**
- 3–6 words per box. One line. No `\n`.
- Start with a verb (Register, Record, Review, Approve, Send, Track, etc.).
- Business language only. No database terms, no trigger names, no field names.
- No examples, no parentheses, no inline explanations.

**Good:**
```
:Register student;
:Review request;
:Approve transition;
```

**Bad:**
```
:Register student with\nintake form and guardians;
:Review request (check\nbalance first);
:fn_enforce_payout_limits triggers;
```

---

## 3. Decisions

**Format:** `if (Question?) then (Yes/No)`

**Rules:**
- Question must be a yes/no question, 3–6 words.
- Branches use `then (Yes)` and `else (No)` or `else (Other label)`.
- Decision text goes inside the `if (...)` — no separate question box.

**Good:**
```
if (Approved?) then (Yes)
  :Approve transition;
else (No)
  :Reject request;
endif
```

**Bad:**
```
:Check if approved;
if (true) then (Yes)
```

---

## 4. Loops

**Format:**
```
repeat
  :Action;
repeat while (Question?) is (Yes)
```

**Rules:**
- `repeat` starts the loop body.
- `repeat while` ends it with an inline condition.
- Keep the condition short.

**Good:**
```
repeat
  :Pay student needs;
repeat while (Still studying?) is (Yes)
```

---

## 5. Swimlane Switches

**Format:** `|Actor|` on its own line.

**Rules:**
- Place on the line *before* the first action that actor does.
- The lane stays active until the next `|Actor|` line.
- Declare all swimlanes at the top if desired, or switch inline.

**Good:**
```
|Secretary|
:Register student;

|Director|
:Review request;
```

---

## 6. Start / Stop

- Every diagram starts with `start` and ends with `stop`.
- `start` must be the first element after `@startuml`.
- Every path must end with `stop`.

---

## 7. Layout Rules

- No `skinparam` in activity diagrams (leave defaults).
- No `title`.
- No formatting markup (Creole).
- No `\n` line breaks in boxes.
- No `fork` / `fork again` unless truly parallel work.

---

## 8. Content Rules

- Describe **what** happens, not **how**.
- No database, table, trigger, or schema references.
- No field names, no column names, no SQL.
- No system archiecture (e.g. "System creates record" → just do the business step).
- One action per box. If two things happen sequentially, use two boxes.

---

## 9. File Format

- UTF-8, Unix line endings.
- No trailing whitespace.
- Indent `if` / `repeat` bodies with 2 spaces.
- One blank line between major swimlane sections.
