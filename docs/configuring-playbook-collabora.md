# Setting up Collabora integration

**WARNING**: Work in progress - Currently only external reverse proxy supported.

The following configuration enables you to install the [Collabora Online Development Edition (CODE)](https://www.collaboraoffice.com/) document server.
You will have a fully functioning [WOIP server]() that (together with the [Nextcloud Office App](https://apps.nextcloud.com/apps/richdocuments)) enables you to
edit office documents online. This version is more performant than the [CODE App](https://apps.nextcloud.com/apps/richdocumentscode).

The document server will run under a different domain than your Nextcloud.

## `vars.yml` configuration

Enable the server like this in your configuration file (`inventory/host_vars/<your-domain>/vars.yml`) and set a password
for the admin interface.

```yaml
nextcloud_collabora_online_enabled: true
nextcloud_collabora_document_server_domain: collabora.yourdomain.org
nextcloud_collabora_online_env_variable_password: 'lHAbqkYapmelxLWFqjrYS3v9RQtIzQbWrvs'
```


## DNS configuration

You'd need to create a DNS record for the Collabora domain defined in `nextcloud_collabora_document_server_domain`.

You can make it a `CNAME` record pointing to your Nextcloud domain.


## Installing

If you had already installed Nextcloud, you'll need to re-run the [installation](installing.md) procedure and restart the services.

In any case, once Nextcloud is fully installed (**don't forget** that there are some manual steps [after installing](installing.md) with the playbook),
you can also install and configure the [Nextcloud Office app](https://apps.nextcloud.com/apps/richdocuments) by running this command:

```bash
ansible-playbook -i inventory/hosts setup.yml --tags=setup-collabora-app
```

The above only does basic configuration, hooking your Collabora document server with Nextcloud.
The Nextcloud office app supports additional options, which you can configure manually from: **Administration Settings** -> **Office**.

For security reasons you should set the `Allow list for WOPI requests` to match the IP of your server. Read more under [here](https://docs.nextcloud.com/server/latest/admin_manual/office/configuration.html#wopi-settings)


## Reverse Proxy Configuration

If you want to use an external reverse proxy (not managed by this playbook) you should set the `nextcloud_collabora_document_server_container_http_host_bind_port` variable in your `vars.yml`

```
# Controls whether the collabora container exposes its HTTP port (tcp/9980 in the container).
# Takes an "<ip>:<port>" or "<port>" value (e.g. "127.0.0.1:9980), or empty string to not expose.
nextcloud_collabora_document_server_container_http_host_bind_port: "127.0.0.1:9980"
```

If you use an external reverse proxy you have to configure it correctly. Here is an example of a working nginx configuration.

```
server {
    if ($scheme = http) {
            return 301 https://$server_name$request_uri;
    }

    listen 443 ssl;
    listen [::]:443 ssl;
    ssl_certificate /etc/letsencrypt/live/collabora.example.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/collabora.example.com/privkey.pem; # managed by Certbot
    ssl_protocols       TLSv1 TLSv1.1;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    # Set header
    add_header X-Clacks-Overhead "GNU Terry Pratchett";

    server_name collabora.example.com;

    # static files
    location ^~ /browser {
        proxy_pass https://127.0.0.1:9980;
        proxy_set_header Host $http_host;
    }

    # WOPI discovery URL
    location ^~ /hosting/discovery {
        proxy_pass https://127.0.0.1:9980;
        proxy_set_header Host $http_host;
    }

    # Capabilities
    location ^~ /hosting/capabilities {
        proxy_pass https://127.0.0.1:9980;
        proxy_set_header Host $http_host;
    }

    # main websocket
    location ~ ^/cool/(.*)/ws$ {
        proxy_pass https://127.0.0.1:9980;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $http_host;
        proxy_read_timeout 36000s;
    }



    # download, presentation and image upload
    location ~ ^/(c|l)ool {
        proxy_pass https://127.0.0.1:9980;
        proxy_set_header Host $http_host;
    }



    # Admin Console websocket
    location ^~ /cool/adminws {
        proxy_pass https://127.0.0.1:9980;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $http_host;
        proxy_read_timeout 36000s;
    }
}

server {
    if ($host = collabora.example.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    listen 80;
    listen [::]:80;

    server_name collabora.example.com;
    return 404; # managed by Certbot
}
```
