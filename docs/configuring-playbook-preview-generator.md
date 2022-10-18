# Setting up preview generator
To install [Preview Generator](https://github.com/nextcloud/previewgenerator) first you need to setup your Nextcloud instance. When finisehd, enable it in your configuration file (`inventory/host_vars/<your-domain>/vars.yml`) like this:

```yaml
nextcloud_previewgenerator_enabled: true
```

In any case, once Nextcloud is fully installed (**don't forget** that there are some manual steps [after installing](installing.md) with the playbook),
you can also install and configure the [Preview Generator](https://github.com/nextcloud/previewgenerator) by running this command:

```bash
ansible-playbook -i inventory/hosts setup.yml --tags=setup-previewgenerator-app
```

***As of writting this (2021-11-01) this plugin is not supported by Nextcloud version 22 or higher, so the plugin is enabled as "Unsupported".***

## Configuration
The playbook does 2 configuration.
1) Sets some sizes for preview generation. These defaults are taken from the Github [page](https://github.com/nextcloud/previewgenerator#i-dont-want-to-generate-all-the-preview-sizes).
2) Creates systemd timers to periodically rerun the preview generation. The period is configured via the variable `nextcloud_previewgenerator_timer`. The default value is once every hour. The timer kicks in at boot if the timer missed the last calendar time. See the systemd manual for syntax, on this [link](https://www.freedesktop.org/software/systemd/man/systemd.timer.html).
