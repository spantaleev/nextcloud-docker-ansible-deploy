# Prerequisites

- **CentOS** (7.0+), **Debian** (9/Stretch+ -- untested) or **Ubuntu** (16.04+ -- untested) server. This playbook can take over your whole server or co-exist with other services that you have there.

- [Python](https://www.python.org/) being installed on the server. Most distributions install Python by default, but some don't (e.g. Ubuntu 18.04) and require manual installation (something like `apt-get install python`).

- the [Ansible](http://ansible.com/) program being installed on your own computer. It's used to run this playbook and configures your server for you

- `nextcloud.<your-domain>` domain name pointing to your new server - this is where the Nextcloud server will live

- some TCP/UDP ports open. This playbook configures the server's internal firewall for you. In most cases, you don't need to do anything special. But **if your server is running behind another firewall**, you'd need to open these ports: `80/tcp` (HTTP webserver), `443/tcp` (HTTPS webserver).