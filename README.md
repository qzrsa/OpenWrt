   <div align="center">

<h1>OpenWrt — 自用固件云编译</h1>


[![](https://img.shields.io/badge/-目录:-696969.svg)](#readme) [![](https://img.shields.io/badge/-项目说明-FFFFFF.svg)](#项目说明-) [![](https://img.shields.io/badge/-固件特色-FFFFFF.svg)](#固件特色-) [![](https://img.shields.io/badge/-固件下载-FFFFFF.svg)](#固件下载-) [![](https://img.shields.io/badge/-近期更新-FFFFFF.svg)](#近期更新-) [![](https://img.shields.io/badge/-插件预览-FFFFFF.svg)](#插件预览-) [![](https://img.shields.io/badge/-定制固件-FFFFFF.svg)](#定制固件-) [![](https://img.shields.io/badge/-特别提示-FFFFFF.svg)](#特别提示-) [![](https://img.shields.io/badge/-鸣谢-FFFFFF.svg)](#鸣谢-)
</div>


## 项目说明 [![](https://img.shields.io/badge/-项目基本介绍-FFFFFF.svg)](#项目说明-)
- 固件构成：[![Lean](https://img.shields.io/badge/Lede-Lean-ff69b4.svg?style=flat&logo=appveyor)](https://github.com/coolsnowwolf/lede) [![P3TERX](https://img.shields.io/badge/OpenWrt-P3TERX-blueviolet.svg?style=flat&logo=appveyor)](https://github.com/P3TERX/Actions-OpenWrt) [![Haiibo](https://img.shields.io/badge/Build-Haiibo-32C955.svg?style=flat&logo=appveyor)](https://github.com/haiibo/OpenWrt)
- 项目使用 Github Actions 拉取 [Lean](https://github.com/coolsnowwolf/lede) 的 Openwrt 源码仓库进行云编译
- 固件默认管理地址：`192.168.11.1` 默认用户：`root` 默认密码：空
- 固件集成的所有 ipk 插件全部打包在 Packages 文件中，可以在 [Releases](https://github.com/qzrsa/OpenWrt/releases) 内进行下载
- 项目编译的固件插件为最新版本，最新版插件可能有 BUG，如果之前使用稳定则无需追新
- 第一次使用请采用全新安装，避免出现升级失败以及其他一些可能的 BUG


## 固件特色 [![](https://img.shields.io/badge/-本项目固件特色-FFFFFF.svg)](#固件特色-)
1. 固件每月1日定时自动编译，以确保获得最新体验
2. 集成 Docker 服务，可在 OpenWrt 内自由部署 Docker 应用
3. 集成在线用户插件，可查看所有在线用户 IP 地址与实时速率等


## 固件版本 [![](https://img.shields.io/badge/-本项目版本-FFFFFF.svg)](#固件版本-)
固件内核版本为5.15版本。每月1日由GitHub Actions自动更新，期间不定期更新。
## 固件下载 [![](https://img.shields.io/badge/-编译状态及下载链接-FFFFFF.svg)](#固件下载-)
点击下表中 [![](https://img.shields.io/badge/下载-链接-blueviolet.svg?style=flat&logo=hack-the-box)](https://github.com/qzrsa/OpenWrt/releases) 即可跳转到该设备固件下载页面
| 平台+设备名称 | 固件编译状态 | 配置文件 | 固件下载 |
| :-------------: | :-------------: | :-------------: | :-------------: |
| [![](https://img.shields.io/badge/OpenWrt-x86-64%E4%BD%8D.svg?logo=openwrt)](https://github.com/qzrsa/OpenWrt/blob/main/.github/workflows/build-x86-64-openwrt.yml) | [![](https://github.com/qzrsa/OpenWrt/actions/workflows/build-x86-64-openwrt.yml/badge.svg)](https://github.com/qzrsa/OpenWrt/actions/workflows/x86-64-stable.yml) | [![](https://img.shields.io/badge/编译-配置-orange.svg?logo=apache-spark)](https://github.com/qzrsa/OpenWrt/blob/main/configs/x86-64-18.06.config) | [![](https://img.shields.io/badge/下载-链接-blueviolet.svg?logo=hack-the-box)](https://github.com/qzrsa/OpenWrt/releases) |



## 插件预览 [![](https://img.shields.io/badge/-固件插件及功能预览-FFFFFF.svg)](#插件预览-)

<details>
<summary><b>&nbsp;X86软路由插件预览</b></summary>
<br/>
<details>
<summary><b>├── 状态</b></summary>
　├── 概况<br/>
　├── 防火墙<br/>
　├── 路由表<br/>
　├── 系统日志<br/>
　├── 内核日志<br/>
　├── 系统进程<br/>
　├── 实时信息<br/>
　├── 实时监控<br/>
　└── 在线用户
</details>
<details>
<summary><b>├── 系统</b></summary>
　├── 系统<br/>
　├── 管理权<br/>
　├── TTYD 终端<br/>
　├── 软件包<br/>
　├── 启动项<br/>
　├── 计划任务<br/>
　├── 挂载点<br/>
　├── 磁盘管理<br/>
　├── 备份/升级<br/>
　├── 定时重启<br/>
　├── 文件传输<br/>
　├── Argon 主题设置<br/>
　└── 重启
</details>
<details>
<summary><b>├── 服务</b></summary>
　├── PassWall<br/>
　├── AdGuard Home<br/>
　├── MosDns<br/>
　├── DDNS-GO<br/>
　├── 动态 DNS<br/>
　├── KMS服务器<br/> 
　└── UPnP<br/>
</details>
<details>
<summary><b>├── Docker</b></summary>
　├── 概览<br/>
　├── 容器<br/>
　├── 镜像<br/>
　├── 网络<br/>
　├── 存储卷<br/>
　├── 事件<br/>
　└── 设置
</details>
<details>
<summary><b>├── 网络存储</b></summary>
　├── Alist 文件列表<br/>
　├── WebDav<br/>
　└── 网络共享
</details>
<details>
<summary><b>├── VPN</b></summary>
　└── ZeroTier
</details>
<details>
<summary><b>├── 网络</b></summary>
　├── 接口<br/>
　├── DHCP/DNS<br/>
　├── 主机名<br/>
　├── IP/MAC 绑定<br/>
　├── 静态路由<br/>
　├── 防火墙<br/>
　└── 诊断
</details>
<details>
<summary><b>├── 带宽监控</b></summary>
　├── 显示<br/>
　├── 配置<br/>
　├── 备份<br/>
　├── 网速监控<br/>
　└── 流量监控
</details>
　└── <b>退出</b>
</details>


## 定制固件 [![](https://img.shields.io/badge/-项目基本编译教程-FFFFFF.svg)](#定制固件-)
1. 首先要登录 Gihub 账号，然后 Fork 此项目到你自己的 Github 仓库
2. 修改 `configs` 目录对应文件添加或删除插件，或者上传自己的 `xx.config` 配置文件
3. 插件对应名称及功能请参考恩山网友帖子：[Applications 添加插件应用说明](https://www.right.com.cn/forum/thread-3682029-1-1.html)
4. 如需修改默认 IP、添加或删除插件包以及一些其他设置请在 `diy-script.sh` 文件内修改
5. 添加或修改 `xx.yml` 文件，最后点击 `Actions` 运行要编译的 `workflow` 即可开始编译
6. 编译大概需要3-5小时，编译完成后在仓库主页 [Releases](https://github.com/haiibo/OpenWrt/releases) 对应 Tag 标签内下载固件
<details>
<summary><b>&nbsp;如果你觉得修改 config 文件麻烦，那么你可以点击此处尝试本地提取</b></summary>

1. 首先装好 Linux 系统，推荐 Debian 11 或 Ubuntu LTS

2. 安装编译依赖环境

   ```bash
   sudo apt update -y
   sudo apt full-upgrade -y
   sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
   bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib \
   git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev \
   libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libreadline-dev libssl-dev libtool lrzsz \
   mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python2.7 python3 python3-pyelftools \
   libpython3-dev qemu-utils rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip \
   vim wget xmlto xxd zlib1g-dev
   ```

3. 下载源代码，更新 feeds 并安装到本地

   ```bash
   git clone https://github.com/coolsnowwolf/lede
   cd lede
   ./scripts/feeds update -a
   ./scripts/feeds install -a
   ```

4. 复制 diy-script.sh 文件内所有内容到命令行，添加自定义插件和自定义设置

5. 命令行输入 `make menuconfig` 选择配置，选好配置后导出差异部分到 seed.config 文件

   ```bash
   make defconfig
   ./scripts/diffconfig.sh > seed.config
   ```

7. 命令行输入 `cat seed.config` 查看这个文件，也可以用文本编辑器打开

8. 复制 seed.config 文件内所有内容到 configs 目录对应文件中覆盖就可以了

   **如果看不懂编译界面可以参考 YouTube 视频：[软路由固件 OpenWrt 编译界面设置](https://www.youtube.com/watch?v=jEE_J6-4E3Y&list=WL&index=7)**
</details>


## 特别提示 [![](https://img.shields.io/badge/-个人免责声明-FFFFFF.svg)](#特别提示-)

- **因精力有限不提供任何技术支持和教程等相关问题解答，不保证完全无 BUG！**

- **本人不对任何人因使用本固件所遭受的任何理论或实际的损失承担责任！**

- **本固件禁止用于任何商业用途，请务必严格遵守国家互联网使用相关法律规定！**


## 鸣谢 [![](https://img.shields.io/badge/-跪谢各大佬-FFFFFF.svg)](#鸣谢-)
| [ImmortalWrt](https://github.com/immortalwrt) | [coolsnowwolf](https://github.com/coolsnowwolf) | [P3TERX](https://github.com/P3TERX) | [Flippy](https://github.com/unifreq) |
| :-------------: | :-------------: | :-------------: | :-------------: |
| <img width="100" src="https://avatars.githubusercontent.com/u/53193414"/> | <img width="100" src="https://avatars.githubusercontent.com/u/31687149"/> | <img width="100" src="https://avatars.githubusercontent.com/u/25927179"/> | <img width="100" src="https://avatars.githubusercontent.com/u/39355261"/> |
| [Ophub](https://github.com/ophub) | [SuLingGG](https://github.com/SuLingGG) | [QiuSimons](https://github.com/QiuSimons) | [IvanSolis1989](https://github.com/IvanSolis1989) |
| <img width="100" src="https://avatars.githubusercontent.com/u/68696949"/> | <img width="100" src="https://avatars.githubusercontent.com/u/22287562"/> | <img width="100" src="https://avatars.githubusercontent.com/u/45143996"/> | <img width="100" src="https://avatars.githubusercontent.com/u/44228691"/> |


<a href="#readme">
<img src="https://img.shields.io/badge/-返回顶部-FFFFFF.svg" title="返回顶部" align="right"/>
</a>
