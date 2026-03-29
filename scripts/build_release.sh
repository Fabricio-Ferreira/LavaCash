#!/usr/bin/env bash
# Release build from repo root: Dart obfuscation + split debug symbols.
# Requires dart_defines.json (or DEFINES_FILE) with SUPABASE_* and LICENSE_SUPABASE_*.
# Android signing: android/key.properties + keystore (see README).
#
# Usage:
#   ./scripts/build_release.sh           # APK (default)
#   ./scripts/build_release.sh apk
#   ./scripts/build_release.sh appbundle # AAB for Play Store
#
# Env: DEFINES_FILE (default: dart_defines.json), SYMBOLS_DIR (optional).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

DEFINES_FILE="${DEFINES_FILE:-dart_defines.json}"
if [[ ! -f "${DEFINES_FILE}" ]]; then
  echo "Missing ${DEFINES_FILE}. Copy dart_defines.example.json and fill keys." >&2
  exit 1
fi

SYMBOLS_DIR="${SYMBOLS_DIR:-${ROOT}/build/symbols/android}"
mkdir -p "${SYMBOLS_DIR}"

TARGET="${1:-apk}"

case "${TARGET}" in
  apk)
    echo "Building release APK (obfuscated); symbols → ${SYMBOLS_DIR}"
    flutter build apk --release \
      --obfuscate \
      "--split-debug-info=${SYMBOLS_DIR}" \
      "--dart-define-from-file=${DEFINES_FILE}"
    echo "APK: ${ROOT}/build/app/outputs/flutter-apk/app-release.apk"
    ;;
  appbundle|bundle|aab)
    echo "Building release App Bundle (obfuscated); symbols → ${SYMBOLS_DIR}"
    flutter build appbundle --release \
      --obfuscate \
      "--split-debug-info=${SYMBOLS_DIR}" \
      "--dart-define-from-file=${DEFINES_FILE}"
    echo "AAB: ${ROOT}/build/app/outputs/bundle/release/app-release.aab"
    ;;
  *)
    echo "Usage: $0 [apk|appbundle]" >&2
    echo "  apk (default)  — release APK" >&2
    echo "  appbundle      — release AAB (Play Store)" >&2
    echo "Env: DEFINES_FILE, SYMBOLS_DIR" >&2
    exit 1
    ;;
esac

echo "Keep ${SYMBOLS_DIR}/ for crash symbolication (Firebase / flutter symbolize)."
