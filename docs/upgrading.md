# Upgrading Vaultwarden

Vaultwarden updates its database the first time a new version starts, and that can't be undone. Re-deploying the old version afterwards isn't enough to roll back: you also need the database and `/data` from before the upgrade. Back up every time.

## 1. Read the release notes

Read the [release notes](https://github.com/dani-garcia/vaultwarden/releases) for every version between yours and the target.

## 2. Back up

On the server, as the admin user:

```bash
app=vaultwarden
backup=~/vaultwarden-backups/$(date +%Y%m%d-%H%M%S)
mkdir -p -m 700 "$backup"

sudo dokku ps:stop "$app"
sudo dokku postgres:export "$app-db" > "$backup/db.dump"
sudo tar -C /var/lib/dokku/data/storage -czf - "$app" > "$backup/data.tar.gz"
sudo dokku ps:start "$app"

ls -l "$backup"
```

The app is stopped for a few seconds, so the database and `/data` are copied at the same point. Check that every command succeeded and that both files are larger than zero. Note the backup's directory, because a rollback needs it.

The backup stays on the server. It protects you from a bad upgrade, not from losing the server. Delete old backups once you're happy with an upgrade.

## 3. Upgrade

Set `vaultwarden_version` in `ansible/group_vars/all.yml` to the new version, and run the playbook:

```bash
ansible-playbook vaultwarden.yml
```

## 4. Check

Log in to the web vault, and open an item and an attachment.

## Rolling back

On the server, with the backup's directory from step 2:

```bash
app=vaultwarden
backup=~/vaultwarden-backups/<timestamp>

sudo dokku ps:stop "$app"
sudo dokku --no-restart postgres:unlink "$app-db" "$app"
sudo dokku postgres:destroy "$app-db"
sudo dokku postgres:create "$app-db"
sudo dokku postgres:import "$app-db" < "$backup/db.dump"

sudo rm -r "/var/lib/dokku/data/storage/$app"
sudo tar -C /var/lib/dokku/data/storage -xzf "$backup/data.tar.gz"
```

`postgres:destroy` asks you to type the database's name to confirm. Check it's the database you mean to replace.

Recreate the database rather than importing over it. An import over the upgraded database leaves the new version's changes behind. The old version still starts, but the next upgrade then fails.

Set `vaultwarden_version` back to the old version and run the playbook. It links the restored database and deploys the old version. Then check as in step 4.

## Rehearsing on a test copy

Rehearse an upgrade and a rollback once on a [separate test copy](../ansible/README.md#a-separate-test-copy) before relying on them for the real vault. Its domain needs a DNS record pointing at the host.

1. Deploy the copy at your current version, with `-e vaultwarden_app=vaultwarden-upgrade-test -e vaultwarden_domain=<test domain>`.
2. Create an account on it as in [first-account.md](first-account.md), and add an item with an attachment.
3. Follow steps 2 to 4 and the rollback above, with `app=vaultwarden-upgrade-test` on the server, and the same `-e` options plus `-e vaultwarden_version=<version>` for each playbook run.
4. Remove the copy afterwards, as the test copy section describes.
