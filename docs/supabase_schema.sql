create extension if not exists "pgcrypto";

create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  theme_pref text not null default 'gruvbox',
  created_at timestamptz not null default now()
);

create table if not exists task_folders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  title text not null,
  created_at timestamptz not null default now()
);

create table if not exists task_templates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  title text not null,
  label text not null,
  expected_duration interval not null default interval '0',
  sub_tasks jsonb not null default '[]'::jsonb,
  task_folder_id uuid references task_folders(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists habits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  title text not null,
  label text not null,
  recurrence_mask integer not null default 0,
  current_streak integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists activity_instances (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  task_template_id uuid references task_templates(id) on delete set null,
  habit_id uuid references habits(id) on delete set null,
  label text,
  scheduled_date timestamptz not null,
  status text not null,
  actual_duration interval,
  note text,
  sub_tasks_states jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  constraint activity_instance_source check (
    (task_template_id is null) <> (habit_id is null)
  )
);

alter table profiles enable row level security;
alter table task_folders enable row level security;
alter table task_templates enable row level security;
alter table habits enable row level security;
alter table activity_instances enable row level security;

create policy "Profiles are self-access" on profiles
  for all using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "Folders are user-owned" on task_folders
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Templates are user-owned" on task_templates
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Habits are user-owned" on habits
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Activity instances are user-owned" on activity_instances
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
