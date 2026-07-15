-- Zeni Comprehensive Schema
-- Source of truth for all database structures
-- Aligns perfectly with Dart models and business logic

-- =============================================================================
-- Extensions
-- =============================================================================
create extension if not exists "uuid-ossp";
create extension if not exists "postgis";

-- =============================================================================
-- Enum Types
-- =============================================================================
create type driver_status as enum ('offline', 'online', 'onRide', 'pendingApproval', 'suspended');
create type ride_status as enum ('pending', 'accepted', 'driverArrived', 'started', 'completed', 'cancelled');
create type payment_method as enum ('cash', 'yocoCard', 'mtnMomo');
create type payment_status as enum ('pending', 'authorized', 'captured', 'failed', 'refunded');
create type vehicle_type as enum ('standard', 'comfort', 'premium', 'motorcycle');
create type document_status as enum ('pending', 'verified', 'rejected');

-- =============================================================================
-- Profiles table (linked to auth.users)
-- =============================================================================
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  phone_number text unique not null,
  email text,
  full_name text,
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create index idx_profiles_phone on public.profiles(phone_number);

-- =============================================================================
-- Passengers
-- =============================================================================
create table public.passengers (
  id uuid references public.profiles on delete cascade primary key,
  average_rating decimal(3,2) default 5.0,
  total_rides int default 0,
  emergency_contact_name text,
  emergency_contact_phone text,
  favorite_addresses text[],
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create index idx_passengers_rating on public.passengers(average_rating);

-- =============================================================================
-- Drivers
-- =============================================================================
create table public.drivers (
  id uuid references public.profiles on delete cascade primary key,
  profile_id uuid references public.profiles on delete cascade not null,
  status driver_status default 'pendingApproval',
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

create index idx_drivers_status on public.drivers(status);
create index idx_drivers_is_verified on public.drivers(is_verified);
create index idx_drivers_status_verified on public.drivers(status, is_verified);

-- =============================================================================
-- Vehicles
-- =============================================================================
create table public.vehicles (
  id uuid default gen_random_uuid() primary key,
  driver_id uuid references public.drivers on delete cascade not null,
  type vehicle_type not null default 'standard',
  make text not null,
  model text not null,
  year int not null,
  license_plate text not null,
  color text,
  capacity int,
  photo_url text,
  is_active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(driver_id, license_plate)
);

create index idx_vehicles_driver_id on public.vehicles(driver_id);
create index idx_vehicles_is_active on public.vehicles(is_active);

-- =============================================================================
-- Vehicle Documents
-- =============================================================================
create table public.vehicle_documents (
  id uuid default gen_random_uuid() primary key,
  vehicle_id uuid references public.vehicles on delete cascade not null,
  document_type text not null,
  document_url text not null,
  status document_status not null default 'pending',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create index idx_vehicle_documents_status on public.vehicle_documents(status);

-- =============================================================================
-- Ride Requests
-- =============================================================================
create table public.ride_requests (
  id uuid default gen_random_uuid() primary key,
  passenger_id uuid references public.passengers on delete cascade not null,
  pickup_latitude double precision not null,
  pickup_longitude double precision not null,
  pickup_address text not null,
  dropoff_latitude double precision not null,
  dropoff_longitude double precision not null,
  dropoff_address text not null,
  payment_method payment_method not null,
  requested_vehicle_type vehicle_type,
  estimated_fare double precision,
  estimated_distance double precision,
  estimated_duration int,
  status text not null default 'pending' check (status in ('pending', 'accepted', 'cancelled', 'expired')),
  expires_at timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create index idx_ride_requests_status on public.ride_requests(status);
create index idx_ride_requests_status_created on public.ride_requests(status, created_at);
create index idx_ride_requests_passenger on public.ride_requests(passenger_id);

-- PostGIS geography column for spatial queries
alter table public.ride_requests add column if not exists pickup_location geography(Point, 4326);
create index idx_ride_requests_pickup_location on public.ride_requests using GIST (pickup_location);

-- =============================================================================
-- Rides
-- =============================================================================
create table public.rides (
  id uuid default gen_random_uuid() primary key,
  ride_request_id uuid references public.ride_requests on delete restrict not null unique,
  driver_id uuid references public.drivers on delete restrict not null,
  passenger_id uuid references public.passengers on delete restrict not null,
  status ride_status not null default 'accepted',
  payment_method payment_method not null,
  payment_status payment_status default 'pending',
  pickup_latitude double precision not null,
  pickup_longitude double precision not null,
  pickup_address text not null,
  dropoff_latitude double precision not null,
  dropoff_longitude double precision not null,
  dropoff_address text not null,
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

create index idx_rides_driver_id_status on public.rides(driver_id, status);
create index idx_rides_passenger_id_status on public.rides(passenger_id, status);
create index idx_rides_status on public.rides(status);

-- =============================================================================
-- Ride Locations (singleton per driver - live location tracking)
-- =============================================================================
create table public.ride_locations (
  driver_id uuid references public.drivers on delete cascade primary key,
  latitude double precision not null,
  longitude double precision not null,
  heading double precision,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- PostGIS column for spatial queries
alter table public.ride_locations add column if not exists location geography(Point, 4326);
create index idx_ride_locations_location on public.ride_locations using GIST (location);

-- =============================================================================
-- Ratings
-- =============================================================================
create table public.ratings (
  id uuid default gen_random_uuid() primary key,
  ride_id uuid references public.rides on delete cascade not null,
  reviewer_id uuid references public.profiles on delete cascade not null,
  reviewed_id uuid references public.profiles on delete cascade not null,
  score smallint not null check (score between 1 and 5),
  review text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(ride_id, reviewer_id)
);

create index idx_ratings_reviewed_id on public.ratings(reviewed_id);
create index idx_ratings_reviewer_id on public.ratings(reviewer_id);

-- =============================================================================
-- Notifications
-- =============================================================================
create table public.notifications (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles on delete cascade not null,
  title text not null,
  body text not null,
  data jsonb,
  ride_id uuid references public.rides on delete set null,
  is_read boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create index idx_notifications_user_id on public.notifications(user_id);
create index idx_notifications_is_read on public.notifications(is_read);

-- =============================================================================
-- Device Tokens (for FCM push notifications)
-- =============================================================================
create table public.device_tokens (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles on delete cascade not null,
  token text not null,
  platform text check (platform in ('android', 'ios', 'web')),
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(user_id, token)
);

create index idx_device_tokens_user_id on public.device_tokens(user_id);

-- =============================================================================
-- Payments
-- =============================================================================
create table public.payments (
  id uuid default gen_random_uuid() primary key,
  ride_id uuid references public.rides on delete cascade not null,
  amount decimal(10, 2) not null,
  currency text default 'ZAR',
  payment_method payment_method not null,
  status payment_status default 'pending',
  transaction_id text unique,
  receipt_url text,
  metadata jsonb,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create index idx_payments_ride_id on public.payments(ride_id);
create index idx_payments_status on public.payments(status);

-- =============================================================================
-- Support Tickets
-- =============================================================================
create table public.support_tickets (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles on delete cascade not null,
  ride_id uuid references public.rides on delete set null,
  subject text not null,
  description text not null,
  status text default 'open' check (status in ('open', 'in_progress', 'resolved', 'closed')),
  priority text default 'normal' check (priority in ('low', 'normal', 'high', 'critical')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create index idx_support_tickets_user_id on public.support_tickets(user_id);
create index idx_support_tickets_status on public.support_tickets(status);

-- =============================================================================
-- Saved Places
-- =============================================================================
create table public.saved_places (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles on delete cascade not null,
  label text not null,
  address text not null,
  latitude double precision not null,
  longitude double precision not null,
  is_favorite boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(user_id, address)
);

create index idx_saved_places_user_id on public.saved_places(user_id);

-- =============================================================================
-- Enable Row Level Security
-- =============================================================================
alter table public.profiles enable row level security;
alter table public.passengers enable row level security;
alter table public.drivers enable row level security;
alter table public.vehicles enable row level security;
alter table public.vehicle_documents enable row level security;
alter table public.ride_requests enable row level security;
alter table public.rides enable row level security;
alter table public.ride_locations enable row level security;
alter table public.ratings enable row level security;
alter table public.notifications enable row level security;
alter table public.device_tokens enable row level security;
alter table public.payments enable row level security;
alter table public.support_tickets enable row level security;
alter table public.saved_places enable row level security;

-- =============================================================================
-- RLS Policies: profiles
-- =============================================================================
create policy "profiles: users can read own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profiles: admins can read all profiles"
  on public.profiles for select
  using ((select coalesce((auth.jwt() ->> 'user_metadata')::jsonb ->> 'is_admin', 'false')::boolean));

create policy "profiles: users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

create policy "profiles: users can insert own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

-- =============================================================================
-- RLS Policies: passengers
-- =============================================================================
create policy "passengers: users can read own record"
  on public.passengers for select
  using (auth.uid() = id);

create policy "passengers: admins can read all"
  on public.passengers for select
  using ((select coalesce((auth.jwt() ->> 'user_metadata')::jsonb ->> 'is_admin', 'false')::boolean));

create policy "passengers: users can insert own record"
  on public.passengers for insert
  with check (auth.uid() = id);

create policy "passengers: users can update own record"
  on public.passengers for update
  using (auth.uid() = id);

-- =============================================================================
-- RLS Policies: drivers
-- =============================================================================
create policy "drivers: drivers can read own record"
  on public.drivers for select
  using (auth.uid() = id);

create policy "drivers: admins can read all"
  on public.drivers for select
  using ((select coalesce((auth.jwt() ->> 'user_metadata')::jsonb ->> 'is_admin', 'false')::boolean));

create policy "drivers: drivers can insert own record"
  on public.drivers for insert
  with check (auth.uid() = id);

create policy "drivers: drivers can update own record"
  on public.drivers for update
  using (auth.uid() = id);

-- Riders can see driver location and name
create policy "drivers: riders can see driver profile when on ride"
  on public.drivers for select
  using (
    exists (
      select 1 from public.rides
      where rides.driver_id = drivers.id
        and rides.passenger_id = auth.uid()
        and rides.status != 'completed'
        and rides.status != 'cancelled'
    )
  );

-- =============================================================================
-- RLS Policies: vehicles
-- =============================================================================
create policy "vehicles: drivers can read own vehicles"
  on public.vehicles for select
  using (driver_id = auth.uid());

create policy "vehicles: admins can read all"
  on public.vehicles for select
  using ((select coalesce((auth.jwt() ->> 'user_metadata')::jsonb ->> 'is_admin', 'false')::boolean));

create policy "vehicles: drivers can insert own vehicles"
  on public.vehicles for insert
  with check (driver_id = auth.uid());

create policy "vehicles: drivers can update own vehicles"
  on public.vehicles for update
  using (driver_id = auth.uid());

-- =============================================================================
-- RLS Policies: vehicle_documents
-- =============================================================================
create policy "vehicle_documents: drivers can read own documents"
  on public.vehicle_documents for select
  using (
    exists (
      select 1 from public.vehicles
      where vehicles.id = vehicle_documents.vehicle_id
        and vehicles.driver_id = auth.uid()
    )
  );

create policy "vehicle_documents: admins can read all"
  on public.vehicle_documents for select
  using ((select coalesce((auth.jwt() ->> 'user_metadata')::jsonb ->> 'is_admin', 'false')::boolean));

create policy "vehicle_documents: drivers can insert own documents"
  on public.vehicle_documents for insert
  with check (
    exists (
      select 1 from public.vehicles
      where vehicles.id = vehicle_documents.vehicle_id
        and vehicles.driver_id = auth.uid()
    )
  );

-- =============================================================================
-- RLS Policies: ride_requests
-- =============================================================================
create policy "ride_requests: passengers can read own requests"
  on public.ride_requests for select
  using (passenger_id = auth.uid());

create policy "ride_requests: admins can read all"
  on public.ride_requests for select
  using ((select coalesce((auth.jwt() ->> 'user_metadata')::jsonb ->> 'is_admin', 'false')::boolean));

create policy "ride_requests: drivers can read pending requests"
  on public.ride_requests for select
  using (status = 'pending' and exists (select 1 from public.drivers where drivers.id = auth.uid()));

create policy "ride_requests: passengers can insert own requests"
  on public.ride_requests for insert
  with check (passenger_id = auth.uid());

create policy "ride_requests: passengers can update own pending requests"
  on public.ride_requests for update
  using (passenger_id = auth.uid() and status = 'pending');

-- =============================================================================
-- RLS Policies: rides
-- =============================================================================
create policy "rides: drivers can read own rides"
  on public.rides for select
  using (driver_id = auth.uid());

create policy "rides: passengers can read own rides"
  on public.rides for select
  using (passenger_id = auth.uid());

create policy "rides: admins can read all"
  on public.rides for select
  using ((select coalesce((auth.jwt() ->> 'user_metadata')::jsonb ->> 'is_admin', 'false')::boolean));

create policy "rides: drivers can insert rides"
  on public.rides for insert
  with check (driver_id = auth.uid());

create policy "rides: drivers can update own rides"
  on public.rides for update
  using (driver_id = auth.uid());

-- =============================================================================
-- RLS Policies: ride_locations
-- =============================================================================
create policy "ride_locations: drivers can read own location"
  on public.ride_locations for select
  using (driver_id = auth.uid());

create policy "ride_locations: admins can read all"
  on public.ride_locations for select
  using ((select coalesce((auth.jwt() ->> 'user_metadata')::jsonb ->> 'is_admin', 'false')::boolean));

create policy "ride_locations: passengers can read driver location on active ride"
  on public.ride_locations for select
  using (
    exists (
      select 1 from public.rides
      where rides.driver_id = ride_locations.driver_id
        and rides.passenger_id = auth.uid()
        and rides.status in ('accepted', 'driverArrived', 'started')
    )
  );

create policy "ride_locations: drivers can update own location"
  on public.ride_locations for update
  using (driver_id = auth.uid());

create policy "ride_locations: drivers can insert own location"
  on public.ride_locations for insert
  with check (driver_id = auth.uid());

-- =============================================================================
-- RLS Policies: ratings
-- =============================================================================
create policy "ratings: users can read ratings for their rides"
  on public.ratings for select
  using (
    reviewed_id = auth.uid() or
    exists (
      select 1 from public.rides
      where rides.id = ratings.ride_id
        and (rides.driver_id = auth.uid() or rides.passenger_id = auth.uid())
    )
  );

create policy "ratings: admins can read all"
  on public.ratings for select
  using ((select coalesce((auth.jwt() ->> 'user_metadata')::jsonb ->> 'is_admin', 'false')::boolean));

create policy "ratings: users can insert ratings for completed rides"
  on public.ratings for insert
  with check (
    reviewer_id = auth.uid() and
    exists (
      select 1 from public.rides
      where rides.id = ratings.ride_id
        and rides.completed_at is not null
        and (rides.driver_id = auth.uid() or rides.passenger_id = auth.uid())
    )
  );

-- =============================================================================
-- RLS Policies: notifications
-- =============================================================================
create policy "notifications: users can read own notifications"
  on public.notifications for select
  using (user_id = auth.uid());

create policy "notifications: admins can read all"
  on public.notifications for select
  using ((select coalesce((auth.jwt() ->> 'user_metadata')::jsonb ->> 'is_admin', 'false')::boolean));

create policy "notifications: users can update own notifications"
  on public.notifications for update
  using (user_id = auth.uid());

-- =============================================================================
-- RLS Policies: device_tokens
-- =============================================================================
create policy "device_tokens: users can manage own tokens"
  on public.device_tokens for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- =============================================================================
-- RLS Policies: payments
-- =============================================================================
create policy "payments: users can read payments for own rides"
  on public.payments for select
  using (
    exists (
      select 1 from public.rides
      where rides.id = payments.ride_id
        and (rides.driver_id = auth.uid() or rides.passenger_id = auth.uid())
    )
  );

create policy "payments: admins can read all"
  on public.payments for select
  using ((select coalesce((auth.jwt() ->> 'user_metadata')::jsonb ->> 'is_admin', 'false')::boolean));

create policy "payments: system can insert payments"
  on public.payments for insert
  with check (true);

-- =============================================================================
-- RLS Policies: support_tickets
-- =============================================================================
create policy "support_tickets: users can read own tickets"
  on public.support_tickets for select
  using (user_id = auth.uid());

create policy "support_tickets: admins can read all"
  on public.support_tickets for select
  using ((select coalesce((auth.jwt() ->> 'user_metadata')::jsonb ->> 'is_admin', 'false')::boolean));

create policy "support_tickets: users can create tickets"
  on public.support_tickets for insert
  with check (user_id = auth.uid());

-- =============================================================================
-- RLS Policies: saved_places
-- =============================================================================
create policy "saved_places: users can manage own places"
  on public.saved_places for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- =============================================================================
-- Database Functions
-- =============================================================================

-- Function: find_nearby_drivers
-- Purpose: Find drivers within a specified radius of a pickup location
create or replace function find_nearby_drivers(
  pickup_lat double precision,
  pickup_lng double precision,
  radius_m int default 5000
)
returns table (
  driver_id uuid,
  driver_name text,
  distance_m double precision,
  current_latitude double precision,
  current_longitude double precision
) as $$
  select
    d.id,
    p.full_name,
    st_distance(
      st_makepoint(pickup_lng, pickup_lat)::geography,
      rl.location
    ) as distance_m,
    rl.latitude,
    rl.longitude
  from public.drivers d
  join public.ride_locations rl on d.id = rl.driver_id
  join public.profiles p on d.id = p.id
  where d.status = 'online'
    and d.is_verified = true
    and rl.location is not null
    and st_dwithin(
      st_makepoint(pickup_lng, pickup_lat)::geography,
      rl.location,
      radius_m
    )
  order by distance_m asc;
$$ language sql stable;

-- Function: accept_ride_request_atomic
-- Purpose: Atomically accept a ride request, preventing race conditions
-- Security: definer=true so it runs with schema owner privileges
create or replace function accept_ride_request_atomic(
  p_request_id uuid,
  p_driver_id uuid
)
returns jsonb as $$
declare
  v_request public.ride_requests%rowtype;
  v_ride_id uuid;
  v_result jsonb;
begin
  -- Lock and check the ride request in one atomic operation
  select * into v_request from public.ride_requests
  where id = p_request_id
  for update;

  -- Verify request exists and is still pending
  if v_request.id is null then
    return jsonb_build_object(
      'success', false,
      'error', 'Ride request not found'
    );
  end if;

  if v_request.status != 'pending' then
    return jsonb_build_object(
      'success', false,
      'error', 'Ride request is no longer available'
    );
  end if;

  -- Verify driver exists and is verified
  if not exists (select 1 from public.drivers where id = p_driver_id and is_verified = true) then
    return jsonb_build_object(
      'success', false,
      'error', 'Driver is not verified'
    );
  end if;

  -- Create the ride record (unique constraint on ride_request_id acts as backstop)
  insert into public.rides (
    ride_request_id,
    driver_id,
    passenger_id,
    status,
    payment_method,
    pickup_latitude,
    pickup_longitude,
    pickup_address,
    dropoff_latitude,
    dropoff_longitude,
    dropoff_address,
    driver_accepted_at
  )
  values (
    v_request.id,
    p_driver_id,
    v_request.passenger_id,
    'accepted'::ride_status,
    v_request.payment_method,
    v_request.pickup_latitude,
    v_request.pickup_longitude,
    v_request.pickup_address,
    v_request.dropoff_latitude,
    v_request.dropoff_longitude,
    v_request.dropoff_address,
    now()
  )
  returning rides.id into v_ride_id;

  -- Update request status
  update public.ride_requests
  set status = 'accepted', updated_at = now()
  where id = p_request_id;

  -- Update driver status
  update public.drivers
  set status = 'onRide', updated_at = now()
  where id = p_driver_id;

  v_result := jsonb_build_object(
    'success', true,
    'ride_id', v_ride_id,
    'message', 'Ride accepted successfully'
  );

  return v_result;
exception when unique_violation then
  return jsonb_build_object(
    'success', false,
    'error', 'Ride already accepted by another driver'
  );
end;
$$ language plpgsql security definer;

-- Function: calculate_fare
-- Purpose: Calculate fare based on coordinates and vehicle type
create or replace function calculate_fare(
  pickup_lat double precision,
  pickup_lng double precision,
  dropoff_lat double precision,
  dropoff_lng double precision,
  vehicle_type_param vehicle_type default 'standard'::vehicle_type
)
returns decimal as $$
declare
  v_distance_m double precision;
  v_base_rate decimal := 10.00;
  v_rate_per_km decimal;
  v_minimum_fare decimal := 50.00;
  v_fare decimal;
begin
  -- Calculate distance using PostGIS
  v_distance_m := st_distance(
    st_makepoint(pickup_lng, pickup_lat)::geography,
    st_makepoint(dropoff_lng, dropoff_lat)::geography
  );

  -- Determine rate per km based on vehicle type
  case vehicle_type_param
    when 'motorcycle' then v_rate_per_km := 8.00;
    when 'standard' then v_rate_per_km := 12.00;
    when 'comfort' then v_rate_per_km := 15.00;
    when 'premium' then v_rate_per_km := 18.00;
    else v_rate_per_km := 12.00;
  end case;

  -- Calculate fare
  v_fare := v_base_rate + ((v_distance_m / 1000) * v_rate_per_km);

  -- Apply minimum fare
  if v_fare < v_minimum_fare then
    v_fare := v_minimum_fare;
  end if;

  return v_fare;
end;
$$ language plpgsql immutable;

-- =============================================================================
-- Triggers
-- =============================================================================

-- Trigger: update_driver_stats_on_rating
-- Purpose: Update driver average rating and ride count when a new rating is created
create or replace function update_driver_stats_on_rating()
returns trigger as $$
declare
  v_driver_id uuid;
  v_avg_rating decimal(3,2);
  v_total_ratings int;
begin
  -- Get the driver ID from the ride
  select driver_id into v_driver_id
  from public.rides
  where id = new.ride_id;

  if v_driver_id is not null then
    -- Calculate average rating for the driver
    select coalesce(avg(score)::decimal(3,2), 5.0), count(*)
    into v_avg_rating, v_total_ratings
    from public.ratings
    where reviewed_id = v_driver_id;

    -- Update driver stats
    update public.drivers
    set average_rating = v_avg_rating
    where id = v_driver_id;
  end if;

  -- Update passenger stats if rating is for passenger
  if new.reviewed_id in (select id from public.passengers) then
    select coalesce(avg(score)::decimal(3,2), 5.0), count(*)
    into v_avg_rating, v_total_ratings
    from public.ratings
    where reviewed_id = new.reviewed_id;

    update public.passengers
    set average_rating = v_avg_rating
    where id = new.reviewed_id;
  end if;

  return new;
end;
$$ language plpgsql;

create trigger trigger_update_driver_stats_on_rating
after insert on public.ratings
for each row
execute function update_driver_stats_on_rating();

-- Trigger: increment_ride_count_on_completed_ride
-- Purpose: Increment driver and passenger ride counts when a ride is completed
create or replace function increment_ride_count_on_completed_ride()
returns trigger as $$
begin
  if new.status = 'completed' and (old.status != 'completed' or old.status is null) then
    -- Increment driver ride count
    update public.drivers
    set total_rides = total_rides + 1
    where id = new.driver_id;

    -- Increment passenger ride count
    update public.passengers
    set total_rides = total_rides + 1
    where id = new.passenger_id;
  end if;

  return new;
end;
$$ language plpgsql;

create trigger trigger_increment_ride_count_on_completed_ride
after update on public.rides
for each row
execute function increment_ride_count_on_completed_ride();

-- Trigger: update_pickup_location_geography
-- Purpose: Automatically maintain PostGIS geography column from lat/lng
create or replace function update_pickup_location_geography()
returns trigger as $$
begin
  new.pickup_location := st_makepoint(new.pickup_longitude, new.pickup_latitude)::geography;
  return new;
end;
$$ language plpgsql;

create trigger trigger_update_pickup_location_geography
before insert or update on public.ride_requests
for each row
execute function update_pickup_location_geography();

-- Trigger: update_driver_location_geography
-- Purpose: Automatically maintain PostGIS geography column from lat/lng
create or replace function update_driver_location_geography()
returns trigger as $$
begin
  new.location := st_makepoint(new.longitude, new.latitude)::geography;
  return new;
end;
$$ language plpgsql;

create trigger trigger_update_driver_location_geography
before insert or update on public.ride_locations
for each row
execute function update_driver_location_geography();

-- Trigger: update_updated_at_timestamp
-- Purpose: Automatically update the updated_at column
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trigger_update_profiles_updated_at
before update on public.profiles
for each row
execute function update_updated_at_column();

create trigger trigger_update_passengers_updated_at
before update on public.passengers
for each row
execute function update_updated_at_column();

create trigger trigger_update_drivers_updated_at
before update on public.drivers
for each row
execute function update_updated_at_column();

create trigger trigger_update_vehicles_updated_at
before update on public.vehicles
for each row
execute function update_updated_at_column();

create trigger trigger_update_ride_requests_updated_at
before update on public.ride_requests
for each row
execute function update_updated_at_column();

create trigger trigger_update_rides_updated_at
before update on public.rides
for each row
execute function update_updated_at_column();

create trigger trigger_update_payments_updated_at
before update on public.payments
for each row
execute function update_updated_at_column();

create trigger trigger_update_support_tickets_updated_at
before update on public.support_tickets
for each row
execute function update_updated_at_column();

create trigger trigger_update_saved_places_updated_at
before update on public.saved_places
for each row
execute function update_updated_at_column();

-- =============================================================================
-- Storage Configuration (to be set up via Supabase Dashboard or Edge Function)
-- =============================================================================
-- Create storage buckets for:
--   - avatars (user profile pictures)
--   - driver_documents (licenses, etc.)
--   - vehicle_photos (vehicle pictures)
--   - vehicle_registration (vehicle docs)
--   - insurance (insurance docs)
--
-- Each bucket should have RLS policies that allow:
--   - Users to upload/read their own files
--   - Admins to read all files
