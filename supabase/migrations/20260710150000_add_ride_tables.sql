-- Create enum types if not exists
do $$ begin
    if not exists (select 1 from pg_type where typname = 'ride_status') then
        create type ride_status as enum ('pending', 'accepted', 'driverArrived', 'started', 'completed', 'cancelled');
    end if;
    if not exists (select 1 from pg_type where typname = 'payment_method') then
        create type payment_method as enum ('cash', 'yocoCard', 'mtnMomo');
    end if;
    if not exists (select 1 from pg_type where typname = 'payment_status') then
        create type payment_status as enum ('pending', 'authorized', 'captured', 'failed', 'refunded');
    end if;
end $$;

-- Ride Requests
create table public.ride_requests (
  id uuid default gen_random_uuid() primary key,
  passenger_id uuid references public.passengers on delete cascade not null,
  pickup_latitude decimal not null,
  pickup_longitude decimal not null,
  pickup_address text not null,
  dropoff_latitude decimal not null,
  dropoff_longitude decimal not null,
  dropoff_address text not null,
  payment_method payment_method not null,
  estimated_fare decimal,
  status text default 'pending',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Rides
create table public.rides (
  id uuid default gen_random_uuid() primary key,
  ride_request_id uuid references public.ride_requests on delete cascade not null,
  driver_id uuid references public.drivers on delete cascade not null,
  status ride_status not null,
  payment_status payment_status default 'pending',
  fare decimal,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Ride Locations
create table public.ride_locations (
  driver_id uuid references public.drivers on delete cascade primary key,
  latitude decimal not null,
  longitude decimal not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);
