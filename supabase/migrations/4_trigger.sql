create table if not exists public.local_table_with_trigger(
  id uuid primary key default uuid_generate_v4(),
  "name" text,
  email text,
  phone text,
  record_id text unique not null,
  updated_at timestamp with time zone not null
);

CREATE INDEX IF NOT EXISTS idx_local_table_with_trigger_record_id ON public.local_table_with_trigger(record_id);
CREATE INDEX IF NOT EXISTS idx_local_table_with_trigger_updated_at ON public.local_table_with_trigger(updated_at);

CREATE OR REPLACE FUNCTION sync_changes()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO local_table_with_trigger (
    "name",
    email,
    phone,
    updated_at,
    record_id
  )
  SELECT
    "name",
    email,
    phone,
    updated_at,
    record_id
  FROM remote_table
  WHERE updated_at > (SELECT max(updated_at) FROM local_table_with_trigger)
  ON CONFLICT (record_id)
  DO UPDATE SET
    "name" = EXCLUDED."name",
    email = EXCLUDED.email,
    phone = EXCLUDED.phone,
    updated_at = EXCLUDED.updated_at;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sync_trigger
AFTER INSERT OR UPDATE ON remote_table
EXECUTE FUNCTION sync_changes();