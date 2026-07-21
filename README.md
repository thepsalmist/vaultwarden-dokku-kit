# vaultwarden-dokku-kit

Dokku deployment kit for running a personal Vaultwarden instance with secure defaults, repeatable setup, and documented operations.

## Status

This project is in the initial setup phase. The first implementation milestone is a minimal, repeatable Vaultwarden deployment on Dokku with persistent storage, HTTPS, secure runtime defaults, backups, and restore documentation.

Track implementation work in the GitHub issues for this repository.

## Goals

Provide a practical production baseline for Vaultwarden on Dokku:

- Dokku app creation and configuration.
- Vaultwarden runtime configuration through environment variables.
- Persistent data volume setup.
- HTTPS through Dokku's reverse proxy and Let's Encrypt flow.
- Closed public registration after the first account is created.
- Backups, restore drills, and operational checklists.
- Optional host hardening tasks such as fail2ban.

## Repository layout

- `ansible/`: idempotent host and Dokku app automation.
- `scripts/`: small operator commands for validation, bootstrap, deploy, backup, and restore checks.
- `docs/`: planning, decisions, and runbooks.
- `.env.example`: documented placeholder values for private configuration.

## Security expectations

This repository is intended to be safe for public use. Do not commit:

- Real domains or private hostnames.
- Email addresses used for production administration.
- SMTP credentials.
- Vaultwarden admin tokens.
- Backup credentials, repository passwords, or encryption keys.
- SSH keys or production inventory files.
- Generated secrets or local `.env` files.

Use the example files as templates and keep production values in private configuration.

## License

This project is licensed under the MIT License. See `LICENSE` for details.

## References

The implementation should follow the official Vaultwarden wiki and Dokku documentation, especially:

- Vaultwarden configuration: https://github.com/dani-garcia/vaultwarden/wiki/Configuration-overview
- Vaultwarden hardening: https://github.com/dani-garcia/vaultwarden/wiki/Hardening-Guide
- Vaultwarden backups: https://github.com/dani-garcia/vaultwarden/wiki/Backing-up-your-vault
- Dokku application deployment: https://dokku.com/docs/deployment/application-deployment/
