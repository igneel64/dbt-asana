WITH source AS (
    SELECT * FROM {{ source('asana', 'asana_projects') }}
),

members_agg AS (
    {{ extract_jsonb_external_resource('members', 'source', 'member_id') }}
),

is_current_calculation AS (
    {{ is_current_calculation('source') }}
),

parsed AS (
    SELECT
        (s.info::jsonb ->> 'gid')::bigint AS project_id,
        (s.info::jsonb ->> 'archived')::boolean AS project_is_archived,
        (s.info::jsonb ->> 'completed')::boolean AS project_is_completed,
        (s.info::jsonb ->> 'completed_at')::timestamp AS project_completed_at,
        (s.info::jsonb ->> 'created_at')::timestamp AS project_created_at,
        (s.info::jsonb ->> 'modified_at')::timestamp AS project_modified_at,
        s2.is_current AS is_current,
        s.info::jsonb ->> 'name' AS project_name,
        array_agg(s3.member_id) AS project_members
    FROM source AS s
    INNER JOIN
        is_current_calculation AS s2
        USING(id, updated_at)
    INNER JOIN
        members_agg AS s3
        USING(id, updated_at)
    {{ dbt_utils.group_by(n=8) }}
)

SELECT * FROM parsed
