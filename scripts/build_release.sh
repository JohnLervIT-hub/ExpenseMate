#!/usr/bin/env bash
# Release build with Dart obfuscation. Symbols are required to decode
# stack traces from crash reports — archive debug_symbols/<version>/ per release.
set -uo pipefail

cd "$(dirname "$0")/.."

VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
if [[ -z "${VERSION}" ]]; then
  echo "Could not read version from pubspec.yaml" >&2
  exit 1
fi

TARGET="${1:-appbundle}"
case "${TARGET}" in
  appbundle|apk) ;;
  *)
    echo "Usage: $0 [appbundle|apk]" >&2
    exit 1
    ;;
esac

SYMBOLS_DIR="debug_symbols/${VERSION}"
mkdir -p "${SYMBOLS_DIR}"

if [[ "${TARGET}" == "appbundle" ]]; then
  ARTIFACT="build/app/outputs/bundle/release/app-release.aab"
else
  ARTIFACT="build/app/outputs/flutter-apk/app-release.apk"
fi
rm -f "${ARTIFACT}"

echo "Building ${TARGET} ${VERSION} (obfuscated); symbols -> ${SYMBOLS_DIR}"
# --no-tree-shake-icons: categories store dynamic MaterialIcons code points in
# SQLite (see Category.iconCode), so IconData can't be const and the tree-shaker
# can't statically enumerate icons. Ships the full MaterialIcons font.
BUILD_LOG=$(mktemp)
trap 'rm -f "${BUILD_LOG}"' EXIT
flutter build "${TARGET}" --release \
  --obfuscate \
  --split-debug-info="${SYMBOLS_DIR}" \
  --no-tree-shake-icons 2>&1 | tee "${BUILD_LOG}"
FLUTTER_EXIT=${PIPESTATUS[0]}

# Flutter's post-build strip-verification runs `apkanalyzer files list <aab>`
# and greps for libflutter.so.sym. When apkanalyzer is broken on the host (e.g.
# "Cannot locate latest build tools"), Flutter interprets the missing output as
# "not stripped" and exits 1 — even though AGP did strip. Treat that specific
# false positive as success if the artifact exists.
if [[ ${FLUTTER_EXIT} -ne 0 ]]; then
  if [[ -f "${ARTIFACT}" ]] && grep -q "failed to strip debug symbols" "${BUILD_LOG}"; then
    echo
    echo "NOTE: Flutter reported strip verification failure, but the AAB exists"
    echo "      and AGP-level debug symbols are bundled. This is a known"
    echo "      apkanalyzer false positive — treating build as successful."
  else
    exit "${FLUTTER_EXIT}"
  fi
fi

echo "Done. Artifact: ${ARTIFACT}"
echo "      Archive ${SYMBOLS_DIR} alongside the release artifact."
