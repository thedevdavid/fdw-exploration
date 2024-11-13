create extension pg_cron with schema pg_catalog;

grant usage on schema cron to postgres;
grant all privileges on all tables in schema cron to postgres;

select cron.schedule(
  'onemin-contacts-sync',
  '* * * * *', -- runs every minute. more info and playground: https://crontab.guru/#*_*_*_*_*
  $$
    insert into public.local_table("name", email, phone, updated_at, record_id)
    select rt."name", rt.email, rt.phone, rt.updated_at, rt.record_id
    from public.remote_table rt
    left join public.local_table lt on lt.record_id = rt.record_id
    where lt.record_id is null
      or rt.updated_at > lt.updated_at
    on conflict (record_id) do update
    set
      "name" = EXCLUDED."name",
      email = EXCLUDED.email,
      phone = EXCLUDED.phone,
      updated_at = EXCLUDED.updated_at;
  $$
);