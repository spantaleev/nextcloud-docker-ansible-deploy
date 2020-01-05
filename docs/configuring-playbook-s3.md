# Storing Nextcloud files on Amazon S3 (optional)

Nextcloud supports external storage natively and can connect to Amazon S3 and many others.
Unfortunately, as of this moment (currently at version 12.0.3 at the time of this writing),
its external storage support suffers from:

- being unable to create folders on Amazon S3 external storage mountpoints
- being unbearably slow

To avoid this problem, what this playbook does is mount some Amazon S3 bucket as a local directory using [Goofys](https://github.com/kahing/goofys).

It makes this bucket avaialable as a local directory

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

If you want to use another S3 compatible provider add the following config setting to set a custom endpoint:
```yaml
nextcloud_goofys_external_storage_endpoint: "https://custom.endpoint.here"
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