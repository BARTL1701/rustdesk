#!/usr/bin/env bash
# Distriqo branding: patches the hbb_common submodule at build time.
# Server and key come from repository secrets (DISTRIQO_SERVER / DISTRIQO_KEY)
# so the public repo contains no infrastructure details.
set -euo pipefail

CFG=libs/hbb_common/src/config.rs

: "${DISTRIQO_SERVER:?ERROR: DISTRIQO_SERVER secret is not set}"
: "${DISTRIQO_KEY:?ERROR: DISTRIQO_KEY secret is not set}"

sed -i 's#&\["rs-ny\.rustdesk\.com"\]#\&["'"$DISTRIQO_SERVER"'"]#' "$CFG"
sed -i 's#OeVuKk5nlHiXp+APNn0Y3pC1Iwpwn44JGqrQCsWqmBw=#'"$DISTRIQO_KEY"'#' "$CFG"
sed -i 's#RwLock::new("RustDesk"\.to_owned())#RwLock::new("Distriqo".to_owned())#' "$CFG"

# sed succeeds even without a match, so assert the patches landed (print nothing)
grep -q "$DISTRIQO_SERVER" "$CFG" || { echo "ERROR: server patch failed"; exit 1; }
grep -q '"Distriqo"' "$CFG" || { echo "ERROR: app name patch failed"; exit 1; }
grep -q 'rs-ny\.rustdesk\.com' "$CFG" && { echo "ERROR: default server still present"; exit 1; }

echo "Distriqo branding applied."
