#!/bin/bash
# OpenWrt 24.10 编译自定义脚本
# 适配官方 OpenWrt 24.10 分支和 LuCI 24.10 界面

# ================== 检查编译路径 ==================
if [ -z "$OPENWRT_PATH" ]; then
    echo "错误：OPENWRT_PATH 未设置"
    exit 1
fi

cd "$OPENWRT_PATH" || exit 1

# ================== 清理操作（仅首次运行）==================
if [ ! -f ".cleaned" ]; then
    echo "执行首次清理..."
    make clean
    rm -rf tmp/* staging_dir/target-*
    touch .cleaned
else
    echo "跳过清理，保留编译缓存"
fi

# ================== Toolchain 打包（可选） ==================
if [[ "$REBUILD_TOOLCHAIN" = "true" ]]; then
    echo -e "\e[1;33m开始打包 toolchain 目录\e[0m"
    sed -i 's/ $(tool.*\/stamp-compile)//' Makefile
    [ -d ".ccache" ] && (ccache=".ccache"; ls -alh .ccache)
    du -h --max-depth=1 ./staging_dir
    du -h --max-depth=1 ./ --exclude=staging_dir
    mkdir -p "$GITHUB_WORKSPACE/output"
    tar -I zstdmt -cf "$GITHUB_WORKSPACE/output/$CACHE_NAME.tzst" staging_dir/host* staging_dir/tool* $ccache
    ls -lh "$GITHUB_WORKSPACE/output"
    [ -e "$GITHUB_WORKSPACE/output/$CACHE_NAME.tzst" ] || exit 1
    exit 0
fi

[ -d "$GITHUB_WORKSPACE/output" ] || mkdir -p "$GITHUB_WORKSPACE/output"

# ================== 辅助函数 ==================
color() {
    case "$1" in
        cr) echo -e "\e[1;31m$2\e[0m" ;;
        cg) echo -e "\e[1;32m$2\e[0m" ;;
        cy) echo -e "\e[1;33m$2\e[0m" ;;
        cb) echo -e "\e[1;34m$2\e[0m" ;;
        cp) echo -e "\e[1;35m$2\e[0m" ;;
        cc) echo -e "\e[1;36m$2\e[0m" ;;
    esac
}

status() {
    local check=$? end_time total_time
    end_time=$(date '+%H:%M:%S')
    total_time="==> 用时 $[$(date +%s -d "$end_time") - $(date +%s -d "$begin_time")] 秒"
    [[ $total_time =~ [0-9]+ ]] || total_time=""
    if [[ $check = 0 ]]; then
        printf "%-62s %s %s %s\n" "$(color cy "$1")" "[ $(color cg ✔) ]" "$(echo -e "\e[1m$total_time")"
    else
        printf "%-62s %s %s %s\n" "$(color cy "$1")" "[ $(color cr ✕) ]" "$(echo -e "\e[1m$total_time")"
    fi
}

find_dir() {
    find "$1" -maxdepth 3 -type d -name "$2" -print -quit 2>/dev/null
}

print_info() {
    printf "%s %-40s %s %s %s\n" "$1" "$2" "$3" "$4" "$5"
}

git_clone() {
    local repo_url branch target_dir current_dir
    if [[ "$1" == */* ]]; then
        repo_url="$1"
        shift
    else
        branch="-b $1 --single-branch"
        repo_url="$2"
        shift 2
    fi
    if [[ -n "$@" ]]; then
        target_dir="$*"
    else
        target_dir="${repo_url##*/}"
    fi
    git clone -q $branch --depth=1 "$repo_url" "$target_dir" 2>/dev/null || {
        print_info "$(color cr 拉取)" "$repo_url" "[" "$(color cr ✕)" "]"
        return 0
    }
    rm -rf "$target_dir"/{.git*,README*.md,LICENSE}
    current_dir=$(find_dir "package/ feeds/ target/" "$target_dir")
    if [[ -d "$current_dir" ]] && rm -rf "$current_dir"; then
        mv -f "$target_dir" "${current_dir%/*}"
        print_info "$(color cg 替换)" "$target_dir" "[" "$(color cg ✔)" "]"
    else
        mv -f "$target_dir" "$destination_dir"
        print_info "$(color cb 添加)" "$target_dir" "[" "$(color cb ✔)" "]"
    fi
}

