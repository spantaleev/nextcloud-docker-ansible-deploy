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

`nextcloud_config_additional_parameters` was introduced to supersede the previously-existing `nextcloud_config_parameters` variable.
You're supposed to put your own parameters in `nextcloud_config_additional_parameters` from now on.


# 2018-11-01

## Postgres 11 support

The playbook now installs [Postgres 11](https://www.postgresql.org/about/news/1894/) by default.

If you have have an existing setup, it's likely running on an older Postgres version (9.x or 10.x). You can easily upgrade by following the [Maintenance / upgrading PostgreSQL](docs/maintenance-postgres.md) guide.


## (BC Break) Renaming playbook variables

The following playbook variables were renamed:

- from `nextcloud_docker_image_nextcloud` to `nextcloud_nextcloud_docker_image`
- from `nextcloud_docker_image_nginx` to `nextcloud_nginx_proxy_docker_image`
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

We've been using [acmetool](https://github.com/hlandau/acme) (with the [willwill/acme-docker](https://hub.docker.com/r/willwill/acme-docker/) Docker image) until now.

Due to the Docker image being deprecated, and things looking bleak for acmetool's support of the newer ACME v2 API endpoint, we've switched to using [certbot](https://certbot.eff.org/) (with the [certbot/certbot](https://hub.docker.com/r/certbot/certbot/) Docker image).

Simply re-running the playbook will retrieve new certificates (via certbot) for you.
To ensure you don't leave any old files behind, though, you'd better do this:

- `systemctl stop 'nextcloud*'`
- stop your custom webserver, if you're running one (only affects you if you've installed with `nextcloud_nginx_proxy_enabled: false`)
- `mv /nextcloud/ssl /nextcloud/ssl-acmetool-delete-later`
- re-run the playbook's installation
- possibly delete `/nextcloud/ssl-acmetool-delete-later`
