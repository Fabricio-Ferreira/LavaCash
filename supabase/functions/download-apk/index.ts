/// <reference path="./deno.d.ts" />
import { createClient } from "@supabase/supabase-js";

const bucket = "app-releases";
const signedUrlExpiresSeconds = 60;

Deno.serve(async (_req: Request) => {
  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !serviceRoleKey) {
      return new Response(
        JSON.stringify({ error: "Server configuration error" }),
        {
          status: 500,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey);

    const { data: row, error: rowError } = await supabase
      .from("app_version")
      .select("apk_storage_path")
      .eq("id", 1)
      .single();

    if (rowError) {
      return new Response(
        JSON.stringify({ error: rowError.message }),
        {
          status: 500,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    const filePath = (row as { apk_storage_path?: string })
      .apk_storage_path?.trim() ?? "";

    if (!filePath) {
      return new Response(
        JSON.stringify({ error: "APK path is not configured" }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    const { data, error } = await supabase.storage
      .from(bucket)
      .createSignedUrl(filePath, signedUrlExpiresSeconds);

    if (error) {
      return new Response(
        JSON.stringify({ error: error.message }),
        {
          status: 500,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    return new Response(
      JSON.stringify({ url: data.signedUrl }),
      {
        headers: { "Content-Type": "application/json" },
      },
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ error: String(e) }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      },
    );
  }
});
