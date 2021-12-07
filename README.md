# S3FSFTP

[![Docker Version](https://img.shields.io/docker/v/ryanwinchester/s3fsftp?arch=amd64&sort=date)](https://hub.docker.com/r/ryanwinchester/s3fsftp/tags)
 [![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/ryanwinchester/s3fsftp)](https://hub.docker.com/r/ryanwinchester/s3fsftp/tags)
 [![Docker Stars](https://img.shields.io/docker/stars/ryanwinchester/s3fsftp)](https://hub.docker.com/r/ryanwinchester/s3fsftp/tags)
 [![Docker Pulls](https://img.shields.io/docker/pulls/ryanwinchester/s3fsftp.svg)](https://hub.docker.com/r/ryanwinchester/s3fsftp/tags)

Docker container providing SFTP using an S3 bucket for the users' home directories.

## Using Docker Hub

```sh
docker pull ryanwinchester/s3fsftp:latest
```

## Using the repository

 - For local dev, set the required environment variables in the `.env` file.
 - For production, set the ENV variables for the container runtime.
 - Programs in `./scripts/sftp.d` will automatically run when the container starts.
 - Build docker container with `docker compose build`.
 - Run docker container with `docker compose up`.

#### *Without* `docker compose`

Build example:

```sh
docker build . --no-cache --tag s3fsftp_sftp:latest
```

Run example:

```sh
docker run -it -p 22002:22 --init \
  --env-file .env \
  --device /dev/fuse \
  --cap-add SYS_ADMIN \
  s3fsftp_sftp
```

### ENV vars

 - `AWS_S3_AUTHFILE` - The name of the auth file used by s3fs (defaults to `/etc/passwd-s3fs`).
 - `AWS_S3_BUCKET`* - The name of the bucket in S3 to mount.
 - `AWS_S3_CREDENTIALS`* - AWS S3 credentials (key and ID).
 - `AWS_S3_MOUNT` - The path to mount the bucket (defaults to `/opt/s3fs/bucket`)
 - `AWS_S3_REGION`* - The region of the S3 bucket (e.g. `ca-central-1`).
 - `AWS_S3_URL`* - The S3 url (e.g. `https://s3.ca-central-1.amazonaws.com`).
 - `SSH_HOST_DSA_KEY` (base64-encoded)
 - `SSH_HOST_DSA_PUBLIC_KEY` (base64-encoded)
 - `SSH_HOST_ECDSA_KEY` (base64-encoded)
 - `SSH_HOST_ECDSA_PUBLIC_KEY` (base64-encoded)
 - `SSH_HOST_ED25519_KEY` (base64-encoded)
 - `SSH_HOST_ED25519_PUBLIC_KEY` (base64-encoded)
 - `SSH_HOST_RSA_KEY` (base64-encoded)
 - `SSH_HOST_RSA_PUBLIC_KEY` (base64-encoded)
 - `USER_CONFIG`* (base64-encoded)

*required

### Secret format

`AWS_S3_CREDENTIALS`
```bash
${AWS_KEY_ID}:${AWS_SECRET_ACCESS_KEY}
```

`USER_CONFIG` (base64-encoded):
```json
{
  "users": [
    {
      "username": "foo",
      "uid": 1004,
      "gid": 1000,
      "folders": [
        {"path": "outgoing", "umask": "0770"}
      ],
      "publicKeys": [
        "ssh-rsa AAAAB3NzaC1yc2EAAAH+PqrlQ83wwpayFqTITgqZWL+UE8= foobar@example.com"
      ]
    }
  ]
}
```

## Acknowledgements

- Built on [`atmoz/sftp`](https://github.com/atmoz/sftp)
- Relies on [`s3fs-fuse`](https://github.com/s3fs-fuse/s3fs-fuse)
- Used part of the mounting script from [`efrecon/docker-s3fs-client`](https://github.com/efrecon/docker-s3fs-client/blob/master/docker-entrypoint.sh)'s entrypoint file.
