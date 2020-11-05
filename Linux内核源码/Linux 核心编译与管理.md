# Linux 核心编译与管理
**核心 （ kernel） ”是整个操作系统的最底层， 他负责了整个硬件的驱动， 以及提供各种系统所需的核心功能， 包括防火墙机制、 是否支持 LVM 或 Quota 等文件系统等等， 这些都是核心所负责的**
**如果你的核心不认识某个最新的硬件， 那么该硬件也就无法被驱动， 你当然也就无法使用该硬件**

**编译内核必须要安装相应的工具, `$yum install libelf-dev ncurses-devel  gcc make kernel-devel elfutils-libelf-devel` .这步是必须的,按照内核的版本不同,有可能需要的工具更多.**

## 什么是核心
**其实核心就是系统上面的一个文件而已， 这个文件包含了驱动主机各项硬件的侦测程序与驱动模块.**

**当系统读完 BIOS 并载入 MBR 内的开机管理程序后， 就能够载入核心到内存当中。 然后核心开始侦测硬件， 挂载根目录并取得核心模块来驱动所有的硬件， 之后调用systemd 就能够依序启动所有系统所需要的服务了.**

### 核心模块 （ kernel module） 的用途
**是将一些不常用的 `类似驱动程序的内容` 独立出核心, 编译成为模块, 然后, 核心可以在系统正常运行的过程当中载入这个模块到核心的支持。 如此一来， 我在不需要更动核心的前提之下， 只要编译出适当的核心模块， 并且载入他,这个时候Linux 就可以使用这个硬件.**

**这些被独立出核心的模块位于 `/lib/modules/$(uname -r)/kernel/`  目录下.**

### 更新核心的目的
**除了 BIOS （ 或 UEFI） 之外， 核心是操作系统中最早被载入到内存的咚咚， 他包含了所有可以让硬件与软件工作的信息**
** 核心的编译重点在于“你要你的 Linux 作什么” , 而不是一股脑的加入非常多鸡肋的内容.**
**重新编译核心的最主要目的是“想让系统变的更稳定的运行”.**

- 编译核心可能的目的:
  - 新功能的需求.
  - 原本的内核臃肿,想取消掉一些功能.
  - 与硬件搭配的稳定性,也就是正确的驱动新硬件.
  - 其他需求: 嵌入式系统,自行设计的特殊用途核心

**由于“核心的主要工作是在控制硬件！ ”所以编译核心之前， 请先了解一下你的硬件配备， 与你这部主机的未来功能.**
**由于核心是“越简单越好！ ”所以只要将这部主机的未来功能给他编进去就好了！ 其他的就不用去理他**

**可以使用 patch 文件来进行内核源代码的升级,然后在进行编译,这样很节省带宽,而且也方便.**

### 核心源代码的/下载/解压缩/安装/观察
**Linux内核源码(5.x版本)下载网址 `http://ftp.sjtu.edu.cn/sites/ftp.kernel.org/pub/linux/kernel/v5.x/`, 在里面挑选某个内核,然后使用 `$wget` 来进行下载.**
**例如我下载的是 `linux-5.3.9.tar.gz` 这个核心,所使用的命令就是 `$wget http://ftp.sjtu.edu.cn/sites/ftp.kernel.org/pub/linux/kernel/v5.x/linux-5.3.9.tar.gz `**

