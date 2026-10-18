# Project Brief

## Objective

Create a public repository that deploys a personal Vaultwarden instance on Dokku using repeatable automation and secure operational defaults.

## Key decisions

1. Use Dokku as the deployment target.
2. Use Ansible for app state because it gives idempotency, inventory support, dry-run capability, and clear reviewable changes.
3. Treat host provisioning as a prerequisite. [ansible-server-bootstrap](https://github.com/thepsalmist/ansible-server-bootstrap) prepares the host: admin user, SSH hardening, ufw, fail2ban, Docker, Dokku and its `postgres` and `letsencrypt` plugins. This repo only manages the Vaultwarden app, so it also works on any Dokku host that already has those plugins.
4. Use small shell scripts only as operator wrappers around Ansible, Dokku, backup, restore, and validation tasks.
5. Configure Vaultwarden via environment variables set through Dokku, not `config.json`, so configuration remains reproducible and reviewable. Operator values live in Ansible group_vars, the only config surface.
6. Keep the repo public-safe by committing examples and templates only.
7. Use PostgreSQL through the `dokku-postgres` plugin, linked to the app. `/data` is still persisted, because it holds attachments, Sends and the key that signs login tokens. The tradeoff is that backups cover two parts, the database and `/data`, and a restore must bring both back together.
8. Require HTTPS behind Dokku's reverse proxy for production.
9. Never open public registration. The first account is invited from `/admin` while `SIGNUPS_ALLOWED=false`.
10. Add automated backups and a restore test path before treating the deployment as production-ready.

## Source Guidance

Vaultwarden's wiki recommends environment variables as the normal configuration path and warns that `config.json` can override other methods and become hard to reason about. The implementation should therefore drive app config through Dokku env vars and documented examples.

The hardening guide calls out disabling anonymous registration, optionally disabling invitations, disabling password hints, using a production reverse proxy instead of Vaultwarden's built-in TLS, running with minimum required privileges where practical, and avoiding unnecessary host mounts.

The backup guide says Vaultwarden data should be backed up regularly, preferably automatically, with at least one remote copy, and explicitly says restore testing should be performed periodically. With PostgreSQL, the database half is covered by `dokku-postgres`'s own S3-compatible backups, and `/data` needs a separate job.

## Resolved planning questions

1. Target OS: Ubuntu 22.04 or 24.04, the releases Dokku supports.
2. Vault domain: an operator variable. Real domains never appear in tracked files.
3. SMTP: deferred until a mailbox exists ([#12](https://github.com/thepsalmist/vaultwarden-dokku-kit/issues/12)).
4. `/admin`: stays enabled, guarded by an Argon2 `ADMIN_TOKEN`, with a documented way to turn it off ([#8](https://github.com/thepsalmist/vaultwarden-dokku-kit/issues/8)).
5. Backup target: S3-compatible storage through `dokku-postgres` backups, plus an encrypted `/data` tarball, with retention set by bucket lifecycle rules ([#5](https://github.com/thepsalmist/vaultwarden-dokku-kit/issues/5)).
6. Firewall and fail2ban: handled by ansible-server-bootstrap. This repo adds a Vaultwarden login jail ([#13](https://github.com/thepsalmist/vaultwarden-dokku-kit/issues/13)).

## First milestone

The [M1: Hardened deployment](https://github.com/thepsalmist/vaultwarden-dokku-kit/milestone/1) milestone tracks the first release: a working, hardened deployment with smoke tests and a manual pre-upgrade backup. Scheduled off-site backups follow in the backlog, and until they land the deployment is not production-ready under decision 10.

## Security guardrails

- Never commit `.env`, inventory files containing real hosts, generated admin tokens, SMTP passwords, backup credentials or passphrases, private keys, or production domains.
- Generate `ADMIN_TOKEN` as an Argon2 PHC string with `vaultwarden hash`.
- Use explicit examples with placeholders such as `vault.example.com` and `admin@example.com`.
- Document every irreversible or destructive command before adding automation for it.
- Include restore validation, not only backup creation.

## References

- Vaultwarden wiki home: https://github.com/dani-garcia/vaultwarden/wiki
- Configuration overview: https://github.com/dani-garcia/vaultwarden/wiki/Configuration-overview
- Hardening guide: https://github.com/dani-garcia/vaultwarden/wiki/Hardening-Guide
- Backup guide: https://github.com/dani-garcia/vaultwarden/wiki/Backing-up-your-vault
- Dokku deployment docs: https://dokku.com/docs/deployment/application-deployment/
- Dokku PostgreSQL plugin: https://github.com/dokku/dokku-postgres
