# Casa Lazzarini

Mobile booking application for a private three-suite structure.

## Stack

- **Flutter** 3.47.1 / Dart 3.13.1
- **Supabase** — Auth, PostgreSQL, Row Level Security
- **Riverpod** 2.6.1 — state management
- **go_router** 14.8.1 — navigation
- **Google Fonts** — Playfair Display (display) + Inter (UI)

## Prerequisites

- Flutter SDK 3.47.1 or later
- Android Studio (Android SDK, platform-tools, NDK 28.2.13676358)
- Connected Android device or emulator (API 36+)
- A Supabase project (free tier is sufficient for development)

## Setup

### 1. Clone and install dependencies

```sh
flutter pub get
```

### 2. Configure Supabase credentials

The app reads credentials via Dart compile-time environment variables.  
**Never commit real credentials to source control.**

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Or create a local launch configuration in your IDE that passes the same flags.

> The anon/publishable key is safe to embed in the client — it respects Row Level Security.  
> Never place the **service-role key** in the app.

### 3. Apply database migrations

Run the migration files in order against your Supabase project via the SQL Editor or CLI:

```
supabase/migrations/20260930000001_initial_schema.sql
supabase/migrations/20260930000002_rls_policies.sql
```

Then seed the three suites:

```
supabase/seed.sql
```

### 4. Create a test user

Sign up is intentionally not exposed in the app UI. Create users directly in the Supabase dashboard:

**Authentication → Users → Add user**

The `handle_new_user` database trigger will automatically create the `profiles` row with `role = 'user'`.

To create a SUPER_ADMIN, update the role in the Supabase Table Editor after the profile is created:

```sql
UPDATE public.profiles SET role = 'super_admin' WHERE id = '<user-uuid>';
```

## Running on Android

```sh
flutter run -d <device-id>
```

List available devices:
```sh
flutter devices
```

## Testing

```sh
flutter test
```

## Architecture

```
lib/
  main.dart                        — entry point
  app/app.dart                     — root widget + router
  core/
    routing/                       — go_router + auth guard
    theme/                         — CLColors, CLTypography, CLSpacing, CLTheme
    constants/supabase_config.dart — credential config (no secrets)
    errors/app_exceptions.dart     — error hierarchy
  features/
    auth/                          — login, auth state, Riverpod providers
    home/                          — home screen
    admin/                         — admin placeholder
  shared/
    models/                        — Profile, Suite, Booking, enums
    widgets/                       — CLPrimaryButton, CLCard, CLBottomSheet, …
supabase/
  migrations/                      — SQL schema + RLS
  seed.sql                         — initial suite data
```

## Current Phase

**Phase 1 — Foundation** (complete)

- Flutter project, Android + iOS targets
- Domain models and error hierarchy
- Casa Lazzarini premium design system
- Supabase schema, RLS, anti-double-booking constraint
- Email/password authentication with session persistence
- Role-aware routing (USER / SUPER_ADMIN)
- Login screen, home screen, admin placeholder

## Known Limitations

- Booking calendar — Phase 2
- My Bookings — Phase 3
- Admin booking management — Phase 3
- iOS build requires macOS + Xcode