#### 解压与放置目录
**Linux 核心源代码一般建议放置于 /usr/src/kernels/ 目录下面**
```bash
#解压命令,到 /usr/src/kernels 目录下面
$mkdir /usr/src/kernels ; tar  -zxv -f  linux-5.3.9.tar.gz  -C /usr/src/kernels/   #文件大约就100MB左右
```
- **核心源代码下的子目录** (就是刚刚解压的核心源代码内的)
  - `arch`  ; 与硬件平台有关的项目， 大部分指的是 CPU 的类别， 例如 x86, x86_64, Xen 虚拟支持等.
  - `block` : 与区块设备较相关的设置数据， 区块数据通常指的是大量储存媒体！ 还包括类似ext3 等文件系统的支持是否允许等
  - `crypto` : 核心所支持的加密的技术， 例如 md5 或者是 des 等
  - `Documentation` : 与核心有关的一堆说明文档.
  - `drivers` ： 一些硬件的驱动程序， 例如显卡、 网卡、 PCI 相关硬件等等
  - `firmware` ： 一些旧式硬件的微指令码 （ 固件） 数据；
  - `fs` ： 核心所支持的 filesystems ， 例如 vfat, reiserfs, nfs 等等
  - `include` ： 一些可让其他程序调用的标头 （ header） 定义数据；
  - `init` ： 一些核心初始化的定义功能， 包括挂载与 init 程序的调用等；
  - `ipc` ： 定义 Linux 操作系统内各程序的沟通；
  - `kernel` ： 定义核心的程序、 核心状态、 线程、 程序的调度 （ schedule） 、 程序的信号（ signle） 等
  - `lib` ： 一些函数库
  - `mm` ： 与内存单元有关的各项数据， 包括 swap 与虚拟内存等；
  - `net` ： 与网络有关的各项协定数据， 还有防火墙模块 （ net/ipv4/netfilter/*） 等等
  - `security` ： 包括 selinux 等在内的安全性设置
  - `sound` ： 与音效有关的各项模块；
  - `virt` ： 与虚拟化机器有关的信息， 目前核心支持的是 KVM （ Kernel base VirtualMachine）

## 核心编译的前处理与核心功能选择
**整个核心编译的重要工作就是在“挑选你想要的功能”。**
### 保持干净源代码： make mrproper
** 了解硬件的相关数据之后,还得要处理一下核心源代码下面的残留文件才行.**
```bash
$make mrproper         #处理掉这些“编译过程的目标文件以及配置文件”, 只有第一次执行核心编译前需要进行这个动作
$make  clean              #删除前一次编译产生的残留数据,但不会删除配置文件.
```

### 开始挑选核心功能： make XXconfig
**在 `/boot/` 下面存在一个名为 `config-xxx` 的文件, 那个文件其实就是核心功能列表文件.**
**下面要进行的动作， 其实就是作出该文件！接下来所要进行的编译动作， 其实也就是通过这个文件来处理的.**
**核心功能的挑选， 最后会在`/usr/src/kernels/linux-5.3.9/` 下面产生一个名为 .config 的隐藏文件， 这个文件就是 `/boot/config-xxx` 的文件**

- **生成这配置文件的方法有:** (建议使用 menuconfig)
  - **make menuconfig 最常使用的， 是文字模式下面可以显示类似图形接口的方式， 不需要启动 X Window 就能够挑选核心功能菜单**
  - make oldconfig 通过使用已存在的 ./.config 文件内容， 使用该文件内的设置值为默认值， 只将新版本核心内的新功能选项列出让使用者选择， 可以简化核心功能的挑选过程！ 对于作为升级核心源代码后的功能挑选来说， 是非常好用的一个项目
  - make xconfig 通过以 Qt 为图形接口基础功能的图形化接口显示， 需要具有 X window 的支持。
  - make gconfig 通过以 Gtk 为图形接口基础功能的图形化接口显示， 需要具有 X window的支持
  - make config 最旧式的功能挑选方法， 每个项目都以条列式一条一条的列出让你选择， 如果设置错误只能够再次选择， 很不人性化
  - 更多方式可以参考核心目录下的 README 文件 .

**可以依据已有的设置来进行更改,也就是 `/boot/conf.xxx` 文件,这样可以更加方便, `cp /boot/config.xxx  linux-5.3.9`.**

```bash
$make menuconfig
	#在执行之后,会提示缺少支持的软件,这个时候使用 yum 一个一个的安装完成就好了,然后再次执行,就会进入一个图形菜单.
#图形菜单的中间是 功能选择区,下面是设定区：
	#功能选择区里面都是各种各样的项目,  —-> 代表后面还有更细致的项目需要来设置
      #设定区只有 Select查看, exit退出, help帮助, save保存, Load载入.
#用法如下：
	#左右方向键 用来选择设定区内容
	#上下方向键 用来选择功能区内容
	#选定项目： 以“上下键”选择好想要设置的项目之后， 并以“左右键”选择 <Select> 之后，按下“ Enter ”就可以进入该项目去作更进一步的细部设置；
	#可挑选之功能： 在细部项目的设置当中， 如果前面有 [ ] 或 < > 符号时， 该项目才可以使用 “空格键”来选择
	#若为 [ * ]  < * > 则表示编译进核心； 若为 <M> 则表示编译成模块！ 尽量在不知道该项目为何时， 且有模块可以选， 那么就可以直接选择为模块
	#当在细项目选择 <Exit> 后， 并按下 Enter ， 那么就可以离开该细部项目

#建议： 
	#“肯定”核心一定要的功能， 直接编译进核心内；
	#“可能在未来会用到”的功能， 那么尽量编译成为模块；
	#“不知道那个东西要干嘛的， 看 help 也看不懂”的话， 那么就保留默认值， 或者将他编译成为模块；
```
### 核心功能细项选择
 - **General setup**
  - 与 Linux 最相关的程序互动、 核心版本说明、 是否使用发展中程序码等信息都在这里设置的
  - 这里的项目主要都是针对核心与程序之间的相关性来设计的， 基本上， 保留默认值即可
  - 不要随便取消下面的任何一个项目， 因为可能会造成某些程序无法被同时执行的困境
  - **这个核心功能下的内容有:**
    - `(vvbt) Local version - append to kernel release`   希望核心版本为 5.3.9.vvbt, 就是uname -r 命令输出的内容.
      - `[ * ] Automatically append version infomation to the version string`  让核心版本成为5.3.9.vvbt 的设置生效,并写入内核
    - `Kernel comperssion mode (Bzip2) —->`    核心压缩比, 建议选择 Bzip2, 性能较好
    - `<M> Kernel .config support`    内核配置文件的设置,存放到模块中,而不是在内核
     - `[ ] Enable access to .config through /proc/config.gz(NEW)` 让.config 这个核心功能列表写入到模块目录下,就不需要.config文件了
    - `(20) Kernel log buffer size(16==>64KB,17==>128kB)` 核心登陆文件容量, 数值是2的N次方, 2的20次方,大概是1MB
    - `Initial RAM filesystem and RAM disk(initramfs/initrd) support`  支持开机时载入 虚拟根目录文件系统
      - `() Initaramfs source  file(s)`  虚拟文件系统源文件的文件名
    - ` [ ] Configure standard kernel features (expert users)  --->`    配置标准内核功能(专家模式),用来决定是否支持 嵌入式系统
    - `[ ] embedded system`  是否支持嵌入式系统
- **loadable module + block layer**
  - 让核心能够支持动态的核心模块
    - ` [*] Enable loadable module support  --->`  启动动态加载模块支持,这个必须要打开的(除了死板的嵌入式)
      - `[*]   Forced module loading                                                           `      强制加载模块
      - `[*]   Module unloading                                                                `   模块卸载
      - `                [*]     Forced module unloading                                                     `  强制卸载模块 (这个必须开,除了嵌入式))
      - `                [*]   Module versioning support                                                       `   模块版本支持
      - `                [*]   Source checksum for all modules`   所有模块的源校验和
      - `   [*]   Module signature verification                                                    `    模块签名验证
      - `                [ ]     Require modules to be validly signed                                        `  要求模块有效签名
      - `                [*]     Automatically sign all modules                                                `   自动签署所有模块
      - `Which hash algorithm should modules be signed with? (Sign modules with SHA-256)`   模块应该使用哪种哈希算法,默认给SHA256即可
      - `                [ ]   Compress modules on installation                                                `   安装时解压模块
      - `               [ ]   Trim unused exported kernel symbols`   修剪未使用的导出内核符号
    - `-*- Enable the block layer  --->`     启用块层,也就是 ext4 或usb等支持,前面的符号表示的是默认启用的 
      - 这下面的内容,基本的都启用就可以了,都和文件系统有关.
- **Processor type and features** 
  - **CPU的类型与功能选择, 这里必须要知道 CPU的型号和所能支持的内容,以及虚拟化之类的内容**
    - `[*] Symmetric multi-processing support`  对称多核心处理器支持,
    - `[*] Linux guest support --->`   提供 Linux 虚拟化功能 
      - `-*- Enable paravirtualization code`  启用半虚拟化代码
      - `[*] Paravirtualization layer for spinlocks` 自旋锁的半虚拟化层
      - `[*] Xen guest support`   Xen 来宾支持
      - `[*] KVM Guest support （ including kvmclock)`   KVM Guest支持（包括kvmclock）
      - `[*] Paravirtual steal time accounting`   半虚拟窃取时间记录
    - ` Processor family (Generic-x86-64)  --->`   处理器家族, 志强,还是其他什么的.就4种类型.
    - `[*] Enable Maximum number of SMP Processors and NUMA Nodes`   启用SMP处理器和NUMA节点的最大数量
    - `[*] Multi-core scheduler support`    **多核调度程序支持**
    - `Timer frequency (1000 HZ)  --->`    **计时器频率,服务器多用户登陆调整到300, 个人桌面版调整到1000**
- **Power management and ACPI options**
  - **电源管理功能**
    - `[*] ACPI （ Advanced Configuration and Power Interface） Support --->`   ACPI(高级配置和电源接口支持)
    - `CPU Frequency scaling  --->`  CPU 频率缩放,ondemand选项 和 决定了CPU的频率.
      - `Default CPUFreq governor (ondemand)  --->`   默认的CPUFreq调控器（ondemand按需) .这样设置比较好
      - `[*]   CPU frequency transition statistics`   CPU频率转换统计,  可开可不开. 无所谓
      - 底下的内容 基本上都和省电有关,能开则开.
- **“Bus options (PCI etc.)**
  - **一些总线(bus)的选项，分为最常见的 PCI 与 PCI-express 的支持， 还有笔记本电脑常见的 PCMCIA 插卡啊！ 要记住的是， 那个 PCI-E 的接口务必要选取！ 不然你的新显卡可能会捉不到**
    - `[*] Support mmconfig PCI config space access`   支持mmconfig PCI配置空间访问
    - `[ ] Mark VGA/VBE/EFI FB as generic system framebuffer`   将VGA / VBE / EFI FB标记为通用系统帧缓冲区
- **Executable file formats  --->**
  - **编译后可执行文件的格式, 是给 Linux 核心运行可执行文件之用的数据,通常与编译行为有关,目录下的内容必须选择**
    - `  -*- Kernel support for ELF binaries                                                   `    ELF二进制文件的内核支持
    - `[*] Write ELF core dumps with partial segments                                        `   编写带有部分段的ELF核心转储
    - `               <*> Kernel support for scripts starting with #!                                      `    对以 #!  开头的脚本的内核支持 
    - `                <M> Kernel support for MISC binaries`   <M>对MISC二进制文件的内核支持
- **Networking support**
  - **核心的网络功能,以及防火墙项目, 防火墙的绝大多部分内容都可以设置成模块,而不是全部编入内核.  还有一部分蓝牙和红外线之类的**
    - `Networking options  --->`  网络选项,里面基本都是重要的防火墙项目,尽量编译成模块
    - `Bluetooth subsystem support`    蓝牙支持模块, 除了必要的选项之外,其他的都变成模块
    - `-*-   Wireless  --->`   这个则是无线网络设备， 里面保留默认值， 但可编成模块的就选模块
    - `< >   WiMAX Wireless Broadband support  ---->`  新一代无线网络, 尽量也变成模块
    - `NFC subsystem support -->`   NFC卡片有关的芯片驱动
- **Device Drivers**
  - ** 所有硬件设备的驱动程序库,这里面的内容非常关键,尽量一个一个的去设置**
    - `<M> Serial ATA and Parallel ATA drivers (libata)  --->`  就是 SATA/IDE 磁盘, 大多数选择为模组
    - `[*] Multiple devices driver support (RAID and LVM)  --->`   多设备驱动程序支持 LVM与 RAID
    - `-*- Network device support  --->`  网络设备支持
      - `[*]   Network core driver support`  网络核心程序驱动支持
      - `<M>     Bonding driver support`   与网卡整合有关的项目,必须要选
      - `<M>     Ethernet team driver support  --->`    以太网团队驱动程序支持
      - `<M>     Virtio network driver`  虚拟化的网卡驱动程序
      - ` -*-   Ethernet driver support  --->`   以太网驱动程序支持,里面有非常多的网卡驱动,还有一堆10G 卡,要选.
        - `<M>     Chelsio 10Gb Ethernet support`   <M>     Chelsio 10Gb 以太网支持
        - `<M>     Intel(R) PRO/10GbE support`   支持英特尔®PRO / 10GbE
      - `<M>   PPP (point-to-point protocol) support`   PPP点对点协议支持
      - `<*>   USB Network Adapters  --->`   USB网络适配器, 全部变为模组.
      - `[*]   Wireless LAN  --->`   无线网卡很重要,全部编译成模组
    - `-*- GPIO Support  --->`  树莓派和香蕉派会需要这里面的内容.
    - ` <M> Multimedia support  --->`    多媒体支持,影像摘取,广播声卡 等.
    - ` Graphics support  --->`    显卡. 图像支持 ,图形操作界面会需要这里面的东西
    - `  <M> Sound card support  --->`  声卡, 也是图形操作界面需要
    - ` [*] USB support  --->`   USB支持, 下面也有一些很重要的选项
      - `<*>   xHCI HCD (USB 3.0) support`   对 USB3.0 的支持
      - `<*>   xHCI HCD (USB 2.0) support`    对 USB 2.0 的支持
      - `<*>   OHCI HCD (USB 1.1) support`    对 USB1.1 的支持
      - `<*>   UHCI HCD (most Intel and VIA) support`   <*> UHCI HCD（大多数Intel和VIA）支持
    - `<M> InfiniBand support  --->`    较高阶的网络设备,速度通常达到 40GB 以上
    - `<M> VFIO Non-Privileged userspace driver framework  --->`    VFIO非特权用户空间驱动程序框架,作为VGA passthrought(直通)用
      - `[*]     VFIO PCI support for VGA devices`     VFIO PCI支持VGA设备
    - `[*] Virtualization drivers  ---->`    虚拟化的驱动程序 
    - `[*] Virtio drivers  --->`   Virtio 驱动程序,在虚拟机里面很重要的驱动程序项目
    - `[*] IOMMU Hardware Support  --->`  IOMMU 硬件支持,同样与虚拟化相关性高.
- **file systems**
  - **文件系统支持**
    - `<M> Second extended fs support`    第二个拓展的 fs 支持,需要启用它,才可以支持其他的主文件系统
    - `<M> The Extended 4 (ext4) filesystem`    扩展4（ext4）文件系统
    - `<M> Btrfs filesystem support`    Btrfs文件系统支持
    - `[*] Network File Systems  --->`   网络文件系统支持
    - `-*- Native language support  --->`    默认文件系统支持的语系, 非常重要
      - `(utf8) Default NLS Option`   选择 utf8 这个语系
- **Kernel hacking**
  - **核心设置,给默认值,不乱动,除非进行核心方面的研究**
- **Security options**
  - **信息安全方面, 包括 SELinux**
- **Cryptographic API**
  - **密码应用,默认加密是 SHA这种机制了, 不需要改动什么.**
- **Virtualization**
  - **虚拟化,Linux默认的是 KVM**
- **Library routines**
  - **函数库**

## 核心的编译与安装
**核心的使用是依靠grub的.**

### 编译核心与核心模块
```bash
#通过  make help 会得到很多的帮助信息,其中有助于编译的有下面这些:
$make vmlinux      #未经压缩的核心
$make modules    #仅核心模块
$make bzImage    #经压缩过的核心（ 默认） 这个是Linux内核的默认值,用来开机使用的.
$make all              #进行上述的三个动作

#进行编译:      (  -j 4  表示的是 使用cpu 4个核心来进行编译,如果支持超线程,那么就是4个线程)
$make -j 4 clean         #先清除暂存盘
$make -j 4 bzImage    #先编译核心, I 是大写的 i , 编译出来的核心文件名应该是 bzImage 
$make -j 4 modules    #再编译模块

$make -j 4 clean bzImage modules      #连续动作是上面两个命令的连续执行, 编译核心,编译模块,免得等待

#如果编译出现错误,那么就是配置文件有错误, 应该逐个恢复,或重新设置.
#如果编译没有出现错误,正确的执行完毕了,那么在 make bzImage 命令之后,会输出一个目录.
	# 应该为 当前源码所在目录的  arch/x86/boot/  这个目录下.
```

### 实际安装模块
**模块或放置到 /lib/modules/$（ uname -r）目录下.**
**当同一个核心版本被反复编译时,会出现模块的安装目录冲突,解决方法是`执行 $make menuconfig  ,进入General setup 内的 Local version 修改成新的名称`即可**
```bash
#模块安装命令
$make modules_install
$ll /lib/modules/
输出:
drwxr-xr-x. 7 root root 4096 May 4 17:56  5.3.9vvbt     #执行命令之后产生的模块目录
```

### 开始安装新核心与多重核心菜单 （ grub）
**编译完成后的核心是 `/usr/src/kernels/linux-5.3.9/arch/x86/boot/bzImage`.**

```bash
#开始安装核心
#首先将  /usr/src/kernels/linux-5.3.9/arch/x86/boot/bzImage 这个核心文件复制到 /boot 目录下,但不能覆盖原有核心
$cp  /usr/src/kernels/linux-5.3.9/arch/x86/boot/bzImage    /boot/vmlinuz-5.3.9.vvbt      #后面是核心命名规则,每个系统都不相同.

#复制配置文件过去,也就是调整好的 .config 文件, 配置文件也有命名规则的,每个系统都不相同
$cp .config    /boot/config-5.3.9.vvbt	       #vvbt和 核心名称相同.毕竟对应的就是那颗核心

#给予核心文件可执行权限, 是所有人的可执行权限,这样才可以被 grub2 载入内存
$chmod   a+x   /boot/vmlinuz-5.3.9.vvbt

#将  核心功能放置到内存位址的对应表 拷贝过去,注意命名
$cp    /usr/src/kernels/linux-5.3.9/System.map     /boot/System.map-5.3.9vvbt

#将 模块记录文件 压缩并拷贝过去,并重命名, 保持与核心的命名规则,内核通过这个文件来加载内核
$gzip -c Module.symvers > /boot/symvers-5.3.9.vvbt.gz

#restorecon命令用来恢复SELinux文件属性即恢复文件的安全上下文. (只有支持SELinux 的才需要)
$restorecon -Rv /boot


#创建 对应的虚拟初始化文件系统 Initial Ram Disk （ initrd）
$dracut -v    /boot/initramfs-5.3.9.vvbt.img    /lib/modules/5.3.9vvbt   #后面这个指的是模块目录 /lib/modules  下的哪个目录名

#编辑开机菜单 （ grub )
	#较新的核心会在最前面 默认开机 启动菜单选项
$grub2-mkconfig -o /boot/grub2/grub.cfg     #重建配置文件即可. 
	#必须要在这个命令的输出内中,找到刚刚复制过去的核心,以及 img 虚拟文件.


#设置默认新内核开机 (也可以修改成原有的内核), 注意:如果这么设置了,一旦出现问题,就会无法开机. 需要在grub界面手动修改grub.cfg文件
$cat /boot/grub2/grub.cfg |grep "menuentry "  # 查看所有可用内核
输出:  
menuentry 'CentOS Linux (3.10.1lq) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.1lq-advanced-87ba1103-a0d7-49ef-a8ae-6ce1d3fd2453' {
menuentry 'CentOS Linux (3.10.0-1062.1.2.el7.x86_64) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted menuentry_id_option 'gnulinux-3.10.0-1062.1.2.el7.x86_64-advanced-87ba1103-a0d7-49ef-a8ae-6ce1d3fd2453' {

		#找到新内核并设置开机
$grub2-set-default   'CentOS Linux (3.10.1lq) 7 (Core)’      #这个是在上个输出结果中寻找的
		#查看是否设置成功
$grub2-editenv list
输出：saved_entry=CentOS Linux (3.10.1lq) 7 (Core)   #成功

#再次重建配置文件 grub2
$grub2-mkconfig -o /boot/grub2/grub.cfg

#核心配置完成,可以重启进行测试新核心了.
#reboot

#使用新核心重启后.
$uname -r    #会出现核心名
5.3.9vvbt



#如果不想保留旧内核, 可以进行删除
$rpm -qa |grep kernel-[0-9]     # 查看全部内核包,找出想要删除的内核
输出：
kernel-3.10.0-1062.el7.x86_64
kernel-3.10.0-1062.1.2.el7.x86_64

#假设我要删除 第一个内核
$yum remove kernel-3.10.0-1062.el7.x86_64      # 删除指定的无用内核

#然后重建 gurb.cfg 文件
$grub2-mkconfig -o /boot/grub2/grub.cfg
```


## 额外（ 单一） 核心模块编译

**硬件开发商需要针对核心所提供的功能来设计他们的驱动程序模块, 核心也就有提供很多的核心工具给硬件开发商来使用.**

**我们如果想要自行使用硬件开发商所提供的模块来进行编译时， 就需要使用到核心所提供的原始文件当中， 所谓的头文件（ header include file） 来取得驱动模块所需要的一些函数库或标头的定义,也就是放在 `/usr/src/kernels/linux-3.10.89/include/` 目录，是借由 build/source 这两个链接文件来取得目录的.**

**核心的源代码放置目录， 那就是以 /lib/modules/$（ uname -r） /build 及 /lib/modules/$（ uname -r） /source 这两个链接文件来指向正确的核心源代码放置目录, 其中 source 指向 build, 而build指向 /usr/src/kernels/$(uname -r) 源文件目录.**

**`/lib/modules/$(uname -r)/modules.dep` 文件记录了核心模块的相依属性的地方， 依据该文件，可以简单的使用 `modprobe` 这个指令来载入模块**

- **核心模块的编译与核心原本的源代码有关系**
  - **重新编译模块时需要的工具:**
    - **`gcc, make, 等编译工具, kernel-devel`**
  - **在默认核心下面新增模块,也就是写入内核**
    - **就需要 kernel 的 SRPM 文件,将这个文件安装,并取得源代码后,才能顺利编译.**

### 单一模块编译
- **可以解决的问题**
  - **核心忘记加入某个功能， 而且该功能可以编译成为模块， 不过， 默认核心却也没有将该项功能编译成为模块， 造成不能使用时，可以自行编译.**
  - **Linux 核心源代码并没有某个硬件的驱动程序 （ module） ， 但是开发该硬件的厂商有提供给 Linux 使用的驱动程序源代码， 也可以将该项功能编进核心模块**

#### 硬件开发商提供的额外模块 (基本上就是硬件驱动)
**一定要下载厂商提供的`Open source driver`  开源驱动 版本,还要注意看支持的Linux 发行版. RHEL/CentOS 7 x86_64**
**通过开源代码来更新驱动, 必须先编译核心, 然后再安装, 而且通过这种方式来安装的驱动,在内核更新后,也必须重新进行编译驱动和安装.**

```bash
#首先要下载驱动的开源版本文件, 这里选择的是一个AMD显卡的开源驱动. 使用 wget 下载,需要bzip2 压缩工具支持.
$wget   http://www.highpoint-tech.com/BIOS_Driver/RR64xL/Linux/RR64xl_Linux_Src_v1.3.9_15_03_07.tar.gz

#解压, 因为是 tar.gz ，所以使用 -z 参数, -j是bz2 , -J 是xz
$tar -zxv -f   RR64xl_Linux_Src_v1.3.9_15_03_07.tar.gz


#接下来进入 内核源代码目录
$cd  /lib/modules/$(uname -r)/source        #也可以是 /lib/modules/$(uname -r)/build   这两个都是链接文件,指向一个目录

#安装编译核心所需要的工具, 如果编译时还出现问题,那么就是工具没有安装全
$yum install libelf-dev  gcc make kernel-devel elfutils-libelf-devel

#编译 内核源代码 , 因为驱动需要相应的头文件或.o 目标文件.
$make 

#内核编译完成后 , 进入解压之后的目录
$cd  rr64xl-linux-src-v1.3.9
	#会有如下内容: inc  lib  osm  product  README      前面四个是目录,最后一个是说明文档

#进入到 存放 makefile 文件的目录中.  (基本上都是找makefile, 如果没有,就找 .configure )
$cd rr64xl-linux-src-v1.3.9/product/rr64xl/linux/

#开始编译驱动  make
$make            #跟前一定要有 makefile， 否则就找.configure 进行 ./configure 执行  来生成这个makefile文件)


#编译结束后 当前目录会多出一个模块文件 .ko
$ ls -lh  ~/rr64xl-linux-src-v1.3.9/product/rr64xl/linux
-rw-r--r--. 1 root root 1399896 Oct 21 00:59 rr640l.ko # 就是产生这家伙！

#将模块放置到正确的位置去, 因为是 硬件驱动,而且与硬盘多设备驱动支持,所以拷贝到目录/lib/modules/3.10.89/kernel/drivers/scsi/
$cp rr640l.ko      /lib/modules/3.10.89/kernel/drivers/scsi/

#产生模块相依性文件！
$depmod -a

# 确定模块有在相依性的配置文件中！
$grep   rr640l   /lib/modules/3.10.89/modules.dep
输出:   kernel/drivers/scsi/rr640l.ko    #确实在

#载入测试一下
$modprobe     rr640l 

#若开机过程中就得要载入此模块， 则需要将模块放入 initramfs 才行
$dracut   --force   -v    --add-drivers    rr640l     /boot/initramfs-3.10.89.img 3.10.89

#验证一下 
$lsinitrd   /boot/initramfs-3.10.89.img ｜ grep ‘rr640’
````

### 利用旧有的核心源代码进行编译
**如果是忘记了加入某个模块的功能,那么可以利用核心的源代码来进行非常简单的编译.(非常有用)**
**如果出现编译错误,那么就是系统自带的核心没有源代码,需要去下载一个与内核一摸一样的 官方内核源代码.**
```bash
#首先来到核心源代码目录
$cd  /lib/modules/$(uname -r)/source

#假设要添加一个 NTFS 的文件系统支持
# 那么可以这么做:
$make menuconfig         
	#在核心选项中找到 NTFS 的文件系统支持,选择成为模块 M  ,然后保存退出.

#再次下达命令:
$make SUBDIRS=./fs/ntfs modules        #那么这时候NTFS会被编译出来, ntfs.ko ,这个文件在 fs/ntfs/ 目录内

#将编译好的模块复制到过去
$cp  fs/ntfs/ntfs.ko   /lib/modules/3.10.89/kernel/fs/ntsf/

#重建模块相依性,  结束
$depmod -a

#查看一下是确实有相依性了
$cat /lib/modules/3.10.89/modules.dep | grep 'ntfs'
输出:  kernel/fs/ntfs/ntfs.ko:

#载入测试一下
$modprobe     ntfs

#若开机过程中就得要载入此模块， 则需要将模块放入 initramfs 才行
$dracut   --force   -v    --add-drivers    ntfs     /boot/initramfs-3.10.89.img 3.10.89

#验证一下 
$lsinitrd   /boot/initramfs-3.10.89.img ｜ grep  ‘ntfs’

```

### 核心模块管理
**核心与核心模块是分不开的， 至于驱动程序模块在编译的时候， 更与核心的源代码功能分不开**
**与核心模块有相关的， 还有那个很常被使用的 modprobe 指令， 以及开机的时候会读取到的模块定义数据文件 `/etc/modprobe.conf`.**

## 以最新核心版本编译 CentOS 7.x 的核心

**一定要注意 下载的SRPM与 核心版本 的版本号一定要相同.**
1. 先从 ELRepo 网站下载不含源代码的 SRPM 文件， 并且安装该文件,(http://www.ftp.ne.jp/Linux/RPMS/elrepo/kernel/el7/SRPMS/kernel-ml-5.4.0-1.el7.elrepo.nosrc.rpm)
2. 从网站下载满足 ELRepo 网站所需要的核心版本来处理 (http://ftp.sjtu.edu.cn/sites/ftp.kernel.org/pub/linux/kernel/v5.x/linux-5.4.tar.gz)
3. 修改核心功能 ( config-5.4-x86_64   ,  kernel-ml-5.4.spec)
4. 通过 SRPM 的 rpmbuild 重新编译打包核心  ( rpmbuild -bb kernel-ml-5.4.spec)
5. 进行核心的安装 (yum install /root/rpmbuild/RPMS/x86/kernel-ml-5.4.0-1.el7.centos.x86_64.rpm  )
6. 重建配置文件 grub2
7. 设置默认新内核开机 
8. 再次重建配置文件 grub2
9. 重启即可完成更新
10. 将源代码和配置文件都放入适当的地方,以备后续使用.

```bash
# 1.1. 下载不含源代码的 SRPM 文件 .  nosrc 表示没有源代码,  5.4版本
$wget http://www.ftp.ne.jp/Linux/RPMS/elrepo/kernel/el7/SRPMS/kernel-ml-5.4.0-1.el7.elrepo.nosrc.rpm

# 1.2 安装他, 会有很多警告信息。不用管, 安装完成后会出现一个 rpmbuild  目录.
$rpm -ivh kernel-ml-5.4.0-1.el7.elrepo.nosrc.rpm

# 2.1 进入源代码目录 rpmbuild/SOURCES
$cd rpmbuild/SOURCES

# 2.2 下载正确的核心源代码 5.4版本
$wget  http://ftp.sjtu.edu.cn/sites/ftp.kernel.org/pub/linux/kernel/v5.x/linux-5.4.tar.gz

# 2.3 查看一下
$ll   -tr
输出:
-rw-r--r-- 1 root root 170244619 Nov 25 18:32 linux-5.4.tar.gz    # 核心源代码
-rw-rw-r-- 1 root root       294 Nov 25 22:14 cpupower.service
-rw-rw-r-- 1 root root       150 Nov 25 22:14 cpupower.config
-rw-rw-r-- 1 root root    207825 Nov 25 22:14 config-5.4.0-x86_64   # 主要的核心功能

# 3.1 修改核心功能设置, 这里的内容和编译核心的 make menuconfig 是一样的.修改自己想增加的功能即可.
$vim    config-5.4.0-x86_64 

	#3.1.1  范例: 假设我需要 VFIO 的 VGA 直接支持的核心功能打开
         在 config-5.4.0-x86_64  文件中找到  下面这行
                # CONFIG_VFIO_PCI_VGA is not set
          在这一行的下面增加一些内容,以打开这个功能,(基本上都是这个格式)
               CONFIG_VFIO_PCI_VGA=y     

# 3.2 修改一下其他的全局安装配置文件 (重要), 在 上个目录的 SPECS 目录下.
$cd  ../SPECS
$vim  kernel-ml-5.4.spec
	# 找到这个关键字   Source0      它后面跟的是一个网址
	#修改他成为下面这行   (因为我下载的内核源代码文件是 tar.gz ,所以文件结尾就是这个,否则依照具体情况而定)
Source0: linux-%{LKAver}.tar.gz

#4.1 安装编译打包的依赖环境和库
$yum install rpm-build  asciidoc newt-devel openssl-devel rsync xmlto audit-libs-devel binutils-devel bison \
			elfutils-devel java-1.8.0-openjdk-devel  libcap-devel perl python-devel slang-devel xz-devel \
			 pciutils-devel numactl-devel perl-ExtUtils-Embed          #这些都是需要的编译环境和包

# 4.2  开始编译打包 (时间很漫长), 当前在 rpmbuild/SPECS 目录内
$rpmbuild -bb kernel-ml-5.4.spec
	
	#编译完成后,会在 rpmbuild目录内生成一个RPMS 目录, 里面会有一个 x86_64目录,在里面有kernel-ml-5.4.0-1.el7.centos.x86_64.rpm
	
# 5.1 编译完成后执行安装操作,
$yum install    /root/rpmbuild/RPMS/x86_64/kernel-ml-5.4.0-1.el7.centos.x86_64.rpm

# 6 重建配置文件 grub2
$grub2-mkconfig -o /boot/grub2/grub.cfg

#7 设置默认新内核开机 (也可以修改成原有的内核), 注意:如果这么设置了,一旦出现问题,就会无法开机. 需要在grub界面手动修改grub.cfg文件
$cat /boot/grub2/grub.cfg |grep "menuentry "  # 查看所有可用内核
输出:  
menuentry 'CentOS Linux (5.4.0-1.el7.centos.x86_64) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted   menuentry_id_option 'gnulinux-5.4.0-1.el7.centos.x86_64-advanced-eb448abb-3012-4d8d-bcde-94434d586a31' {
menuentry 'CentOS Linux (3.10.0-693.2.2.el7.x86_64) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted   menuentry_id_option 'gnulinux-3.10.0-693.2.2.el7.x86_64-advanced-eb448abb-3012-4d8d-bcde-94434d586a31' {

		#找到新内核并设置开机
$grub2-set-default   'CentOS Linux (5.4.0-1.el7.centos.x86_64) 7 (Core)’      #这个是在上个输出结果中寻找的
		#查看是否设置成功
$grub2-editenv list
输出：saved_entry= CentOS Linux (5.4.0-1.el7.centos.x86_64) 7 (Core)  #成功


# 8 再次重建配置文件 grub2
$grub2-mkconfig -o /boot/grub2/grub.cfg

# 9  重启即可完成更新
$reboot


# 10  将源代码和配置文件都放入适当的地方,以备后续使用.
#10.1  解压核心源代码
$cd  /root/rpmbuild/SOURCES        #这个目录下有 linux-5.4.tar.gz 核心源码
$tar -zxv -f linux-5.4.tar.gz               #解压他会生成一个 linux-5.4  目录,里面就是核心源代码

#10.2  将配置文件拷贝到核心源代码中, 并以 .config 命名
$cp /boot/config-5.4.0-1.el7.centos.x86_64    linux-5.4/.config

#10.3  查看一下 内核要求把源代码放入哪个位置？   （每种系统都不一样)
$ll /lib/modules/5.4.0-1.el7.centos.x86_64/build 
lrwxrwxrwx 1 root root 42 Nov 27 11:32 /lib/modules/5.4.0-1.el7.centos.x86_64/build -> /usr/src/kernels/5.4.0-1.el7.centos.x86_64
	#这里指示 把内核源码放在  /usr/src/kernels/5.4.0-1.el7.centos.x86_64  这个目录内

#10.4 将源代码放入指定目录内， 如果这个目录不存在, 则直接创建出来就好了,但是注意权限
$cp -ap  linux-5.4  /usr/src/kernels/5.4.0-1.el7.centos.x86_64

#10.5 修改权限
$cd /usr/src/kernels/
$ ls -lh  
输出:
	drwxr-xr-x  22  root root  4096  Nov  27  10:05     3.10.0-1062.4.3.el7.x86_64     #注意权限问题
	drwxrwxr-x 24 root root  4096  Nov  27  11:56      5.4.0-1.el7.centos.x86_64     #修改成和原有内容权限相同

$chmod  5.4.0-1.el7.centos.x86_64  755 5.4.0-1.el7.centos.x86_64         #修改完成 ,不需要递归修改
```


## 小结
- 其实核心就是系统上面的一个文件而已， 这个文件包含了驱动主机各项硬件的侦测程序与驱动模块；
- 核心模块(驱动)放置于： **`/lib/modules/$（ uname -r） /kernel/`**
- “驱动程序开发”的工作上面来说， 应该是属于硬件发展厂商的问题
- 一般的使用者， 由于系统已经将核心编译的相当的适合一般使用者使用了， 因此一般入门的使用者， 基本上， 不太需要编译核心
- 编译核心的一般目的： 新功能的需求、 原本的核心太过臃肿、 与硬件搭配的稳定性、 其他需求（ 如嵌入式系统）
- 编译核心前， 最好先了解到您主机的硬件， 以及主机的用途， 才能选择好核心功能；
- 编译前若想要保持核心源代码的干净， 可使用 **`make mrproper`** 来清除暂存盘与配置文件；
- 挑选核心功能与模块可用 make 配合： `menuconfig, oldconfig, xconfig, gconfig` 等等
- 核心功能挑选完毕后， 一般常见的编译过程为： `make bzImage,    make modules`
- 模块编译成功后的安装方式为： `make modules_install`
- 核心的安装过程中， 需要移动 bzImage 文件、 创建 initramfs 文件、 重建 grub.cfg 等动作；但是要注意文件的命名规则
- 我们可以自行由硬件开发商之官网下载驱动程序来自行编译核心模块！


**核心编译的步骤**
1. 先下载核心源代码， 可以从 http://www.kernel.org 或者是 distributions 的 SRPM 来着手；
2. 以下以 Tarball 来处理， 解开源代码到 /usr/src/kernels 目录下；
3. 先进行旧数据删除的动作： “make mrproper”；
4. 开始挑选核心功能， 可以利用“make menuconfig”、 “make oldconfig”、 “makegconfig”等等；
5. 清除过去的中间暂存盘数据： “make clean”
6. 开始核心文件与核心模块的编译： “make bzImage”、 “make modules”
7. 开始核心模块的安装： “make modules_install”
8. 开始核心文件的安装， 可以使用的方式有： “make install”或者是通过手动的方式复制核心文件到 /boot/ 当中；
9. 创建 initramfs 文件；
10. 使用 grub2-mkconfig 修改 /boot/grub2/grub.cfg 文件；


**删除 新编译的核心 步骤**
1. 重新开机， 并使用旧的稳定的核心开机！
2. 此时才可以将新版核心模块删除： **`rm -rf /lib/modules/3.10.89vbird`**
3. 删除掉 /boot 里面的新核心,配置文件,虚拟文件系统： **`rm /boot/vmlinuz-3.10.89vbird /boot/initramfs-3.10.89vbird.img ...`**
4. 重建 grub.cfg： **`grub2-mkconfig -o /boot/grub2/grub.cfg`**
5. 如果设置过开机启动项,那么也应该删除配置文件的一些内容:  **`vim /etc/grub.d/40_custom`**