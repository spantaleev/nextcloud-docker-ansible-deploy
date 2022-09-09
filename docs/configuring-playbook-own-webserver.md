# Using your own webserver, instead of this playbook's nginx proxy (optional, advanced)

By default, this playbook installs its own nginx webserver (in a Docker container) which listens on ports 80 and 443.
If that's alright, you can skip this.

If you don't want this playbook's nginx webserver to take over your server's 80/443 ports like that,
and you'd like to use your own webserver (be it nginx, Apache, Varnish Cache, etc.), you can.

There are **2 ways you can go about it**, if you'd like to use your own webserver:

- [Using your own webserver, instead of this playbook's nginx proxy (optional, advanced)](#using-your-own-webserver-instead-of-this-playbooks-nginx-proxy-optional-advanced)
  - [Method 1: Disabling the integrated nginx reverse-proxy webserver](#method-1-disabling-the-integrated-nginx-reverse-proxy-webserver)
  - [Method 2: Fronting the integrated nginx reverse-proxy webserver with another reverse-proxy](#method-2-fronting-the-integrated-nginx-reverse-proxy-webserver-with-another-reverse-proxy)
    - [Sample configuration for running behind Traefik 2.0](#sample-configuration-for-running-behind-traefik-20)

## Method 1: Disabling the integrated nginx reverse-proxy webserver

All it takes is:

1) making sure your web server user (something like `http`, `apache`, `www-data`, `nginx`) is part of the `nextcloud` group. You should run something like this: `usermod -a -G nextcloud nginx`

2) editing your configuration file (`inventory/nextcloud.<your-domain>/vars.yml`):

```
nextcloud_nginx_proxy_enabled: false
```

**Note**: even if you do this, in order [to install](installing.md), this playbook still expects port 80 to be available. **Please manually stop your other webserver while installing**. You can start it back again afterwards.

**If your own webserver is nginx**, you can most likely directly use the config files installed by this playbook at: `/nextcloud/nginx-proxy/conf.d`. Just include them in your `nginx.conf` like this: `include /nextcloud/nginx-proxy/conf.d/*.conf;`

**If your own webserver is not nginx**, you can still take a look at the sample files in `/nextcloud/nginx-proxy/conf.d`, and:

- ensure you set up a vhost that proxies to Nextcloud (`localhost:37150`)

- ensure that the `/.well-known/acme-challenge` location for the "port=80 vhost" gets proxied to `http://localhost:2403` (controlled by `nextcloud_ssl_certbot_standalone_http_port`) for automated SSL renewal to work

- ensure that you restart/reload your webserver once in a while, so that renewed SSL certificates would take effect (once a month should be enough)

## Method 2: Fronting the integrated nginx reverse-proxy webserver with another reverse-proxy

This method is about leaving the integrated nginx reverse-proxy webserver be, but making it not get in the way (using up important ports, trying to retrieve SSL certificates, etc.).

If you wish to use another webserver, the integrated nginx reverse-proxy webserver usually gets in the way because it attempts to fetch SSL certificates and binds to ports 80 and 443.

You can disable such behavior and make the integrated nginx reverse-proxy webserver only serve traffic locally (or over a local network).

You would need some configuration like this:

### Sample configuration for running behind Traefik 2.0

Below is a sample configuration for using this playbook with a [Traefik](https://traefik.io/) 2.0 reverse proxy.

```yaml
# Disable generation and retrieval of SSL certs (Traefik will handle this)
nextcloud_ssl_retrieval_method: none

# All containers need to be on the same Docker network as Traefik
# (This network should already exist and Traefik should be using this network)
nextcloud_docker_network: 'traefik'

nextcloud_nextcloud_docker_container_extra_arguments:
  # May be unnecessary depending on Traefik config, but can't hurt
  - '--label "traefik.enable=true"'

  # The Nginx proxy container will receive traffic from these subdomains
  - '--label "traefik.http.routers.nextcloud-nginx-proxy.rule=Host(`{{ host_specific_nextcloud_hostname }}`)"'

  # (The 'web-secure' entrypoint must bind to port 443 in Traefik config)
  - '--label "traefik.http.routers.nextcloud-nginx-proxy.entrypoints=web-secure"'

  # (The 'default' certificate resolver must be defined in Traefik config)
  - '--label "traefik.http.routers.nextcloud-nginx-proxy.tls.certResolver=default"'
```

This method uses labels attached to the Nginx and Synapse containers to provide the Traefik Docker provider with the information it needs to proxy `nextcloud.DOMAIN`. Some [static configuration](https://docs.traefik.io/v2.0/reference/static-configuration/file/) is required in Traefik; namely, having endpoints on ports 443 and having a certificate resolver.

Note that this configuration on its own does **not** redirect traffic on port 80 (plain HTTP) to port 443 for HTTPS, which may cause some issues, since the built-in Nginx proxy usually does this. If you are not already doing this in Traefik, it can be added to Traefik in a [file provider](https://docs.traefik.io/v2.0/providers/file/) as follows:

```toml
[http]
  [http.routers]
    [http.routers.redirect-http]
      entrypoints = ["web"] # The 'web' entrypoint must bind to port 80
      rule = "HostRegexp(`{host:.+}`)" # Change if you don't want to redirect all hosts to HTTPS
      service = "dummy" # Unused, but all routers need services (for now)
      middlewares = ["https"]
  [http.services]
    [http.services.dummy.loadbalancer]
      [[http.services.dummy.loadbalancer.servers]]
        url = "localhost"
  [http.middlewares]
    [http.middlewares.https.redirectscheme]
      scheme = "https"
      permanent = true
```

You can use the following `docker-compose.yml` as example to launch Traefik.

```yaml
version: "3.3"

services:

  traefik:
    image: "traefik:v2.8"
    restart: always
    container_name: "traefik"
    networks:
      - traefik
    command:
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.network=traefik"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web-secure.address=:443"
      - "--certificatesresolvers.default.acme.tlschallenge=true"
      - "--certificatesresolvers.default.acme.email=YOUR EMAIL"
      - "--certificatesresolvers.default.acme.storage=/letsencrypt/acme.json"
    ports:
      - "443:443"
    volumes:
      - "./letsencrypt:/letsencrypt"
      - "/var/run/docker.sock:/var/run/docker.sock:ro"

networks:
  traefik:
    external: true
```
