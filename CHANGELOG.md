# 2023-02-10

## Collabora Online support

Thanks to [Julian-Samuel Gebühr (@moan0s)](https://github.com/moan0s), the playbook can now set up [Collabora Online Development Edition (CODE)](https://www.collaboraoffice.com/) - Your Private Office Suite In The Cloud.

See our [Setting up Collabora Online (Office) integration](docs/configuring-playbook-collabora-online.md) documentation to get started.


# 2023-01-13

## Support for running commands via just

We've previously used [make](https://www.gnu.org/software/make/) for easily running some playbook commands (e.g. `make roles` which triggers `ansible-galaxy`, see [Makefile](Makefile)).
Our `Makefile` is still around and you can still run these commands.

In addition, we've added support for running commands via [just](https://github.com/casey/just) - a more modern command-runner alternative to `make`. Instead of `make roles`, you can now run `just roles` to accomplish the same.

Our [justfile](justfile) already defines some additional helpful **shortcut** commands that weren't part of our `Makefile`. Here are some examples:

- `just install-all` to trigger the much longer `ansible-playbook -i inventory/hosts setup.yml --tags=install-all,start` command
- `just install-all --ask-vault-pass` - commands also support additional arguments (`--ask-vault-pass` will be appended to the above installation command)
- `just run-tags install-nextcloud,start` - to run specific playbook tags
- `just start-all` - (re-)starts all services
- `just stop-group postgres` - to stop only the Postgres service

Additional helpful commands and shortcuts may be defined in the future.

This is all completely optional. If you find it difficult to [install `just`](https://github.com/casey/just#installation) or don't find any of this convenient, feel free to run all commands manually.


# 2022-12-14

# Container networks have flipped around

If you're using an externally-managed Traefik server or other reverse-proxy, you may need to adapt your `vars.yml` configuration.

To ensure connectivity of Nextcloud (actually `nextcloud-reverse-proxy-companion`) to Traefik, we used to put `nextcloud-reverse-proxy-companion` in Traefik's network (as a main network), and then also connect the `nextcloud-reverse-proxy-companion` container to "additional networks" (the `nextcloud` network, etc.).

While this worked, it was a little backwards. We now have a better way to do things - putting `nextcloud-reverse-proxy-companion` in its own `nextcloud` network as main, and connecting it to additional networks (e.g. `traefik`) after creating the container, but before starting it. This also seems to work well and is more straightforward.

The playbook will warn you if you're using any variables that have been renamed or dropped.


# 2022-11-25

# Traefik now runs in a separate container network from the rest of the Nextcloud services

Until now, Traefik ran in the same container network (`nextcloud`) as all Nextcloud services so it could reverse-proxy to them easily.

From now on:

- Traefik runs in its own new `traefik` container network

- Nextcloud services continue to run in the `nextcloud` container network

- Nextcloud services which Traefik needs to reverse-proxy to (e.g. the `nextcloud-reverse-proxy-companion` container) are automatically connected to the `traefik` additional container network, thanks to a new `nextcloud_playbook_reverse_proxyable_services_additional_networks` variable controlling this behavior

To **upgrade your setup**, consider first stopping all services (running the playbook with `--tags=stop`) and then installing (`--tags=setup-all,start`).

If you're reverse-proxying via your own Traefik instance (not installed by this playbook), you may need to use this additional configuration: `nextcloud_playbook_reverse_proxyable_services_additional_networks: [traefik]` (for Traefik running in a container network named `traefik`).


# 2022-10-31

## (Backward Compatibility Break) Major playbook changes which necessitate manual action

This playbook has been completely overhauled:

- Docker installation is now handled by an upstream Ansible role [geerlingguy/ansible-role-docker](https://github.com/geerlingguy/ansible-role-docker), so we don't need to maintain this in this playbook

- various other Ansible roles have been extracted out into roles shared with other Ansible playbooks (see `requirements.yml`). These get installed into your working directory (in `roles/galaxy`) by you running `make roles`. Consider running `make roles` every time you update the playbook

- functionality which used to live in a single `nextcloud_server` role has been split into various Ansible roles (see `roles/custom/`)

- the Postgres database setup has been redone (improved security; support for additional databases in the future; etc), so you'll need to dump and reimport your database

- [support for various functionality has changed](#support-for-various-functionality-has-changed)

- [Traefik is the new default reverse-proxy](#the-default-reverse-proxy-has-changed-to-traefik), because it plays more nicely with other containered web services on the host. You can still [switch back to nginx](#switching-back-to-nextcloud-nginx-proxy) though

- Nextcloud now runs with more tightened permissions (`docker run --user=.. --cap-drop=ALL --read-only`) for increased security

- it no longer installs scripts in `/usr/local/bin`, but only in `/nextcloud/*/bin`

- it no longer uses cronjobs (and thus, no longer depends on a cron daemon) - periodic tasks are now powered by [systemd timers](https://wiki.archlinux.org/title/systemd/Timers)


### Support for various functionality has changed

Support for the following services has changed:

- **dropped** support for [Goofys](https://github.com/kahing/goofys) - consider finding an alternative for mounting S3 storage into Nextcloud. It was deemed complicated to migrate this feature to our new setup and its usefulness is dubious. If you need it, let us know or better yet spend the time to re-add it.

- **dropped** support for [Preview Generator](https://github.com/nextcloud/previewgenerator). The usefulness of this feature is also dubious, so we've kept things simple and dropped it. If you need it, let us know or better yet spend the time to re-add it.

- **regressed** support for [OnlyOffice](docs/configuring-playbook-onlyoffice.md). We've tried to port this feature to the next playbook setup, but are still hitting some problems. This may be fixed later.

- various playbook variables have been renamed. The playbook should tell you about the old and new names of most of these the next time you run it.


### The default reverse-proxy has changed to Traefik

By default, this playbook now uses [Traefik](https://traefik.io) for reverse-proxying to Nextcloud.

We recommend that you adopt this new default as it's a simpler and more interoperable setup.

To switch back to the previous default (`nextcloud-nginx-proxy`) or to figure out how to make your other reverse-proxy work with the new setup, see [Switching back to nextcloud-nginx-proxy](#switching-back-to-nextcloud-nginx-proxy) or the [Using your own webserver, instead of this playbook's Traefik](docs/configuring-playbook-own-webserver.md) documentation.

Using Traefik as a default reverse-proxy makes this playbook play more nicely with other containerized web services on the host which are also using Traefik (among which other playbooks like [gitea-docker-ansible-deploy](https://github.com/spantaleev/gitea-docker-ansible-deploy)).

If you were previously using Traefik as described in our docs, you can now probably get rid of **all** your custom reverse-proxy configuration except for the `nextcloud_container_network` variable (previously called `nextcloud_docker_network`), which specifies the container network Traefik and Nextcloud would share. Consider learning more in the [Using your own webserver, instead of this playbook's Traefik](docs/configuring-playbook-own-webserver.md) documentation.


### Switching back to nextcloud-nginx-proxy

Despite Traefik being the default reverse-proxy, you can still switch back to using `nginx` as a reverse-proxy with the following configuration:

```yaml
nextcloud_playbook_traefik_role_enabled: false
nextcloud_playbook_nginx_proxy_installation_enabled: true
```

You will also need to relocate your SSL certificate files from `/nextcloud/ssl` to `/nextcloud/nginx-proxy/ssl`. We tell you how to do this below, in [Restore your SSL certificates (if you will be using nextcloud-nginx-proxy)](#restore-your-ssl-certificates-if-you-will-be-using-nextcloud-nginx-proxy).


### Migrating to the new setup

#### Dump your Postgres database first

While your existing Nextcloud installation is still up and running, perform a Postgres database dump.

You will need this database dump later, to re-import it into the new Nextcloud Postgres database server the playbook will set up for you.

Use a command like this:

```sh
/usr/bin/docker exec \
--env-file=/nextcloud/environment-variables/env-postgres-pgsql-docker \
nextcloud-postgres \
/usr/local/bin/pg_dumpall -h nextcloud-postgres \
| gzip -c \
> /nextcloud-postgres-dump.sql.gz
```

#### Back up everything

**Before migrating, do a full backup**. A simple way to do it is like this:

1. Run `make roles` to pull dependency Ansible roles (defined in `requirements.yml`) into `roles/galaxy`. Also, remember to run this every time you update your playbook.
2. Stop all services: `ansible-playbook -i inventory/hosts setup.yml --tags=stop`
3. **Move** `/nextcloud` away: `mv /nextcloud /nextcloud-backup`

Doing this, you're both making a backup and freeing up `/nextcloud`, so that the new playbook installation can use it.


#### Adjust your playbook configuration

You will need to add these required variables (also see [`examples/host-vars.yml`](examples/host-vars.yml)).

```yaml
# This variable used to be called host_specific_nextcloud_hostname
nextcloud_server_fqn_nextcloud: nextcloud.DOMAIN

# A secret used as a base, for generating various other secrets.
# You can put any string here, but generating a strong one is preferred (e.g. `pwgen -s 64 1`).
nextcloud_generic_secret_key: ''

# The email address to provide to Traefik (which is then provided to Let's Encrypt) for obtaining SSL certificates
devture_traefik_config_certificatesResolvers_acme_email: ''
# or (if you're disabling Traefik) and using `nextcloud-nginx-proxy`:
# nextcloud_nginx_proxy_ssl_support_email: ''

# A Postgres password to use for the superuser Postgres user (called `root` by default).
#
# The playbook creates additional Postgres users and databases (one for each enabled service) using this superuser account.
devture_postgres_connection_password: ''

# A Postgres password to use for the `nextcloud` database.
# You will use the same password during initial Nextcloud installation.
nextcloud_nextcloud_database_password: ''
```

**Don't forget** to make your `vars.yml` adjustments related to the reverse-proxy for Traefik or nginx, as described above in [Traefik is the new default reverse-proxy](#the-default-reverse-proxy-has-changed-to-traefik) or [switching back to nginx](#switching-back-to-nextcloud-nginx-proxy).

The next time you run the playbook, it will warn you if you're still using some variables that have been renamed or dropped.


#### Clean up

1. Delete cronjobs: `rm /etc/cron.d/nextcloud-*`. The new setup uses systemd timers, not cronjobs

2. Delete scripts: `rm /usr/local/bin/nextcloud-*`. These scripts will live in `/nextcloud/*/bin` after the new setup

3. Delete existing systemd services: `rm /etc/systemd/system/nextcloud*.service`. The new setup may recreate some of them later


#### Restore your SSL certificates (if you will be using nextcloud-nginx-proxy)

If you are using Traefik (the new default reverse-proxy), this step does not apply to you.

This step is not strictly required, as the new playbook can obtain new SSL certificates.
Still, you may wish to use your existing ones to avoid hitting some Let's Encrypt rate-limits, etc.

To restore your old SSL certificates, do this:

1. Create the directory tree: `mkdir -p /nextcloud/nginx-proxy/ssl`
2. Copy your old certificates: `rsync -avr /nextcloud-backup/ssl/. /nextcloud/nginx-proxy/ssl/.`
3. Fix up permissions: `chown -R nextcloud:nextcloud /nextcloud/nginx-proxy/ssl`


#### Install and migrate your data

Make sure you've [adjusted your playbook configuration](#adjust-your-playbook-configuration).

1. If you haven't already, run `make roles` to pull dependency Ansible roles (defined in `requirements.yml`) into `roles/galaxy`. Also, remember to run this every time you update your playbook.

2. Run the playbook: `ansible-playbook -i inventory/hosts setup.yml --tags=setup-all`

3. Import your old Postgres database: `ansible-playbook -i inventory/hosts setup.yml --tags=import-postgres --extra-vars='{"server_path_postgres_dump": "/nextcloud-postgres-dump.sql.gz", "postgres_default_import_database": "nextcloud"}'`

4. Make sure all Nextcloud services are stopped: `ansible-playbook -i inventory/hosts setup.yml --tags=stop`

5. Migrate your old data: `rsync -avr --delete /nextcloud-backup/nextcloud-data/. /nextcloud/nextcloud/data/.`

6. Fix ownership of the data: `chown nextcloud:nextcloud /nextcloud/nextcloud/data/ -R`

7. Change the database password in the Nextcloud config (we used a `nextcloud-password` password by default, but now use one provided by you in the `nextcloud_nextcloud_database_password` variable): Either edit the `/nextcloud/nextcloud/data/config/config.php` file manually or run this command (after adjusting the `YOUR_DATABASE_PASSWORD_HERE` part): `sed -i "s/  'dbpassword' => 'nextcloud-password',/  'dbpassword' => 'YOUR_DATABASE_PASSWORD_HERE',/" /nextcloud/nextcloud/data/config/config.php`

8. Start all services: `ansible-playbook -i inventory/hosts setup.yml --tags=start`


# 2022-09-23

## Fail2ban support added and enabled by default

Thanks to [Gergely Horváth (@hooger)](https://github.com/hooger) we now have [Fail2ban](https://www.fail2ban.org) support, configured as recommended by the [Nextcloud guide upstream](https://docs.nextcloud.com/server/21/admin_manual/installation/harden_server.html#setup-fail2ban).

**Fail2ban is also enabled by default now**. If you wish to continue running **without** Fail2ban, add this to your `vars.yml` file: `nextcloud_fail2ban_enabled: false`.


# 2019-08-08

## Volume-mounting changes

Instead of mounting individual directories for storage (`config`, `data`, `custom_apps`, etc.), we now directly mount `/nextcloud/nextcloud-data` at `/var/www/html`.

What we were doing before is nice and clean, but not standard and was leading to various Nextcloud issues (pretty URLs not working, etc.).

The only thing you need to do to migrate (besides re-running the playbook) is to fix pretty URLs support: `docker exec -u www-data nextcloud-apache php /var/www/html/occ maintenance:update:htaccess`


# 2019-05-28

## Ansible 2.8 compatibility

The playbook now supports the new Ansible 2.8.

A manual change is required to the `inventory/hosts` file, changing the group name from `nextcloud-servers` to `nextcloud_servers` (dash to underscore).

To avoid doing it manually, run this:
- Linux: `sed -i 's/nextcloud-servers/nextcloud_servers/g' inventory/hosts`
- Mac: `sed -i '' 's/nextcloud-servers/nextcloud_servers/g' inventory/hosts`


# 2019-04-16

## Nextcloud default parameters introduced

`nextcloud_nextcloud_config_additional_parameters` was introduced to supersede the previously-existing `nextcloud_nextcloud_config_parameters` variable.
You're supposed to put your own parameters in `nextcloud_nextcloud_config_additional_parameters` from now on.


# 2018-11-01

## Postgres 11 support

The playbook now installs [Postgres 11](https://www.postgresql.org/about/news/1894/) by default.

If you have have an existing setup, it's likely running on an older Postgres version (9.x or 10.x). You can easily upgrade by following the [Maintenance / upgrading PostgreSQL](docs/maintenance-postgres.md) guide.


## (BC Break) Renaming playbook variables

The following playbook variables were renamed:

- from `nextcloud_docker_image_nextcloud` to `nextcloud_nextcloud_container_image`
- from `nextcloud_docker_image_nginx` to `nextcloud_nginx_proxy_container_image`
- from `nextcloud_docker_image_goofys` to `nextcloud_goofys_docker_image`
- from `nextcloud_docker_image_postgres_v9` to `nextcloud_postgres_docker_image_v9`
- from `nextcloud_docker_image_postgres_v10` to `nextcloud_postgres_docker_image_v10`
- from `nextcloud_apache_container_memory_limit` to `nextcloud_nextcloud_apache_container_memory_limit`
- from `nextcloud_apache_container_memory_swap_limit` to `nextcloud_nextcloud_apache_container_memory_swap_limit`


# 2018-10-24

## OnlyOffice integration

The playbook can now [install and configure](docs/configuring-playbook-onlyoffice.md) an [OnlyOffice](https://www.onlyoffice.com/) Document Server and the [OnlyOffice app for Nextcloud](https://apps.nextcloud.com/apps/onlyoffice).


# 2018-09-26

## Disabling Docker container logging

`--log-driver=none` is used for all Docker containers now.

All these containers are started through systemd anyway and get logged in journald, so there's no need for Docker to be logging the same thing using the default `json-file` driver. Doing that was growing `/var/lib/docker/containers/..` infinitely until service/container restart.

As a result of this, things like `docker logs nextcloud-apache` won't work anymore. `journalctl -u nextcloud-apache` is how one can see the logs.


# 2018-08-29

## Changing the way SSL certificates are retrieved

We've been using [acmetool](https://github.com/hlandau/acme) (with the [willwill/acme-docker](https://hub.docker.com/r/willwill/acme-docker/) container image) until now.

Due to the container image being deprecated, and things looking bleak for acmetool's support of the newer ACME v2 API endpoint, we've switched to using [certbot](https://certbot.eff.org/) (with the [certbot/certbot](https://hub.docker.com/r/certbot/certbot/) container image).

Simply re-running the playbook will retrieve new certificates (via certbot) for you.
To ensure you don't leave any old files behind, though, you'd better do this:

- `systemctl stop 'nextcloud*'`
- stop your custom webserver, if you're running one (only affects you if you've installed with `nextcloud_nginx_proxy_enabled: false`)
- `mv /nextcloud/ssl /nextcloud/ssl-acmetool-delete-later`
- re-run the playbook's installation
- possibly delete `/nextcloud/ssl-acmetool-delete-later`
