# Scripts

Small operator helpers. Scripts should wrap clear actions such as validation, bootstrap, deploy, backup, and restore checks. They should avoid storing secrets or replacing Ansible's role as the source of repeatable server state.

| Script | What it does |
|---|---|
| `check-prereqs.sh` | Checks this workstation has `ansible-playbook`, `ssh` and `git`, and prints how to install any that are missing. Exits non-zero if one is missing. Contacts no server and reads no secrets. |
| `smoke-test.sh <domain>` | Checks a deployed vault from outside: plain HTTP redirects to HTTPS, the certificate is valid, `/alive` returns 200, `/` serves the web vault and `/api/config` returns JSON. Prints PASS or FAIL for each and exits non-zero if any fail. Run it after every deploy, upgrade or restore. Needs `curl`, and no account or secrets. |
