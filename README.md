# vaultwarden-dokku-kit

Dokku deployment kit for running a personal Vaultwarden instance with secure defaults, repeatable setup, and documented operations.

## Project intent

This repository will provide a practical production baseline for Vaultwarden on Dokku:

- Dokku app creation and configuration.
- Vaultwarden runtime configuration through environment variables.
- Persistent data volume setup.
- HTTPS through Dokku's reverse proxy and Let's Encrypt flow.
- Closed public registration after the first account is created.
- Backups, restore drills, and operational checklists.
- Optional host hardening tasks such as fail2ban.

The repo must be safe to publish. No real domains, emails, tokens, SMTP credentials, backup keys, SSH material, or generated secrets should be committed.

## Why this name

`vaultwarden-dokku-kit` is clear, searchable, and reusable. It describes the product, target platform, and repo purpose without implying it is an official Vaultwarden project.

## Proposed implementation shape

- `ansible/`: idempotent server and Dokku app automation.
- `scripts/`: thin operator commands for bootstrap, validation, backup, restore rehearsal, and deploy.
- `docs/`: planning, decisions, and runbooks.
- `.env.example`: documented variables only, with placeholder values.

## Source guidance

The implementation should follow the official Vaultwarden wiki and Dokku documentation, especially:

- Vaultwarden configuration: https://github.com/dani-garcia/vaultwarden/wiki/Configuration-overview
- Vaultwarden hardening: https://github.com/dani-garcia/vaultwarden/wiki/Hardening-Guide
- Vaultwarden backups: https://github.com/dani-garcia/vaultwarden/wiki/Backing-up-your-vault
- Dokku application deployment: https://dokku.com/docs/deployment/application-deployment/
