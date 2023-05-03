WITH tasks AS (
    SELECT * FROM {{ ref('stg_asana__tasks_current') }}
),

SELECT
    date_part('year', tsk.task_created_at),
    count(*) AS task_count
FROM tasks AS tsk
GROUP BY 1
ORDER BY 1 DESC