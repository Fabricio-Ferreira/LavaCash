# Changelog

Todas as mudanças notáveis neste projeto serão documentadas aqui.

O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e o versionamento segue [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Adicionado

- (Próximas mudanças.)

---

## [1.1.0+1] — 2026-04-21

### Adicionado

- **Relatórios — Histórico:** nova aba com atendimentos **finalizados**, filtro por **período** e **cliente ou placa** (mesma normalização da busca), resumo e lista por veículo (expansível).
- **Paginação:** carregamento de **10 veículos** por vez, indicador ao carregar mais e aviso ao **fim da lista** (total de veículos no filtro).
- **PDF / impressão** do histórico (período + termo de busca; exportação usa todos os veículos do filtro, com teto de linhas no backend).

### Alterado

- **Supabase:** RPC `get_attendance_history` com paginação por veículo, contagem total e modo exportação; ajuste de fuso para exibição em horário de São Paulo (migrations `009` / `010` conforme aplicadas no projeto).

---

## [1.0.1+3] — 2026-04-13

### Alterado

- **CI (`release-android`):** assinatura de release com keystore a partir de secrets (`ANDROID_KEYSTORE_BASE64`, `LAVACASH_STORE_PASSWORD`, `LAVACASH_KEY_PASSWORD`; opcional `ANDROID_KEY_ALIAS`), alinhada ao `android/app/build.gradle.kts` e ao `key.properties` local.

### Corrigido

- APK gerado no GitHub Actions deixou de usar assinatura de **debug** quando o keystore de release não estava disponível no runner — cenário que gerava conflito de pacote ao atualizar sobre instalações já assinadas com o keystore de release.

---

## [1.0.1+2] — 2026-04-11

### Adicionado

- Pipeline **GitHub Actions** (`release-android`): build de APK (split **arm64-v8a**, ofuscação, ícones *tree-shaken*), upload para Storage `app-releases` e `PATCH` em `public.app_version` (versão, `release_notes`, `is_mandatory`).

### Alterado

- **README:** GitFlow (`main` / `development` / `release/*`), secrets do CI, impacto do release nos dados e notas sobre `apk_storage_path`.
- Ajustes gerais de UI e layout (dashboard, home, relatórios, cartões de pagamento).

### Corrigido

- **Despesas:** limpeza dos itens quando o carregamento do dia selecionado falha.

### Refatorado

- **Relatórios:** extração de helpers partilhados de saída PDF (partilhar vs impressão).

---

## [1.0.0+1] — 2026-04-11

### Adicionado

- Despesas e exportação de relatórios em PDF.
- Atualização automática do app e fluxo de verificação de versão.
- Diálogo de intervalo de datas com máscara `dd/MM/aaaa`, validação e opção “Hoje” na data final.
- Mensagem amigável no hero do relatório mensal quando não há movimentação no mês.

### Alterado

- Arquitetura: camadas `data` e `domain` por feature consolidadas em `lib/core/data/` e `lib/core/domain/`; entidades compartilhadas em `lib/core/domain/entities/`.
- Módulo **dashboard** separado de **reports**; relatórios organizados em **daily**, **monthly** e **period** (intervalo).
- Widgets compartilhados (`EliteHeroCard`, estatísticas, `ServiceSummaryTile`) em `lib/shared/widgets/`.
- `MonthlyReportTab`: correção de rebuild do `Obx` ao mudar o mês (leitura de Rx no topo do callback).
- `DashboardTab`: estrutura de scroll alinhada ao relatório diário (`ThemedRefreshIndicator` → `LayoutBuilder` → `ListView`).
- Chamadas WhatsApp e ajustes na página de pagamento.
- Fluxo de criação de empresa e login.

### Corrigido

- Layout e chamadas diversas (incl. licença ativa e segurança em fluxos sensíveis).
