-- ===========================================================================
-- Deal Board — database schema for Supabase
-- ZenaTech buy-side mandate · Transworld Business Advisors of Florida
--
-- Run this ONCE, in the Supabase SQL editor, before importing any data.
-- It creates three tables and locks all of them behind a login, so a row is
-- readable only by someone you have invited by email. Nothing here is public.
-- ===========================================================================

-- Who is allowed in. Add a row per caller BEFORE they try to sign in.
create table if not exists team (
  email       text primary key,
  full_name   text not null,
  initials    text,
  active      boolean not null default true
);

-- The prospect list. Rewritten from the Mac each morning; never edited by hand.
create table if not exists firms (
  firm_id          text primary key,
  company          text not null,
  priority         text,
  score            integer,
  state            text,
  city             text,
  address          text,
  principal        text,
  phone            text,
  phone_type       text,
  email            text,
  website          text,
  staff            integer,
  revenue_estimate text,
  line_of_work     text,
  why              text,
  refreshed_at     timestamptz not null default now()
);
create index if not exists firms_state_score on firms (state, score desc);

-- What the desk has done. One row per firm, written by the callers.
create table if not exists work (
  firm_id     text primary key references firms (firm_id) on delete cascade,
  owner_email text references team (email),
  status      text not null default 'Not started',
  next_date   date,
  next_note   text,
  updated_at  timestamptz not null default now(),
  updated_by  text
);
create index if not exists work_owner on work (owner_email);
create index if not exists work_due   on work (next_date);

-- Every action, append only. This is the history inside each company's file.
create table if not exists activity (
  id       bigserial primary key,
  firm_id  text not null references firms (firm_id) on delete cascade,
  at       timestamptz not null default now(),
  by_email text,
  what     text not null,
  note     text
);
create index if not exists activity_firm on activity (firm_id, at desc);

-- ---------------------------------------------------------------------------
-- Access control. Everything requires a signed-in account whose email is in
-- the team table. An anonymous visitor to the page sees nothing at all.
-- ---------------------------------------------------------------------------
alter table team     enable row level security;
alter table firms    enable row level security;
alter table work     enable row level security;
alter table activity enable row level security;

create or replace function is_team() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from team
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
      and active
  );
$$;

drop policy if exists team_read      on team;
drop policy if exists firms_read     on firms;
drop policy if exists work_read      on work;
drop policy if exists work_write     on work;
drop policy if exists work_update    on work;
drop policy if exists activity_read  on activity;
drop policy if exists activity_write on activity;

create policy team_read      on team     for select using (is_team());
create policy firms_read     on firms    for select using (is_team());
create policy work_read      on work     for select using (is_team());
create policy work_write     on work     for insert with check (is_team());
create policy work_update    on work     for update using (is_team()) with check (is_team());
create policy activity_read  on activity for select using (is_team());
create policy activity_write on activity for insert with check (is_team());

-- Live updates: push changes to every open browser.
alter publication supabase_realtime add table work;
alter publication supabase_realtime add table activity;

-- ---------------------------------------------------------------------------
-- The desk. Replace these with the real work addresses before running this.
-- They are the ONLY addresses that will ever be able to sign in, so a typo
-- here locks that person out with a message that will not explain why.
-- Deliberately placeholders: this file is in a public repository.
-- ---------------------------------------------------------------------------
insert into team (email, full_name, initials) values
  ('first.caller@example.com',  'First Caller',  'FC'),
  ('second.caller@example.com', 'Second Caller', 'SC'),
  ('third.caller@example.com',  'Third Caller',  'TC')
on conflict (email) do update
  set full_name = excluded.full_name,
      initials  = excluded.initials,
      active    = true;
