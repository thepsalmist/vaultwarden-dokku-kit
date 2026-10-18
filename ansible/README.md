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
ansible-playbook site.yml
ansible-playbook site.yml --check --diff
```

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
ansible-playbook site.yml --syntax-check            # from this directory
```
