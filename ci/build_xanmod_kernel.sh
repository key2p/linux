#!/bin/bash
set -ex

export PATH="/usr/lib/llvm-21/bin/:$PATH"
export MAIN_KCONFIG_FILE=.config

mkdir -p ${WORK_DIR} || true

## CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE  boost build
sed -i "s/KBUILD_CFLAGS += -O2/KBUILD_CFLAGS += -O3/g" arch/x86/Makefile 
cat arch/x86/Makefile | grep KBUILD_CFLAGS

[ -e "CONFIGS/x86_64/config" ] && cp -a CONFIGS/x86_64/config ${MAIN_KCONFIG_FILE}

if [ "$BUILD_TYPE" != "std" ]; then
  # cloud 版本不需要 kvm
  sed -i 's/CONFIG_KVM=[mny]/CONFIG_KVM=n/g'                                    ${MAIN_KCONFIG_FILE}
fi

# CONFIG_KALLSYMS=y, so no need System.map file
bash ${WORK_DIR}/ci/patch-linux-files.sh

export DEBFULLNAME="Alexandre Frade"
export DEBEMAIL="kernel@xanmod.org"
export KDEB_CHANGELOG_DIST="bookworm"

export lv=$(make -s kernelversion)
export xv="-xanmod1"
export rv=0

PAREL_BUILD=$(nproc)
if [ "$PAREL_BUILD" -ge '12' ]; then
  PAREL_BUILD=16
fi

date; time make olddefconfig LLVM=1 LLVM_IAS=1
date; time make KDEB_COMPRESS=xz INSTALL_MOD_STRIP=1 bindeb-pkg -j${PAREL_BUILD} LLVM=1 LLVM_IAS=1 || (date; echo $PATH; make KDEB_COMPRESS=xz INSTALL_MOD_STRIP=1 bindeb-pkg -j${PAREL_BUILD} LLVM=1 LLVM_IAS=1)
date

# 统计builtin的文件大小
bash ${WORK_DIR}/ci/report-object-sizes.sh
ls -al ${WORK_DIR}/../

# dbg info not need
rm -f ${WORK_DIR}/../*-dbg*.deb || true