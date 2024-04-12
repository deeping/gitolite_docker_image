### gitolite on docker from ubuntu:14.04

#### Host usage
1. build image:
```
$ docker build -t ubuntu/gitolite:14.04 .
```

2. generate ssh key:
```
$ ssh-keygen -t ed25519
```

3. run:
```
$ docker run -d -p 2222:22 --hostname gitolite -e SSH_KEY="$(cat ~/.ssh/id_ed25519.pub)" -e SSH_KEY_NAME="$(whoami)" -e UID="$(id -u)" -e GID="$(id -g)" -v ~/repositories:/home/git/repositories ubuntu/gitolite:14.04
```

#### Client usage
1. test
```
$ git clone ssh://git@YOUR_HOST:2222/testing.git
```

### Load the docker image
If you don't want to build a docker image yourself, you can load an already built docker image
1. load image
```
$ docker load -i ubuntu_gitolite_14.04.tar
```
