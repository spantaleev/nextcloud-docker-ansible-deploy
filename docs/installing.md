# Installing

If you've [configured the playbook](configuring-playbook.md), you can start the installation procedure.

Run this as-is to set up a server:

```bash
ansible-playbook -i inventory/hosts setup.yml --tags=setup-all
```

This **doesn't start any services just yet** (another step does this later - below).

Feel free to **re-run this any time** you think something is off with the server configuration.


## Starting the services

When you're ready to start the Nextcloud services (and set them up to auto-start in the future):

```bash
ansible-playbook -i inventory/hosts setup.yml --tags=start
```


## Initial Nextcloud configuration

After starting the services for the first time, you should
follow Nextcloud's setup wizard at `https://<your-domain>`.

You can choose any username/password for your account.

In **Storage & database**, you should choose PostgreSQL, with the following settings:

- Database user: `nextcloud`
- Database password: `nextcloud-password`
- Database name: `nextcloud`
- Database host: `nextcloud-postgres:5432`

The database is strictly local, so using the default username/password is OK.


## Adjusting the configuration

Once you've fully installed Nextcloud, you'd better edit its default configuration.

This is necessary, because Nextcloud's brute-force security system doesn't like how traffic is being proxied to it
(this playbook fronts the `nextcloud` Apache image with an nginx proxy server).

Thus, we disable Nextcloud's bruteforce security system:

```bash
ansible-playbook -i inventory/hosts setup.yml --tags=setup-adjust-config
```