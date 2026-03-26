# LavaCash

App Flutter para operação de lavagem de veículos: cadastro, atendimento com serviços e pagamento, **dashboard** com visão do dia e **relatórios** diário e mensal (incluindo desempenho por semana do mês e melhor dia da semana). Backend **Supabase**; arquitetura em camadas (*domain* → *data* → *presentation*) com **GetX** e **Either** (dartz).

**Identidade visual:** tipografia **Inter**, verde principal **#006B2C** — ver `lib/app/theme/app_colors.dart`.

---

## Stack

| Camada | Tecnologia |
|--------|------------|
| UI | Flutter (Material), `fl_chart` para gráficos |
| Estado / rotas | GetX (`Controller`, `Binding`, `GetPage`) |
| Backend | Supabase (Postgres + RPC) |
| Erros | `Either<Failure, T>` (dartz), `Failure` em `core/error/` |
| Datas / locale | `intl`, formatação `pt_BR` |

---

## Visão geral do produto

1. **Splash** — checagem de licença por dispositivo antes de entrar no app.  
2. **Home** — duas áreas principais:
   - **Dashboard** — resumo do dia (total, carros, em andamento), recebimento por forma de pagamento, atalhos para novo atendimento e relatório diário, e seção de **desempenho mensal** (semanas do mês + tendência).  
   - **Relatórios** — sub-abas **Diário** e **Mensal**: métricas detalhadas, lista de meses com destaque e crescimento vs. mês anterior, **melhor dia da semana** no mês, e performance semanal (`get_weekly_report` / `get_best_weekday_report` no Supabase).  
3. **Barra inferior** — **Relatórios** | **Dashboard** | **Novo** (abre cadastro de cliente/veículo).  
4. **Busca** — acesso a partir do relatório diário (**VER TODOS** ao lado de “Atendimentos do dia”), em tela dedicada com `SearchTabBody`.  
5. **Fluxo operacional** — cadastro → atendimento (por veículo) → pagamento (Pix, dinheiro, débito, crédito).  
6. **Licença bloqueada** — dispositivo sem licença ativa no Supabase.

---

## Referência de telas (UI)

Fluxo e visão geral das principais superfícies:

![Referência de telas LavaCash](docs/ui_reference.png)

| Área | Descrição |
|------|-----------|
| **Splash** | Marca LavaCash, sincronização inicial e validação de licença. |
| **Dashboard** | Hero do dia, estatísticas, recebimento, atalhos e performance mensal (semanas + link para relatório mensal). |
| **Relatórios → Diário** | Relatório do dia, formas de pagamento, atendimentos; busca completa via **VER TODOS**. |
| **Relatórios → Mensal** | Histórico de meses, crescimento, gráfico semanal, melhor dia da semana. |
| **Novo atendimento** | Cadastro cliente/veículo e sequência serviço → pagamento. |
| **Licença bloqueada** | Dispositivo sem licença ativa (dados do aparelho + suporte). |

---

## Funcionalidades

- **Licenciamento por dispositivo** — `features/license`; bloqueio se inativo.  
- **Busca cliente/veículo** — `features/search`; debounce e uso no fluxo do relatório diário.  
- **Cadastro** — cliente + veículo (`features/registration`).  
- **Serviço** — itens, total, status e timer (`features/service`).  
- **Pagamento** — conclusão com método (`features/payment`).  
- **Relatórios** — diário e mensal; agregações semanais e melhor dia da semana via RPC (`features/reports`).  
- **Backend** — repositórios Supabase em `features/*/data/repositories`.  
- **Core** — `core/utils`, `core/services` (ex.: ID do dispositivo), widgets compartilhados.

---

## Arquitetura

