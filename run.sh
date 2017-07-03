#!/bin/sh

# Make sure all sub-shells/processes are stopped when we're exiting by killing this process group
trap "kill 0" INT EXIT

# Make sure the web root has the right permissions
chown sftp:sftp /srv/www

# Generate ssh host keys if needed
for keyType in rsa dsa ecdsa ed25519; do
	if [ ! -f /ssh/ssh_host_${keyType}_key ]; then
		ssh-keygen -t ${keyType} -f /ssh/ssh_host_${keyType}_key -N ''
	fi
done

# Create the authorized_keys file if it doesn't exist
if [ ! -f /ssh/authorized_keys ]; then
	touch /ssh/authorized_keys
fi

# Start sshd in the background, and kill this process group when it exits
{ /usr/sbin/sshd -D -e; kill 0; } &

# Run nginx in the foreground
nginx
