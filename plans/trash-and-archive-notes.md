# Trash & Archive — Decision Notes

## Archive vs Trash

| | Archive | Trash |
|---|---|---|
| Purpose | Remove from active view, keep for records | Remove because it's wrong or no longer needed |
| Staff visibility | Archive folder, searchable | Trash folder only, hidden from search |
| Restore | One-click un-archive | Restore within retention period |
| Retention | Permanent | Auto-purged after N days (e.g., 30) |
| Analytics | Counts toward historical stats | Excluded from all stats |
| Who can | Any staff | Supervisors or higher |

## Sponsor Inbox Independence

Staff-side archive/trash never affects what the sponsor sees. A sponsor's inbox is their permanent record of everything sent to them. Archive/trash is purely workspace organization for staff.

## Block Delete Under Review

Items under Review cannot be deleted directly. The workflow is:

```
Draft → Review → (Return) → Draft → Delete
```

Delete button only shows when status is Drafts. Attempting to delete from Review is blocked — must Return to Drafts first.

## Communication Statuses

- `Pending` — waiting to be sent
- `Sent` — delivery confirmed, can be archived
- `Failed` — delivery permanently failed (email bounce, etc.), needs intervention, **not** eligible for auto-archive
- Failed requires a separate triage flow, distinct from both Sent and Draft

## Return vs Failed

- **Return** = workflow rejection (supervisor sends back to secretary). Document goes Review → Drafts. No delivery attempted.
- **Failed** = delivery failure. System tried to send, destination rejected it. Terminal delivery outcome, different from workflow state.
