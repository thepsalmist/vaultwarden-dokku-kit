# vaultwarden-dokku-kit

Ansible automation that deploys a personal Vaultwarden instance on an existing Dokku host, with PostgreSQL, persistent storage, HTTPS and closed registration.

## Status

> **Pre-release. Not ready for production data.** Backups are not automated yet ([#5](https://github.com/thepsalmist/vaultwarden-dokku-kit/issues/5)). Don't store anything in a vault deployed with this kit that you can't afford to lose until that lands.

Work towards the first release is tracked in the [M1: Hardened deployment](https://github.com/thepsalmist/vaultwarden-dokku-kit/milestone/1) milestone.

## Requirements

- A Dokku host on Ubuntu 22.04 or 24.04, with Dokku's `postgres` and `letsencrypt` plugins installed and a global Let's Encrypt email set.
- A DNS record pointing the vault's domain at that host.

**Bare VPS?** Run [ansible-server-bootstrap](https://github.com/thepsalmist/ansible-server-bootstrap) first. It hardens SSH, sets up ufw and fail2ban, and installs Docker, Dokku and both plugins. This kit only manages the Vaultwarden app.

## What it changes on your server

Once M1 is complete, the playbook will:

- Create the Dokku app `vaultwarden` and a PostgreSQL service `vaultwarden-db`, linked to it.
- Create `/var/lib/dokku/data/storage/vaultwarden` and mount it at `/data` for attachments, Sends and the token-signing key.
- Set the app's domain, request its Let's Encrypt certificate, and set Vaultwarden's config as Dokku environment variables.
- Deploy the official `vaultwarden/server` image at a pinned tag.

It never exposes the database port, and it doesn't change SSH, the firewall or other Dokku apps. The one planned exception is a fail2ban jail for Vaultwarden logins ([#13](https://github.com/thepsalmist/vaultwarden-dokku-kit/issues/13)).

## Non-goals

- Host provisioning. That's ansible-server-bootstrap's job.
- High availability. This is one app on one host.
- Modifying Vaultwarden. The upstream image is deployed unchanged.

## Releases

Clone a release tag, not `main`. `main` can hold work that hasn't been tested on a server yet. Changes are listed in [CHANGELOG.md](CHANGELOG.md). The first release, `v0.1.0`, will be tagged when M1 is complete.

## Repository layout

- `ansible/`: the playbook and roles for the Vaultwarden app, plus example inventory and variables.
- `scripts/`: small operator helpers for checks, smoke tests and backups.
- `docs/`: decisions and runbooks.

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
- Dokku PostgreSQL plugin: https://github.com/dokku/dokku-postgres
