-- Ingresos extra — pega esto en Supabase: SQL Editor → New query → Run.
create table if not exists public.extras (
  id         text primary key,
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  at_ms      bigint not null,
  amount     numeric(12,2) not null check (amount > 0),
  cur        text not null default 'DOP' check (cur in ('DOP','USD')),
  note       text default '',
  created_at timestamptz default now()
);
create index if not exists extras_user_at on public.extras (user_id, at_ms);

grant select, insert, update, delete on public.extras to authenticated;

alter table public.extras enable row level security;
drop policy if exists "propios extras" on public.extras;
create policy "propios extras" on public.extras
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

do $$ begin
  begin alter publication supabase_realtime add table public.extras; exception when duplicate_object then null; end;
end $$;
