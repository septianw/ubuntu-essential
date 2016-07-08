#!/bin/bash

# based on https://github.com/textlab/glossa/blob/master/script/build_ubuntu_essential.sh

TAG=ailispaw/ubuntu-essential
VERSION=16.04
CODENAME=xenial
REVISION=20160706

set -ve

docker build -t ubuntu-essential-multilayer - <<EOF
FROM ubuntu:${CODENAME}-${REVISION}
# Make an exception for apt: it gets deselected, even though it probably shouldn't.
RUN export DEBIAN_FRONTEND=noninteractive && \
    dpkg --clear-selections && echo "apt install" | dpkg --set-selections && \
    apt-get --purge -y dselect-upgrade && \
    apt-get purge -y --allow-remove-essential init systemd && \
    apt-get purge -y libapparmor1 libcap2 libcryptsetup4 libdevmapper1.02.1 libkmod2 libseccomp2 && \
    apt-get --purge -y autoremove && \
    dpkg-query -Wf '\${db:Status-Abbrev}\t\${binary:Package}\n' | \
      grep '^.i' | awk -F'\t' '{print \$2 " install"}' | dpkg --set-selections && \
    rm -r /var/cache/apt /var/lib/apt/lists
RUN rm -f /core
EOF

TMP_FILE="$(mktemp -t ubuntu-essential-XXXXXX).tar.gz"

docker run --rm -i ubuntu-essential-multilayer tar zpc --exclude=/etc/hostname \
  --exclude=/etc/resolv.conf --exclude=/etc/hosts --one-file-system / > "$TMP_FILE"
docker rmi ubuntu-essential-multilayer

docker import - ubuntu-essential-nocmd < "$TMP_FILE"

docker build -t ${TAG}:${VERSION} - <<EOF
FROM ubuntu-essential-nocmd
CMD ["/bin/bash"]
EOF

docker rmi ubuntu-essential-nocmd
rm -f "$TMP_FILE"

docker tag -f ${TAG}:${VERSION} ${TAG}:${VERSION}-${REVISION}
docker tag -f ${TAG}:${VERSION} ${TAG}:latest
