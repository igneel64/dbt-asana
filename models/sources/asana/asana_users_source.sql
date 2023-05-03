WITH source AS (
    SELECT * FROM {{ source('asana', 'asana_users') }}
),

parsed AS (
    SELECT
        (info::jsonb ->> 'gid')::bigint AS user_id,
        info::jsonb ->> 'name' AS user_name,
        info::jsonb ->> 'email' AS user_email
    FROM source
)

SELECT * FROM parsed
