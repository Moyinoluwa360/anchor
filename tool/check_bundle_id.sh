#!/usr/bin/env bash
# Fails the build if the bundle identifier is not the same everywhere.
set -euo pipefail
cd "$(dirname "$0")/.."
xc=$(sed -n 's/^APP_BUNDLE_ID *= *//p' ios/Flutter/AppConfig.xcconfig | tr -d '[:space:]')
dart=$(sed -n "s/.*bundleId = '\(.*\)';/\1/p" lib/app_config.dart)
yaml=$(sed -n 's/^ *BUNDLE_ID: *//p' codemagic.yaml | head -1 | tr -d '"[:space:]')
tests=$(grep -o 'PRODUCT_BUNDLE_IDENTIFIER = [^;]*RunnerTests' ios/Runner.xcodeproj/project.pbxproj | head -1 | sed 's/PRODUCT_BUNDLE_IDENTIFIER = //; s/\.RunnerTests//')
echo "xcconfig=$xc dart=$dart codemagic=$yaml tests=$tests"
if [ "$xc" != "$dart" ] || [ "$xc" != "$yaml" ] || [ "$xc" != "$tests" ]; then
  echo "Bundle identifier mismatch. Fix ios/Flutter/AppConfig.xcconfig, lib/app_config.dart, codemagic.yaml (BUNDLE_ID) and RunnerTests in project.pbxproj." >&2
  exit 1
fi
