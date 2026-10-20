# Changelog

All notable changes to this project are listed here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Ansible playbook with example inventory and variables, and preflight checks that stop before changing the host when it isn't Ubuntu 22.04/24.04, Dokku or its `postgres`/`letsencrypt` plugins are missing, Let's Encrypt has no global email, or `vaultwarden_domain` isn't set.
- `scripts/check-prereqs.sh`, which checks the workstation has `ansible-playbook`, `ssh` and `git`.
- `vaultwarden` role: deploys `vaultwarden/server` 1.37.4 on Dokku with a linked PostgreSQL service, persistent `/data`, the vault's domain, and closed registration. Re-runs change only what drifted.
- HTTPS through Let's Encrypt. The certificate is requested once, and the letsencrypt plugin's cron job renews it.
- `vaultwarden_admin_token` turns on `/admin`, and `docs/first-account.md` covers inviting the first account from it while registration stays closed.

### Changed

- PostgreSQL through `dokku-postgres` replaces SQLite as the database.
- Host provisioning is a prerequisite, handled by ansible-server-bootstrap or any Dokku host with the `postgres` and `letsencrypt` plugins.
- The first account is invited from `/admin`, so public registration is never opened.

### Removed

- `.env.example`. Operator configuration lives in Ansible group_vars.
