# 开机流程,模块管理与Loader
grub2 是Linux 下优秀的开机管理程序 (boot loader).
**aLoader 的最主要功能是要认识操作系统的文件格式并据以载入核心到内存中去执行.**
## Linux开机流程 (重要)
- **载入BOIS 的硬件信息与进行自我检测, 并依据设置取得第一个可开机的设备(硬盘或网络,保存操作系统的硬件)**
- **读取并执行第一个开机设备内的 MBR或GPT 分区中的 **开机启动程序 `boot loader`** (就是grub2,spfdisk等程序)**
- **依据 boot loader 的设置载入 Kernel(内核), kernel会开始侦测硬件与载入驱动程序.**
- **在硬件驱动成功后,Kernel会主动调用systemd 程序,并以 default.target(操作环境)准备操作系统.**
  - **systemd 执行 sysinit.target 初始化系统及basic.target 准备操作系统**
  - **systemd 启动 multi-user.target 下的本机与服务器服务**
  - **systemd 执行 multi-user.target 下的 /etc/rc.d/rc.local 文件**
  - **systemd 执行 multi-user.target 下的 getty.target 及登陆服务**
  - **systemd 执行 graphical(图形化) 需要的服务**

**MBR 代表该磁盘的前面可安装 boot loader 的那个区块.**

### BIOS,boot loader 与 kernel 载入
**开机管理程序(Boot loader)是用来处理 核心文件载入(load)的.**
**Boot Loader 安装在开机设备的第一个扇区(sector)内,也就是 MBR(master Boot Record,主要开机记录区)**
**BIOS是通过硬件的 INT 13  中断功能来读取  MBR 的,也就是说,BIOS只要能够侦测到磁盘,那就有办法通过INT 13 这条信道来读取该磁盘的第一个扇区内的 MBR 软件, 这样 boot loader 也能够被执行了**
**当系统存在多块硬盘时,需要看BIOS的设置来决定去读取哪块硬盘的MBR分区**

- 首先让系统去载入BIOS(basic input output System)
  - 通过BIOS 程序去载入CMOS 的信息
  - 借由 CMOS内的设置值去取得主机的各项硬件设置
    - CPU,周边设备的沟通频率,开机设备的搜寻顺序,磁盘的大小与类型,系统事件,各周边总线的是否启动 Plug and Play(PnP随插即用设备), 周边设备的I/O位址,与CPU沟通的IRQ岔断.
- 取得上面的信息后,BIOS会进行开机自我检测(Power-on self Test,POST)
  - 开始执行硬件侦测的初始化,并设置 PnP设备
  - 再定义出可开机的设备顺序
  - 开始进行开机设备的数据读取

#### Boot Loader 的功能
**不同的操作系统的文件格式不一致,每种操作系统都有自己的 boot loader ,使用自己的boot loader才有办法载入核心文件**
**每个文件系统都会保留一块开机扇区(boot sector) 提供操作系统安装 boot loader ,而通常操作系统默认都会安装一份loader到他根目录所在的文件系统的boot sector 上.(也就是一式两份)**
- ***boot loader 的主要功能:**
  - 提供菜单 :使用者可以选择不同的开机项目，这也是多重开机的重要功能.
  - 载入核心文件 :可以指向可开机的程序区段来开始操作系统.
  - 转交其他 loader :将开机管理开机管理功能转交给其他 loader 负责.

借由 boot loader 的管理而开始读取核心文件后,接下来,Linux会将核心文件解压缩到内存当中,并利用核心功能能开始测试与驱动各个周边设备, 包括存储设备,CPU,网卡,声卡.此时Linux还会以自己的功能重新检测一次硬件. 这个时候核心就已经开始接管BOIS后的工作了.

