# Scripts

Small operator helpers. Scripts should wrap clear actions such as validation, bootstrap, deploy, backup, and restore checks. They should avoid storing secrets or replacing Ansible's role as the source of repeatable server state.

| Script | What it does |
|---|---|
| `check-prereqs.sh` | Checks this workstation has `ansible-playbook`, `ssh` and `git`, and prints how to install any that are missing. Exits non-zero if one is missing. Contacts no server and reads no secrets. |
