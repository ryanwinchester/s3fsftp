#!/usr/bin/env bash
#
# Bind mount S3 folders to their home directories, specified in config.json.

set -e

config_file=/etc/ssh/config.json

if [[ ! -f "${config_file}" ]] ; then
    echo 'config.json is missing'
    exit 128
fi

echo "[config.json => users.conf]"

mkdir -p /etc/sftp
usersconf="/etc/sftp/users.conf"
touch $usersconf
echo "" > $usersconf

# Loop over users and bind mount the directories, and set permissions and masks
# on the specified folders from config.json.
for row in $(jq -r '.users[] | @base64' $config_file); do
    _jq() {
        echo ${2} | base64 --decode | jq -r ${1}
    }

    # Get the user's properties from the config.json.
    username=$(_jq '.username' $row)
    password=$(_jq '.password' $row)
    uid=$(_jq '.uid' $row)
    gid=$(_jq '.gid' $row)

    printf "${username}:${password}:${uid}:${gid}\n" >> $usersconf
    chown root:root $usersconf
done