**核心文件放在 /boot 分区内,并取名为 vmlinuz .**
```bash
$ls --format=single-column -F /boot

config-3.10.0-229.el7.x86_64              #此版本核心被编译时选择的功能与模块配置文件,才
grub/  									  #旧版	grub1	，不需要理会这目录了！
grub2/ 									  #就是开机管理程序	grub2	相关数据目录
initramfs-0-rescue-309eb890d3d95ec7a.img  #下面几个为虚拟文件系统 文件！这一个是用来救援的！
initramfs-3.10.0-229.el7.x86_64.img	      #正常开机会用到的虚拟文件系统
initramfs-3.10.0-229.el7.x86_64kdump.img  #核心出问题时会用到的虚拟文件系统
System.map-3.10.0-229.el7.x86_64          #核心功能放置到内存位址的对应表
vmlinuz-0-rescue-309eb890d09543d95ec7a*   #救援用的核心文件
vmlinuz-3.10.0-229.el7.x86_64*	          #就是核心文件啦！最重要者！6.5M 左右
```
Linux核心是可以通过动态载入核心模块的(也就是驱动程序),这些核心模块放置在**`/lib/modules/`**目录内.
由于核心模块放置到磁盘根目录(/lib必须和 / 在一个分区),因此开机过程中核心必须挂载根目录,这样才能够读取核心模块提供载入驱动程序的工呢能.
**开机过程中 根目录是以只读的方式来挂载的**
**非必要的功能且可以编译成模块的核心功能,目前Linux发行版 都会将它编译成模块,因此USB,STA,SCSI...等磁盘设备的驱动都是以模块的方式来存在的.**

- **Linux是安装在SATA磁盘上面的,可以通过BIOS的 INT 13 取得 boot loader 与 kernel 文件来开机,然后kernel会开始接管系统并侦测硬件 以及尝试挂载根目录来取得额外的驱动程序.**
  - **但是这个时候核心却根本不认识SATA磁盘,所以需要 SATA磁盘的驱动程序 否则无法挂载根目录,但驱动程序在/lib/modules 内,无法读取. 这个时候使用下面的方式来进行处理**
    - **通过虚拟文件系统来处理这个问题(lnitial RAM Disk或 lnitial RAM Filesystem),一般文件名为 `/boot/initrd` 或 `/boot/initramfs`.**
	  - **`initramfs`这个文件特色是:他能够通过boot loader来载入到内存,然后这个文件会被解压缩并且在内存当中仿真成一个根目录,且此仿真在内存当中的文件系统能够提供一个可执行的程序,通过该程序来载入开机过程中最需要的核心模块,通常这些模块都是 USB,RAID,LVM,SATA 等文件系统与磁盘接口的驱动程序,等载入完成后,会帮助核心重新调用systemd 来开始后续的正常开机流程**
      - **当必要的驱动都载入完成后,内核会将这个虚拟的文件系统卸载掉,并挂载实际的根目录文件系统,开始后续的正常开机流程**
      - **可以使用这个命令来挂载并查看initramfs内容`lsinitrd /boot/initramfs-3.10.0-229.el7.x86_64.img`**


### 第一个程序 systemd 及使用 default.target 进入开机程序分析

**在核心载入完毕,进行完硬件侦测与驱动程序载入后,此时主机硬件已经准备就绪了,这个时候核心会主动调用第一支进程 systemd.**
**systemd 最主要的功能就是准备软件执行的环境,包括系统的主机名称,网络设置,语系处理,文件系统格式 及其他服务的启动等等, 所有的动作都会通过 systemd 的默认启动服务集合`/etc/systemd/system/default.target` 来规划.**

- Centos7 的 systemd 开机流程是这样的:
  - locale-fs.target + swap.target  :这两个 target(操作界面服务单元) 主要是挂载本机 /etc/fstab 里面所规范的文件系统与相关的内存交换空间.
  - sysinit.target  :这个target 主要在侦测硬件,载入所需的核心模块等动作.
  - basic.target  :载入主要的周边硬件驱动程序与防火墙相关服务.
  - multi-user.target 下面的其他一般系统或网络服务的载入
  - 图形界面相关服务 如gdm.service 等其他服务的载入

#### systemd 执行 sysinit.target 初始化系统, basic.target 准备系统
**使用`systemctl list-dependencies sysinit.target` 来查看的话,会发现很多相依的服务, 这些服务一个一个去查询设置脚本的内容就能大致理解每个服务的意义.**
- 基本上 所有的服务归类成几个大项目:
  - 特殊文件系统设备的挂载  :包括 dev-hugepages.mount, dev-mqueue.mount 等挂载服务.
    - 主要在挂载跟巨量内存分页使用与讯息存储的功能,挂载成功之后会在 /dev 下创建 hugepages,mqueue 等目录。
  - 特殊文件系统的启用: 包括磁盘阵列,网络磁盘(iscsi) ,LVM文件系统,文件系统对照服务(multipath) 等,也会在这里被侦测与使用到.
  - 开机过程的讯息传递与动画执行: 使用 plymouthd 服务搭配plmouth 指令来传递动画与讯息.
  - 日志式登陆文件的使用 : 就是systemd-journald 这个服务的启用.
  - 载入额外的核心模块 : 通过 `/etc/modules-load.d/*.conf` 文件的设置,让核心额外载入管理员所需要的核心模块.
  - 载入额外的核心参数设置: 包括 `/etc/sysctl.conf` 以及 `/etc/sysctl.d/*.conf` 内部设置.
  - 启动系统的乱数产生器: 乱数产生器可以帮助系统进行一些密码加密演算的功能
  - 设置终端机(console)字形
  - 启动 动态设备管理员 : 就是udevd 这个,用在动态对应实际设备存取与设备文件名对应的一个服务,非常重要,也是在这里启动.

