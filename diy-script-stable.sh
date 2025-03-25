#!/bin/bash

# 修改默认IP
sed -i 's/192.168.1.1/192.168.11.1/g' package/base-files/files/bin/config_generate

# 修改主机名称为 OPENWRT
sed -i 's/LEDE/OPENWRT/g' package/base-files/files/bin/config_generate

# 更改默认 Shell 为 zsh
# sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config


# 增加软件源
sed -i '$a src-git small https://github.com/kenzok8/small' feeds.conf.default
sed -i '$a src-git smpackage https://github.com/kenzok8/small-package' feeds.conf.default


# 修改feeds.conf.default文件
sed -i 's/^#src-git luci https:\/\/github.com\/coolsnowwolf\/luci/src-git luci https:\/\/github.com\/coolsnowwolf\/luci/g' feeds.conf.default
sed -i 's/^src-git luci https:\/\/github.com\/coolsnowwolf\/luci/#src-git luci https:\/\/github.com\/coolsnowwolf\/luci/g' feeds.conf.default


# 移除要替换的包
rm -rf feeds/smpackage/{base-files,dnsmasq,firewall*,fullconenat,libnftnl,nftables,ppp,opkg,ucl,upx,vsftpd*,miniupnpd-iptables,wireless-regdb}
rm -rf feeds/packages/lang/golang
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/msd_lite
rm -rf feeds/packages/net/smartdns
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/luci/applications/luci-app-netdata
rm -rf package/luci-app-ssr-plus
rm -rf package/luci-theme-argon

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

#更新go语言版本
git clone --depth=1 https://github.com/kenzok8/golang feeds/packages/lang/golang

# 添加额外插件
git clone --depth=1 https://github.com/kongfl888/luci-app-adguardhome package/luci-app-adguardhome
git clone --depth=1 https://github.com/Jason6111/luci-app-netdata package/luci-app-netdata


# MosDNS
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns package/luci-app-mosdns

# 科学上网插件
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages/tree/patches-xray-core-1.8.21 package/openwrt-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall

# Themes
git clone --depth=1 -b master https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon


# Alist
git clone --depth=1 https://github.com/sbwml/luci-app-alist package/luci-app-alist


# 更改 Argon 主题背景
cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg


# 在线用户
git_sparse_clone main https://github.com/haiibo/packages luci-app-onliner
sed -i '$i uci set nlbwmon.@nlbwmon[0].refresh_interval=2s' package/lean/default-settings/files/zzz-default-settings
sed -i '$i uci commit nlbwmon' package/lean/default-settings/files/zzz-default-settings
chmod 755 package/luci-app-onliner/root/usr/share/onliner/setnlbw.sh

# x86 型号只显示 CPU 型号
sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore

# 修改本地时间格式
sed -i 's/os.date()/os.date("%a %Y-%m-%d %H:%M:%S")/g' package/lean/autocore/files/*/index.htm

# 修改版本为编译日期
date_version=$(date +"%y.%m.%d")
orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
sed -i "s/${orig_version}/R${date_version} by 丶曲終人散ゞ/g" package/lean/default-settings/files/zzz-default-settings


# 修改 Makefile
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHREPO/PKG_SOURCE_URL:=https:\/\/github.com/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHCODELOAD/PKG_SOURCE_URL:=https:\/\/codeload.github.com/g' {}

# 取消主题默认设置
find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;

# 修改内核版本为 5.15
sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=5.15/' target/linux/x86/Makefile


./scripts/feeds update -a
./scripts/feeds install -a
