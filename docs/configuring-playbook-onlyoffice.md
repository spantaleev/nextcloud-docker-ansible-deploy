# Setting up OnlyOffice integration

To install the [OnlyOffice](https://www.onlyoffice.com/) document-editing services, enable it like this in your configuration file (`inventory/<your-domain>/vars.yml`).

```yaml
nextcloud_onlyoffice_enabled: true
```

If you had already installed Nextcloud, you'll need to re-run the [installation](installing.md) procedure and restart the services.

In any case, once Nextcloud is fully installed (**don't forget** that there are some manual steps [after installing](installing.md) with the playbook),
you can also install and configure the [OnlyOffice app for Nextcloud](https://apps.nextcloud.com/apps/onlyoffice) by running this command:

```bash
ansible-playbook -i inventory/hosts setup.yml --tags=setup-onlyoffice-app
```

The above only does basic configuration, hooking your OnlyOffice document server with Nextcloud.
The OnlyOffice app for Nextcloud supports additional options, which you can configure manually from: **Settings** -> **ONLYOFFICE**.