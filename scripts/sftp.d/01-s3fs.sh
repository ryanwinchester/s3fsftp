#!/usr/bin/env bash
#
# Start s3fs-fuse to mount the S3 bucket.
#
# A lot of the stuff in this script is from the entrypoint script located in
# the <https://github.com/efrecon/docker-s3fs-client> project. Copyright (c) 2019, Emmanuel Frecon.
# License (3-Clause BSD): <https://github.com/efrecon/docker-s3fs-client/blob/cdacc189e791d6d47e597b1fb71e4dd600c2c939/LICENSE>

set -e

if [ -z "${AWS_S3_MOUNT}" ]; then
    AWS_S3_MOUNT=/opt/s3fs/bucket
fi

if [ ! -d $AWS_S3_MOUNT ]; then
    mkdir -p $AWS_S3_MOUNT
fi

if [ -z "${AWS_S3_CREDENTIALS}" -a -n "${AWS_S3_ACCESS_KEY_ID}" -a -n "${AWS_S3_SECRET_ACCESS_KEY}" ]; then
    AWS_S3_CREDENTIALS="${AWS_S3_ACCESS_KEY_ID}:${AWS_S3_SECRET_ACCESS_KEY}"
fi

if [ -z "${AWS_S3_AUTHFILE}" ]; then
    AWS_S3_AUTHFILE=/opt/s3fs/passwd-s3fs
fi

# Create or use authorisation file
if [ -n "${AWS_S3_CREDENTIALS}" ]; then
    echo "${AWS_S3_CREDENTIALS}" > $AWS_S3_AUTHFILE
    chmod 400 $AWS_S3_AUTHFILE
else
    echo "Error: You need to provide some AWS credentials"
    exit 128
fi

if [ -z "${AWS_S3_BUCKET}" ]; then
    echo "Error: AWS_S3_BUCKET not provided"
    exit 128
fi

if [ -z "${AWS_S3_URL}" ]; then
    AWS_S3_URL="https://s3.amazonaws.com"
fi

if [ -z "${AWS_S3_REGION}" ]; then
    AWS_S3_REGION="us-east-1"
fi

if [ -n "${AWS_S3_SECRET_ACCESS_KEY}" ]; then
    unset AWS_S3_SECRET_ACCESS_KEY
fi

DEBUG_OPTS=
if [ $S3FS_DEBUG = "1" ]; then
    DEBUG_OPTS="-d -d"
fi

if [ -n "${S3FS_ARGS}" ]; then
    S3FS_ARGS="-o $S3FS_ARGS"
fi

# Mount and verify that something is present. davfs2 always creates a lost+found
# sub-directory, so we can use the presence of some file/dir as a marker to
# detect that mounting was a success. Execute the command on success.

s3fs ${DEBUG_OPTS} ${S3FS_ARGS} \
    -o passwd_file=${AWS_S3_AUTHFILE} \
    -o url=${AWS_S3_URL} \
    -o endpoint=${AWS_S3_REGION} \
    ${AWS_S3_BUCKET} ${AWS_S3_MOUNT}

# s3fs can claim to have a mount even though it didn't succeed.
# Doing an operation actually forces it to detect that and remove the mount.
ls "${AWS_S3_MOUNT}"

mounted=$(mount | grep fuse.s3fs | grep "${AWS_S3_MOUNT}")
if [ -n "${mounted}" ]; then
    echo "Mounted bucket ${AWS_S3_BUCKET} onto ${AWS_S3_MOUNT}"
else
    echo "Mount failure"
    exit 128
fi
