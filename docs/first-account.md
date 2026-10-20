# Creating the first account

Registration stays closed (`SIGNUPS_ALLOWED=false`), so accounts are invited from the admin page instead. While mail isn't configured, Vaultwarden sends no email: it keeps the invite and lets that one address register.

Only do this once the vault serves HTTPS. Never open `/admin` over plain HTTP.

## 1. Turn on the admin page

The admin page is off until `vaultwarden_admin_token` is set. On the server, hash an admin password. Use the image tag that matches your `vaultwarden_version`:

```bash
sudo docker run --rm -it vaultwarden/server:1.37.4 /vaultwarden hash
```

It asks for the password twice and prints a line starting with `$argon2id$`. Put that line in `ansible/group_vars/all.yml`, in single quotes:

```yaml
vaultwarden_admin_token: '$argon2id$v=19$m=65540,t=3,p=4$...'
```

Run the playbook. It sets `ADMIN_TOKEN` and restarts the app.

## 2. Invite yourself

Open `https://<your domain>/admin` and log in with the admin password, not the hash. Under **Users**, invite your email address.

## 3. Register

The web vault hides its sign-up link while registration is closed. Open `https://<your domain>/#/signup` directly and register with the invited address. Any other address is refused.

## 4. Secure the account

- Turn on two-step login under **Settings → Security → Two-step login**, and keep the recovery code outside the vault.
- Check **Settings → Emergency access**.
- Decide whether to keep `/admin` on. You need it again only to invite more people.

## Turning `/admin` off

Remove `vaultwarden_admin_token` from `group_vars/all.yml`, then run on the server:

```bash
sudo dokku config:unset vaultwarden ADMIN_TOKEN
```

The app restarts with `/admin` off. If you only run `config:unset`, the next playbook run turns `/admin` back on.

## Don't save settings on `/admin`

The **Settings** page on `/admin` writes to `/data/config.json`, and that file overrides the settings the playbook sets, `SIGNUPS_ALLOWED` and `ADMIN_TOKEN` included. Change settings through the playbook. If you already saved something there, press **Reset defaults** on the same page to delete the file.
