#!/bin/bash
# Build apod-sysctl deb: vendor-curated server tuning sysctls for the apod kernel.
# Usage: build_sysctl_deb.sh <conf_path> <version> <output_dir>
set -euo pipefail
conf="${1:?conf path}"; ver="${2:?version}"; outdir="${3:?output dir}"
[ -e "$conf" ] || { echo "conf 不存在: $conf"; exit 1; }
tmp=$(mktemp -d /dev/shm/apodsysctl.XXXXXX)
mkdir -p "$tmp/DEBIAN"
trap 'rm -rf "$tmp"' EXIT
install -D -m 0644 "$conf" "$tmp/usr/lib/sysctl.d/70-apod-server.conf"
cat > "$tmp/DEBIAN/control" <<EOF
Package: apod-sysctl
Version: $ver
Section: admin
Priority: optional
Architecture: all
Maintainer: key2p <code@key2p.com>
Description: APOD server tuning sysctl defaults
 Vendor-convergence server tuning defaults for the apod kernel
 (net queues / TCP behavior / VM swappiness). Installs
 /usr/lib/sysctl.d/70-apod-server.conf; override on specific hosts
 with a 90-*.conf if needed.
EOF
dpkg-deb --root-owner-group --build "$tmp" "$outdir/apod-sysctl_${ver}_all.deb" > /dev/null
dpkg-deb -I "$outdir/apod-sysctl_${ver}_all.deb" | grep 'Package: apod-sysctl' >/dev/null || { echo 'sysctl deb 元数据自检失败'; exit 1; }
dpkg-deb -c "$outdir/apod-sysctl_${ver}_all.deb" | grep '70-apod-server.conf' >/dev/null || { echo 'sysctl deb 内容自检失败'; exit 1; }
echo "apod-sysctl deb 构建成功: $outdir/apod-sysctl_${ver}_all.deb"
