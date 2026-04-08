-- CRM + app comercial: create empresa row returning id; join empresa as device user.

-- ---------------------------------------------------------------------------
-- create_empresa_for_crm — SECURITY DEFINER (CRM anon inserts pre-claim empresa)
-- ---------------------------------------------------------------------------

create or replace function public.create_empresa_for_crm(
  p_nome text,
  p_telefone text,
  p_activation_code text
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid;
  v_code text := nullif(trim(coalesce(p_activation_code, '')), '');
  v_nome text := nullif(trim(coalesce(p_nome, '')), '');
begin
  if v_code is null then
    raise exception 'activation_code obrigatório';
  end if;
  if v_nome is null or v_nome = '' then
    raise exception 'nome obrigatório';
  end if;

  insert into public.empresas (nome, telefone, activation_code)
  values (
    v_nome,
    nullif(trim(coalesce(p_telefone, '')), ''),
    upper(v_code)
  )
  returning id into v_id;

  return v_id;
end;
$$;

comment on function public.create_empresa_for_crm(text, text, text) is
  'Licenses CRM: inserts empresa with owner_id NULL; returns id for licenses.empresa_id.';

grant execute on function public.create_empresa_for_crm(text, text, text) to anon;
grant execute on function public.create_empresa_for_crm(text, text, text) to authenticated;

-- ---------------------------------------------------------------------------
-- join_empresa_as_device — first user admin, next operador
-- ---------------------------------------------------------------------------

create or replace function public.join_empresa_as_device(p_empresa_id uuid)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_role text;
  v_count int;
begin
  if auth.uid() is null then
    raise exception 'autenticação obrigatória';
  end if;

  if not exists (select 1 from public.empresas where id = p_empresa_id) then
    raise exception 'empresa não encontrada';
  end if;

  select count(*)::int into v_count
  from public.empresa_usuarios
  where empresa_id = p_empresa_id;

  v_role := case when v_count = 0 then 'admin' else 'operador' end;

  insert into public.empresa_usuarios (empresa_id, user_id, role)
  values (p_empresa_id, auth.uid(), v_role)
  on conflict (empresa_id, user_id) do nothing;

  select eu.role into v_role
  from public.empresa_usuarios eu
  where eu.empresa_id = p_empresa_id
    and eu.user_id = auth.uid()
  limit 1;

  return coalesce(v_role, 'operador');
end;
$$;

comment on function public.join_empresa_as_device(uuid) is
  'App comercial: links auth user to empresa; first member admin, rest operador.';

grant execute on function public.join_empresa_as_device(uuid) to authenticated;