clone_dir() {
    local repo_url branch temp_dir
    temp_dir=$(mktemp -d)
    if [[ "$1" == */* ]]; then
        repo_url="$1"
        shift
    else
        branch="-b $1 --single-branch"
        repo_url="$2"
        shift 2
    fi
    git clone -q $branch --depth=1 "$repo_url" "$temp_dir" 2>/dev/null || {
        print_info "$(color cr 拉取)" "$repo_url" "[" "$(color cr ✕)" "]"
        rm -rf "$temp_dir"
        return 0
    }
    local target_dir source_dir current_dir
    for target_dir in "$@"; do
        source_dir=$(find_dir "$temp_dir" "$target_dir")
        [[ -d "$source_dir" ]] || \
        source_dir=$(find "$temp_dir" -maxdepth 4 -type d -name "$target_dir" -print -quit) && \
        [[ -d "$source_dir" ]] || {
            print_info "$(color cr 查找)" "$target_dir" "[" "$(color cr ✕)" "]"
            continue
        }
        current_dir=$(find_dir "package/ feeds/ target/" "$target_dir")
        if [[ -d "$current_dir" ]] && rm -rf "$current_dir"; then
            mv -f "$source_dir" "${current_dir%/*}"
            print_info "$(color cg 替换)" "$target_dir" "[" "$(color cg ✔)" "]"
        else
            mv -f "$source_dir" "$destination_dir"
            print_info "$(color cb 添加)" "$target_dir" "[" "$(color cb ✔)" "]"
        fi
    done
    rm -rf "$temp_dir"
}

clone_all() {
    local repo_url branch temp_dir
    temp_dir=$(mktemp -d)
    if [[ "$1" == */* ]]; then
        repo_url="$1"
        shift
    else
        branch="-b $1 --single-branch"
        repo_url="$2"
        shift 2
    fi
    git clone -q $branch --depth=1 "$repo_url" "$temp_dir" 2>/dev/null || {
        print_info "$(color cr 拉取)" "$repo_url" "[" "$(color cr ✕)" "]"
        rm -rf "$temp_dir"
        return 0
    }
    local target_dir source_dir current_dir base_path
    base_path="$temp_dir/$*"
    for target_dir in $(ls -l "$base_path" | awk '/^d/{print $NF}'); do
        source_dir=$(find_dir "$temp_dir" "$target_dir")
        current_dir=$(find_dir "package/ feeds/ target/" "$target_dir")
        if [[ -d "$current_dir" ]] && rm -rf "$current_dir"; then
            mv -f "$source_dir" "${current_dir%/*}"
            print_info "$(color cg 替换)" "$target_dir" "[" "$(color cg ✔)" "]"
        else
            mv -f "$source_dir" "$destination_dir"
            print_info "$(color cb 添加)" "$target_dir" "[" "$(color cb ✔)" "]"
        fi
    done
    rm -rf "$temp_dir"
}

# ================== 生成全局变量 ==================
begin_time=$(date '+%H:%M:%S')

SOURCE_REPO=$(basename "${REPO_URL:-https://github.com/openwrt/openwrt}")
echo "SOURCE_REPO=$SOURCE_REPO" >>"$GITHUB_ENV"
echo "LITE_BRANCH=${REPO_BRANCH#*-}" >>"$GITHUB_ENV"

# 加载配置文件生成平台信息（这里的 CONFIG_FILE 必须是 x86-64 的）
if [ -e "$GITHUB_WORKSPACE/$CONFIG_FILE" ]; then
    cp -f "$GITHUB_WORKSPACE/$CONFIG_FILE" .config
fi
make defconfig 1>/dev/null 2>&1

TARGET_NAME=$(awk -F '"' '/CONFIG_TARGET_BOARD/{print $2}' .config)
SUBTARGET_NAME=$(awk -F '"' '/CONFIG_TARGET_SUBTARGET/{print $2}' .config)
DEVICE_TARGET="$TARGET_NAME-$SUBTARGET_NAME"
echo "DEVICE_TARGET=$DEVICE_TARGET" >>"$GITHUB_ENV"

