# Zeni — Full Audit & Fix/Upgrade Plan

**Scope reviewed:** `database/schema.sql`, `supabase/migrations/*`, `shared_packages/*` (models, services, widgets, utilities), `rider_app/lib`, `driver_app/lib`, `admin_site/src`, `.env` files, `the-plan`, `admin_dashboard_plan.md`, `implementation_iteration_plan.md`.

**Main goal this plan serves:** ship a *correct, secure, internally-consistent* V1 — rider app + driver app + minimal admin — on the stack already chosen (Flutter, BLoC, GoRouter, Supabase/Postgres/PostGIS, Firebase Cloud Messaging). Nothing here proposes a framework change.

---

## 1. The core problem: three schemas that disagree with each other

There isn't one database schema in this repo — there are three, and they don't match:

| Source | Represents | Status |
|---|---|---|
| `supabase/migrations/*.sql` | What actually gets deployed to Supabase | **Oldest, most incomplete** |
| `database/schema.sql` | An aspirational "full" schema, never turned into a migration | Partially matches the app code |
| `shared_packages/models/lib/src/*.dart` | What the Flutter apps assume the DB looks like | **Newest, most complete** — but not fully matched by either SQL source |

Concretely:

- **`drivers.status`** — migration allows `pending_approval / active / suspended`; `schema.sql` and the Dart `DriverStatus` enum use `offline / online / onRide / pendingApproval / suspended`. If you ran the migrations today, driver status logic in the app would break immediately (`onRide` isn't a legal value).
- **`rides`** — the migration's `rides` table has no `passenger_id`, no pickup/dropoff columns, no `driver_accepted_at`/`started_at`/etc. `driver_home_bloc.dart` inserts all of those fields. Against the migrated DB, every ride-accept call fails.
- **`ride_requests`** — migration is missing `requested_vehicle_type`, `estimated_distance`, `estimated_duration`, `expires_at`. `booking_bloc.dart` writes those fields directly. Same failure mode.
- **`vehicles`** — the Dart `Vehicle` model expects `type`, `license_plate`, `color`, `capacity`, `is_active`. Neither SQL source has `color`, `capacity`, or `is_active`, and both use `vehicle_type`/`plate_number` instead. `Vehicle.fromJson` will throw on real data.
- **`passengers`** — the Dart model expects `profile_id`, `average_rating`, `total_rides`, `emergency_contact_name/phone`, `favorite_addresses`. The table has only `id`, `rating`, `created_at`. Every passenger-profile read will throw.
- **`ratings`** — Dart model expects `reviewer_id`/`reviewed_id`/`review`; the table has `rated_by`/`rated_user`/`comment`.
- **`ride_locations`** — this is the most structurally serious mismatch. The DB models it as **one row per driver** (`driver_id` is the primary key, upserted continuously — good for "where is my driver now"). The Dart `RideLocation` model expects a **history table** (`id`, `ride_id`, `speed`, `accuracy`, `recorded_at` — a log of GPS pings per ride). These are two different designs solving two different problems, and only one can be right.

**Why this hasn't blown up yet:** the actual `services/` layer (`api_client.dart`, `supabase_client.dart`) is just a thin client wrapper — there's no repository/data-access layer wired up yet that would exercise these mismatched paths end-to-end in a way that surfaces at compile time. The blocs call `.from('table').insert(...)` directly with raw maps, which is why it compiles fine today and would only fail at runtime against a real database.

**Fix approach:** pick one schema as the source of truth (below), rewrite the migrations to match it exactly, and make the Dart models match the same source. Do this before anything else — every other fix in this plan builds on top of a schema that actually exists.

---

## 2. Critical issues (fix before any further feature work)

### 2.1 Schema/model/migration divergence — *see above*
**Fix:** Section 6 gives the target schema. Delete the three existing migrations (nothing is in production yet — confirmed via `supabase/.temp/linked-project.json`, this is a live-linked but presumably pre-launch project) and replace with one clean, correct migration set.

### 2.2 Ride acceptance has a race condition — two drivers can win the same ride
In `driver_home_bloc.dart`, accepting a ride is two separate, non-atomic client calls:
1. `insert` into `rides`
2. `update` `ride_requests.status = 'accepted'`

There's no unique constraint on `rides.ride_request_id`, and the RLS policy that gates step 2 (`status = 'pending'`) doesn't lock the row. Two drivers who both read `status: pending` in the same instant can both pass the RLS check and both insert a `rides` row for the same request. Result: two drivers show up, one passenger, a support nightmare.

**Fix:**
- Add `unique (ride_request_id)` on `rides` as a hard backstop.
- Replace the two-step client flow with a single **Postgres RPC function** (`accept_ride_request(request_id uuid)`, `security definer`) that does the `UPDATE ride_requests SET status='accepted' WHERE id = $1 AND status = 'pending'` and the `INSERT INTO rides` in one transaction, checks `FOUND`, and raises an exception (which the client surfaces as "ride no longer available") if another driver got there first. Call this from an Edge Function or directly via `rpc()` — either works, RPC is simpler here.

### 2.3 Fare is computed client-side and trusted verbatim
`booking_bloc.dart` computes `estimated_fare` with a client-side Haversine formula and writes it straight into `ride_requests`. Nothing recalculates or validates it server-side before it becomes the amount charged. A modified client (or a MITM'd request) can set fare to anything, including negative or zero.

**Fix:** Move fare calculation into a Postgres function or Edge Function that takes pickup/dropoff coordinates and vehicle type and returns the fare; the client calls it to *display* an estimate, but the authoritative fare is (re)computed server-side at ride-accept time and again at ride-completion time (using actual distance/duration, not the estimate). Never trust a fare value written by the client.

### 2.4 No admin access path exists — the admin dashboard cannot read any data
Every RLS policy in `schema.sql` is scoped to `auth.uid() = <owner column>`. There is no `is_admin` concept anywhere in the schema, and `admin_site/src/lib/supabase.ts` connects with the plain anon key. As built, an admin logging into `admin_site` would see empty tables everywhere — RLS blocks all of it. (This is the same pattern already solved for the IllDoIt admin console — `is_admin` in JWT `user_metadata` plus RLS policies that check it — and it should be reused here rather than re-invented.)

**Fix:** Section 6 includes `is_admin`-aware RLS policies. Admin auth needs a real login flow in `admin_site` (currently there isn't one at all — no session check, no protected routes).

### 2.5 `.env` files with live credentials are committed to a public GitHub repo
`rider_app/.env`, `driver_app/.env`, and `admin_site/.env` are all tracked in git and contain the real Supabase project URL and **anon** key. The anon key is designed to be public-safe (it's meaningless without correct RLS behind it), so this isn't a "rotate everything now" emergency the way a `service_role` key leak would be — but:
- It's still bad practice and makes it trivial for anyone to point traffic at your project and probe your RLS policies (which, per 2.2–2.4, currently have real gaps).
- If a `service_role` key or payment-gateway secret ever gets added to one of these files later out of habit, it goes straight into git history.

**Fix:**
- `git rm --cached` all three `.env` files, add `.env` to `.gitignore` (currently missing from the repo entirely — there's no root `.gitignore`), and commit `.env.example` templates instead.
- Because the key has been public, rotate it anyway as routine hygiene — it's a 5-minute Supabase dashboard action and removes any doubt.
- Add a pre-commit hook or CI secret scan (e.g. gitleaks) so this can't recur silently.

### 2.6 PostGIS is enabled but never used — driver matching has no real query behind it
`postgis` is enabled in the schema, but every coordinate column is `double precision` lat/lng, not `geography(Point,4326)`. There's no spatial index. And `driver_request_bloc.dart` on the driver side just subscribes to *all* `ride_requests` with `status = 'pending'` — a driver in Polokwane will see a ride request in Cape Town. There is no "nearby drivers" query anywhere in the codebase, despite it being core to the product.

**Fix:**
- Add a generated `geography(Point,4326)` column (or store pickup as geography directly) with a `GIST` index.
- Add a Postgres function `find_nearby_drivers(pickup geography, radius_m int)` using `ST_DWithin`, and use it both for (a) filtering which drivers get notified of a request, and (b) the rider's "searching for driver" estimate.
- This is the single most important missing piece for the product to actually function as a ride-hailing app at any scale beyond a demo.

### 2.7 Driver document verification has no upload path
`registration_bloc.dart` inserts driver/vehicle rows but never uploads to Supabase Storage — no bucket writes anywhere in the codebase, despite `vehicle_documents` existing in the schema and `the-plan` specifying license/vehicle-photo/insurance uploads as required for driver approval. As built, a driver can reach `pendingApproval` status with nothing for an admin to actually review.

**Fix:** Add storage bucket creation (`avatars`, `driver_documents`, `vehicle_photos`, `vehicle_registration`, `insurance`) with owner-scoped RLS-equivalent storage policies, wire `image_picker` → upload → `vehicle_documents` insert in the registration flow, and give the admin console a document-review screen (reuse the KYC-verification pattern already built for IllDoIt's admin console).

### 2.8 No payments beyond cash actually exist
`the-plan` and the `PaymentMethod` enum both list Yoco and MTN MoMo as V1-required. In the code, only `ConfirmCashPayment` exists in `payment_bloc.dart` — no Yoco SDK integration, no MoMo API calls, no webhook handler for either. Riders can currently *select* Yoco/MoMo at booking time, but nothing happens when they do — the ride proceeds with no actual payment captured.

**Fix:** Either (a) implement both gateways properly before launch — Edge Functions for the server-side webhook/callback handling (never do card/payment auth from the Flutter client directly), or (b) cut MoMo/Yoco from the payment-method selector until they're real, so the UI doesn't promise something that silently does nothing. Given "flawless" is the goal, (b) now + (a) as a fast-follow is the safer sequencing.

---

## 3. High-priority issues (fix right after the above)

- **No rating aggregates.** Nothing recalculates `drivers.average_rating`/`total_rides` or the passenger equivalent when a row is inserted into `ratings`. Add an `AFTER INSERT` trigger that updates both.
- **No indexes anywhere except primary keys.** At minimum: `ride_requests(status, created_at)` for the driver polling/subscription query, `rides(driver_id, status)`, `rides(passenger_id, status)`, `drivers(status, is_verified)`.
- **No notification-sending pipeline.** `NotificationService` only *registers* FCM tokens — nothing sends a push on ride-accepted/driver-arrived/ride-cancelled, despite these being explicitly scoped in `the-plan`. Needs a `notifications` table + Edge Function (or DB trigger → `pg_net` call to an Edge Function) that fires FCM sends on the relevant status transitions.
- **`ride_locations` design decision needed now** (tied to 2.1): recommend keeping the **singleton-per-driver** design (matches real ride-hailing UX — you only need "where is the driver right now," not a full GPS trail) and updating the Dart model to match, rather than building a history table you don't have a use case for yet. If trip-replay/insurance-dispute history is a real future requirement, add a separate lightweight `ride_location_history` table later rather than overloading the live-tracking table.
- **Missing tables `the-plan` promises but the schema doesn't have:** `payments`, `payment_methods`, `notifications`, `support_tickets`, `saved_places`. `reviews` was apparently folded into `ratings` (fine, but `the-plan` should be updated to reflect that decision rather than left contradicting the implementation).

---

## 4. Medium-priority issues

- No soft-delete/audit trail on any table — a cancelled ride or a suspended driver just changes a status column with no record of who/why. Add a lightweight `audit_log` table (mirrors the IllDoIt admin console's audit log — reuse that pattern) at least for driver approval/suspension and dispute-relevant ride changes.
- No automated tests found under `driver_app/test` or `rider_app/test` beyond default Flutter scaffolding — confirm and add bloc-level tests for the ride-accept race condition specifically (that's the one bug class you really don't want to find in production).
- `admin_site` has no auth/session/route-guarding at all yet — it's UI scaffolding only (`DashboardPage.tsx` is a static "Welcome" page). Needs the same admin auth pattern used for IllDoIt before it's usable.
- No CI (no GitHub Actions found) — nothing currently stops a broken migration or a model/schema mismatch like the ones in Section 1 from being merged silently.

---

## 5. What's actually solid already

Worth naming, so the fix plan doesn't read as "everything is broken":
- Feature-folder BLoC architecture is clean and consistent across both apps.
- RLS is *enabled* on every table and the policies that do exist are reasonably scoped (owner-only, with sensible ride-partner exceptions for driver location/profile visibility).
- The cash payment confirmation flow correctly guards against confirming payment before a ride is actually completed.
- Credentials are passed via `--dart-define` rather than hardcoded in Dart source — the `.env` issue is a git-hygiene problem, not a "secrets in code" problem.
- `shared_packages` separation (models/services/widgets/utilities) is the right call for a two-app monorepo and should stay.

---

## 6. Target database schema (source of truth going forward)

Replace `database/schema.sql` and all of `supabase/migrations/` with one corrected migration set built around:

**Fix all field-name mismatches** (align to the Dart models, since they're the newest/most complete spec):
- `vehicles`: rename `vehicle_type`→`type`, `plate_number`→`license_plate`; add `color text`, `capacity int`, `is_active boolean default true`.
- `passengers`: add `profile_id` (or drop it from the Dart model and keep `id` as the FK — pick one, don't have both concepts), `average_rating`, `total_rides`, `emergency_contact_name`, `emergency_contact_phone`, `favorite_addresses text[]`.
- `ratings`: rename `rated_by`→`reviewer_id`, `rated_user`→`reviewed_id`, `comment`→`review`.
- `ride_locations`: keep singleton-per-driver design; update Dart model to match instead (`driver_id` PK, `latitude`, `longitude`, `heading`, `updated_at` — no `id`/`ride_id`/`speed`/`accuracy`/`recorded_at`).
- `drivers.status`: standardize on the Dart enum values (`offline/online/onRide/pendingApproval/suspended`) everywhere.

**Add missing structural pieces:**
- `geography(Point,4326)` + GIST index for driver/pickup matching (2.6).
- `unique (ride_request_id)` on `rides` (2.2).
- Indexes listed in Section 3.
- `is_admin`-aware RLS policies (2.4).
- Rating-aggregate trigger (Section 3).
- New tables: `payments`, `notifications`, `support_tickets`, `saved_places` (skip `payment_methods` unless you're storing tokenized cards — Yoco/MoMo typically don't need it client-side).
- Storage buckets + policies (2.7).

---

## 7. Sequencing (phased, dependency-ordered)

**Phase 0 — Stop the bleeding (do first, ~1–2 days)**
1. Remove `.env` files from git, add `.gitignore`, rotate the anon key.
2. Decide the source-of-truth schema (Section 6) and write it down before touching code.

**Phase 1 — Schema correctness (blocks everything else)**
3. Rewrite `supabase/migrations/` as one clean, correct set matching Section 6.
4. Update all Dart models in `shared_packages/models` to match exactly (especially `Vehicle`, `Passenger`, `Rating`, `RideLocation`).
5. Add the missing indexes, the `rides.ride_request_id` unique constraint, and the rating-aggregate trigger.

**Phase 2 — Correctness-critical business logic**
6. Implement `accept_ride_request` RPC function; update `driver_home_bloc.dart` to call it instead of the two-step insert/update.
7. Move fare calculation server-side (estimate function + authoritative recompute on accept/complete).
8. Add PostGIS geography column + `find_nearby_drivers` function; wire the driver-side subscription to filter by proximity instead of "all pending requests."

**Phase 3 — Complete the promised feature set**
9. Storage buckets + document upload flow + admin KYC review screen.
10. `notifications` table + Edge Function push-sending pipeline for ride-status events.
11. Admin auth (`is_admin` claim) + protect `admin_site` routes + wire real data fetching.
12. Either finish Yoco/MoMo integration properly (Edge Function webhook handlers) or remove them from the payment-method selector until they're real.

**Phase 4 — Hardening**
13. Bloc-level tests, especially for the ride-accept race condition.
14. Basic CI (lint + `flutter analyze` + a migration-lint step that fails if `schema.sql`/models drift again).
15. Audit log table for driver approval/suspension and dispute-relevant changes.

---

## 8. One process fix worth calling out

The root cause of Section 1 wasn't any single bad decision — it's that `database/schema.sql` and `supabase/migrations/` were allowed to exist as two separate "sources of truth" that quietly diverged. Going forward: **only the migrations directory should exist.** `schema.sql` should either be deleted or regenerated *from* the migrations (`supabase db dump`) so it's a read-only artifact, never a second place to hand-edit schema. That single rule would have prevented most of Section 1.
