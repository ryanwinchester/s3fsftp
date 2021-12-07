#!/usr/bin/env bash
#
# Run the docker container

set -e

docker run -it -p 22002:22 --init \
    --env-file .env \
    --device /dev/fuse \
    --cap-add SYS_ADMIN \
    s3fsftp_sftp
