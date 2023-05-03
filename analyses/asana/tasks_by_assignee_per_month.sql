WITH tasks AS (
    SELECT * FROM {{ ref('stg_asana__tasks_current') }}
),

users AS (
    SELECT * FROM {{ ref('asana_users_source') }}
),

date_dim AS (
    SELECT * FROM {{ ref('date_dim') }}
),

SELECT
    count(distinct satc.task_id) AS task_count,
    coalesce(aus.user_name, 'Unassigned') AS assignee,
    date_trunc('month', dd.date_day) AS year_month
FROM tasks AS tsk
INNER JOIN
   date_dim AS dd
    ON
        (
            dd.date_day < tsk.task_completed_at
            AND dd.date_day > tsk.task_created_at
            AND tsk.task_is_completed = true
        )
        OR (
            tsk.task_is_completed = false
            AND dd.date_day > tsk.task_created_at
        )
LEFT JOIN
    users AS aus
    ON aus.user_id = tsk.task_assignee_id
WHERE date_trunc('month', dd.date_day) <= date_trunc('month', now())
GROUP BY 2, 3
ORDER BY 3 ASC