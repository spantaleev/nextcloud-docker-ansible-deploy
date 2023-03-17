[![Support room on Matrix](https://img.shields.io/matrix/nextcloud-docker-ansible-deploy:devture.com.svg?label=%23nextcloud-docker-ansible-deploy%3Adevture.com&logo=matrix&style=for-the-badge&server_fqdn=matrix.devture.com)](https://matrix.to/#/#nextcloud-docker-ansible-deploy:devture.com) [![donate](https://liberapay.com/assets/widgets/donate.svg)](https://liberapay.com/s.pantaleev/donate)

-------

**WARNING**: this playbook has been **made obsolete** by the [MASH playbook](https://github.com/mother-of-all-self-hosting/mash-playbook), which also supports installing the [Nextcloud](https://github.com/mother-of-all-self-hosting/mash-playbook/blob/main/docs/services/nextcloud.md) and [Collabora Online](https://github.com/mother-of-all-self-hosting/mash-playbook/blob/main/docs/services/collabora-online.md) services.

-------

# Nextcloud (A safe home for all your data) server setup using Ansible and Docker

This [Ansible](https://www.ansible.com/) playbook can help you set your own [Nextcloud](https://nextcloud.com/) server:

- on your own Debian/CentOS/RedHat server

- with all services ([Nextcloud](https://nextcloud.com/), [PostgreSQL](https://www.postgresql.org/), [Traefik](https://traefik.io), [OnlyOffice](https://www.onlyoffice.com/), etc.) running in [Docker](https://www.docker.com/) containers

- powered by [the official Nextcloud container image](https://hub.docker.com/_/nextcloud)

- [interoperates nicely](docs/configuring-playbook-interoperability.md) with [related](#related) Ansible playbooks or other services using Traefik for reverse-proxying

SSL certificates are automatically managed by a [Traefik](https://traefik.io) reverse-proxy.

Various components (Postgres, Traefik, etc.) can be disabled and replaced with your own other implementations (see [configuring the playbook](docs/configuring-playbook.md)).


## Features

Using this playbook, you can get the following services configured on your server:

- a [Nextcloud](https://nextcloud.com/) server - storing your data

- (optional) a [PostgreSQL](https://www.postgresql.org/) database for Nextcloud

- (optional) free [Let's Encrypt](https://letsencrypt.org/) SSL certificate, which secures the connection to the Nextcloud server

- (optional) [OnlyOffice](https://www.onlyoffice.com/) integration - for online document editing/previewing

- (optional) [Collabora Online](https://www.collaboraoffice.com/) integration - for online document editing/previewing

Basically, this playbook aims to get you up-and-running with all the basic necessities around Nextcloud.


## Installing

To configure and install Nextcloud on your own server, follow the [README in the docs/ directory](docs/README.md).


## Changes

This playbook evolves over time, sometimes with backward-incompatible changes.

When updating the playbook, refer to [the changelog](CHANGELOG.md) to catch up with what's new.


## Support

- Matrix room: [#nextcloud-docker-ansible-deploy:devture.com](https://matrix.to/#/#nextcloud-docker-ansible-deploy:devture.com)

- Github issues: [spantaleev/nextcloud-docker-ansible-deploy/issues](https://github.com/spantaleev/nextcloud-docker-ansible-deploy/issues)


## Related

You may also be interested in these other playbooks:

- [gitea-docker-ansible-deploy](https://github.com/spantaleev/gitea-docker-ansible-deploy) - for deploying a [Gitea](https://gitea.io) (self-hosted [Git](https://git-scm.com/) service) server

- [matrix-docker-ansible-deploy](https://github.com/spantaleev/matrix-docker-ansible-deploy) - for deploying a fully-featured [Matrix](https://matrix.org) homeserver

- [peertube-docker-ansible-deploy](https://github.com/spantaleev/peertube-docker-ansible-deploy) - for deploying a [PeerTube](https://joinpeertube.org/) video-platform server

- [vaultwarden-docker-ansible-deploy](https://github.com/spantaleev/vaultwarden-docker-ansible-deploy) - for deploying a [Vaultwarden](https://github.com/dani-garcia/vaultwarden) password manager server (unofficial [Bitwarden](https://bitwarden.com/) compatible server)
