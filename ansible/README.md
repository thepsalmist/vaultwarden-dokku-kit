# Ansible

Deploys Vaultwarden onto a Dokku host that is already prepared. See Requirements in the [root README](../README.md).

Keep production inventory and secret variable files out of git. Commit only examples and defaults that are safe for a public repository.

## Setup (on your workstation)

```bash
uv tool install ansible-core                        # 2.15+, tested with 2.21
scripts/check-prereqs.sh                            # from the repo root
cd ansible
cp inventory.ini.example inventory.ini              # server address
cp group_vars/all.yml.example group_vars/all.yml    # admin_user, vaultwarden_domain
```

If `ansible-playbook` isn't found afterwards, run `uv tool update-shell` and open a new shell.

## Usage

Run from this directory, so `ansible.cfg` applies:

```bash
ansible-playbook vaultwarden.yml
```

A second run should report `changed=0`. `--check` isn't useful here. Every change goes through a `dokku` command, which Ansible skips under `--check`. On a deployed host a check run reports `changed=0` even when something has drifted, and before the first deploy it fails, because the app doesn't exist yet. Use a normal run: it only changes what differs.

## What the playbook does

Each step reads Dokku's current state first and only changes what differs:

1. Creates the PostgreSQL service `vaultwarden-db` and the Dokku app `vaultwarden`.
2. Links the database to the app, which sets `DATABASE_URL`. This always happens before the first deploy, so Vaultwarden never starts on a stray SQLite file.
3. Creates `/var/lib/dokku/data/storage/vaultwarden` (root-only, `0700`) and mounts it at `/data`. That directory holds attachments, Sends, the icon cache and the key that signs login tokens. Losing it logs every client out and loses every attachment.
4. Sets the app's domain to `vaultwarden_domain` and routes port 80 to the container.
5. Sets Vaultwarden's config: `DOMAIN`, `SIGNUPS_ALLOWED=false`, `INVITATIONS_ALLOWED=false` and `SHOW_PASSWORD_HINT=false`. A value changed by hand on the server is set back on the next run.
6. Deploys `vaultwarden/server:<vaultwarden_version>` whenever that version isn't the one running. Otherwise it restarts the app once if the database link, the mount or the config had to be fixed.
7. Turns on HTTPS with a Let's Encrypt certificate, if it isn't on yet. Dokku then redirects plain HTTP to HTTPS.

If a deploy fails, the version that was already running keeps running, and the next run tries again.

It never publishes the database port.

## HTTPS

The domain's DNS record must point at the host before the first run, or the certificate request fails.

The certificate is requested once. The letsencrypt plugin's daily cron job renews it. ansible-server-bootstrap adds that job. On a host prepared some other way, check it's there and add it if it isn't:

```bash
sudo dokku letsencrypt:cron-job          # shows whether it's enabled
sudo dokku letsencrypt:cron-job --add
```

To confirm HTTPS works:

```bash
curl -sI http://vault.example.com          # 301 to https://vault.example.com
curl -s https://vault.example.com/alive    # succeeds, with a valid certificate
```

## Variables

Set these in `group_vars/all.yml`.

| Variable | Default | Meaning |
|---|---|---|
| `admin_user` | required | Sudo admin Ansible connects as |
| `vaultwarden_domain` | required | The vault's hostname, without `https://` |
| `vaultwarden_version` | `1.37.4` | `vaultwarden/server` image tag. Bump it to upgrade |
| `vaultwarden_app` | `vaultwarden` | Dokku app name. Change it to run a separate test copy |
| `vaultwarden_db_service` | `<vaultwarden_app>-db` | PostgreSQL service name |

### A separate test copy

Pass a different app name and domain to deploy an independent copy next to the real vault. It gets its own database and its own storage directory, `/var/lib/dokku/data/storage/<app name>`:

```bash
ansible-playbook vaultwarden.yml -e vaultwarden_app=vaultwarden-test -e vaultwarden_domain=vault-test.example.com
```

Remove it afterwards. This deletes the copy's data, and only the copy's:

```bash
sudo dokku apps:destroy vaultwarden-test
sudo dokku postgres:destroy vaultwarden-test-db
sudo rm -r /var/lib/dokku/data/storage/vaultwarden-test
```

Dokku keeps a small storage record for the removed directory. It's harmless, and it's reused if you create the copy again.

## Upgrading

Read the [release notes](https://github.com/dani-garcia/vaultwarden/releases) for every version between yours and the target. Then bump `vaultwarden_version` and run the playbook.

Vaultwarden updates its database when the new version starts, and that can't be undone. Back up the database and `/data` before upgrading, so you can roll back.

## Preflight

Every run starts with checks that stop before anything on the host changes. They fail when:

- The host isn't Ubuntu 22.04 or 24.04.
- `vaultwarden_domain` is unset, still `vault.example.com`, or starts with `https://`.
- Dokku isn't installed, or its `postgres` or `letsencrypt` plugin is missing.
- Let's Encrypt has no global email.

The host is expected to have been prepared by [ansible-server-bootstrap](https://github.com/thepsalmist/ansible-server-bootstrap), which installs all of the above. Checked against Dokku 0.38.

## Linting

```bash
uvx ansible-lint                                    # from the repo root, production profile
ansible-playbook vaultwarden.yml --syntax-check     # from this directory
```
