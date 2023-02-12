# Configuring the reverse-proxy

By default, this playbook installs its own [Traefik](https://traefik.io/) webserver (in a Docker container) which listens on ports 80 and 443.
If that's alright, you can skip this.

## Introduction

The default flow is like this: (Traefik installed by this playbook -> `nextcloud-reverse-proxy-companion` -> `nextcloud-apache`).

If you don't want this playbook's Traefik webserver to take over your server's 80/443 ports like that,
and you'd like to use your own webserver (be it your own Traefik installed in another way, nginx, Apache, Varnish Cache, etc.), you can.

Whichever reverse-proxy you decide on using, we recommend that you keep the last part the same (`nextcloud-reverse-proxy-companion` -> `nextcloud-apache`) the same.

## Reverse-proxy type

To control the playbook's reverse-proxy integration use `nextcloud_playbook_reverse_proxy_type` variable, which controls the type of reverse-proxy that the playbook will use. Valid values:

  - `playbook-managed-traefik` (the default)
  - `playbook-managed-nginx`, see [Using nextcloud-nginx-proxy for SSL termination](#using-nextcloud-nginx-proxy-for-ssl-termination)
  - `other-traefik-container`, see [Using your own Traefik server (installed separately)](#using-your-own-traefik-server-installed-separately)
  - `other-nginx-non-container`, see [Using nextcloud-nginx-proxy to generate configuration for your own, other, nginx proxy](#using-nextcloud-nginx-proxy-to-generate-configuration-for-your-own-other-nginx-proxy)
  - `none`

Learn more about these values and their behavior from [roles/custom/base/defaults/main.yml](../roles/custom/base/defaults/main.yml)

## Other variables of interest

The variables below are **automatically set** based on the reverse-proxy type (`nextcloud_playbook_reverse_proxy_type`). Nevertheless, you may find them useful if you need to do something more advanced.

- `devture_traefik_enabled` (same as `nextcloud_playbook_traefik_role_enabled` by default - `true`) - controls whether the Traefik role's functionality is enabled or not. If disabled, the role will try to uninstall Traefik, etc. Flipping this to `false` disables Traefik, but also potentially uninstalls and deletes data in `/devture-traefik`.

- `nextcloud_playbook_traefik_role_enabled` (default `true`) - controls whether the Traefik role will execute or not. Setting this to `false` disables Traefik and doesn't touch `/devture-traefik` (which is potentially managed by another playbook)

- `nextcloud_playbook_traefik_labels_enabled` (default `true`) - controls whether Traefik container labels are attached to services. You may disable Traefik with the variables above, yet still keep attaching labels, so that a separately-installed Traefik instance can reverse-proxy to these services. If you're not using Traefik at all, flip this to `false`

- `nextcloud_playbook_reverse_proxyable_services_additional_network` (default `traefik`) - additional container network for reverse-proxyable services (like `nextcloud-reverse-proxy-companion`). We default these to the `traefik` network for the default Traefik installation's benefit, but you can set this to another network


## Examples

### Using your own Traefik server (installed separately)

If you'd like to avoid the playbook installing its own Traefik server and instead use your own, use this configuration:

```yaml
nextcloud_playbook_reverse_proxy_type: other-traefik-container
# Specify the name of your Traefik network here
nextcloud_playbook_reverse_proxyable_services_additional_network: traefik
```

All services will have container labels attached, so that a Traefik instance can reverse-proxy to them.


### Using Traefik in local-only mode

Below is an example of **putting Traefik in local-only mode** (no SSL termination) and letting you use another SSL-terminating reverse-proxy in front:

```yaml
# We keep the default reverse-proxy type
# nextcloud_playbook_reverse_proxy_type: playbook-managed-traefik

# We disable Traefik's web-secure endpoint, which will disable SSL certificate retrieval and http-to-https redirection
devture_traefik_config_entrypoint_web_secure_enabled: false
```

You can now reverse-proxy to port `80` where Traefik handles domains for all services managed by the playbook (Nextcloud and potentially others, if enabled).


### Disabling Traefik and reverse-proxying manually


Below is an example of **disabling Traefik completely** and letting you reverse-proxy using other means:

```yaml
nextcloud_playbook_reverse_proxy_type: none

# Optionally, you can still attach services to some additional network
# so that your reverse-proxy (potentially running there) can reach these services
nextcloud_playbook_reverse_proxyable_services_additional_network: network-name-of-the-other-reverse-proxy

# Alternatively:
# Expose the nextcloud-reverse-proxy-companion container's webserver to port 37150 on the loopback network interface only.
# You can reverse-proxy to it using a locally running webserver.
nextcloud_reverse_proxy_companion_http_bind_port: '127.0.0.1:37150'

# Or:
# Expose the nextcloud-reverse-proxy-companion container's webserver to port 37150 on all network interfaces.
# You can reverse-proxy to it from another machine on the public or private network.
# nextcloud_reverse_proxy_companion_http_bind_port: '37150'
```

You can now reverse-proxy to port `37150` for Nextcloud. If you need to expose other services managed by this playbook, you'd need to expose them the same way (`_bind_port` variables) manually.

Make sure to add proxy headers appropriately. If you use nginx the following configuration should get you started:

```
proxy_set_header Host $host;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```


### Using nginx

#### Using nextcloud-nginx-proxy for SSL termination

To disable Traefik and use `nextcloud-nginx-proxy` instead, use the following configuration:

```yaml
nextcloud_playbook_reverse_proxy_type: playbook-managed-nginx
```

This will disable all Traefik integration, uninstall Traefik and install `nextcloud-nginx-proxy` in its place. Nginx will terminate SSL automatically via SSL certificates obtained using Certbot.

The flow would be: (`nextcloud-nginx-proxy` -> `nextcloud-reverse-proxy-companion` -> `nextcloud-apache`).

If you'd like to provide your own certifiates, consider tweaking `nextcloud_nginx_proxy_ssl_retrieval_method`, etc.


#### Using nextcloud-nginx-proxy to generate configuration for your own, other, nginx proxy

You can also make use of the `nextcloud-nginx-proxy` role to retrieve SSL certificates and generate *some* configuration, which you later plug into your own nginx server running on the host.

All it takes is:

1) making sure your web server user (something like `http`, `apache`, `www-data`, `nginx`) is part of the `nextcloud` group. You should run something like this: `usermod -a -G nextcloud nginx`

2) editing your configuration file (`inventory/nextcloud.<your-domain>/vars.yml`):

To do this, use the following configuration:

```yaml
nextcloud_playbook_reverse_proxy_type: other-nginx-non-container
```

**Note**: even if you do this, in order [to install](installing.md), this playbook still expects port 80 to be available. **Please manually stop your other webserver while installing**. You can start it back again afterwards.

**If your own webserver is nginx**, you can most likely directly use the config files installed by this playbook at: `/nextcloud/nginx-proxy/conf.d`. Just include them in your `nginx.conf` like this: `include /nextcloud/nginx-proxy/conf.d/*.conf;`

**If your own webserver is not nginx**, you can still take a look at the sample files in `/nextcloud/nginx-proxy/conf.d`, and:

- ensure you set up a vhost that proxies to Nextcloud (`localhost:37150`)

- ensure that the `/.well-known/acme-challenge` location for the "port=80 vhost" gets proxied to `http://localhost:2403` (controlled by `nextcloud_nginx_proxy_ssl_certbot_standalone_http_port`) for automated SSL renewal to work

- ensure that you restart/reload your webserver once in a while, so that renewed SSL certificates would take effect (once a month should be enough)
