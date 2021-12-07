#!/usr/bin/env bash
#
# Bind mount S3 folders to their home directories, specified in config.json.

set -e

mount_path="${AWS_S3_MOUNT:-/opt/s3fs/bucket}"

config_file=/etc/ssh/config.json
if [[ ! -f $config_file ]] ; then
    echo 'config.json is missing'
    exit 128
fi

# Bind mount directories.
function bindmount() {
    if [ -d "$1" ]; then
        mkdir -p "$2"
    fi
    mount --bind $3 "$1" "$2"
}

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
    folders=$(_jq '.folders' $row)
    group_name=$(getent group "${gid}" | cut -d":" -f1)
    pubkeys=$(_jq '.publicKeys' $row)

    echo "[SETUP USER ${username}]"

    for folder_row in $(echo $folders | jq -r '.[] | @base64'); do
        folder_path=$(_jq '.path' $folder_row)
        mode=$(_jq '.umask' $folder_row)

        # Do the bind mount and set user's home permissions.
        echo "| ==> Mounting ${mount_path}/${username} to /home/${username}"
        mkdir -p "${mount_path}/${username}"
        bindmount "${mount_path}/${username}" "/home/${username}"
        chown root:root "/home/${username}"
        chmod 755 "/home/${username}"

        # Set up user's subfolder permissions and masking.
        echo "| ====> Create and set ${mode} on /home/${username}/${folder_path}"
        mkdir -p "/home/${username}/${folder_path}"
        chown "${uid}:${group_name}" "/home/${username}/${folder_path}"
        chmod "${mode}" "/home/${username}/${folder_path}"
        umask "${mode}" "/home/${username}/${folder_path}"
    done


    # Add SSH keys to authorized_keys with valid permissions
    ssh_dir="/home/${username}/.ssh"
    user_keys_allowed_file_tmp="$(mktemp)"
    user_keys_allowed_file="${ssh_dir}/authorized_keys"
    echo "| ==> Adding ssh keys to ${user_keys_allowed_file}"

    mkdir -p "${ssh_dir}"
    chown "${uid}" "${ssh_dir}"
    chmod 700 "${ssh_dir}"

    for publickey in $(echo $pubkeys | jq -r '.[] | @base64'); do
        echo $(echo $publickey | base64 --decode) >> "${user_keys_allowed_file_tmp}"
    done

    readme_file="${ssh_dir}/README.txt"
    cat > "${readme_file}" <<- EOM
The authorized_keys file is generated from configuration and will periodically
be overwritten. If you would like to add public keys for access, please contact
the server administrator.
EOM
    chown "${uid}" "${readme_file}"
    chmod 600 "${readme_file}"

    # Remove duplicate keys and write to file.
    sort < "${user_keys_allowed_file_tmp}" | uniq > "${user_keys_allowed_file}"

    chown "${uid}" "${user_keys_allowed_file}"
    chmod 600 "${user_keys_allowed_file}"
done
