# Installing

After [configuring DNS](configuring-dns.md) and [configuring the playbook](configuring-playbook.md), you're ready to install.

First, update the Ansible roles in this playbook by running `make roles`.

Then, run the playbook: `ansible-playbook -i inventory/hosts setup.yml --tags=setup-all`.

If your inventory file (`vars.yml`) contains encrypted variables, you may need to pass `--ask-vault-pass` to the `ansible-playbook` command.

After installing, you can start services: `ansible-playbook -i inventory/hosts setup.yml --tags=start`.


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