- **Regra de dependência:** *presentation* → *domain* ← *data*. O domínio não depende de Flutter nem Supabase.  
- **Domain:** entidades em `lib/domain/entities/`, contratos de repositório e casos de uso por feature (`features/<feature>/domain/`).  
- **Data:** `*RepositoryImpl` com Supabase; modelos em `lib/data/models/` quando aplicável.  
- **Presentation:** páginas, `Controller` + `Binding` por rota (`app/routes/app_pages.dart`).  
- **Erros:** `Either` com `Failure` / mapeamento de exceções em `core/error/`.  
- **Núcleo:** `SupabaseInitializer`, tema (`app/theme`), widgets (`core/widgets`).

### Rotas nomeadas (GetX)

| Rota | Página |
|------|--------|
| `/splash` | Splash + licença |
| `/blocked` | Licença inativa |
| `/home` | Home (Dashboard + Relatórios) |
| `/registration` | Cadastro |
| `/service/:vehicleId` | Atendimento |
| `/payment/:serviceId` | Pagamento |

---

## Executar (com Supabase)

1. Copie `dart_defines.example.json` para `dart_defines.json` e preencha URL + anon key, ou use `.env` com `SUPABASE_URL` e `SUPABASE_ANON_KEY` (o app Flutter continua precisando de `dart_defines.json` ou `--dart-define`).  
2. Rode:

```bash
flutter run --dart-define-from-file=dart_defines.json
```

Ou inline:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_KEY
```

`dart_defines.json` e `.env` estão no `.gitignore`.

### Onde a URL do Supabase é lida

- **Código:** [`lib/core/network/supabase_initializer.dart`](lib/core/network/supabase_initializer.dart) — usa `SUPABASE_URL` e `SUPABASE_ANON_KEY` via `--dart-define` / `dart_defines.json` (prioridade); constantes `_url` e `_anonKey` no mesmo arquivo servem só como fallback opcional.
- **Valores corretos:** Supabase Dashboard → **Project Settings** → **API** — copie **Project URL** e a chave **anon** / **publishable**.

### Erro `Failed host lookup: '....supabase.co'`

Isso indica **falha de DNS ou rede** no dispositivo/emulador (o host nem chegou a ser resolvido). Não é um bug típico de código Dart.

- Confirme internet no aparelho/emulador; abra o mesmo URL no navegador no mesmo ambiente.
- Confira se o **Project URL** no dashboard é exatamente o que está em `dart_defines.json` (espaços no final são ignorados pelo app).
- Emulador Android: cold boot, ou teste em dispositivo físico; VPN/firewall corporativo pode bloquear DNS.

---

## Banco de dados (Supabase)

Aplicar as migrações na ordem em `supabase/migrations/`:

| Arquivo | Conteúdo (resumo) |
|---------|-------------------|
| `001_initial.sql` | Schema base (tabelas, licenças, atendimentos, etc.) |
| `002_views_security_invoker.sql` | Views com `security_invoker` |
| `003_weekly_report_fn.sql` | Funções RPC `get_weekly_report` e `get_best_weekday_report` |

**Recomendado:** [Supabase CLI](https://supabase.com/docs/guides/cli) — `supabase link` e `supabase db push`. Alternativa: colar cada arquivo no SQL Editor do dashboard (na ordem).

Detalhes e seed de desenvolvimento: [`supabase/README.md`](supabase/README.md).

### Licença de teste

O ID do dispositivo aparece na tela de bloqueio se estiver inativo. Inserir licença:

```sql
INSERT INTO public.licencas (device_id, nome_lavagem, is_active)
VALUES ('YOUR_DEVICE_ID', 'Minha Lavagem', true);
```

---

## Assets e ícones

- Referência Stitch: `assets/stitch/`  
- Imagens / logo: `assets/images/` (ex.: `logo.svg`, `launcher_icon.png`)  
- Fonte **Inter:** `fonts/`  
- **Launcher Android:** `flutter_launcher_icons` — após alterar o ícone base, rodar `dart run flutter_launcher_icons`

---

## Testes e qualidade

```bash
flutter analyze
flutter test
```
