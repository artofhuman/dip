# Docker installation

```sh
  brew install docker
  brew switch docker 1.12.2
```

Download https://github.com/nlf/dlite/releases/download/1.1.5/dlite

```sh
  sudo dlite install -c 2 -m 4 -d 20 -S $HOME
```

## Simple

- `dlite stop`
- download `bzImage` and `rootfs.cpio.xz` https://github.com/bibendi/dhyve-os/releases/tag/2.3.1
- move in `~/.dlite/`
- `dlite start`

## Advanced (for other docker version)

```sh
  git clone https://github.com/nlf/dhyve-os.git
  cd dhyve-os
  git checkout legacy
  vi Dockerfile
  # find the DOCKER_VERSION and replace with needed version
  make
  dlite stop
  cp output/{bzImage,rootfs.cpio.xz} ~/.dlite/
  dlite start
```

## Configure

First, let's start by configuring the default Docker service DNS server to IP where the DNS server will run (`172.17.0.1`). Currently, this requires SSH'ing into the VM and editing `/etc/default/docker`

```sh
  ssh docker@local.docker

  vi /etc/default/docker
  # Add the DNS server static IP via `--bip` and `--dns`
  # Change DOCKER_ARGS to:
  DOCKER_ARGS="-H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375 -s btrfs --bip=172.17.0.1/24 --dns=172.17.0.1"
  # save :x

  exit

  dlite stop && dlite start
```

Lastly, configure OSX so that all `.docker` requests are forwarded to Docker's DNS server. Since routing has already been taken care of, just create a custom resolver under `/etc/resolver/docker` with the following content:

```
  nameserver 172.17.0.1
```

Then restart OSX's own DNS server:

```sh
  sudo killall -HUP mDNSResponder
```

By default, Docker creates a virtual interface named `docker0` on the host machine that forwards packets between any other network interface.

However, on OSX, this means you are not able to access the Docker network directly. To be able to do so, you need to add a route and allow traffic from any host on the interface that connects to the VM.

Run the following commands on your OSX machine:

```sh
  sudo route -n add 172.17.0.0/8 local.docker
  DOCKER_INTERFACE=$(route get local.docker | grep interface: | cut -f 2 -d: | tr -d ' ')
  DOCKER_INTERFACE_MEMBERSHIP=$(ifconfig ${DOCKER_INTERFACE} | grep member: | cut -f 2 -d: | cut -c 2-4)
  sudo ifconfig "${DOCKER_INTERFACE}" -hostfilter "${DOCKER_INTERFACE_MEMBERSHIP}"
```

Check:

```sh
  ping dnsdock.docker
```
