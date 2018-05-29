# Nextcloud (A safe home for all your data) server setup using Ansible and Docker

## Purpose

This Ansible playbook is meant to easily let you run your own [Nextcloud](https://nextcloud.com/) server.

Using this playbook, you can get the following services configured on your server:

- a [Nextcloud](https://nextcloud.com/) server - storing your data

- (optional) [Amazon S3](https://aws.amazon.com/s3/) remote storage for your Nextcloud data using [Goofys](https://github.com/kahing/goofys)

- a [PostgreSQL](https://www.postgresql.org/) database for Nextcloud - providing better performance than the default [SQLite](https://sqlite.org/) database

- free [Let's Encrypt](https://letsencrypt.org/) SSL certificate, which secures the connection to the Nextcloud server

Basically, this playbook aims to get you up-and-running with all the basic necessities around Nextcloud, without you having to do anything else.


## Prerequisites


- **CentOS** (7.0+), **Debian** (9/Stretch+ -- untested) or **Ubuntu** (16.04+ -- untested) server. This playbook can take over your whole server or co-exist with other services that you have there.

- the [Ansible](http://ansible.com/) program, which is used to run this playbook and configures everything for you

- `<your-domain>` domain name pointing to your new server - this is where the Nextcloud server will live

- some TCP/UDP ports open. This playbook configures the server's internal firewall for you. In most cases, you don't need to do anything special. But **if your server is running behind another firewall**, you'd need to open these ports: `80/tcp` (HTTP webserver), `443/tcp` (HTTPS webserver).


## Configuration

Before [installation](#installing), you need to configure this playbook, so that it knows what to install and where.

You can follow these steps:

- create a directory to hold your configuration (`mkdir inventory/<your-domain>`)

- copy the sample configuration file (`cp examples/host-vars.yml inventory/<your-domain>/vars.yml`)

- edit the configuration file (`inventory/<your-domain>/vars.yml`) to your liking

- copy the sample inventory hosts file (`cp examples/hosts inventory/hosts`)

- edit the inventory hosts file (`inventory/hosts`) to your liking


## Using your own webserver, instead of this playbook's nginx proxy (optional)

By default, this playbook installs its own nginx webserver (in a Docker container) which listens on ports 80 and 443.
If that's alright, you can skip ahead.

If you don't want this playbook's nginx webserver to take over your server's 80/443 ports like that,
and you'd like to use your own webserver (be it nginx, Apache, Varnish Cache, etc.), you can.

All it takes is editing your configuration file (`inventory/<your-domain>/vars.yml`):

```
nextcloud_nginx_proxy_enabled: false
```

**Note**: even if you do this, in order [to install](#installing), this playbook still expects port 80 to be available. **Please manually stop your other webserver while installing**. You can start it back again afterwards.

**If your own webserver is nginx**, you can most likely directly use the config files installed by this playbook at: `/nextcloud/nginx-proxy/conf.d`. Just include them in your `nginx.conf` like this: `include /nextcloud/nginx-proxy/conf.d/*.conf;`

**If your own webserver is not nginx**, you can still take a look at the sample files in `/nextcloud/nginx-proxy/conf.d`, and:

- ensure you set up a vhost that proxies to Nextcloud (`localhost:31750`)

- ensure that the `/.well-known/acme-challenge` location for the "port=80 vhost" is an alias to the `/nextcloud/ssl/run/acme-challenge` directory (for automated SSL renewal to work)

- ensure that you restart/reload your webserver once in a while, so that renewed SSL certificates would take effect (once a month should be enough)


## Installing

To make use of this playbook, you should invoke the `setup.yml` playbook multiple times, with different tags.


### Configuring a server

Run this as-is to set up a server.
This doesn't start any services just yet (another step does this later - below).
Feel free to re-run this any time you think something is off with the server configuration.

	ansible-playbook -i inventory/hosts setup.yml --tags=setup-main


### Starting the services

Run this as-is to start all the services and to ensure they'll run on system startup later on.

	ansible-playbook -i inventory/hosts setup.yml --tags=start


### Initial Nextcloud configuration

After [starting the services](#starting-the-services) for the first time, you should
follow Nextcloud's setup wizard at `https://<your-domain>`.

You can choose any username/password for your account.

In **Storage & database**, you should choose PostgreSQL, with the following settings:

- Database user: `nextcloud`
- Database password: `nextcloud-password`
- Database name: `nextcloud`
- Database host: `postgres:5432`

The database is strictly local, so using the default username/password is OK.


### Adjusting the configuration

Once you've fully installed Nextcloud, you'd better edit its default configuration.

This is necessary, because Nextcloud's brute-force security system doesn't like how traffic is being proxied to it
(this playbook fronts the `nextcloud` Apache image with an nginx proxy server).

Thus, we disable Nextcloud's bruteforce security system:

	ansible-playbook -i inventory/hosts setup.yml --tags=setup-adjust-config


## Amazon S3 configuration (optional)

Nextcloud supports external storage natively and can connect to Amazon S3 and many others.
Unfortunately, as of this moment (currently at version 12.0.3 at the time of this writing),
its external storage support suffers from:

- being unable to create folders on Amazon S3 external storage mountpoints
- being unbearably slow

To avoid this problem, what this playbook does is mount some Amazon S3 bucket as a local directory using [Goofys](https://github.com/kahing/goofys).

It makes this bucket avaialble as a local directory

You'll need an Amazon S3 bucket and some IAM user credentials (access key + secret key) with full write access to the bucket. Example security policy:

```json
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "Stmt1400105486000",
			"Effect": "Allow",
			"Action": [
				"s3:*"
			],
			"Resource": [
				"arn:aws:s3:::your-bucket-name",
				"arn:aws:s3:::your-bucket-name/*"
			]
		}
	]
}
```

You then need to enable S3 support in your configuration file (`inventory/<your-domain>/vars.yml`).
It would be something like this:

```yaml
nextcloud_goofys_external_storage_enabled: true
nextcloud_goofys_external_storage_bucket_name: "your-bucket-name"
nextcloud_goofys_external_storage_aws_access_key: "your-aws-access-key"
nextcloud_goofys_external_storage_aws_secret_key: "your-aws-secret-key"
nextcloud_goofys_external_storage_region: eu-west-3
```

To also store your appdata's `preview` directory there, you need to find your instance id (can happen when running `cat /nextcloud/nextcloud-data/config/config.php | grep instanceid` **after** installing) and add this additional configuration:

```yaml
nextcloud_goofys_external_storage_for_appdata_previews_enabled: true
nextcloud_goofys_external_storage_for_appdata_previews_instance_id: "your-instance-id-goes-here"
```

This storage is available on both your server and within the Nextcloud container via the `/nextcloud/external-storage/goofys` directory.

Once this common part is done, you can dedicate a separate sub-directory from it to each of your users.
This way, all users would be sharing the same S3 bucket, but won't be able to see each other's files.

To prepare it for a new user:

```
user_directory=/nextcloud/external-storage/goofys/<username>
docker exec nextcloud-apache su -s /bin/sh -c "mkdir $user_directory" www-data
```

Since the S3 bucket appears as a local directory on our filesystem, the **Local** type of External Storage must be used, which is only available through the "global External Storage" configuration (Admin -> External Storages).

Once the user-specific sub-directory is prepared, you can add (mount) it from (Admin -> External Storages) with the following options:

- Folder name: a friendly name that the user would see (example: `s3-<username>`)
- External storage type: Local
- Configuration: the user-specific sub-directory you had prepared above (example: `/nextcloud/external-storage/goofys/<username>`)
- Available for: select the user that the directory is for (otherwise it's availale to everyone)

**Note**: if you add/remove remote S3 files manually from `/nextcloud/external-storage/goofys/<username>` on the server or by some S3 tool, Nextcloud would not catch the change. You'd need to run `docker exec nextcloud-apache su - www-data -s /bin/bash -c 'php /var/www/html/occ files:scan <username>'` or go to (Admin -> External Storages) and delete & recreate the Folder definition.


### Upgrading Postgres

If you're not using an external Postgres server, this playbook initially installs Postgres for you.

Once installed like that, this playbook attempts to preserve the Postgres version it starts with.
This is because newer Postgres versions cannot start with data generated by an older Postgres version.
An upgrade must be performed.

This playbook can upgrade your existing Postgres setup with the following command:

	ansible-playbook -i inventory/hosts setup.yml --tags=upgrade-postgres

**The old Postgres data directory is backed up** (by renaming to `/nextcloud/postgres-auto-upgrade-backup`).
It stays around forever, until you **manually decide to delete it**.

As part of the upgrade, the database is dumped to `/tmp`, upgraded and then restored from that dump.
To use a different directory, pass some extra flags to the command above, like this: `--extra-vars="postgres_dump_dir=/directory/to/dump/here"`

**ONLY one database is migrated** (the one specified in `nextcloud_postgres_db_name`, named `nextcloud` by default).
If you've created other databases in that database instance (something this playbook never does and never advises), data will be lost.


## Deficiencies

This Ansible playbook can be improved in the following ways:

- setting up automatic backups to one or more storage providers
