-- Remove legacy license tables from the main app DB.
-- Current licensing uses a dedicated Supabase project (Flutter: license_supabase_client).

DROP FUNCTION IF EXISTS public.activate_license(text, text);

DROP TABLE IF EXISTS public.activation_keys CASCADE;
DROP TABLE IF EXISTS public.licencas CASCADE;
