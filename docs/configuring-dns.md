# Configuring your DNS server

To set up Nextcloud on your domain, you'd need to do some DNS configuration.

## DNS settings for services enabled by default

| Type  | Host                         | Priority | Weight | Port | Target                 |
| ----- | ---------------------------- | -------- | ------ | ---- | ---------------------- |
| A     | `nextcloud`                  | -        | -      | -    | `nextcloud-server-IP`  |

Be mindful as to how long it will take for the DNS records to propagate.

When you're done configuring DNS, proceed to [Configuring the playbook](configuring-playbook.md).
