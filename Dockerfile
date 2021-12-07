FROM atmoz/sftp:debian

COPY ./scripts/setup /scripts
COPY ./scripts/sftp.d /etc/sftp.d
COPY ./entrypoint.sh /override-entrypoint.sh

# Install s3fs and necessary tools.
RUN apt-get update && apt-get -y install s3fs jq

EXPOSE 22

ENTRYPOINT ["/override-entrypoint.sh"]