**sysinit.target 在初始化系统,而 basic.target 则是在启动一个简单的操作系统.
- basic.target 的阶段主要启动的服务有:
  - 载入 alsa 音效驱动程序
  - 载入 firewalld 防火墙
  - 载入 CPU 的微指令功能
  - 启动与设置 SELinux 的安全文本
  - 将目前的开机过程所产生的开机信息写入到 /var/log/dmesg 当中
  - 由 `/etc/sysconfig/modules/*.modules`及`/etc/rc.modules`载入管理员指定的模块
  - 载入 systemd 支持的 timer 功能


#### systemd 启动 multi-user.target 下的服务
- 服务的启动脚本设置都是放在下面的目录内
  - **`/usr/lib/systemd/system`**  系统默认的服务启动脚本设置
  - **`/etc/systemd/system`**  管理员自己开发与设置的脚本设置
**想要开机自启动某个服务的话 将它的脚本链接到 `/etc/systemd/system/multi-user.target.wants/`这个目录即可**

**系统完成开机后,可以让系统额外执行某些程序,只需要将该程序命令或脚本的绝对路径名称写入到 `/etc/systemd/system` 下面. 然后用 `systemctl enable`的方式启用它.**

**在multi-user.target 下面还有个 getty.target 的操作界面项目,主要是提供适当的登陆服务(tty界面之类的),这个项目包括 systemd-logind.service , systemd-user-sessions.service 等服务, 这些服务必须全部启动之后,用户才可以登陆系统.**


### 开机过程会用到的主要配置文件
**很多服务的脚本设置会去读取 `/etc/sysconfig/` 下面的环境配置文件.**

#### 关于模块 /etc/modprobe.d/x.conf 及 /etc/modules-load.d/x.conf
- **`/etc/modules-load.d/*.conf` :单纯要核心载入模块的位置**
- **`/etc/modprobe.d/*.conf`  :可以加上模块参数的位置**

**`/etc/sysconfig/` 这个目录下都是一些环境配置文件**
- authconfig: 规范使用者的身份认证机制
- cpupower  :Liunx核心如何操作CPU的原则.(需要启动 cpupower.service)
- firewalld, iptables-config, ip6tables-config, ebtables-config  :与防火墙服务的启动外带的参数有关.
- network-scripts/  :这个目录的内容主要是设置网卡的.


## 核心与核心模块

**在整个开机的工程当中,是否能够成功的驱动我们主机的硬件配备,是核心(kernel)的工作.**
**核心一般都是压缩文件(6.5M左右),在使用前需要将它解压,之后才能载入内存**

- 核心和核心模块(硬件驱动) 存放的位置
  - 核心 : /boot/vmlinuz 或 /boot/vmlinuz-version
  - 核心解压所需 RAM Disk: /boot/initramfs (/boot/initramfs-version)
  - 核心模块 : /lib/modules/version/kernel 或 lib/modules/$(uname -r)/kernel 
  - 核心源代码 : /usr/src/linux 或 /usr/src/kernels/  (要安装才会有.默认不安装)

如果该核心顺利的载入系统当中了,那么就会有几个信息记录下来:
- 核心版本 :/proc/version
- 系统核心功能 : /proc/sys/kernel/

**如果有新的硬件,但是操作系统不支持 的两种解决方法**
- 重新编译核心, 并加入最新的硬件驱动程序源代码.
- 将该硬件的驱动程序编译成模块, 在开机时载入该模块.

