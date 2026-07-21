# Project Brief

## Objective

Create a public repository that deploys a personal Vaultwarden instance on Dokku using repeatable automation and secure operational defaults.

## Key decisions

1. Use Dokku as the deployment target.
2. Use Ansible for host and app state because it gives idempotency, inventory support, dry-run capability, and clear reviewable changes.
3. Use small shell scripts only as operator wrappers around Ansible, Dokku, backup, restore, and validation tasks.
4. Configure Vaultwarden via environment variables, not `config.json`, so configuration remains reproducible and reviewable.
5. Keep the repo public-safe by committing examples and templates only.
6. Start with SQLite unless the project later needs multi-instance or external database support.
7. Require HTTPS behind Dokku's reverse proxy for production.
8. Disable public registration after the initial user is created.
9. Add automated backups and a restore test path before treating the deployment as production-ready.

## Source Guidance

Vaultwarden's wiki recommends environment variables as the normal configuration path and warns that `config.json` can override other methods and become hard to reason about. The implementation should therefore drive app config through Dokku env vars and documented examples.

The hardening guide calls out disabling anonymous registration, optionally disabling invitations, disabling password hints, using a production reverse proxy instead of Vaultwarden's built-in TLS, running with minimum required privileges where practical, and avoiding unnecessary host mounts.

The backup guide says Vaultwarden data should be backed up regularly, preferably automatically, with at least one remote copy. For SQLite, it recommends the SQLite online backup approach or Vaultwarden's built-in backup command, and it explicitly says restore testing should be performed periodically.

## Initial repo structure

```text
.
├── README.md
├── docs/PROJECT_BRIEF.md
├── .env.example
├── .gitignore
├── ansible/
│   └── README.md
├── docs/
│   └── IMPLEMENTATION_PLAN.md
└── scripts/
    └── README.md
```

## First implementation milestone

Build a minimal deployable baseline:

1. Create a Dokku app, e.g. `vaultwarden`.
2. Set the app domain, e.g. `vault.example.com`.
3. Deploy the official `vaultwarden/server` image through a Dockerfile or Dokku Docker image deployment.
4. Mount persistent data at a predictable host path.
5. Set `DOMAIN`, `SIGNUPS_ALLOWED=false`, `INVITATIONS_ALLOWED=false`, `SHOW_PASSWORD_HINT=false`, `WEBSOCKET_ENABLED=true`, SMTP settings, and a securely generated admin token if `/admin` is enabled.
6. Enable HTTPS with Dokku's Let's Encrypt plugin.
7. Add backup automation and a documented restore test.

## Planning Questions

1. Target server OS and version.
2. Preferred domain name for the vault.
3. Email provider for SMTP.
4. Whether `/admin` should remain enabled after setup.
5. Backup target: local plus rclone, restic, S3-compatible storage, or another remote.
6. Whether host setup should include firewall and fail2ban, or assume those are managed externally.

## Security guardrails

- Never commit `.env`, inventory files containing real hosts, generated admin tokens, SMTP passwords, backup repository passwords, private keys, or production domains if privacy matters.
- Prefer `ADMIN_TOKEN` generated with Argon2 where supported by the current Vaultwarden guidance.
- Use explicit examples with placeholders such as `vault.example.com` and `admin@example.com`.
- Document every irreversible or destructive command before adding automation for it.
- Include restore validation, not only backup creation.

## References

- Vaultwarden wiki home: https://github.com/dani-garcia/vaultwarden/wiki
- Configuration overview: https://github.com/dani-garcia/vaultwarden/wiki/Configuration-overview
- Hardening guide: https://github.com/dani-garcia/vaultwarden/wiki/Hardening-Guide
- Backup guide: https://github.com/dani-garcia/vaultwarden/wiki/Backing-up-your-vault
- Dokku deployment docs: https://dokku.com/docs/deployment/application-deployment/
