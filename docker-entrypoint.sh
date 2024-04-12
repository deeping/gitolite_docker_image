#!/bin/sh

set -e

echo "whoami: $(whoami) $(id)"
echo "$@"

# Setup SSH HostKeys if needed
for algorithm in rsa dsa ecdsa ed25519
do
  keyfile=/etc/ssh/ssh_host_${algorithm}_key
  if [ ! -f $keyfile ]; then
    echo "ssh-keygen $keyfile"
    ssh-keygen -q -N '' -f $keyfile -t $algorithm
  fi
  grep -q "HostKey $keyfile" /etc/ssh/sshd_config || echo "HostKey $keyfile" >> /etc/ssh/sshd_config
done

# Fixed container volume access permissions inconsistent with local users
if [ -n "$GID" ]; then
  echo "change the git group ID to $GID"
  groupmod -g $GID git
fi
if [ -n "$UID" ]; then
  echo "change the git user ID to $UID"
  usermod -u $UID git
fi

# Fix permissions at every startup
chown -R git:git ~git

# Setup gitolite admin  
if [ ! -f ~git/.ssh/authorized_keys ]; then
  echo "Setup gitolite admin"
  if [ -n "$SSH_KEY" ]; then
    [ -n "$SSH_KEY_NAME" ] || SSH_KEY_NAME=admin
    echo "$SSH_KEY" > "/tmp/$SSH_KEY_NAME.pub"
    su - git -c "gitolite setup -pk \"/tmp/$SSH_KEY_NAME.pub\""
    rm "/tmp/$SSH_KEY_NAME.pub"
  else
    echo "You need to specify SSH_KEY on first run to setup gitolite"
    echo "You can also use SSH_KEY_NAME to specify the key name (optional)"
	echo 'Example: docker run -p 2222:22 -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" -e SSH_KEY_NAME="$(whoami)" -e UID="$(id -u)" -e GID="$(id -g)" -v ~/repositories:/home/git/repositories ubuntu/gitolite:22.04'
    exit 1
  fi
# Check setup at every startup
else
  echo "gitolite setup"
  su - git -c "gitolite setup"
fi

# allow the container to be started with `--user`
#if [ "$1" = '/usr/sbin/sshd' -a "$(id -u)" = '0' ]; then
#	echo "gosu git"
#	exec gosu git "$0" "$@"
#fi

echo "Executing $@"
exec "$@"
