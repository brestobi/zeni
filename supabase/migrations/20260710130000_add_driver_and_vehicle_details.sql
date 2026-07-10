-- Add driver details
alter table public.drivers add column license_number text;
alter table public.drivers add column license_image_url text;

-- Add vehicle details
alter table public.vehicles add column photo_url text;
