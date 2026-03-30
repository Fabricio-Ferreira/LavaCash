/** Ambient types for Supabase Edge Functions (Deno). Used when the IDE does not resolve JSR edge-runtime. */
declare namespace Deno {
  function serve(
    handler: (req: Request) => Response | Promise<Response>,
  ): void;

  const env: {
    get(key: string): string | undefined;
  };
}
