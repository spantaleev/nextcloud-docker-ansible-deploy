# Configuring the database

By default, this playbook installs Postgres in a container alongside Nextcloud.

To use your own Postgres server, use a `vars.yml` configuration like this:

```yaml
# Disable the integrated Postgres service
nextcloud_playbook_postgres_installation_enabled: false

# Uncomment and possibly change this, if you'd like to use another database engine.
# nextcloud_nextcloud_database_type: postgres

# Fill these out
nextcloud_nextcloud_database_hostname: ''
nextcloud_nextcloud_database_port: 5432
nextcloud_nextcloud_database_name: nextcloud
nextcloud_nextcloud_database_username: ''
nextcloud_nextcloud_database_password: ''
```
