#!/bin/bash
set -e

# 检查 OPENWRT_PATH
if [ -z "$OPENWRT_PATH" ]; then
    echo "错误：OPENWRT_PATH 未设置"
    exit 1
fi

# 进入 OpenWrt 源码目录
cd "$OPENWRT_PATH"

echo "当前源码目录：$PWD"
echo "开始更新 feeds ..."

# 1. 更新 & 安装 feeds（按需保留/精简）
./scripts/feeds update -a
./scripts/feeds install -a

echo "feeds 更新完成，开始处理 PassWall 相关包 ..."

# 2. 清理可能已有的 PassWall 相关目录（防止重复）
rm -rf feeds/luci/applications/luci-app-passwall*
rm -rf feeds/luci/applications/luci-app-passwall2*
rm -rf package/A/openwrt-passwall-packages
rm -rf package/A/openwrt-passwall
rm -rf package/A/openwrt-passwall2

mkdir -p package/A

# 3. 拉取 PassWall 依赖包，并锁定到旧版本（解决 geoview 需要 Go 1.24 的问题）
git clone https://github.com/xiaorouji/openwrt-passwall-packages.git package/A/openwrt-passwall-packages

(
  cd package/A/openwrt-passwall-packages || exit 0
  echo "当前 openwrt-passwall-packages 提交："
  git log -1 --oneline || true

  # 将仓库回退到 geoview 0.1.11 之前的某个旧提交
  # !!! 把 <OLD_HASH> 替换成你在 GitHub 上选好的那个提交号，如：9f22c6c
  git reset --hard <OLD_HASH>

  echo "已回退到旧提交："
  git log -1 --oneline || true
)

# 4. 拉取 PassWall / PassWall2 主程序（不锁或按需锁）
git clone https://github.com/xiaorouji/openwrt-passwall.git package/A/openwrt-passwall
git clone https://github.com/xiaorouji/openwrt-passwall2.git package/A/openwrt-passwall2

echo "PassWall 相关包处理完成。"

# 5. 应用预置 .config（来自你仓库的 configs/x86-64-24.10.config）
if [ -n "$CONFIG_FILE" ] && [ -f "$GITHUB_WORKSPACE/$CONFIG_FILE" ]; then
    echo "使用预置配置：$GITHUB_WORKSPACE/$CONFIG_FILE"
    cp "$GITHUB_WORKSPACE/$CONFIG_FILE" .config
else
    echo "未找到预置配置文件：$GITHUB_WORKSPACE/$CONFIG_FILE，跳过拷贝。"
fi

# 6. 生成最终配置（合并默认选项）
echo "运行 make defconfig 生成最终配置 ..."
make defconfig

echo "DIY 脚本执行完成。"
