# Poor Man's Backup

Backup a folder to the local filesystem with periodic rotating backups, based on [prodrigestivill/docker-postgres-backup-local](https://github.com/prodrigestivill/docker-postgres-backup-local/).

Supports the following Docker architectures: `linux/amd64`, `linux/arm64`.

## Usage

### Docker

```sh
docker run -e PMB__SOURCE_DIR=/data/source -e PMB__DESTINATION_DIR=/data/destination ghcr.io/bjw-s/pmb:rolling
```

This will run a single backup from the local `/data/source` directory to a local directory (`/data/destination`).

### Kubernetes

Poor Man's Backup can be used in Kubernetes as well. Examples will follow soon.

## Configuration

### Environment Variables

| Variable | Description | Default value |
|--|--|--|
| PMB__MODE | Mode to run in. Can be either `standalone` or `cron`. | `standalone` |
| PMB__SOURCE_DIR | Source directory to backup. | `""` |
| PMB__DESTINATION_DIR | Destination directory to save the backup to. **When this is set, `PMB__RCLONE_REMOTE` will be ignored!** | `""` |
| PMB__KEEP_DAYS | Number of daily backups to keep before removal. | `7` |
| PMB__FSFREEZE | Run [`fsfreeze`](https://linux.die.net/man/8/fsfreeze) command on the `PMB__SOURCE_DIR` before performing a backup. **This only works when the container is running privileged and as `root`**. | `false` |
| PMB__RCLONE_REMOTE | The rclone remote to back up to. | `local_dir` |
| PMB__RCLONE_REMOTE_PATH | The path on the rclone remote to back up to. | `/` |
| PMB__RCLONE_CONFIG | The location where the rclone configuration file can be found. | `/app/rclone.conf` |
| PMB__CRON_HEALTHCHECK_PORT | Port listening for cron-schedule health check. | `18080` |
| PMB__CRON_SCHEDULE | [Cron-schedule](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules) specifying the interval between backups. If set to empty the backup command will run just once. | `@daily` |
| TZ | [POSIX TZ variable](https://www.gnu.org/software/libc/manual/html_node/TZ-Variable.html) specifying the timezone used to evaluate SCHEDULE cron (example "Europe/Paris"). | `""` |

## Advanced usage

### Rclone

By mounting an Rclone configuration file to the location specified under the `PMB__RCLONE_REMOTE` environment variable it is possible to send the backups to any storage provider supported by Rclone.

First you need to create a rclone config for your storage provider. You can use the [interactive method](https://rclone.org/commands/rclone_config/) of create a manual file. See the [rclone site](https://rclone.org/commands/rclone_config/) on how to do this.

For example:
```
[aws-s3]
type = s3
env_auth = false
access_key_id = <key_id>
region = eu-amsterdam-1
secret_access_key = <secret>
endpoint = <endpoint>
```

Then run Poor Man's Backup as follows:

```sh
docker run -v ~/rclone.conf:/app/rclone.conf -e PMB__SOURCE_DIR=/data/source -e PMB__RCLONE_REMOTE="aws-s3" ghcr.io/bjw-s/pmb:rolling
```

### Automatic Periodic Backups

When you run Poor Man's Backup with in CRON mode (by setting the `PMB__MODE` environment variable to `cron`) it will run as a cron daemon that runs the backup script according to the schedule specified in the `PMB__CRON_SCHEDULE` environment variable.

You can change the `PMB__CRON_SCHEDULE` environment variable in `-e PMB__CRON_SCHEDULE="@daily"` to alter the default frequency. Default is `daily`.

More information about the scheduling can be found [here](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).

Folders `daily`, `weekly` and `monthly` are created and populated using hard links to save disk space.
