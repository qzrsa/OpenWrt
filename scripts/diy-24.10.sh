#!/bin/bash

set -e

if [ -z "$OPENWRT_PATH" ]; then
    echo "错误：OPENWRT_PATH 未设置"
    exit 1
fi

cd "$OPENWRT_PATH"
echo "当前源码目录：$PWD"

# 1. 添加 kenzo 和 small 源（如果还没添加）
grep -q "src-git kenzo " feeds.conf.default || \
    sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default

grep -q "src-git small " feeds.conf.default || \
    sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default

# 2. 更新 feeds
./scripts/feeds update -a

# 3. 删除会冲突的旧包（按 small README 推荐）
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat

# 4. 替换golang
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

# 5. 安装所有 feed 包
./scripts/feeds install -a

# 6. 修复 Docker 编译路径问题
echo "======================================="
echo "开始修复 Docker 构建配置..."
echo "======================================="

DOCKER_MAKEFILE="feeds/packages/utils/docker/Makefile"
if [ -f "$DOCKER_MAKEFILE" ]; then
    echo "找到 Docker Makefile: $DOCKER_MAKEFILE"
    
    # 备份原文件
    cp "$DOCKER_MAKEFILE" "${DOCKER_MAKEFILE}.bak"
    echo "已备份原始 Makefile"
    
    # 修复构建输出路径问题
    # 将 build/docker 替换为实际的构建输出路径
    sed -i 's|$(PKG_BUILD_DIR)/build/docker|$(PKG_BUILD_DIR)/x86-64/docker-linux-amd64|g' "$DOCKER_MAKEFILE"
    
    echo "Docker Makefile 路径已修复"
    echo "修改内容: build/docker -> x86-64/docker-linux-amd64"
else
    echo "警告: 未找到 Docker Makefile，跳过修复"
fi

echo "======================================="
echo "Docker 配置修复完成"
echo "======================================="

# 7. 使用你预置的 .config
if [ -n "$CONFIG_FILE" ] && [ -f "$GITHUB_WORKSPACE/$CONFIG_FILE" ]; then
    echo "使用预置配置：$GITHUB_WORKSPACE/$CONFIG_FILE"
    cp "$GITHUB_WORKSPACE/$CONFIG_FILE" .config
else
    echo "未找到预置配置文件：$GITHUB_WORKSPACE/$CONFIG_FILE，跳过拷贝。"
fi

# 8. 生成最终配置
make defconfig

echo "======================================="
echo "diy-24.10.sh 执行完成"
echo "======================================="
