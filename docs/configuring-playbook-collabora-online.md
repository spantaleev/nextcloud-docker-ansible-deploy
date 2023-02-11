# Setting up Collabora Online integration

The following configuration enables you to install the [Collabora Online Development Edition (CODE)](https://www.collaboraoffice.com/) office suite.

Together with the [Nextcloud Office App](https://apps.nextcloud.com/apps/richdocuments), it enables you to edit office documents online. This version is more performant than the [CODE App](https://apps.nextcloud.com/apps/richdocumentscode).

The document server will run under a different domain than your Nextcloud.


## Configuring the playbook

Enable Collabora Online like this in your configuration file (`inventory/host_vars/<your-domain>/vars.yml`):

```yaml
nextcloud_collabora_online_enabled: true

nextcloud_collabora_online_domain: collabora.yourdomain.org

# A password for the admin interface, available at: https://COLLABORA_ONLINE_DOMAIN/browser/dist/admin/admin.html
nextcloud_collabora_online_env_variable_password: 'verystrongpassword'
```


## DNS configuration

You'd need to create a DNS record for the Collabora domain defined in `nextcloud_collabora_online_domain`.

You can make it a `CNAME` record pointing to your Nextcloud domain.


## Installing

If you had already installed Nextcloud, you'll need to re-run the [installation](installing.md) procedure and restart the services.

In any case, once Nextcloud is fully installed (**don't forget** that there are some manual steps [after installing](installing.md) with the playbook),
you can also install and configure the [Nextcloud Office app](https://apps.nextcloud.com/apps/richdocuments) by running this command:

```bash
ansible-playbook -i inventory/hosts setup.yml --tags=setup-collabora-app
```

If you later need to change a setting (e.g. `nextcloud_collabora_online_woip_allowlist`) run 

```bash
ansible-playbook -i inventory/hosts setup.yml --tags=configure-collabora-app
```

You could also install the app manually via the Apps menu (search for **Nextcloud Office**). After installing the
application, you connect Nextcloud to your Collabora Online server by going to
**Administration Settings** -> **Nextcloud Office** and setting:

- **Use your own server** and specifying the address (e.g. `https://collabora.yourdomain.org`). Refer to your `nextcloud_collabora_online_domain` variable
- Setting **Allow list for WOPI requests** to the container network's address range (e.g. `172.19.0.0/16`). To find your container network's range, SSH into the server and run this command: `docker network inspect nextcloud --format '{{ (index .IPAM.Config 0).Subnet }}'`. This is done for security reasons described [here](https://docs.nextcloud.com/server/latest/admin_manual/office/configuration.html#wopi-settings)

## Usage

Open any document (`.doc`, `.odt`, etc.) in Nextcloud Files and it should automatically open a Collabora Online editor.

You can also create new documents via the "plus" button.


## Admin Interface

There's an admin interface with various statistics and information at: `https://COLLABORA_ONLINE_DOMAIN/browser/dist/admin/admin.html`

Use your admin credentials for logging in:

- the default username is `admin`, as specified in `nextcloud_collabora_online_env_variable_username`
- the password is the one you've specified in `nextcloud_collabora_online_env_variable_password`


## Reverse Proxy Configuration

If you're using the Traefik or nginx reverse proxies integrated with this playbook (by default, you are), you don't need do read this section.

If you want to **use an external reverse proxy** (not managed by this playbook) you should set the `nextcloud_collabora_online_container_http_host_bind_port` variable in your `vars.yml`

```
# Controls whether the collabora container exposes its HTTP port (tcp/9980 in the container).
# Takes an "<ip>:<port>" or "<port>" value (e.g. "127.0.0.1:9980), or empty string to not expose.
nextcloud_collabora_online_container_http_host_bind_port: "127.0.0.1:9980"
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
