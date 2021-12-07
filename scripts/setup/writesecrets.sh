#!/usr/bin/env bash
#
# Write the base64-encoded secrets to files.

set -e

echo "[ENV secrets]"

if [ -n "${USER_CONFIG}" ]; then
    echo "==> Writing config.json"
    printenv USER_CONFIG | base64 --decode > /etc/ssh/config.json
    chmod 600 /etc/ssh/config.json
else
    echo "Error: USER_CONFIG not provided"
    exit 128
fi

if [ -n "${SSH_HOST_DSA_KEY}" ]; then
    echo "==> Writing provided DSA host keys"
    printenv SSH_HOST_DSA_KEY | base64 --decode > /etc/ssh/ssh_host_dsa_key
    printenv SSH_HOST_DSA_PUBLIC_KEY | base64 --decode > /etc/ssh/ssh_host_dsa_key.pub
    chmod 600 /etc/ssh/ssh_host_dsa_key
    chmod 600 /etc/ssh/ssh_host_dsa_key.pub
fi

if [ -n "${SSH_HOST_ECDSA_KEY}" ]; then
    echo "==> Writing provided ECDSA host keys"
    printenv SSH_HOST_ECDSA_KEY | base64 --decode > /etc/ssh/ssh_host_ecdsa_key
    printenv SSH_HOST_ECDSA_PUBLIC_KEY | base64 --decode > /etc/ssh/ssh_host_ecdsa_key.pub
    chmod 600 /etc/ssh/ssh_host_ecdsa_key
    chmod 600 /etc/ssh/ssh_host_ecdsa_key.pub
fi

if [ -n "${SSH_HOST_ED25519_KEY}" ]; then
    echo "==> Writing provided ED25519 host keys"
    printenv SSH_HOST_ED25519_KEY | base64 --decode > /etc/ssh/ssh_host_ed25519_key
    printenv SSH_HOST_ED25519_PUBLIC_KEY | base64 --decode > /etc/ssh/ssh_host_ed25519_key.pub
    chmod 600 /etc/ssh/ssh_host_ed25519_key
    chmod 600 /etc/ssh/ssh_host_ed25519_key.pub
fi

if [ -n "${SSH_HOST_RSA_KEY}" ]; then
    echo "==> Writing provided RSA host keys"
    printenv SSH_HOST_RSA_KEY | base64 --decode > /etc/ssh/ssh_host_rsa_key
    printenv SSH_HOST_RSA_PUBLIC_KEY | base64 --decode > /etc/ssh/ssh_host_rsa_key.pub
    chmod 600 /etc/ssh/ssh_host_rsa_key
    chmod 600 /etc/ssh/ssh_host_rsa_key.pub
fi
