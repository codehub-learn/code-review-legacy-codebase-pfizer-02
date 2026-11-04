#!/usr/bin/env bash
# Build Shopizer once so the Maven dependencies are cached (tests skipped). Run it before the course.
#
#   scripts/build-shopizer.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -d "$ROOT/shopizer" ] || { echo "No shopizer/ folder. Run scripts/setup-shopizer.sh first." >&2; exit 1; }
cd "$ROOT/shopizer"
mvn -B -ntp clean install -DskipTests
