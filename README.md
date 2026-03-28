# LavaCash

App Flutter para operação de lavagem de veículos: cadastro, atendimento com serviços e pagamento, **dashboard** com visão do dia e **relatórios** diário e mensal (incluindo desempenho por semana do mês e melhor dia da semana). Backend **Supabase**; arquitetura **feature-first** com camadas *domain* → *data* → *presentation*, **GetX** e **Either** (dartz).

**Identidade visual:** tipografia **Inter**, verde principal **#006B2C** — ver [`lib/app/theme/app_colors.dart`](lib/app/theme/app_colors.dart).

**SDK:** Dart `>=3.7.0 <4.0.0` (ver `pubspec.yaml`).

**Guia de arquitetura (referência interna):** [`.agents/skills/flutter-architecting-apps/SKILL.md`](.agents/skills/flutter-architecting-apps/SKILL.md) — princípios, árvore por feature, camada de dados (repositórios, adapters) e fluxo de implementação.

---

## Princípios de arquitetura

Alinhado ao skill acima:

| Princípio | Aplicação no projeto |
|-----------|----------------------|
| **Separação de responsabilidades** | UI só apresentação; regras e I/O em domain/data. |
| **Single source of truth** | Repositórios como fronteira de dados; Supabase atrás de implementações em `features/*/data/`. |
| **Fluxo unidirecional** | Eventos sobem da UI; estado desce via controllers e entidades. |
| **UI como função de estado** | Controllers GetX + `Obx` / reatividade onde faz sentido. |

### Organização por feature (`lib/features/<feature>/`)

Cada feature agrupa as camadas que precisa:

```
features/<nome>/
  data/
    adapters/        # Mapeamento RPC/JSON → entidades (opcional, quando o payload não bate com select aninhado)
    repositories/    # Implementações Supabase
  domain/
    repositories/    # Contratos
    usecases/        # Casos de uso quando a lógica merece isolamento
  presentation/
    controllers/     # GetX Controllers
    pages/
    widgets/
```

Código **compartilhado:** `lib/core/` (erros, rede, utilitários, widgets genéricos). Entidades globais reutilizáveis: `lib/domain/entities/` e modelos DTO em `lib/data/models/` quando aplicável.

**Regra de dependência:** *presentation* → *domain* ← *data*. O domínio não importa Flutter nem Supabase.

---

## Stack

| Camada | Tecnologia |
|--------|------------|
| UI | Flutter (Material), `fl_chart` para gráficos |
| Estado / rotas | GetX (`Controller`, `Binding`, `GetPage`) |
| Backend | Supabase (Postgres + RPC) |
| Erros | `Either<Failure, T>` (dartz); falhas em [`lib/core/error/failures.dart`](lib/core/error/failures.dart) |
| Datas / locale | `intl`, formatação `pt_BR` |

---

## Bootstrap (`main.dart`)

Inicialização assíncrona roda dentro de **`runZonedGuarded`**, com **`WidgetsFlutterBinding.ensureInitialized()`** na mesma zona que **`runApp`** (evita *zone mismatch* do Flutter). Ordem: `ensureInitialized` → `initializeDateFormatting('pt_BR')` → Supabase → orientação retrato → `AppGlobalController` → `runApp`.

---

## Visão geral do produto

1. **Splash** — checagem de licença por dispositivo antes de entrar no app.
2. **Home** — duas áreas principais:
   - **Dashboard** — resumo do dia (total, carros, em andamento), recebimento por forma de pagamento, atalhos para novo atendimento e relatório diário, e seção de **desempenho mensal** (semanas do mês + tendência).
   - **Relatórios** — sub-abas **Diário** e **Mensal**: métricas detalhadas, lista de meses com destaque e crescimento vs. mês anterior, **melhor dia da semana** no mês, e performance semanal (`get_weekly_report` / `get_best_weekday_report` no Supabase).
3. **Barra inferior** — **Relatórios** | **Dashboard** | **Novo** (abre **Novo atendimento**: busca por placa/nome, clientes recentes e fluxo para atendimento).
4. **Busca** — `VehicleSearchController` + repositório em `features/search`; busca normalizada (case e acentos) via RPC `search_vehicles_normalized`; UI principal em **Novo atendimento**; no relatório diário, lista ampliada via **VER TODOS** ao lado de “Atendimentos do dia”.
5. **Fluxo operacional** — cadastro (rota dedicada) → atendimento por veículo → pagamento (Pix, dinheiro, débito, crédito).
6. **Licença** — dispositivo sem licença ativa ou ativação por chave (`activation_keys` + RPC `activate_license`); ver migrações abaixo.

---

