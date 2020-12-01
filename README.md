[![Support room on Matrix](https://img.shields.io/matrix/nextcloud-docker-ansible-deploy:devture.com.svg?label=%23nextcloud-docker-ansible-deploy%3Adevture.com&logo=matrix&style=for-the-badge&server_fqdn=matrix.devture.com)](https://matrix.to/#/#nextcloud-docker-ansible-deploy:devture.com) [![donate](https://liberapay.com/assets/widgets/donate.svg)](https://liberapay.com/s.pantaleev/donate)

# Nextcloud (A safe home for all your data) server setup using Ansible and Docker

## Purpose

This Ansible playbook is meant to easily let you run your own [Nextcloud](https://nextcloud.com/) server.

Using this playbook, you can get the following services configured on your server:

- a [Nextcloud](https://nextcloud.com/) server - storing your data

- (optional) [Amazon S3](https://aws.amazon.com/s3/) remote storage for your Nextcloud data using [Goofys](https://github.com/kahing/goofys)

- a [PostgreSQL](https://www.postgresql.org/) database for Nextcloud

- free [Let's Encrypt](https://letsencrypt.org/) SSL certificate, which secures the connection to the Nextcloud server

- (optional) [OnlyOffice](https://www.onlyoffice.com/) integration - for online document editing/previewing

Basically, this playbook aims to get you up-and-running with all the basic necessities around Nextcloud, without you having to do anything else.


## Installing

To configure and install Nextcloud on your own server, follow the [README in the docs/ directory](docs/README.md).


## Changes

This playbook evolves over time, sometimes with backward-incompatible changes.

When updating the playbook, refer to [the changelog](CHANGELOG.md) to catch up with what's new.


## Docker images used by this playbook

This playbook sets up your server using the following Docker images:

- [nextcloud](https://hub.docker.com/r/_/nextcloud/) - the official [Nextcloud](https://github.com/nextcloud/server) server

- [postgres](https://hub.docker.com/_/postgres/) - the [Postgres](https://www.postgresql.org/) database server (optional)

- [cloudproto/goofys](https://hub.docker.com/r/cloudproto/goofys/) - the [Goofys](https://github.com/kahing/goofys) Amazon [S3](https://aws.amazon.com/s3/) file-system-mounting program (optional)

- [nginx](https://hub.docker.com/_/nginx/) - the [nginx](http://nginx.org/) web server (optional)

- [certbot/certbot](https://hub.docker.com/r/certbot/certbot/) - the [certbot](https://certbot.eff.org/) tool for obtaining SSL certificates from [Let's Encrypt](https://letsencrypt.org/)

- [onlyoffice/documentserver](https://hub.docker.com/r/onlyoffice/documentserver/) - the [OnlyOffice](https://www.onlyoffice.com/) Document Server, for online document editing/previewing (optional)


## Deficiencies

This Ansible playbook can be improved in the following ways:

- setting up automatic backups to one or more storage providers

## Support

- Matrix room: [#nextcloud-docker-ansible-deploy:devture.com](https://matrix.to/#/#nextcloud-docker-ansible-deploy:devture.com)

- Github issues: [spantaleev/nextcloud-docker-ansible-deploy/issues](https://github.com/spantaleev/nextcloud-docker-ansible-deploy/issues)
