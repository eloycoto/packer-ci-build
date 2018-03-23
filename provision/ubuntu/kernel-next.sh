#!/bin/bash

set -xe

export 'IPROUTE_BRANCH'=${IPROUTE_BRANCH:-"net-next"}
export 'KCONFIG'=${KCONFIG:-"config-`uname -r`"}


sudo apt-get install -y --allow-downgrades \
    pkg-config bison flex build-essential gcc libssl-dev \
    libelf-dev bc

git clone --depth 1 git://git.kernel.org/pub/scm/linux/kernel/git/bpf/bpf-next.git $HOME/k
cd $HOME/k

cp /boot/config-`uname -r` .config
(yes '' | make oldconfig) || true
yes '' | make localmodconfig
(yes '' | make oldconfig) || true
./scripts/config --disable CONFIG_DEBUG_INFO
./scripts/config --disable CONFIG_DEBUG_KERNEL
./scripts/config --enable CONFIG_BPF
./scripts/config --enable CONFIG_BPF_SYSCALL
./scripts/config --module CONFIG_NETFILTER_XT_MATCH_BPF
./scripts/config --module CONFIG_NET_CLS_BPF
./scripts/config --module CONFIG_NET_ACT_BPF
./scripts/config --enable CONFIG_BPF_JIT
./scripts/config --enable CONFIG_HAVE_BPF_JIT
./scripts/config --enable CONFIG_BPF_EVENTS
./scripts/config --enable BPF_STREAM_PARSER
./scripts/config --module CONFIG_TEST_BPF
./scripts/config --disable CONFIG_LUSTRE_FS
./scripts/config --enable CONFIG_CGROUP_BPF
./scripts/config --module CONFIG_NET_SCH_INGRESS
./scripts/config --enable CONFIG_NET_CLS_ACT
./scripts/config --enable CONFIG_LWTUNNEL_BPF
./scripts/config --enable CONFIG_HAVE_EBPF_JIT
./scripts/config --module CONFIG_NETDEVSIM

# make and install latest kernel
make -j `getconf _NPROCESSORS_ONLN` LOCALVERSION=-custom

sudo make modules_install
sudo make install
sudo make headers_install INSTALL_HDR_PATH=/usr/
make headers_install

# iproute2 installation
cd $HOME
git clone -b "${IPROUTE_BRANCH}" git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git
cd iproute2/
./configure --prefix=/usr
make -j `getconf _NPROCESSORS_ONLN`
sudo make install

cp -R ${HOME}/k /usr/src/linux-source-$(uname-r)
ln -s linux-source-$(uname -r) linux-headers-$(uname -r)