### 核心模块与相依性
模块之间的相关性是 核心提供的.
- **核心模块的放置处是在 `/lib/modules/$(uname -r)/kernel` 当中,里面还分成了几个目录**
  - arch    :与硬件平台有关的项目, 例如 CPU 的等级 之类的
  - crypto  :核心所支持的加密的技术, 例如 md5 或者是 des  等等
  - drivers :一些硬件的驱动程序,例如显卡,网卡,PCI 等相关硬件等等
  - fs    :核心所支持的 filesystem ,例如 vfat,nfs , reiserfs 等等
  - lib   :一些函数库
  - net   :与网络有关的各项协定数据,还有防火墙模块 (net/ipv4/netfilter/*) 等
  - sound :与音效有关的各项模块

**文件 `/lib/modules/$(uname -r)/modules.dep` 记录了在核心支持的模块的各项相依性.**
**使用 depmod 这个指令可以达到创建这个文件的需求**
**核心模块的拓展名一定是 .ko 结尾的**
```bash
$depmod  [-Ane]
选项与参数:
-A  :不加任何参数,,depmod 会主动分析目前核心的模块,并且重新写入 modules.dep 当中
     若加入 -A 参数时,则 depmod会寻找比 modules.dep 内还要新的模块,如果真的找到新模块,才会更新.
-n  :不写入 modules.dep ,而是将结果输出到屏幕上(standard out)
-e  :显示出目前已载入的不可执行的模块名称


范例: 一个网卡(核心模块)驱动程序 a.ko ,放入核心驱动 并更新相依性
$cp a.ko  /lib/modules/$(uname -r)/kernel/drivers/net
$depmod
```

### 核心模块的观察
使用lsmod 来查看核心载入了多少模块

```bash
$lsmod       #没有参数,直接输入即可  
输出:
模块名称           模块的大小  此模块是否被其他模块所使用,也就是该模块为后面模块的前提条件.
Module                  Size   Used by
xt_REDIRECT            16384   2
nf_nat_redirect        16384   1 xt_REDIRECT
xt_tcpudp              16384   5
ip_tables              28672   2 iptable_filter,iptable_nat
x_tables               45056   5 iptable_filter,xt_tcpudp,ipt_MASQUERADE,ip_tables,xt_REDIRECT
ipv6                  466944   62 bridge,ip_vs
...省略很多
```

**使用 modinfo 来查看 内核模块的详细信息**

```bash
$modinfo   [-adln]  [module_name|filename]
选项与参数:
-a  :仅列出作者名称
-d  :仅列出 modules(模块) 的说明 (description)
-l  :仅列出授权 (license)
-n  :仅列出该模块的详细路径

范例: 列出stp 模块的相关信息 (除了直接给出模块名,还可以给出模块的绝对路径文件名)
$modinfo  stp
输出:
filename:       /lib/modules/4.14.114-OPENFANS+20190712-v8/kernel/net/802/stp.ko
license:        GPL
srcversion:     AFBB842A0563D27C8F56BBF
depends:        llc
intree:         Y
name:           stp
vermagic:       4.14.114-OPENFANS+20190712-v8 SMP preempt mod_unload modversions aarch64
```

### 核心模块的载入与移除
**最好的情况还是使用 modprobe 这个指令来自动载入模块,而且还会设置相关性.**
**insmod 则完全是由使用者自行载入一个完整文件名的模块,并不会主动分析模块的相依性**
```bash
#不建议使用这两个
$insmod  [模块文件绝对路径] [参数]    #载入模块
$rmmod   [-fw]   模块名               #移除模块
选项与参数:
-f  :强制将该模块移除掉,无论是否正被使用

范例: 尝试载入 fat.ko 这个 "文件系统模块"
$insmod  /lib/modules/$(uname -r)/kernel/fs/fat/fat.ko

范例: 强制卸载 fat.ko 这个 文件系统模块
$rmmod  -f  fat
```
```bash
$modprobe   [-cfr]  模块名
选项与参数:
-c   :列出目前系统所有的模块 (更详细的代号对应表),数据量很庞大.
-f   :强制载入该模块.
-r   :移除该模块
不加选项直接写模块名,则表示载入该模块


范例: 载入 vfat 模块
$modprobe vfat

范例: 卸载 vfat 模块
$modprobe -r vfat
```

#### 核心模块的额外参数设置 : /etc/modprobe.d/*.conf
```bash
只需要在 /etc/modprobe.d/ 目录内,创建和模块名相同的 .conf文件即可,该文件的书写个数如下.

例如:是  fat.ko  模块的额外参数:
文件名为    :  fat.conf    
文件内容如下:
options  fat  ports=555
#表示 fat 的额外参数是 ports=555 ,如果fat是自己写的驱动,那么这个额外参数的规范也是自己设计的.
```


## Boot Loader: Grub2
boot loader 是载入核心的重要工具,没有 boot loader 的话,核心根本就没办法被系统载入.

### boot loader 的两个 stage(阶段)
MBR是整个硬盘的第一个sector(扇区),整个大小才 446bytes .很小很小.无法全部安装 boot loader.
所以使用了分阶段的形式来解决容量过小的问题.
- 阶段1, boot loader 的程序码执行 :
  - 执行boot loader主程序, 这个主程序必须安装在开机区,就是MBR或boot sector ,通常仅安装最小主程序.
- 阶段2, 主程序载入配置文件 :
  - 通过 boot loader 载入所有配置文件与相关的环境参数文件(包括文件系统定义与主要配置文件 grub.cfg), 一般来说配置文件都在 /boot 下面

**与grub2 有关的文件都放置在 `/boot/grub2` 中.**

#### /boot/grub2 目录中的内容
```bash
$ls -lh  /boot/grub2
-rw-r--r--. 1 root root   64 Oct  9 18:47 device.map   #grub2 的设备对应档
drwxr-xr-x. 2 root root 4.0K Oct  9 18:47 fonts        #开机过程中的画面会使用到的字图数据
-rw-r--r--. 1 root root 4.9K Oct  9 18:48 grub.cfg     #grub2 的主配置文件,非常重要
-rw-r--r--. 1 root root 1.0K Oct  9 18:48 grubenv      #一些环境区块的符号
drwxr-xr-x. 2 root root  12K Oct  9 18:47 i386-pc      #针对一般 X86 PC所需的 grub2 的相关模块
drwxr-xr-x. 2 root root 4.0K Oct  9 18:47 locale       #语系相关的数据
drwxr-xr-x. 1 root root 4.0K Oct  9 18:47 themes       #开机主题画面数据

$ls -lh /boot/grub2/i386-pc
total 2.4M
-rw-r--r--. 1 root root 9.8K Oct  9 18:47 acpi.mod      #电源管理有关的模块
-rw-r--r--. 1 root root 5.5K Oct  9 18:47 ata.mod       #磁盘有关的模块
-rw-r--r--. 1 root root 3.8K Oct  9 18:47 command.lst   #运行 loader 控制权移交的相关模块
-rw-r--r--. 1 root root  24K Oct  9 18:47 efiemu.mod    #与 UEFI BIOS 相关的模块
-rw-r--r--. 1 root root 5.5K Oct  9 18:47 ext2.mod      #EXT 文件系统家族相关模块
-rw-r--r--. 1 root root 5.5K Oct  9 18:47 fat.mod       #FAT 文件系统模块
-rw-r--r--. 1 root root 3.7K Oct  9 18:47 gcry_md5.mod  #常见的加密模块
-rw-r--r--. 1 root root 8.2K Oct  9 18:47 gcry_sha1.mod
-rw-r--r--. 1 root root 4.2K Oct  9 18:47 gcry_sha256.mod
-rw-r--r--. 1 root root 8.6K Oct  9 18:47 gcry_sha512.mod
-rw-r--r--. 1 root root 8.4K Oct  9 18:47 iso9660.mod   #光盘系统模块
-rw-r--r--. 1 root root 6.6K Oct  9 18:47 lvm.mod       #LVM 文件系统模块
-rw-r--r--. 1 root root 2.0K Oct  9 18:47 mdraid09.mod  #软件磁盘阵列模块
-rw-r--r--. 1 root root 3.5K Oct  9 18:47 minix.mod     #MINIX 相关文件系统模块
-rw-r--r--. 1 root root 2.4K Oct  9 18:47 msdospart.mod   #一般 MSB 分区表
-rw-r--r--. 1 root root 2.4K Oct  9 18:47 part_gpt.mod    #GPT 分区表
-rw-r--r--. 1 root root 2.4K Oct  9 18:47 part_msdos.mod  #MBR 分区表
-rw-r--r--. 1 root root 2.4K Oct  9 18:47 scsi.mod      #SCSI 相关模块
-rw-r--r--. 1 root root 2.4K Oct  9 18:47 usb_keyboard.mod  #USB相关模块
-rw-r--r--. 1 root root 2.4K Oct  9 18:47 usb.mod           #也是USB相关模块
-rw-r--r--. 1 root root 2.4K Oct  9 18:47 vga.mod           #VGA 显卡相关模块
-rw-r--r--. 1 root root 2.4K Oct  9 18:47 xfs.mod           #XFS 文件系统相关模块
```

### grub2 配置文件 /boot/grub2/grub.cfg 初探
- grub2 的优点:
  - 认识与支持较多的文件系统,并且可以使用 grub2 的主程序直接在文件系统中搜寻核心文件名.
  - 开机的时候,可以"自行编辑与修改开机设置项目",类似于 bash 的指令模式.
  - 可以动态搜寻配置文件,而不需要再修改配置文件后重新安装grub2.只要修改完配置文件的设置后,下次开机就生效了.

#### 磁盘与分区在 grub2 中的代号
**安装在 MBR 的grub2 主程序,最重要的任务之一就是从硬盘当中载入核心文件,让核心能够顺利的驱动整个系统的硬件.**
**grub2 必须要认识硬盘才可以.**
- grub2 对硬盘的识别使用的是如下代号:
  - **`(hd0,1)`**      #一般的默认语法,由grub2自动判别分区格式,这个表示 第一个硬盘的第一个分区.(指的是分区,而不是硬盘)
  - **`(hd0,msdos1)`**  #此磁盘的分区为传统的 MBR 模式
  - **`(hd0,gpt1)`**     #此磁盘的分区为 GPT 模式
- 注意事项:
  - 硬盘代码以小括号 () 包起来.
  - 硬盘以 hd 表示, 后面会接一组数字.
  - 以 "搜寻顺序" 作为硬盘的编号 !  这个很重要!
  - 第一个搜寻到的硬盘为0号, 第二个为1号, 以此类推
  - 每颗硬盘的第一个 partition(分区) 代号为1 ,以此类推
**当电脑仅有一颗SATA磁盘时,第一个逻辑分区在Linux设备文件是 /dev/sad5 (前面的留给主分区与拓展分区),在grub2则是(hd0,5)**

#### /boot/grub2/grub.cfg  配置文件

- set root="hd0,gpt2"   这是root指定的grub2配置文件所在的那个设备,而在Linux则是/dev/sda2
- linux16 /boot/vmlinuz-3.10.0-1062.el7.x86_64 root=UUID=4fb341da-f554-492e-bdc5-34c11683ce89 ro consoleblank=0 crashkernel=auto rhgb quiet LANG=en_US.UTF-8
  - Linux核心文件及核心执行时所下达的参数.一般都是使用UUID来挂载根目录.
- initrd16 /boot/initramfs-3.10.0-1062.el7.x86_64.img
  - 就是虚拟文件系统 文件


#### grub2 配置文件维护 /etc/default/grub  与 /etc/grub.d
**/etc/default/grub 主要环境配置文件,修改这个文件就可以间接的修改 grub.cfg文件了**
```bash
$cat  /etc/default/grub

GRUB_TIMEOUT=5        #指定默认倒数读秒的秒数
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved     #指定默认由哪一个菜单来开机,默认开机菜单之意
GRUB_DISABLE_SUBMENU=true    #是否要隐藏次菜单, 通常都是隐藏起来的.
GRUB_TERMINAL_OUTPUT="console"     #指定数据输出的终端机格式,默认是通过文字终端机
GRUB_CMDLINE_LINUX="consoleblank=0 crashkernel=auto rhgb quiet"    #核心的外加参数功能
GRUB_DISABLE_RECOVERY="true"   #取消救援菜单的制作

```
**当 /etc/default/grub 这个文件修改完成之后,相同步到grub.cfg 的话,使用 `$grub2-mkconfig -o /boot/grub2/grub.cfg` 来进行重建,这样才会生效.**

##### 菜单创建的脚本  /etc/grub.d/*
`grub2-mkconfig` 命令会去分析 **`/etc/grub.d/`** 里面的文件,后去执行该文件来创建 grub.cfg,也就是抓到Linux的核心.
- `/etc/grub.d/` 目录的内容
  - 00_header:  主要在创建初始化的显示项目,包括需要载入的模块分析,屏幕终端机的格式,倒数秒数,菜单是否需要隐藏等等, 大部分在 `/etc/default/grub/` 里面所设置的变量,大概都会在这个脚本当中被利用来重建grub.cfg.
  - 10_linux: 根据分析 /boot 下面的文件,尝试找到正确的 Linux 的核心与读取这个核心需要的文件系统与参数等,在这个脚本运行后找到并设置到 grub.cfg 当中.
    - 这个脚本将所有在 /boot 下面的每一个核心都对应到一个菜单,因此核心文件数量越多,开机菜单项目就越多. 
	  - 如果不想要旧的核心出现在菜单上,那可以通过移除旧核心来处理即可.
  - 30_os-prober : 这个脚本默认会到系统上找其他的 partition 里面可能含有的操作系统,然后将该操作系统当成菜单来处理.
    - 如果不想找其他的系统,那么可以在 `/etc/default/grub` 里面加上 **GRUB_DISABLE_OS_PROBER=true**,取消这个文件的运行.
  - 40_custom :  如果还有其他想自己手动加上去的菜单项目,或者是其他的需求,那么可以在这个文件内补充.
**也就是说,只可以将新的功能添加到 40_custom 这个文件就可,其他的不要乱动**

**在 `/boot/grub2/grub.cfg` 这个文件中,有个 menuentry 功能,也就是一个菜单,可以选择开机的核心.**
- 直接指定核心开机
  - 其实这部分是由`grub2-mkconfig` 去抓取  10_linux 这个脚本直接制作的,不需要关心,如果是想加入额外参数的话,就使用下面的步骤加入:
    - 先到 `/boot/grub2/grib.cfg` 当中取得想要制作的那个核心的菜单项目,然后将它复制到40_custom 当中.
	- 然后再到 40_custom 当中,根据需求进行修改即可.

##### 通过chain loader 的方式移交 loader 控制权
chain loader(开机管理程序的链接) 仅是在将控制权交给下一个 boot loader 而已,不需要 grub2 认识与找出 kernel 的文件名, 只是将 boot 的控制权交给下一个boot sector(启动扇区) 或 MBR内的boot loader 而已.

- chain loader 只需要设置两个内容就可以了
  - 一个是预计前往的 boot sector 所在的分区代号
  - 另一个是设置 chain loader  在那个分区的 boot sector(第一个扇区)上

```bash
假设 /dev/sda2 是 windows7系统, 现在需要额外两个开机选项,一个是取得win7的开机菜单,一个是回到MBR的默认环境.
win7在/dev/sda2 就是 hd0,msdos2 , MBR就是 hd0

$vim  /etc/grub.d/40_custom
#添加如下内容
menuentry 'Go to Windows 7' --id 'win7' {
	insmod chain
	insmod ntfs
	set root=(hd0,msdos2)
	chainloader +1
}
menuentry 'Go to MBR' --id 'mbr' {
	insmod chain
	set root=(hd0) 
	chainloader +1
}

#添加完成后进行重建 /boot/grub2/grub.cfg
$grub2-mkconfig -o /boot/grub2/grub.cfg

#如果想把win7变成默认开机选项,那么一可以在 /etc/default/grub 当中设置 "GRUB_DEFAULT=win7" 然后再grub2-mkconfig即可.
#win7 表示的是 --id 的内容,不需要计算 menuentry 的顺序.
```

#### initramfs 的重要性与创建心 initramfs 文件
**initramfs 的目的在于提供开机过程中所需要的最重要核心模块,以让系统开机过程可以顺利完成,主要以文件系统及硬盘模块(USB,SATA)为主.**
**initramfs 可以将 `/lib/modules/`内的'开机过程当中一定需要的模块'包成一个文件,然后在开机时通过主机的INT 13 硬件功能将该文件读出来解压缩,并且 initramfs在内存会仿真成根目录,由于此虚拟文件系统(initial RAM Disk) 主要包括磁盘与文件系统的模块,因此核心草能认识实际的磁盘,能够进行实际根目录的挂载.**
**
SATA 硬盘是使用SCSI 模块来驱动的.

  - 根目录所在文件系统为 LVM,RAID 等特殊格式
  - 根目录所在文件系统为非传统 Linux 认识的文件系统时
  - 其他必须要在核心载入时提供的模块


**使用 dracut 或者 mkinitrd 以及 dracut 来制作 initramfs 文件**
```bash
$dracut  [-fv] [--add-drivers 列表] initramfs文件名 核心版本
选项与参数:
-f  :强迫编译出 initramfs ,如果 initramfs文件已存在,则覆盖掉旧文件
-v  :显示 dracut 的运行过程
--add-drivers  :在原本的默认核心模块中,增加某些你想要的模块, 
                模块位于核心所在目录/lib/modules/$(uname -r)/kernel/*
initramfs文件名  :就是你需要的文件名,开头最好就是 initramfs,后面接版本与功能
核心版本         :目前运行中的核心版本,也可以收到输入其他不同版本 $(uname -r)

其他选项
  --modules   :将dracut 所提供的开机所需模块(驱动模块)载入,可用模块在 /usr/lib/dracut/modules.d/ 目录内.
  --gzip | --bzip | -xz  :尝试使用哪一种压缩方式来进行 initramfs 压缩,默认使用gzip
  --filesystems  :加入某些额外的文件系统支持


范例: 以 dracut 的默认功能创建一个 initramfs 虚拟硬盘文件
$dracut  -v  initramfs-test.img  3.10.0-229.el7.x86_64     #内核版本可一通过$(uname -r)来获得

范例: 额外加入 e1000e 网卡驱动与 ext4/nfs 文件系统在新的 initramfs 内
$dracut -v --add-drivers "e1000e"  --filesystems "ext4 nfs"  initramfs-new.img  $(uname -r)
```


### 测试与安装 grub2
**首先,必须使用 grub-install 将一些必要的文件复制到/boot/grub2 里面去**
```bash
$grub2-install  [--boot-directory=DIR]  INSTALL_DEVICE
选项与参数:
--boot-directory=DIR  :DIR为实际目录,使用 grub2-install 默认会将grub2所有文件都复制到/boot/grub2/* 内
                       如果想复制到其他目录与设备区,那么就得使用这个参数了
INSTALL_DEVICE   安装的设备代号


范例: 将 grub2 安装在目前系统的 MBR 下面, 我的系统为 /dev/sda
$grub2-install /dev/sda
#这个时候 /boot/grub2 内的文件应该都更新了.
# 但是 我们并没有配置文件,需要自己创建.

#注意 : 如果填的是 /dev/sda 那么grub2会将loader写入MBR中, 
        如果填的是 /dev/sad1  那么会提示并不支持该文件系统,这个时候需要强制写入
$grub2-install --force --recheck --skip-fs-probe  /dev/sad1

在这之后,将一些开机配置写到 /etc/grub.d/40_custom 中
$vim /etc/grub.d/40_custom
加入的内容:
menuentry 'Goto MBR' {
	insmod chain
	insomd part_gpt      #GPT分区格式的磁盘
	set root=(hd0)
	chainloader +1
}
menumentry 'Goto /dev/sad1' {
	insmod chain
	insmod part_gpt
	set root=(hd0,gpt4)
	chainloader +1
}
```
- 总结
  - 如果是其他 boot loader 转成grub2时,的先使用 grub2-install 安装 grub2**配置文件**
  - 如果安装到partition(分区)时,可能需要加上额外的很多参数才能够顺利安装上去(强制)
  - 编辑 /etc/default/grub 及 /etc/grub.d/* 这几个重要的配置文件
  - 使用 grub2-mkconfig -o /boot/grub2/grub.cfg 来创建**开机的配置文件**


## 小结
- 开机流程: BIOS ,MBR, Loader , kernel + initramfs , systemd 等流程
  - loader 具有 : 提供开机菜单,载入核心文件,转交控制权给其他 loader 等功能.
  - boot loader(开机管理程序) 可以安装在 MBR或者是每个分区的 boot sector(启动扇区) 区域中
  - initramfs 可以俄提供核心在开机过程中所需要的最重要的模块,通常与磁盘以及文件系统有关的模块
  - systemd 的配置文件主要来自 `/etc/systemd/system/default.target` 项目.
- 额外的设备与模块对应,可写入 `/etc/modprobe.d/*.conf` 中.
- 核心模块(驱动程序) 的管理可使用ismod, modinfo, rmmod, insmod, modprobe 等指令.
- `modprobe`主要参考 `lib/modules/$(uname -r)/modules.dep` 的设置来载入与卸载核心.
- grub2 的配置文件与相关文件系统定义文件大多放置在 `/boot/grub2` 目录中,配置文件名为 grub.cfg
- grub2 对磁盘的代号设置与 Linux不通, 主要通过侦测的顺序来给予设置,如(hd0) 及 (hd0,1) 等
- `grub.cfg` 内的每个餐带都与 menuentry 有关,而直接指定核心开机时,至少需要 linux16 及 initrd16 两个项目.
- grub.cfg 内设置 loader 控制权移交时,最重要者为 chainloader +1 这个项目
- 若想要重建 initramfs(虚拟文件系统), 可使用 dracut 或 mkinitrd 处理
- 重新安装 grub2 到 MBR 或 boot sector 时,可以利用 `grub2-install` 命令来处理
- 若想要进入救援模式,可于开机菜单过程中,在linux16的项目后面加入 'rd.break' 或 'init=/bin/bash' 等方式来进入救援模式
- 可以对 grub2 的个别菜单给予不同的密码
