#!/usr/bin/env bash
set -u

hint() {
  case "$1" in
    ansible-playbook) echo "uv tool install ansible-core, then uv tool update-shell and open a new shell" ;;
    *) echo "install $1 with your OS package manager" ;;
  esac
}

status=0
for tool in ansible-playbook ssh git; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf 'ok       %s\n' "$tool"
  else
    printf 'missing  %s: %s\n' "$tool" "$(hint "$tool")"
    status=1
  fi
done
exit "$status"
