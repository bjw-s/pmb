# Poor Man's Backup

Backup a folder to the local filesystem with periodic rotating backups using [Kopia](http://kopia.io).

Supports the following Docker architectures: `linux/amd64`, `linux/arm64`.

## Usage

### Docker

```sh
docker run -v /tmp/source:/data/src -v /tmp/dest:/data/dest ghcr.io/bjw-s/pmb:rolling
```

This will run a single backup from the local `/tmp/source` directory to a local directory (`/tmp/dest`).

### Kubernetes

Poor Man's Backup can be used in Kubernetes as well. Examples will follow soon.

## Configuration

### Environment Variables

#### Common variables

| Variable       | Description | Default value |
| -------------- | ----------- | ------------- |
| PMB__ACTION    | Mode to run in. Can be either `backup` or `restore`. | `backup` |
| PMB__DEBUG     | Logs additional information to stdout. | `false` |
| PMB__SRC_DIR   | Source directory to backup. | `/data/src` |
| PMB__DEST_DIR  | Destination directory to save the backup to. | `/data/dest` |
| KOPIA_PASSWORD | The password that is used to create/access the kopia repository. | `""` |

#### Backup variables

| Variable         | Description | Default value |
| ---------------- | ----------- | ------------- |
| PMB__KEEP_LATEST | Number of backups to keep before removal. | `7` |
| PMB__COMPRESSION | Enable compression on the backup. | `true` |
| PMB__FSFREEZE    | Run [`fsfreeze`](https://linux.die.net/man/8/fsfreeze) command on the `PMB__SOURCE_DIR` before performing a backup. **This only works when the container is running privileged and as `root`**. | `true` |

#### Restore variables

| Variable             | Description | Default value |
| -------------------- | ----------- | ------------- |
| PMB__NAMESPACE       | The namespace in which the HelmRelease / controller can be found. | `""` |
| PMB__HELMRELEASE     | The Flux HelmRelease to suspend before restoring. | `""` |
| PMB__CONTROLLER      | The type of controller that consumes the volume. | `deployment` |
| PMB__CONTROLLER_NAME | The name of the controller that consumes the volume. | `""` |
| PMB__SNAPSHOT_ID     | The ID of the snapshot that you wish to restore. | `latest` |