KERNEL_VERSION=$(grep 'KERNEL_PATCHVER:' "target/linux/$TARGET_NAME/Makefile" 2>/dev/null | cut -d= -f2 | tr -d ' ')
[ -z "$KERNEL_VERSION" ] && KERNEL_VERSION="6.6"
echo "KERNEL_VERSION=$KERNEL_VERSION" >>"$GITHUB_ENV"

TOOLS_HASH=$(git log --pretty=tformat:"%h" -n1 tools toolchain 2>/dev/null || echo "unknown")
CACHE_NAME="$SOURCE_REPO-${REPO_BRANCH#*-}-$DEVICE_TARGET-cache-$TOOLS_HASH"
echo "CACHE_NAME=$CACHE_NAME" >>"$GITHUB_ENV"

COMMIT_AUTHOR=$(git show -s --date=short --format="作者: %an" 2>/dev/null || echo "Unknown")
echo "COMMIT_AUTHOR=$COMMIT_AUTHOR" >>"$GITHUB_ENV"
COMMIT_DATE=$(git show -s --date=short --format="时间: %ci" 2>/dev/null || echo "Unknown")
echo "COMMIT_DATE=$COMMIT_DATE" >>"$GITHUB_ENV"
COMMIT_MESSAGE=$(git show -s --date=short --format="内容: %s" 2>/dev/null || echo "Unknown")
echo "COMMIT_MESSAGE=$COMMIT_MESSAGE" >>"$GITHUB_ENV"
COMMIT_HASH=$(git show -s --date=short --format="hash: %H" 2>/dev/null || echo "Unknown")
echo "COMMIT_HASH=$COMMIT_HASH" >>"$GITHUB_ENV"
status "生成全局变量"

# ================== 检查 Toolchain 缓存 ==================
if [[ "$TOOLCHAIN" = "true" ]]; then
    begin_time=$(date '+%H:%M:%S')
    cache_xa=$(curl -sL "https://api.github.com/repos/$GITHUB_REPOSITORY/releases" 2>/dev/null | awk -F '"' '/browser_download_url/{print $4}' | grep "$CACHE_NAME")
    cache_xc=$(curl -sL "https://api.github.com/repos/haiibo/toolchain-cache/releases" 2>/dev/null | awk -F '"' '/browser_download_url/{print $4}' | grep "$CACHE_NAME")
    if [[ $cache_xa || $cache_xc ]]; then
        if [ -n "$cache_xa" ]; then
            wget -qc -t=3 "$cache_xa"
        else
            wget -qc -t=3 "$cache_xc"
        fi
        if ls *.tzst >/dev/null 2>&1; then
            status "下载 toolchain 缓存文件"
            begin_time=$(date '+%H:%M:%S')
            tar -I unzstd -xf *.tzst || tar -xf *.tzst
            [ -n "$cache_xa" ] || (cp *.tzst "$GITHUB_WORKSPACE/output" 2>/dev/null && echo "OUTPUT_RELEASE=true" >>"$GITHUB_ENV")
            sed -i 's/ $(tool.*\/stamp-compile)//' Makefile
            [ -d staging_dir ]; status "部署 toolchain 编译缓存"
        fi
    else
        echo "REBUILD_TOOLCHAIN=true" >>"$GITHUB_ENV"
    fi
else
    echo "REBUILD_TOOLCHAIN=true" >>"$GITHUB_ENV"
fi

# ================== 更新 & 安装插件 ==================
begin_time=$(date '+%H:%M:%S')

sed -i '/luci/d' feeds.conf.default
echo "src-git luci https://github.com/openwrt/luci.git;openwrt-24.10" >> feeds.conf.default

./scripts/feeds update -a 1>/dev/null 2>&1
./scripts/feeds install -a 1>/dev/null 2>&1
status "更新 & 安装插件"

destination_dir="package/A"
[ -d "$destination_dir" ] || mkdir -p "$destination_dir"

color cy "添加 & 替换插件"

# 核心插件
git_clone https://github.com/kongfl888/luci-app-adguardhome
clone_all https://github.com/sirpdboy/luci-app-ddns-go luci-app-ddns-go

# DNS 相关
clone_all v5 https://github.com/sbwml/luci-app-mosdns luci-app-mosdns
git_clone https://github.com/sbwml/packages_lang_golang golang

