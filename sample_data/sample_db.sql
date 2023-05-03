CREATE TABLE {schema}.asana_projects (
	id int8 NOT NULL,
	info json NOT NULL,
	updated_at timestamp NULL,
	mt_loaded_at timestamp NULL,
	mt_load_process varchar(255) NULL,
	CONSTRAINT asana_projects_id_updated_at_key UNIQUE (id, updated_at),
	CONSTRAINT asana_projects_pkey PRIMARY KEY (id, updated_at)
);

CREATE TABLE {schema}.asana_tasks (
	id int8 NOT NULL,
	info json NOT NULL,
	updated_at timestamp NOT NULL,
	mt_loaded_at timestamp NULL,
	mt_load_process varchar(255) NULL,
	CONSTRAINT asana_tasks_id_updated_at_key UNIQUE (id, updated_at),
	CONSTRAINT asana_tasks_pkey PRIMARY KEY (id, updated_at)
);

CREATE TABLE {schema}.asana_users (
	id int8 NOT NULL,
	info json NOT NULL,
	mt_loaded_at timestamp NULL,
	mt_load_process varchar(255) NULL,
	CONSTRAINT source_asana_users_pkey PRIMARY KEY (id)
);