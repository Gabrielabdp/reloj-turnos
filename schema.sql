-- Reloj de Turnos — pega todo esto en Supabase: SQL Editor → New query → Run.

create table if not exists public.shifts (
  id         text primary key,
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  start_ms   bigint not null,
  end_ms     bigint,
  note       text default '',
  created_at timestamptz default now(),
  constraint shifts_end_after_start check (end_ms is null or end_ms > start_ms)
);

create table if not exists public.study (
  id         text primary key,
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  start_ms   bigint not null,
  end_ms     bigint,
  subject    text default '',
  topic      text default '',
  created_at timestamptz default now(),
  constraint study_end_after_start check (end_ms is null or end_ms > start_ms)
);

create table if not exists public.settings (
  user_id    uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz default now()
);

create index if not exists shifts_user_start on public.shifts (user_id, start_ms);
create index if not exists study_user_start  on public.study  (user_id, start_ms);

-- Permisos para usuarios con sesión iniciada (los proyectos nuevos no los dan solos).
-- Las reglas RLS de abajo siguen limitando a cada cuenta a sus propios registros.
grant usage on schema public to authenticated;
grant select, insert, update, delete on public.shifts   to authenticated;
grant select, insert, update, delete on public.study    to authenticated;
grant select, insert, update, delete on public.settings to authenticated;

-- Cada persona solo ve y cambia sus propios registros.
alter table public.shifts   enable row level security;
alter table public.study    enable row level security;
alter table public.settings enable row level security;

drop policy if exists "propios turnos" on public.shifts;
create policy "propios turnos" on public.shifts
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "propio estudio" on public.study;
create policy "propio estudio" on public.study
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "propios ajustes" on public.settings;
create policy "propios ajustes" on public.settings
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Sincronización en vivo entre el celular y la computadora.
do $$ begin
  begin alter publication supabase_realtime add table public.shifts;   exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.study;    exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.settings; exception when duplicate_object then null; end;
end $$;

-- Ingresos extra (también está suelto en extras.sql)
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
