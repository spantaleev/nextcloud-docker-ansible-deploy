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