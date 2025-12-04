#!/bin/bash
set -ex

SAVE_DIR=${PWD}

[ -e "${GITHUB_WORKSPACE}/runner/01_nodoc" ] && cp -a ${GITHUB_WORKSPACE}/runner/01_nodoc /etc/dpkg/dpkg.cfg.d/ || true
[ -e "runner/01_nodoc" ] && cp -a runner/01_nodoc /etc/dpkg/dpkg.cfg.d/ || true

export PATH="/usr/lib/llvm-21/bin/:$PATH"

# avoid redownload
[ -e /usr/lib/llvm-21/bin/clang ] && exit 0

# config apt llvm
sed -i '/llvm-toolchain/d' /etc/apt/sources.list

( cat /etc/os-release | grep jammy ) && (echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-21 main" >> /etc/apt/sources.list)
( cat /etc/os-release | grep noble ) && (echo "deb http://apt.llvm.org/noble/ llvm-toolchain-noble-21 main" >> /etc/apt/sources.list)
( cat /etc/os-release | grep oracular ) && (echo "deb http://apt.llvm.org/oracular/ llvm-toolchain-oracular-21 main" >> /etc/apt/sources.list)

mkdir -p /etc/apt/trusted.gpg.d/ || true
curl -L https://apt.llvm.org/llvm-snapshot.gpg.key -o /etc/apt/trusted.gpg.d/apt.llvm.org.asc
apt update -y

## https://blobfolio.com/2024/building-a-custom-xanmod-kernel-on-ubuntu-23-10/

# for linux kernel build
apt install -y --no-install-suggests --no-install-recommends curl libc6 libgcc-s1 libicu-dev liblzma5 libstdc++6 libxml2 libzstd1 zlib1g xz-utils \
  fakeroot build-essential git wget openssl ca-certificates libncurses-dev zstd xz-utils flex debhelper rsync kmod cpio gpg pahole python3 \
  pkgconf libdwarf-dev libdw-dev systemtap-sdt-dev libunwind-dev python3-dev libzstd-dev libcap-dev libnuma-dev libtraceevent-dev uuid-dev libpfm4-dev libbfd-dev libbabeltrace-dev libperl-dev libpci-dev libpcap-dev rpm \
  debhelper debhelper-compat=12 bc bison flex libdw-dev libelf-dev libssl-dev llvm-21 clang-21 lld-21 \
  curl tar gzip xz-utils dpkg parted fdisk util-linux dosfstools e2fsprogs xorriso grub-pc-bin grub-efi-amd64-bin zerofree mtools upx 

apt-get clean
which llc || true