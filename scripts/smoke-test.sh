#!/usr/bin/env bash
set -u

if [ $# -ne 1 ]; then
  echo "usage: $0 <domain>" >&2
  exit 2
fi
domain=$1
status=0

pass() { printf 'PASS  %s\n' "$1"; }
fail() { printf 'FAIL  %s: %s\n' "$1" "$2"; status=1; }

read -r code location < <(curl -s -o /dev/null -w '%{http_code} %{redirect_url}' "http://$domain/")
case "$code $location" in
  "301 https://$domain/" | "301 https://$domain:443/") pass "HTTP redirects to HTTPS" ;;
  *) fail "HTTP redirects to HTTPS" "got $code ${location:-without a redirect}" ;;
esac

if error=$(curl -sS -o /dev/null "https://$domain/" 2>&1); then
  pass "TLS certificate is valid"
else
  fail "TLS certificate is valid" "${error%%$'\n'*}"
fi

code=$(curl -s -o /dev/null -w '%{http_code}' "https://$domain/alive")
if [ "$code" = 200 ]; then
  pass "/alive returns 200"
else
  fail "/alive returns 200" "got $code"
fi

read -r code type < <(curl -s -o /dev/null -w '%{http_code} %{content_type}' "https://$domain/")
if [ "$code" = 200 ] && [[ $type == text/html* ]]; then
  pass "/ serves the web vault"
else
  fail "/ serves the web vault" "got $code ${type:-without a content type}"
fi

read -r code type < <(curl -s -o /dev/null -w '%{http_code} %{content_type}' "https://$domain/api/config")
if [ "$code" = 200 ] && [[ $type == application/json* ]]; then
  pass "/api/config returns JSON"
else
  fail "/api/config returns JSON" "got $code ${type:-without a content type}"
fi

exit "$status"
