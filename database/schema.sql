-- Enable necessary extensions
create extension if not exists "uuid-ossp";
create extension if not exists "postgis";

-- Profiles table (linked to auth.users)
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  phone_number text unique not null,
  email text,
  full_name text,
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Passengers
create table public.passengers (
  id uuid references public.profiles on delete cascade primary key,
  rating decimal(3,2) default 5.0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Drivers
create table public.drivers (
  id uuid references public.profiles on delete cascade primary key,
  status text default 'pending_approval' check (status in ('pending_approval', 'active', 'suspended')),
  rating decimal(3,2) default 5.0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Vehicles
create table public.vehicles (
  id uuid default uuid_generate_v4() primary key,
  driver_id uuid references public.drivers on delete cascade not null,
  make text not null,
  model text not null,
  year int not null,
  plate_number text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Vehicle Documents
create table public.vehicle_documents (
  id uuid default uuid_generate_v4() primary key,
  vehicle_id uuid references public.vehicles on delete cascade not null,
  document_type text not null,
  document_url text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS (Row Level Security)
alter table public.profiles enable row level security;
alter table public.passengers enable row level security;
alter table public.drivers enable row level security;
alter table public.vehicles enable row level security;
alter table public.vehicle_documents enable row level security;

-- Basic RLS Policy Example: Users can read their own profile
create policy "Users can read own profile" on public.profiles
  for select using (auth.uid() = id);

create policy "Users can update own profile" on public.profiles
  for update using (auth.uid() = id);