## Referência de telas (UI)

Fluxo e visão geral das principais superfícies:

![Referência de telas LavaCash](docs/ui_reference.png)

| Área | Descrição |
|------|-----------|
| **Splash** | Marca LavaCash, sincronização inicial e validação de licença. |
| **Dashboard** | Hero do dia, estatísticas, recebimento, atalhos e performance mensal (semanas + link para relatório mensal). |
| **Relatórios → Diário** | Relatório do dia, formas de pagamento, atendimentos; busca ampliada via **VER TODOS**. |
| **Relatórios → Mensal** | Histórico de meses, crescimento, gráfico semanal, melhor dia da semana. |
| **Novo atendimento** | Busca, recentes e sequência serviço → pagamento; cadastro acessível a partir da mesma tela. |
| **Licença bloqueada** | Dispositivo sem licença ativa ou fluxo de ativação por chave (dados do aparelho + suporte). |

---

## Funcionalidades

- **Licenciamento por dispositivo** — `features/license`; bloqueio se inativo; ativação com chave pré-gerada no Supabase.
- **Busca cliente/veículo** — `features/search`; debounce; adapter RPC em `data/adapters/`; uso em **Novo atendimento** e relatório diário.
- **Cadastro** — cliente + veículo (`features/registration`).
- **Serviço** — detalhes, total, status e timer; caso de uso `StartService` no binding (`features/service`).
- **Pagamento** — conclusão com método (`features/payment`).
- **Relatórios** — diário e mensal; agregações semanais e melhor dia da semana via RPC (`features/reports`).
- **Backend** — repositórios Supabase em `features/*/data/repositories`.
- **Core** — `core/utils`, `core/services` (ex.: ID do dispositivo, cache de recentes), widgets compartilhados.

---

## Arquitetura (resumo técnico)

- **Domain:** entidades em `lib/domain/entities/`, contratos de repositório e casos de uso por feature (`features/<feature>/domain/`).
- **Data:** `*RepositoryImpl` com Supabase; **adapters** em `features/<feature>/data/adapters/` para linhas RPC ou JSON heterogéneo; modelos em `lib/data/models/` quando aplicável.
- **Presentation:** páginas, `Controller` + `Binding` por rota ([`lib/app/routes/app_pages.dart`](lib/app/routes/app_pages.dart)).
- **Erros:** `Either` com `Failure`; tratamento nas camadas de dados e UI.
- **Núcleo:** `SupabaseInitializer`, tema (`app/theme`), widgets (`core/widgets`).

### Rotas nomeadas (GetX)

| Rota | Página |
|------|--------|
| `/splash` | Splash + licença |
| `/blocked` | Licença inativa / ativação |
| `/home` | Home (Dashboard + Relatórios) |
| `/registration` | Cadastro cliente/veículo |
| `/novo-atendimento` | Novo atendimento (busca + recentes) |
| `/in-progress-services` | Lista de atendimentos em andamento (filtro opcional via `arguments`) |
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
| `004_atendimentos_service_details.sql` | Detalhes de serviço nos atendimentos |
| `005_activation_keys_and_activate_license.sql` | Tabela `activation_keys` + RPC `activate_license` |
| `006_activate_license_fix_variable_conflict.sql` | Correção PL/pgSQL (`#variable_conflict`) na `activate_license` |
| `007_search_vehicles_normalized.sql` | Extensão `unaccent`, `normalize_search`, RPC `search_vehicles_normalized` |

**Recomendado:** [Supabase CLI](https://supabase.com/docs/guides/cli) — `supabase link` e `supabase db push`. Alternativa: colar cada arquivo no SQL Editor do dashboard (na ordem).

Detalhes e seed de desenvolvimento: [`supabase/README.md`](supabase/README.md).

### Licença de teste

O ID do dispositivo aparece na tela de bloqueio se estiver inativo. Inserir licença manualmente:

```sql
INSERT INTO public.licencas (device_id, nome_lavagem, is_active)
VALUES ('YOUR_DEVICE_ID', 'Minha Lavagem', true);
```

Ou usar **chaves de ativação** pré-cadastradas em `activation_keys` (ver migração `005` e comentário em `supabase/seed.sql`).

---

## Assets e ícones

- Referência Stitch: `assets/stitch/`
- Imagens / logo: `assets/images/` (ex.: `logo.svg`, `launcher_icon.png`)
- Fonte **Inter:** `fonts/`
- **Launcher Android:** `flutter_launcher_icons` — após alterar o ícone base, rodar `dart run flutter_launcher_icons`

---

## Testes e qualidade

```bash
dart analyze
flutter analyze
flutter test
```
