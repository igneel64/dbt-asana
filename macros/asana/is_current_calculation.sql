{% macro is_current_calculation(target_model_name) %}
    SELECT
        id,
        updated_at,
        coalesce(row_number() OVER (
            PARTITION BY id ORDER BY updated_at DESC
        ) = 1, FALSE) AS is_current
    FROM {{ target_model_name }}
{% endmacro %}