{{
    config(
        materialized='incremental'
    )
}}

WITH source AS (
    SELECT * FROM {{ source('asana', 'asana_tasks') }}
    {% if is_incremental() %}
    WHERE updated_at > (SELECT max(task_modified_at) FROM {{ this }})
    {% endif %}
),

projects_agg AS (
    {{ extract_jsonb_external_resource('projects', 'source', 'project_id') }}
),

is_current_calculation AS (
    {{ is_current_calculation('source') }}
),

parsed AS (
    SELECT -- noqa: ST06
        (s.info::jsonb ->> 'gid')::bigint AS task_id,
        (s.info::jsonb ->> 'due_at')::timestamp AS task_due_at,
        (s.info::jsonb ->> 'due_on')::timestamp AS task_due_on,
        (s.info::jsonb ->> 'completed')::boolean AS task_is_completed,
        (s.info::jsonb ->> 'completed_at')::timestamp AS task_completed_at,
        (s.info::jsonb ->> 'created_at')::timestamp AS task_created_at,
        (s.info::jsonb ->> 'modified_at')::timestamp AS task_modified_at,
        (
            (s.info::jsonb ->> 'assignee')::jsonb ->> 'gid'
        )::bigint AS task_assignee_id,
        s.info::jsonb ->> 'assignee_status' AS task_assignee_status,
        s.info::jsonb ->> 'name' AS task_name,
        date_part(
            'day',
            (s.info::jsonb ->> 'completed_at')::timestamp
            - (s.info::jsonb ->> 'created_at')::timestamp
        ) AS task_creation_to_completion_days,
        s2.is_current AS is_current,
        array_agg(s3.project_id) AS task_projects
    FROM source AS s
    INNER JOIN
        is_current_calculation AS s2
        USING(id, updated_at)
    INNER JOIN
        projects_agg AS s3
        USING(id, updated_at)
    {{ dbt_utils.group_by(n=12) }}
)

SELECT * FROM parsed
