create table public.profiles (id uuid primary key references auth.users(id) on delete cascade, display_name text not null check (char_length(display_name) between 2 and 40), avatar_url text, bio text not null default '' check (char_length(bio) <= 240), created_at timestamptz not null default now(), updated_at timestamptz not null default now());
grant select, insert, update on public.profiles to authenticated;
grant all on public.profiles to service_role;
alter table public.profiles enable row level security;
create policy "Authenticated users can read profiles" on public.profiles for select to authenticated using (true);
create policy "Users can insert own profile" on public.profiles for insert to authenticated with check (auth.uid() = id);
create policy "Users can update own profile" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

create table public.room_messages (id uuid primary key default gen_random_uuid(), room_id text not null check (char_length(room_id) between 2 and 80), user_id uuid not null references auth.users(id) on delete cascade, display_name text not null check (char_length(display_name) between 2 and 40), body text not null check (char_length(body) between 1 and 500), created_at timestamptz not null default now());
grant select, insert on public.room_messages to authenticated;
grant all on public.room_messages to service_role;
alter table public.room_messages enable row level security;
create policy "Authenticated users can read room messages" on public.room_messages for select to authenticated using (true);
create policy "Users can send own messages" on public.room_messages for insert to authenticated with check (auth.uid() = user_id);
create index room_messages_room_created_idx on public.room_messages(room_id, created_at desc);
alter publication supabase_realtime add table public.room_messages;

create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, display_name, avatar_url) values (new.id, left(coalesce(new.raw_user_meta_data->>'full_name', split_part(coalesce(new.email, 'Velvet user'), '@', 1)), 40), new.raw_user_meta_data->>'avatar_url') on conflict (id) do nothing;
  return new;
end;
$$;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
