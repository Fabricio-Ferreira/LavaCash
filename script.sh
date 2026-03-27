#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

SYMBOLS_DIR="${SYMBOLS_DIR:-build/app/outputs/symbols}"
mkdir -p "$SYMBOLS_DIR"

DEFINES="${DEFINES_FILE:-dart_defines.json}"
TARGET="${1:-apk}"

if [ ! -f "$DEFINES" ]; then
  echo "Erro: arquivo '$DEFINES' não encontrado." >&2
  echo "Crie a partir de dart_defines.example.json ou defina DEFINES_FILE." >&2
  exit 1
fi

case "$TARGET" in
  apk)
    flutter build apk --release --obfuscate \
      --split-debug-info="$SYMBOLS_DIR" \
      --dart-define-from-file="$DEFINES"
    ;;
  appbundle|bundle|aab)
    flutter build appbundle --release --obfuscate \
      --split-debug-info="$SYMBOLS_DIR" \
      --dart-define-from-file="$DEFINES"
    ;;
  *)
    echo "Uso: $0 [apk|appbundle]" >&2
    echo "  apk (default)  — gera APK ofuscado" >&2
    echo "  appbundle      — gera AAB ofuscado (Play Store)" >&2
    echo "Variável opcional: SYMBOLS_DIR (default: build/app/outputs/symbols)" >&2
    exit 1
    ;;
esac
