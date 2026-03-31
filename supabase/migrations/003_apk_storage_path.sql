-- Rename apk_url to apk_storage_path (path inside private bucket app-releases).

ALTER TABLE public.app_version
  RENAME COLUMN apk_url TO apk_storage_path;

COMMENT ON COLUMN public.app_version.apk_storage_path IS
  'Storage path within app-releases bucket, e.g. lavacash/latest.apk';