# Web 服务
git_clone https://github.com/ximiTech/luci-app-msd_lite
git_clone https://github.com/ximiTech/msd_lite

# 网络工具
git_clone main https://github.com/qzrsa/packages luci-app-onliner
git_clone main https://github.com/qzrsa/packages luci-app-gowebdav

# 科学上网插件
git_clone main https://github.com/xiaorouji/openwrt-passwall-packages
git_clone main https://github.com/xiaorouji/openwrt-passwall

# 主题
git_clone https://github.com/jerrykuku/luci-theme-argon
git_clone https://github.com/jerrykuku/luci-app-argon-config

# 内网穿透
git_clone https://github.com/djylb/nps-openwrt

# ================== 个性化设置 ==================
begin_time=$(date '+%H:%M:%S')

[ -e "$GITHUB_WORKSPACE/files" ] && cp -rf "$GITHUB_WORKSPACE/files/"* files/ 2>/dev/null

if [ -n "$PART_SIZE" ]; then
    sed -i '/ROOTFS_PARTSIZE/d' "$GITHUB_WORKSPACE/$CONFIG_FILE" 2>/dev/null
    echo "CONFIG_TARGET_ROOTFS_PARTSIZE=$PART_SIZE" >>"$GITHUB_WORKSPACE/$CONFIG_FILE"
fi

[ -n "$DEFAULT_IP" ] && sed -i "/n) ipad/s/\".*\"/\"$DEFAULT_IP\"/" package/base-files/files/bin/config_generate 2>/dev/null

sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config 2>/dev/null || true

sed -i '/CYXluq4wUazHjmCDBCqXF/d' package/lean/default-settings/files/zzz-default-settings 2>/dev/null || true

if [ -e "$GITHUB_WORKSPACE/images/bg1.jpg" ]; then
    mkdir -p feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/
    cp -f "$GITHUB_WORKSPACE/images/bg1.jpg" feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
fi

if [ -e package/lean/autocore/files/x86/autocore ]; then
    sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore
fi

find "$destination_dir"/*/ -maxdepth 2 -path "*/Makefile" 2>/dev/null | \
xargs -I {} sed -i \
    -e 's?\.\./\.\./luci.mk?$(TOPDIR)/feeds/luci/luci.mk?' \
    -e 's?include \.\./\.\./\(lang\|devel\)?include $(TOPDIR)/feeds/packages/\1?' {}

for e in $(ls -d "$destination_dir"/luci-*/po feeds/luci/applications/luci-*/po 2>/dev/null); do
    if [[ -d "$e/zh-cn" && ! -d "$e/zh_Hans" ]]; then
        ln -s zh-cn "$e/zh_Hans" 2>/dev/null
    elif [[ -d "$e/zh_Hans" && ! -d "$e/zh-cn" ]]; then
        ln -s zh_Hans "$e/zh-cn" 2>/dev/null
    fi
done
status "加载个人设置"

# ================== 额外工具 ==================
if [[ "$ZSH_TOOL" = "true" ]] && [ -x "$GITHUB_WORKSPACE/scripts/preset-terminal-tools.sh" ]; then
    begin_time=$(date '+%H:%M:%S')
    "$GITHUB_WORKSPACE/scripts/preset-terminal-tools.sh"
    status "下载 zsh 终端工具"
fi

if [ -n "$CLASH_KERNEL" ] && [ -x "$GITHUB_WORKSPACE/scripts/preset-adguard-core.sh" ]; then
    begin_time=$(date '+%H:%M:%S')
    "$GITHUB_WORKSPACE/scripts/preset-adguard-core.sh" "$CLASH_KERNEL"
    status "下载 adguardhome 运行内核"
fi

# ================== 更新配置文件 ==================
begin_time=$(date '+%H:%M:%S')
if [ -e "$GITHUB_WORKSPACE/$CONFIG_FILE" ]; then
    cp -f "$GITHUB_WORKSPACE/$CONFIG_FILE" .config
fi
make defconfig 1>/dev/null 2>&1
status "更新配置文件"

echo -e "$(color cy 当前编译机型) $(color cb "$SOURCE_REPO-${REPO_BRANCH#*-}-$DEVICE_TARGET-$KERNEL_VERSION")"
color cp "DIY 脚本运行完成！"
