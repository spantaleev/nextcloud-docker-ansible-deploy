# Prerequisites

- **CentOS** (7.0+) or Rockylinux / AlmaLinux, **Debian** (9/Stretch+ -- untested) or **Ubuntu** (16.04+ -- untested) server. This playbook can take over your whole server or [co-exist with other services](configuring-playbook-interoperability.md) that you have there.

- `root` access to your server (or a user capable of elevating to `root` via `sudo`).

- [Python](https://www.python.org/) being installed on the server. Most distributions install Python by default, but some don't

- the [Ansible](http://ansible.com/) program being installed on your own computer. It's used to run this playbook and configures your server for you

- [`git`](https://git-scm.com/) is the recommended way to [download the playbook](getting-the-playbook.md) to your computer

- Properly configured DNS records for `<your-domain>` (details in [Configuring DNS](configuring-dns.md)).

- `nextcloud.<your-domain>` domain name pointing to your new server - this is where the Nextcloud server will live

- Some TCP ports open. This playbook (actually [Docker itself](https://docs.docker.com/network/iptables/)) configures the server's internal firewall for you. In most cases, you don't need to do anything special. But **if your server is running behind another firewall**, you'd need to open these ports:

  - `80/tcp`: HTTP webserver
  - `443/tcp`: HTTPS webserver

This playbook somewhat supports running on non-`amd64` architectures like ARM. See [Alternative Architectures](alternative-architectures.md).

When ready to proceed, continue with [Configuring DNS](configuring-dns.md).
