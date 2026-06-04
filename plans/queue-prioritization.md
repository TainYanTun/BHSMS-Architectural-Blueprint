# Queue Prioritization Paradigm

To prevent long-running tasks (like backups) from blocking time-sensitive operations (like PDF generation), the system utilizes **Queue Prioritization**.

## 1. The Strategy: Multiple Queues
Rather than a single "first-come, first-served" line, we segregate tasks into different queues based on their performance impact and urgency.

| Queue | Priority | Target Jobs | Expected Duration |
| :--- | :--- | :--- | :--- |
| `high` | Critical | PDF Generation, Notifications | < 5 seconds |
| `default` | Standard | General background tasks | 5-30 seconds |
| `low` | Background | Database Backups, Bulk Imports | > 30 seconds |

## 2. Implementation Logic
When dispatching a job from the `Logic` layer, the queue is explicitly specified:

```php
// Fast task (High Priority)
GeneratePdfJob::dispatch($studentId)->onQueue('high');

// Slow task (Low Priority)
ManualBackupJob::dispatch()->onQueue('low');
```

## 3. Worker Configuration
Background workers are configured to prioritize high-urgency queues, ensuring they are always processed first:

*   **Fast-Lane Worker:** `php artisan queue:work --queue=high,default`
    *   *Role:* Primarily processes high-priority tasks; falls back to default if high is empty.
*   **Heavy-Lift Worker:** `php artisan queue:work --queue=low`
    *   *Role:* Processes only long-running, low-priority tasks.

## 4. Result
By separating workers, a massive manual backup running in the `low` queue will **never block** a staff member’s PDF request running in the `high` queue. The system remains responsive regardless of the maintenance load.
