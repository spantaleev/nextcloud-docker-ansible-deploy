# Uninstalling

**Note**: If you have some trouble with your installation configuration, you can just re-run the playbook and it will try to set things up again. You don't need to uninstall and install fresh.

However, if you've installed this on some server where you have other stuff you wish to preserve, and now want get rid of Nextcloud, it's enough to do these:

- ensure all Nextcloud services are stopped and disabled (`systemctl disable --now 'nextcloud*'`)

- delete the Nextcloud-related systemd .service files (`rm -f /etc/systemd/system/nextcloud*`)

- reload systemd (`systemctl daemon-reload`)

- delete some cached container images (or just delete them all: `docker rmi $(docker images -aq)`

- uninstall Docker itself, if necessary

- delete the `/nextcloud` directory (`rm -rf /nextcloud`)
