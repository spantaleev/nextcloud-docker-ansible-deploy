# Installing

After [configuring DNS](configuring-dns.md) and [configuring the playbook](configuring-playbook.md), you're ready to install.

**Before installing** and each time you update the playbook in the future, you will need to update the Ansible roles in this playbook by running `just roles`. `just roles` is a shortcut (a `roles` target defined in [`justfile`](justfile) and executed by the [`just`](https://github.com/casey/just) utility) which ultimately runs [ansible-galaxy](https://docs.ansible.com/ansible/latest/cli/ansible-galaxy.html) to download Ansible roles. If you don't have `just`, you can also manually run the `roles` commands seen in the `justfile`.


## Playbook tags introduction

The Ansible playbook's tasks are tagged, so that certain parts of the Ansible playbook can be run without running all other tasks.

The general command syntax is: `ansible-playbook -i inventory/hosts setup.yml --tags=COMMA_SEPARATED_TAGS_GO_HERE`

Here are some playbook tags that you should be familiar with:

- `setup-all` - runs all setup tasks (installation and uninstallation) for all components, but does not start/restart services

- `install-all` - like `setup-all`, but skips uninstallation tasks. Useful for maintaining your setup quickly when its components remain unchanged. If you adjust your `vars.yml` to remove components, you'd need to run `setup-all` though, or these components will still remain installed

- `setup-postgres` (e.g. `setup-postgres`) - runs the setup tasks only for a given role, but does not start/restart services. You can discover these additional tags in each role (`roles/*/main.yml`). Running per-component setup tasks is **not recommended**, as components sometimes depend on each other

- `install-SERVICE` (e.g. `install-postgres`) - like `setup-SERVICE`, but skips uninstallation tasks. See `install-all` above for additional information.

- `start` - starts all systemd services and makes them start automatically in the future

- `stop` - stops all systemd services

`setup-*` tags and `install-*` tags **do not start services** automatically, because you may wish to do things before starting services, such as importing a database dump, restoring data from another server, etc.


## Installation

Run the playbook: `ansible-playbook -i inventory/hosts setup.yml --tags=setup-all`.

If your inventory file (`vars.yml`) contains encrypted variables, you may need to pass `--ask-vault-pass` to the `ansible-playbook` command.

After installing, you can start services with `just start-all` (or `ansible-playbook -i inventory/hosts setup.yml --tags=start`).


## Initial Nextcloud setup

After starting the services for the first time, you should follow Nextcloud's setup wizard at `https://<your-domain>`.

You can choose any username/password for your account.

In **Storage & database**, you should choose PostgreSQL (changing the default **SQLite** choice), with the following settings:

- Database user: `nextcloud`
- Database password: the value of the `nextcloud_nextcloud_database_password` variable in `vars.yml`
- Database name: `nextcloud`
- Database host: `nextcloud-postgres:5432`


## Adjusting the configuration

Once you've fully installed Nextcloud, you'd better edit its default configuration.

This is necessary, because Nextcloud's brute-force security system doesn't like how traffic is being proxied to it
(this playbook fronts the `nextcloud` Apache image with an nginx proxy server).

Thus, we disable Nextcloud's bruteforce security system:

```bash
ansible-playbook -i inventory/hosts setup.yml --tags=setup-adjust-nextcloud-config
```
