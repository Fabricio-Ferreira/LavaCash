#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

SYMBOLS_DIR="${SYMBOLS_DIR:-build/app/outputs/symbols}"
mkdir -p "$SYMBOLS_DIR"

TARGET="${1:-apk}"

case "$TARGET" in
  apk)
    flutter build apk --release --obfuscate --split-debug-info="$SYMBOLS_DIR"
    ;;
  appbundle|bundle|aab)
    flutter build appbundle --release --obfuscate --split-debug-info="$SYMBOLS_DIR"
    ;;
  *)
    echo "Uso: $0 [apk|appbundle]" >&2
    echo "  apk (default)  — gera APK ofuscado" >&2
    echo "  appbundle      — gera AAB ofuscado (Play Store)" >&2
    echo "Variável opcional: SYMBOLS_DIR (default: build/app/outputs/symbols)" >&2
    exit 1
    ;;
esac
