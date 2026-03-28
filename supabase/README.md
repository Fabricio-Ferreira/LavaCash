# Supabase (Lava Cash)

## Apply migrations to the remote project

**Option A — CLI (recommended)**

1. Install the [Supabase CLI](https://supabase.com/docs/guides/cli).
2. Log in: `supabase login`
3. Link this repo to your project (project ref is in the Supabase dashboard URL):
   `supabase link --project-ref <YOUR_PROJECT_REF>`
4. Push migrations:
   `supabase db push`

**Option B — Dashboard**

Open the Supabase SQL Editor, paste the contents of
`migrations/001_initial.sql`, and run it.

## Seed data (tests)

[`seed.sql`](seed.sql) inserts demo clients, vehicles, and services.

- Local: `supabase db reset` applies migrations then `seed.sql`.
- Remote: paste `seed.sql` in the SQL Editor after migrations.

## Local development

- Start stack: `supabase start`
- Stop: `supabase stop`
