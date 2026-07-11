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
  profile_id uuid references public.profiles on delete cascade not null,
  status text default 'pending_approval' check (status in ('offline', 'online', 'onRide', 'pendingApproval', 'suspended')),
  is_verified boolean not null default false,
  average_rating decimal(3,2) default 5.0,
  total_rides int default 0,
  license_number text,
  license_image_url text,
  current_latitude double precision,
  current_longitude double precision,
  heading double precision,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Vehicles
create table public.vehicles (
  id uuid default uuid_generate_v4() primary key,
  driver_id uuid references public.drivers on delete cascade not null,
  make text not null,
  model text not null,
  year int not null,
  plate_number text not null,
  vehicle_type text not null default 'standard'
    check (vehicle_type in ('standard', 'comfort', 'premium', 'motorcycle')),
  photo_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Vehicle Documents
create table public.vehicle_documents (
  id uuid default uuid_generate_v4() primary key,
  vehicle_id uuid references public.vehicles on delete cascade not null,
  document_type text not null,
  document_url text not null,
  status text not null default 'pending'
    check (status in ('pending', 'verified', 'rejected')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Ride Requests
create table public.ride_requests (
  id uuid default uuid_generate_v4() primary key,
  passenger_id uuid references public.passengers on delete cascade not null,
  pickup_latitude double precision not null,
  pickup_longitude double precision not null,
  pickup_address text not null,
  dropoff_latitude double precision not null,
  dropoff_longitude double precision not null,
  dropoff_address text not null,
  payment_method text not null check (payment_method in ('cash', 'yocoCard', 'mtnMomo')),
  requested_vehicle_type text check (requested_vehicle_type in ('standard', 'comfort', 'premium', 'motorcycle')),
  estimated_fare double precision,
  estimated_distance double precision,
  estimated_duration int,
  status text not null default 'pending'
    check (status in ('pending', 'accepted', 'cancelled', 'expired')),
  expires_at timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Rides
create table public.rides (
  id uuid default uuid_generate_v4() primary key,
  ride_request_id uuid references public.ride_requests on delete restrict not null,
  driver_id uuid references public.drivers on delete restrict not null,
  passenger_id uuid references public.passengers on delete restrict not null,
  status text not null default 'accepted'
    check (status in ('pending', 'accepted', 'driverArrived', 'started', 'completed', 'cancelled')),
  pickup_latitude double precision not null,
  pickup_longitude double precision not null,
  pickup_address text not null,
  dropoff_latitude double precision not null,
  dropoff_longitude double precision not null,
  dropoff_address text not null,
  payment_method text not null check (payment_method in ('cash', 'yocoCard', 'mtnMomo')),
  payment_status text check (payment_status in ('pending', 'authorized', 'captured', 'failed', 'refunded')),
  fare double precision,
  distance double precision,
  duration int,
  driver_accepted_at timestamp with time zone,
  driver_arrived_at timestamp with time zone,
  started_at timestamp with time zone,
  completed_at timestamp with time zone,
  cancelled_at timestamp with time zone,
  cancellation_reason text,
  route_polyline text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Driver location (one row per driver, upserted continuously)
create table public.ride_locations (
  driver_id uuid references public.drivers on delete cascade primary key,
  latitude double precision not null,
  longitude double precision not null,
  heading double precision,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Ratings
create table public.ratings (
  id uuid default uuid_generate_v4() primary key,
  ride_id uuid references public.rides on delete cascade not null,
  rated_by uuid references public.profiles on delete cascade not null,
  rated_user uuid references public.profiles on delete cascade not null,
  score smallint not null check (score between 1 and 5),
  comment text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique (ride_id, rated_by)
);

-- Device tokens (for FCM push notifications)
create table public.device_tokens (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles on delete cascade not null,
  token text not null,
  platform text check (platform in ('android', 'ios', 'web')),
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique (user_id, token)
);

-- ============================================================
-- Enable Row Level Security on all tables
-- ============================================================
alter table public.profiles enable row level security;
alter table public.passengers enable row level security;
alter table public.drivers enable row level security;
alter table public.vehicles enable row level security;
alter table public.vehicle_documents enable row level security;
alter table public.ride_requests enable row level security;
alter table public.rides enable row level security;
alter table public.ride_locations enable row level security;
alter table public.ratings enable row level security;
alter table public.device_tokens enable row level security;

-- ============================================================
-- RLS Policies: profiles
-- ============================================================
create policy "profiles: users can read own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profiles: users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

create policy "profiles: users can insert own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

-- ============================================================
-- RLS Policies: passengers
-- ============================================================
create policy "passengers: users can read own passenger record"
  on public.passengers for select
  using (auth.uid() = id);

create policy "passengers: users can insert own passenger record"
  on public.passengers for insert
  with check (auth.uid() = id);

-- ============================================================
-- RLS Policies: drivers
-- ============================================================
create policy "drivers: drivers can read own record"
  on public.drivers for select
  using (auth.uid() = id);

create policy "drivers: drivers can insert own record"
  on public.drivers for insert
  with check (auth.uid() = id);

create policy "drivers: drivers can update own record"
  on public.drivers for update
  using (auth.uid() = id);

-- Passengers can read basic driver info for a ride they are on.
create policy "drivers: passengers can read driver on their active ride"
  on public.drivers for select
  using (
    exists (
      select 1 from public.rides r
      where r.driver_id = drivers.id
        and r.passenger_id = auth.uid()
        and r.status not in ('completed', 'cancelled')
    )
  );

-- ============================================================
-- RLS Policies: vehicles
-- ============================================================
create policy "vehicles: drivers can manage own vehicles"
  on public.vehicles for all
  using (auth.uid() = driver_id)
  with check (auth.uid() = driver_id);

-- ============================================================
-- RLS Policies: vehicle_documents
-- ============================================================
create policy "vehicle_documents: drivers can manage own documents"
  on public.vehicle_documents for all
  using (
    exists (
      select 1 from public.vehicles v
      where v.id = vehicle_documents.vehicle_id
        and v.driver_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.vehicles v
      where v.id = vehicle_documents.vehicle_id
        and v.driver_id = auth.uid()
    )
  );

-- ============================================================
-- RLS Policies: ride_requests
-- ============================================================
create policy "ride_requests: passengers can insert own requests"
  on public.ride_requests for insert
  with check (auth.uid() = passenger_id);

create policy "ride_requests: passengers can read own requests"
  on public.ride_requests for select
  using (auth.uid() = passenger_id);

create policy "ride_requests: passengers can cancel own pending requests"
  on public.ride_requests for update
  using (auth.uid() = passenger_id and status = 'pending')
  with check (status = 'cancelled');

-- Verified, online drivers can see pending requests.
create policy "ride_requests: verified drivers can view pending requests"
  on public.ride_requests for select
  using (
    status = 'pending'
    and exists (
      select 1 from public.drivers d
      where d.id = auth.uid() and d.is_verified = true
    )
  );

-- Drivers can update a pending request to 'accepted' (when they accept a ride).
create policy "ride_requests: verified drivers can accept pending requests"
  on public.ride_requests for update
  using (
    status = 'pending'
    and exists (
      select 1 from public.drivers d
      where d.id = auth.uid() and d.is_verified = true
    )
  )
  with check (status = 'accepted');

-- ============================================================
-- RLS Policies: rides
-- ============================================================
create policy "rides: drivers can insert rides they accept"
  on public.rides for insert
  with check (auth.uid() = driver_id);

create policy "rides: drivers can view their own rides"
  on public.rides for select
  using (auth.uid() = driver_id);

create policy "rides: drivers can update status on their own rides"
  on public.rides for update
  using (auth.uid() = driver_id)
  with check (auth.uid() = driver_id);

create policy "rides: passengers can view their own rides"
  on public.rides for select
  using (auth.uid() = passenger_id);

-- ============================================================
-- RLS Policies: ride_locations
-- ============================================================
-- Drivers can upsert their own location.
create policy "ride_locations: drivers can upsert own location"
  on public.ride_locations for all
  using (auth.uid() = driver_id)
  with check (auth.uid() = driver_id);

-- Passengers can read driver location for their active ride.
create policy "ride_locations: passengers can read driver location on active ride"
  on public.ride_locations for select
  using (
    exists (
      select 1 from public.rides r
      where r.driver_id = ride_locations.driver_id
        and r.passenger_id = auth.uid()
        and r.status not in ('completed', 'cancelled')
    )
  );

-- ============================================================
-- RLS Policies: ratings
-- ============================================================
create policy "ratings: users can create ratings for completed rides they were part of"
  on public.ratings for insert
  with check (
    auth.uid() = rated_by
    and exists (
      select 1 from public.rides r
      where r.id = ratings.ride_id
        and (r.driver_id = auth.uid() or r.passenger_id = auth.uid())
        and r.status = 'completed'
    )
  );

create policy "ratings: users can read their own ratings"
  on public.ratings for select
  using (auth.uid() = rated_by or auth.uid() = rated_user);

-- ============================================================
-- RLS Policies: device_tokens
-- ============================================================
create policy "device_tokens: users can manage own tokens"
  on public.device_tokens for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
