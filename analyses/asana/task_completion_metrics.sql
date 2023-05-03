WITH tasks AS (
    SELECT * FROM {{ ref('stg_asana__tasks_current') }}
),

SELECT
    avg(tsk.task_creation_to_completion_days) as average_completion_rate,
    percentile_cont(0.5) WITHIN group (
        ORDER BY tsk.task_creation_to_completion_days
    ) as median_completion_rate
FROM tasks AS tsk
WHERE tsk.task_is_completed = true;
