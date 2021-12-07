#!/usr/bin/env bash
#
# Build the docker container

set -e

docker build . --no-cache --tag s3fsftp_sftp:latest
