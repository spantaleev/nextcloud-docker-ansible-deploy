# Nextcloud (A safe home for all your data) server setup using Ansible and Docker

## Purpose

This Ansible playbook is meant to easily let you run your own [Nextcloud](https://nextcloud.com/) server.

Using this playbook, you can get the following services configured on your server:

- a [Nextcloud](https://nextcloud.com/) server - storing your data

- a [PostgreSQL](https://www.postgresql.org/) database for Nextcloud - providing better performance than the default [SQLite](https://sqlite.org/) database

- free [Let's Encrypt](https://letsencrypt.org/) SSL certificate, which secures the connection to the Nextcloud server

Basically, this playbook aims to get you up-and-running with all the basic necessities around Nextcloud, without you having to do anything else.


## Prerequisites

- **CentOS server** with no services running on port 80/443 (making this run on non-CentOS servers should be possible in the future)

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


## Deficiencies

This Ansible playbook can be improved in the following ways:

- setting up automatic backups to one or more storage providers
