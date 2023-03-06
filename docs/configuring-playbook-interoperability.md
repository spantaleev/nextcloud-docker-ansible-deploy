# Configuring interoperability with other services

This playbook tries to get you up and running with minimal effort - installing all required services (Nextcloud, Postgres, [Traefik](https://traefik.io), etc).

Sometimes, you're using a server to host multiple services. In such cases these are undesirable:

- this playbook overtaking your whole server (more specifically ports `tcp/80` and `tcp/443`) with its own Traefik instance

- multiple playbooks trying to install Docker, etc.

Below, we offer some suggestions for how to make this playbook more interoperable. Feel free to cherry-pick the parts that make sense for your set up.


## Disabling Traefik installation

If you're installing [Traefik](https://traefik.io) on your server in another way:

```yaml
# Tell the playbook you're using Traefik installed in another way.
# It won't bother installing Traefik.
nextcloud_playbook_reverse_proxy_type: other-traefik-container

# Tell the playbook to attach services which require reverse-proxying to an additional network by default (e.g. traefik)
# This needs to match your Traefik network.
nextcloud_playbook_reverse_proxyable_services_additional_network: traefik
```

All services will have container labels attached, so that a Traefik instance can reverse-proxy to them. See `roles/custom/nextcloud_reverse_proxy_companion/templates/labels.j2` for an example.

Also, refer to the [configuring the reverse-proxy](configuring-playbook-reverse-proxy.md) documentation page for more information.


## Disabling Docker installation

If you're installing [Docker](https://www.docker.com/) on your server in another way, disable this component from the playbook:

```yaml
nextcloud_playbook_docker_installation_enabled: false
```


## Disabling Postgres installation

If you're installing [PostgreSQL](https://www.postgresql.org/) on your server in another way or wish to use an external Postgres server or another type of database, disable this component from the playbook:

```yaml
nextcloud_playbook_postgres_installation_enabled: false
```

Also, refer to the [configuring the database](configuring-playbook-database.md) documentation page for more information on using another database.


## Disabling timesyncing (systemd-timesyncd / ntp) installation

If you're installing `systemd-timesyncd` or `ntp` on your server in another way, disable this component from the playbook:

```yaml
devture_timesync_installation_enabled: false
```
