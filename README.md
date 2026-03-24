# LavaCash

MVP de operação para lavagem de veículos: faturamento, atendimentos e fluxo de serviço na palma da mão.  
Stack: **Flutter**, **GetX**, **Supabase**, **Clean Architecture** (camadas *domain* → *data* → *presentation*).

**Identidade visual (referência):** tipografia **Inter**, verde principal **#006B2C** (ver também `lib/app/theme/app_colors.dart`).

---

## Referência de telas (UI)

Fluxo principal do produto (busca → cadastro → atendimento → pagamento) e visão de faturamento:

![Referência de telas LavaCash](docs/ui_reference.png)

| Tela | Descrição |
|------|-----------|
| **Splash** | Logo, nome *LavaCash*, tagline e sincronização inicial (licença / fluxo). |
| **Início** | Navegação inferior: **Busca**, **Diário**, **Mensal** — busca de cliente/veículo e relatórios. |
| **Novo atendimento (busca)** | Pesquisa por nome ou placa; opção de cadastrar novo cliente e iniciar atendimento. |
| **Cadastro de cliente** | Nome, telefone e placa do veículo; segue para o atendimento. |
| **Gerenciar atendimento** | Serviços no pedido, total, timer de andamento e finalização. |
| **Finalizar / pagamento** | Valor total e escolha do meio de pagamento (Pix, dinheiro, débito, crédito). |
| **Licença bloqueada** | Dispositivo sem licença ativa no Supabase (mensagem + dados do aparelho). |

---

## Funcionalidades principais

- **Licenciamento por dispositivo** — validação na entrada (`features/license`), lista de bloqueio se inativo.
- **Busca de cliente / veículo** — `SearchTabBody` + casos de uso em `features/search`.
- **Cadastro** — cliente + veículo (`features/registration`).
- **Serviço em andamento** — itens, total e status (`features/service`).
- **Pagamento** — conclusão com método (`features/payment`, entidade `PaymentMethod`).
- **Relatórios** — visão **diária** e **mensal** (`features/reports`, abas no `HomePage`).
- **Backend** — Supabase (repositórios em `features/*/data/repositories`).
- **Utilitários** — formatação/validação (`core/utils`), serviços como WhatsApp e ID do dispositivo (`core/services`).

---

## Arquitetura

- **Regra de dependência:** *presentation* → *domain* ← *data*. O domínio não conhece Flutter nem Supabase.
- **Domain:** entidades em `lib/domain/entities/`, contratos de repositório e *use cases* por feature (`features/<feature>/domain/`).
- **Data:** implementações `*RepositoryImpl` chamando Supabase; modelos em `lib/data/models/` quando necessário.
- **Presentation:** páginas, **GetX** `Controller` + `Binding` por rota (`GetPage` em `app/routes/app_pages.dart`).
- **Erros funcionais:** `Either` (**dartz**) com `Failure` / exceções mapeadas em `core/error/`.
- **Núcleo:** inicialização Supabase (`core/network/supabase_initializer.dart`), tema global (`app/theme`), widgets reutilizáveis (`core/widgets`).

### Rotas nomeadas (GetX)

| Rota | Página |
|------|--------|
| `/splash` | Splash + licença |
| `/blocked` | Licença inativa |
| `/home` | Home (abas busca / diário / mensal) |
| `/registration` | Cadastro |
| `/service/:vehicleId` | Atendimento |
| `/payment/:serviceId` | Pagamento |

---

## Executar (com Supabase)

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

## Banco de dados

Aplicar o SQL em `supabase/migrations/001_initial.sql` (editor SQL do Supabase).

Inserir licença para o dispositivo (o ID aparece na tela de bloqueio se estiver inativo):

```sql
INSERT INTO public.licencas (device_id, nome_lavagem, is_active)
VALUES ('YOUR_DEVICE_ID', 'Minha Lavagem', true);
```

## Assets e ícones

- Referência Stitch: `assets/stitch/splash.png`
- Logo / imagens: `assets/images/` (ex.: `logo.svg`, `launcher_icon.png` para ícone do app)
- Fonte **Inter** embutida: `fonts/`
- **Launcher (Android):** `flutter_launcher_icons` — após mudar o ícone-base, rodar `dart run flutter_launcher_icons`

## Testes e qualidade

```bash
flutter analyze
flutter test
```
