# Getting the playbook

This Ansible playbook is meant to be executed on your own computer (not the Nextcloud server).

In special cases (if your computer cannot run Ansible, etc.) you may put the playbook on the server as well.

You can retrieve the playbook's source code by:

- [Using git to get the playbook](#using-git-to-get-the-playbook) (recommended)

- [Downloading the playbook as a ZIP archive](#downloading-the-playbook-as-a-zip-archive) (not recommended)


## Using git to get the playbook

We recommend using the [git](https://git-scm.com/) tool to get the playbook's source code.

Once you've installed git on your computer, you can go to any directory of your choosing and run the following command to retrieve the playbook's source code:

```bash
git clone https://github.com/spantaleev/nextcloud-docker-ansible-deploy.git
```

This will create a new `nextcloud-docker-ansible-deploy` directory.
You're supposed to execute all other installation commands inside that directory.


## Downloading the playbook as a ZIP archive

Alternatively, you can download the playbook as a ZIP archive.

The latest version is always at the following URL: https://github.com/spantaleev/nextcloud-docker-ansible-deploy/archive/master.zip

You can extract this archive anywhere. You'll get a directory called `nextcloud-docker-ansible-deploy`.
You're supposed to execute all other installation commands inside that directory.


---------------------------------------------

No matter which method you've used to download the playbook, you can proceed by [Configuring the playbook](configuring-playbook.md).
