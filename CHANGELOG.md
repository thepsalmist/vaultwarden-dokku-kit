# Changelog

All notable changes to this project are listed here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- PostgreSQL through `dokku-postgres` replaces SQLite as the database.
- Host provisioning is a prerequisite, handled by ansible-server-bootstrap or any Dokku host with the `postgres` and `letsencrypt` plugins.
- The first account is invited from `/admin`, so public registration is never opened.

### Removed

- `.env.example`. Operator configuration lives in Ansible group_vars.
