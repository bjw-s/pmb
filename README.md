# Poor Man's Backup

Backup a folder to the local filesystem with periodic rotating backups, based on [prodrigestivill/docker-postgres-backup-local](https://github.com/prodrigestivill/docker-postgres-backup-local/).

Supports the following Docker architectures: `linux/amd64`, `linux/arm64`.

## Usage

Docker:

```sh
docker run -e PMB__SOURCE=/tmp/source -e PMB__DESTINATION=/tmp/destination bjw-s/pmb
```

### Environment Variables

| env variable | description |default|
|--|--|--|
| PMB__SOURCE | Source directory to backup. | `**None**` |
| PMB__DESTINATION | Destination directory to save the backup to. | `**None**` |
| PMB__KEEP_DAYS | Number of daily backups to keep before removal. | `7` |
| PMB__KEEP_WEEKS | Number of weekly backups to keep before removal. | `4` |
| PMB__KEEP_MONTHS | Number of monthly backups to keep before removal. | `6` |
| PMB__KEEP_MINS | Number of minutes for `last` folder backups to keep before removal. | `1440` |
| PMB__HEALTHCHECK_PORT | Port listening for cron-schedule health check. | `8080` |
| PMB__SCHEDULE | [Cron-schedule](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules) specifying the interval between backups. | `@daily` |
| TZ | [POSIX TZ variable](https://www.gnu.org/software/libc/manual/html_node/TZ-Variable.html) specifying the timezone used to evaluate SCHEDULE cron (example "Europe/Paris"). | `""` |

### Automatic Periodic Backups

You can change the `PMB__SCHEDULE` environment variable in `-e PMB__SCHEDULE="@daily"` to alter the default frequency. Default is `daily`.

More information about the scheduling can be found [here](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).

Folders `daily`, `weekly` and `monthly` are created and populated using hard links to save disk space.
