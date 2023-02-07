# Configuring your DNS server

To set up Nextcloud on your domain, you'd need to do some DNS configuration.

## DNS settings for services enabled by default

| Type  | Host        | Priority | Weight | Port | Target                     |
|-------|-------------|----------|--------|------|----------------------------|
| A     | `nextcloud` | -        | -      | -    | `nextcloud-server-IP`      |
| CNAME | `collabora` | -        | -      | -    | `nextcloud.yourdomain.org` |

Be mindful as to how long it will take for the DNS records to propagate.

The collabora domain name is configured via the `nextcloud_collabora_document_server_domain` variable. If you'd like to use a different one, adjust that variable and the DNS records to match.

When you're done configuring DNS, proceed to [Configuring the playbook](configuring-playbook.md).
