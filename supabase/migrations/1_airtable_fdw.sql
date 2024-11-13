create extension if not exists wrappers with schema extensions;

create foreign data wrapper airtable_wrapper
  handler airtable_fdw_handler
  validator airtable_fdw_validator;

create server airtable_server
  foreign data wrapper airtable_wrapper
  options (
    api_key 'APIKEY'
  );

create foreign table remote_table (
  "name" text,
  email text,
  phone text,
  record_id text not null,
  updated_at timestamp with time zone DEFAULT now() not null
)
server airtable_server
options (
  base_id 'BASEID',
  table_id 'TABLEID',
  view_id 'VIEWID'
);

create table if not exists public.local_table(
  id uuid primary key default uuid_generate_v4(),
  "name" text,
  email text,
  phone text,
  record_id text unique not null,
  updated_at timestamp with time zone not null
);

create index if not exists idx_local_table_record_id on public.local_table(record_id);
create index if not exists idx_local_table_updated_at on public.local_table(updated_at);