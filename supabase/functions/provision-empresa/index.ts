/// <reference path="./deno.d.ts" />
import { createClient } from "@supabase/supabase-js";

interface ProvisionRequest {
  nome: string;
  telefone?: string;
  activation_code: string;
}

Deno.serve(async (req: Request) => {
  const secret = req.headers.get("x-admin-secret");
  if (secret !== Deno.env.get("ADMIN_SECRET")) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  let body: ProvisionRequest;
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "Invalid JSON body" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  const { nome, telefone, activation_code } = body;

  if (!nome?.trim() || !activation_code?.trim()) {
    return new Response(
      JSON.stringify({ error: "nome e activation_code são obrigatórios" }),
      { status: 400, headers: { "Content-Type": "application/json" } },
    );
  }

  // Service role bypassa RLS — INSERT com owner_id NULL (pre-provisionado)
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const { data, error } = await supabase
    .from("empresas")
    .insert({
      nome: nome.trim(),
      telefone: telefone?.trim() ?? null,
      activation_code: activation_code.trim(),
    })
    .select("id")
    .single();

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }

  return new Response(JSON.stringify({ empresa_id: data.id }), {
    status: 201,
    headers: { "Content-Type": "application/json" },
  });
});
