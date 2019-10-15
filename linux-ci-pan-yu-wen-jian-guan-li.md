# Linux磁盘与文件管理

{% hint style="info" %}
磁盘分区完毕后, 为什么还需要格式化?

**因为每种操作系统所设置的文件 属性/权限 并不相同, 为了存放这些文件所需的数据, 因此就需要将分区进行格式化, 以成为操作系统能够利用的 "文件系统格式\(filesystem\)".**
{% endhint %}

{% hint style="info" %}
我们称  **一个可被挂载的数据为一个 `文件系统`, 而不是一个分区.**
{% endhint %}

{% hint style="info" %}
**文件系统的运行 与 操作系统的文件数据有关.**
{% endhint %}

{% hint style="info" %}
**文件系统通常回你将两部分的数据分别存放在不同的区块, 权限与属性放置在 inode 中, 以至于实际数据则放置到 data block 区块中.  另外还有个超级区块\(superblock\) 回记录整个文件系统的整体信息, 包括inode 与 block 的总量, 使用量, 剩余量等.**

* **超级区块\(superblock\) : `记录此文件系统的整体信息, 包括 inode/block 的总量, 使用量, 剩余量, 以及文件系统的格式与相关信息等.(没有这个就没有文件系统)`**
  * **`主要记录的信息有:`**
    * **`block 与 inode 的总量;`**
    * **`未使用 与 已使用的 inode/block 数量;`**
    * **`block 与 inode 的大小 (block 为1,2,4K, inode为 128Bytes或256Bytes);`**
    * **`文件系统的挂载时间, 最近一次写入数据的时间, 最近一次检验磁盘(fsck) 的时间,等文件系统的相关信息.`**
    * **`一个 valid bit 数值, 若此文件系统已被挂载, 则 valid bit为0, 若未被挂载,则valid bit 为 1 .`**
* **inode :   `记录文件的属性, 一个文件占用一个 inode, 同时记录此文件的数据所在的 block 号码.(inode的数量和大小 是在格式化时就已经固定了的)`**
  * **`每个inode 大小均固定为 128Bytes (新的 ext4与xfs可以设置到256Bytes);`**
  * **`每个文件都仅仅会占用一个inode 而已;`**
    * **`文件系统能够创建的文件数量与inode的数量有关;`**
  * **`系统读取文件时 需要先找到 inode ,并分析inode所记录的权限与使用者是否相符合,若符合才能够开始读取block的内容.`**
  * **`inode bitmap(inode对照表) 记录使用与未使用 inode 号码.`**
  * **`inode 所记录的内容:`**
    * **`该文件的存取模式 (read/write/excute);`**
    * **`该文件的拥有者与群组(owner/group);`**
    * **`该文件的容量;`**
    * **`该文件创建或权限状态改变的时间(ctime);`**
    * **`最近一次的读取时间(atime);`**
    * **`最近文件被修改的时间(mtime);`**
    * **`定义文件特性旗标(flag), 如 SetUID ...;`**
    * **`该文件真正内容的指向 (pointer);`**
* **block :  `实际记录文件的内容, 若文件太大, 会占用多个 block.`**
  * 目前主流的是 4bk 大小的 block.
  * **`通过 block bitmap(区块对照表),得到哪些 block 是空的.`**

**`Filesystem Description (文件系统描述符), 描述每个 block group 的开始与结束的block 号码, 以及说明每个区段(superblock,bitmap,inodemap,data block) 分别介于哪一个block号码之间. (这部分能够用命令 #dumpe2fs  /dev/系统硬盘  来观察);`**

**`可以通过判断 inode号码来 确认不同文件名 是否位=为相同的文件. ($ls -ild 文件)`**
{% endhint %}

{% hint style="info" %}
inode 本身并不记录文件名  ,  文件名是记录在  目录的block当 中的.
{% endhint %}

{% hint style="info" %}
一般来说，我们将 inode table 与 data block 称为**`数据存放区域`**，至于其他例如 superblock、 block bitmap 与 inode bitmap 等区段就被称为 **`metadata (中介数据)`** 啰，因为 superblock, inode bitmap 及 block bitmap 的数据是经常变动的，每次新增、移除、编辑时都可能会影响 到这三个部分的数据，因此才被称为**中介数据**的
{% endhint %}

## 挂载 点的意义

{% hint style="info" %}
每个文件系统都有独立的 inode/block/superblock 等信息, 这个文件系统要能够链接到目录树才能被我们使用.

**`将 文件系统 与 目录树结合的动作 称为挂载;`**
{% endhint %}

**挂载点一定是目录,  该目录为进入该文件系统的入口.  因此并不是你有任何文件系统都能使用,必须要 "挂载" 到 目录树的 某个目录后, 才能够使用该文件系统.**

整个 Linux 的系统都是通过一个名为 Virtual Filesystem Switch 的核 心功能去读取 filesystem 的。 也就是说，整个 Linux 认识的 filesystem 其实都是 VFS 在进行 管理，我们使用者并不需要知道每个 partition 上头的 filesystem 是什么~ VFS 会主动的帮我 们做好读取的动作呢~

## XFS 文件系统的配置

xfs 文件系统在数据的分佈上，主要规划为三个部份，一个数据区 \(data section\)、一个文 件系统活动登录区 \(log section\)以及一个实时运行区 \(realtime section\)。 这三个区域的 数据内容如下:

* **数据区 \(data section\)** : 包括  inode/data/block/suqerblock 等数据,都放置在这个区块.
  * 整个文件系统的 \(suqerblock\)
  * 剩余空间的管理机制
  * inode 的分配与追踪.
* **文件系统活动登录区\(log section\)** : 记录文件系统的变化\(像日志区\).
  * 文件的变化会 在这里纪录下来，直到该变化完整的写入到数据区后， 该笔纪录才会被终结。如果文件系统 因为某些缘故 \(例如最常见的停电\) 而损毁时，系统会拿这个登录区块来进行检验，看看系 统挂掉之前， 文件系统正在运行些啥动作，借以快速的修复文件系统。
* **实时运行区 \(realtime section\) :**  当有文件要被创建时，xfs 会在这个区段里面找一个到数个的 extent 区块，将文件放置在这个 区块内，等到分配完毕后，再写入到 data section 的 inode 与 block 去
  * 大小得要在格式化的时候就先指定，最小值是 4K 最大可到 1G. 
  * 一般非磁盘阵列的磁盘默认 为 64K 容量，而具有类似磁盘阵列的 stripe 情况下，则建议 extent 设置为与 stripe 一样大较佳

{% hint style="info" %}
**XFS 文件系统的描述数据观察**

**命令       $**xfs\_info    挂载点        

\#挂载点就是 /dev下的设备文件,可以 通过    **`$df -T 目录名`**     来获得.
{% endhint %}

```bash
[root@study ~]# xfs_info /dev/vda21 
1.  meta-data=/dev/vda2 isize=256 agcount=4, agsize=65536 blks
2.           =                  sectsz=512   attr=2, projid32bit=1
3.           =                  crc=0        finobt=0
4.  data     =                  bsize=4096   blocks=262144, imaxpct=25
5.           =                  sunit=0      swidth=0 blks
6. naming    =version 2 bsize=4096 ascii-ci=0 ftype=0
7.  log      =internal          bsize=4096   blocks=2560, version=2
8.           = sectsz=512 sunit=0 blks, lazy-count=1
9.  realtime =none              extsz=4096   blocks=0, rtextents=0

解读:
     
第 1 行里面的 isize 指的是 inode 的容量，每个有 256Bytes 这么大。
         至于 agcount 则是储存区群组 (allocation group) 的个数，共有 4 个， 
         agsize 则是指每个储存区群组具有 65536 个 block 。
         配合第 4 行的 block 设置为 4K，因此整个文件系统的容 量应该就是 4655364K 这么大! 
第 2 行里面 sectsz 指的是逻辑扇区 (sector) 的容量设置为 512Bytes 这么大的意思。
第 4 行里面的 bsize 指的是 block 的容量，每个 block 为 4K 的意思，共有 262144 个block 在这个文件系统内。
第 5 行里面的 sunit 与 swidth 与磁盘阵列的 stripe 相关性较高。这部份我们下面格式化 的时候会举一个例子来说明。
第 7 行里面的 internal 指的是这个登录区的位置在文件系统内，而不是外部设备的意思。且占用了 4K * 2560 个 block，总共约 10M 的容量。
第 9 行里面的 realtime 区域，里面的 extent 容量为 4K。不过目前没有使用.
```

## 文件系统的简单操作

{% hint style="info" %}
$**`df`**   :列出文件系统的整体磁盘使用量;

$**`du`**   :评估文件系统的磁盘使用量\(常用在推估目录所占容量\)
{% endhint %}

#### df

```bash
$ df  选项   目录或文件名
选项与参数:
 -a :列出所有的文件系统，包括系统特有的 /proc 等文件系统;
 -k :以 KBytes 的容量显示各文件系统;
 -m :以 MBytes 的容量显示各文件系统;
 -h :以人们较易阅读的 GBytes, MBytes, KBytes 等格式自行显示;
 -H :以 M=1000K 取代 M=1024K 的进位方式;
 -T :连同该 partition 的 filesystem 名称 (例如 xfs) 也列出;
 -i :不用磁盘容量，而以 inode 的数量来显示
```

#### du

```bash
$du  选项  文件或目录名
选项与参数:
 -a :列出所有的文件与目录容量，因为默认仅统计目录下面的文件量而已。
 -h :以人们较易读的容量格式 (G/M) 显示;
 -s :列出总量而已，而不列出每个各别的目录占用容量;
 -S :不包括子目录下的总计，与 -s 有点差别。
 -k :以 KBytes 列出容量显示;
 -m :以 MBytes 列出容量显示;
```

## 硬链接 与 软连接 ln

#### 硬链接 \(hard link\)

**硬链接:  `只是在某个目录下新增一笔文件名链接到某 inode 号码的关联记录而已.`**

```bash
$ln  -i  被连接的文件   创建出的链接文件
    $ln -i  /etc/crontab   /root/net_hl    
        #创建出的硬链接名是  net_cr 在 /root目录, 它指向/etc/crontab, 并且inode号码相同.
#只可以链接文件,不能链接目录.
#不能跨文件系统进行链接.
#只要还有一个硬链接存在,那么被指向的 文件内容就不会消失.
还有个  -f 选项, 表示
```

#### 软连接\(Symbolic link\)

**软连接: `创建一个 独立的文件，而这个文件会让数据的读取指向他 link 的那个文件的文件名.`**

```bash
$ln  -s  被连接的文件   创建出的链接文件
    $ln  -s  /etc/crontab   /root/net_sl
#软连接可以链接目录和文件.
#软链接文件只是指向 被链接文件的 文件名,一旦被链接文件出现修改, 则链接文件失效.
#软连接是一个独立的新文件,会占用掉 inode 与 block.
#创建出的链接文件的大小是由 被链接的文件名的绝对路径 决定的.(net_sl 就是14个字节,/etc/crontab)
```

## 磁盘分区和状态信息

由于目前磁盘分区主要有 MBR 以及 GPT 两种格式，这两种格式所使用的分区工具不太一 样!

#### lsblk  命令 :列出系统上的所有磁盘列表

```bash
$lsblk   参数   磁盘名
选项与参数:
 -d :仅列出磁盘本身，并不会列出该磁盘的分区数据
 -f :同时列出该磁盘内的文件系统名称
 -i :使用 ASCII 的线段输出，不要使用复杂的编码 (再某些环境下很有用)
 -m :同时输出该设备在 /dev 下面的权限数据 (rwx 的数据)
 -p :列出该设备的完整文件名!而不是仅列出最后的名字而已。
 -t :列出该磁盘设备的详细数据，包括磁盘伫列机制、预读写的数据量大小等
 
 输出介绍和解释
 $lsblk  
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   40G  0 disk 
├─sda1            8:1    0   50M  0 part /boot/efi
├─sda2            8:2    0    1G  0 part /boot
└─sda3            8:3    0   30G  0 part 
  ├─centos-root 253:0    0   10G  0 lvm  /
  ├─centos-swap 253:1    0    1G  0 lvm  [SWAP]
  └─centos-home 253:2    0    5G  0 lvm  /home
sr0              11:0    1 1024M  0 rom  

解释:

NAME:    就是设备的文件名啰!会省略 /dev 等前导目录! 
MAJ:MIN: 其实核心认识的设备都是通过这两个代码来熟悉的!分别是主要:次要设备 代码!
RM:      是否为可卸载设备 (removable device)，如光盘、USB 磁盘等等 SIZE:当然就是容量啰!
RO:      是否为只读设备的意思
TYPE:    是磁盘 (disk)、分区 (partition) 还是只读存储器 (rom) 等输出 
MOUTPOINT:  挂载点
```

#### blkid  命令 : 列出设备的UUID

UUID 是全域单一识别码 \(universally unique identifier\)，Linux 会将系统内所有的设备都给予一个独一无二的识别 码， 这个识别码就可以拿来作为挂载或者是使用这个设备/文件系统之用了.

```bash
$blkid      直接就会输出 uuid 和文件系统, 列出设备名称,和文件系统类型(type)
```

### parted   命令: 列出磁盘的分区列表信息与分区信息 \( MBR/GPT/MSDOS\)

```bash
$parted   块设备  print
范例:
  $parted   /dev/sda  print
输出:
Model: ATA CentOS Linux-0 S (scsi)                #磁盘的模块名称( 厂商)
Disk /dev/sda: 42.9GB                             #磁盘的总容量
Sector size (logical/physical): 512B/4096B        #磁盘的每个 逻辑/物理  扇区容量
Partition Table: gpt                              #分区表的格式 (MBR/ GPT)
Disk Flags: 
                              #这下面才是分区数据
Number  Start   End     Size    File system  Name                  Flags
 1      1049kB  53.5MB  52.4MB  fat16        EFI System Partition  bios_grub
 2      53.5MB  1127MB  1074MB  xfs
 3      1127MB  33.3GB  32.2GB                                     lvm
```

## 磁盘分区  :  gdisk  / fdisk

#### MBR 分区需要使用  fdisk 进行分区,   GPT 分区需要使用  gdisk 进行分区.\(否则会失败\)

#### 分区完成后还需要进行格式化 \(创建文件系统\).

* **gdisk 分区主要是以扇区为最小单位 ,  fdisk 分区主要是以柱面或扇区为最小单位.**
* **分区通常选用上个分区的结束扇区号码数加1 作为起始扇区号码.**

### gdisk   \(GPT分区\)

```bash
$gdisk   块设备
    #在使用该命令前,应该先使用 $lsblk 或 $blkid  先找到硬盘,再用 $parted /dev/xxx print 
    #来找出内部的分区表,之后才用 gdisk或fdisk  来操作系统.
    # 当执行 gdisk /dev/xxx 之后, 可以输出 ? 来获取指令动作.
执行命令后的指令和动作:
Command (? for help): ?
b       将GPT数据备份到文件
c       更改分区的名称
d       删除一个分区
i       显示有关分区的详细信息
l       显示已知的分区类型(就是列表,8300Linux,8200 swap,0700 fat16)
n       增加一个分区
o       创建一个新的空GUID分区表（GPT）
p       列出目前存在的分区表 (常用)
q       不储存分区就直接离开 gdisk
r       恢复和转换选项（仅限专家）
s       排序分区
t       更改分区的类型代码
v       验证磁盘
w       储存分区操作后离开 gdisk
x       额外的功能（仅限专家）
?       打印此菜单

范例:
$sudo gdisk /dev/sda            #默认只有这一块硬盘(选择硬盘,而不是带编号的分区)

Command (? for help): p        #输出目前磁盘的信息.
Disk /dev/sda: 83886080 sectors, 40.0 GiB        # 磁盘文件名 /扇区数与  总容量
Logical sector size: 512 bytes                   # 单一扇区大小为 512 Bytes
Disk identifier (GUID): 827CBAFB-EC6D-4E28-BA01-933A259E2FA7  # 磁盘的 GPT 识别码
Partition table holds up to 128 entries
First usable sector is 34, last usable sector is 83886046
Partitions will be aligned on 2048-sector boundaries
Total free space is 18763709 sectors (8.9 GiB)
#分区编号  开始扇区号码位置  结束扇区号码位置 分区容量  分区可能的文件系统
Number  Start (sector)    End (sector)  Size       Code  Name    #下面为完整的分区信息
   1            2048          104447   50.0 MiB    EF00  EFI System Partition    #第一个分区数据
   2          104448         2201599   1024.0 MiB  0700  
   3         2201600        65124351   30.0 GiB    8E00 
```

#### gdisk 创建一个新分区

```bash
创建新分区:
$sudo gdisk /dev/sda
Command (? for help): n         #n 表示开始分区
Partition number (4-128, default 4): 4 # 默认就是4号，所以直接回车即可!
First sector (34-83886046, default = 65026048) or {+-}size{KMGTP}: 65026048 # 也能直接回车
Last sector (65026048-83886046, default = 83886046) or {+-}size{KMGTP}: +1G  #+1G表示要分出1G空间的分区
# 这个地方可有趣了!我们不需要自己去计算扇区号码，通过 +容量 的这个方式，
# 就可以让 gdisk 主动去帮你算出最接近你需要的容量的扇区号码喔!
Current type is 'Linux filesystem'
Hex code or GUID (L to show codes, Enter = 8300): # 使用默认值即可~直接回车下去!
 # 这里在让你选择未来这个分区预计使用的文件系统!默认都是 Linux 文件系统的 8300 
 # swap 是 8200  ,  fat32 是 0700 ,  通过 t 选项查询.
#分区完毕, 接下来确认无误的话,进行w 保存就可以, 如果 有错误则输入 q退出,重新进行分区.
Command (? for help): w     #保存修改.  接下来会有个确认提示,给y就好了.

#gdisk 命令执行完毕后,使用下面的命令来更新核心分区表.
$partprobe   -s      #直接执行该命令更新核心分区列表
```

#### 创建/删除 分区完毕后,使用 $partprobe  命令 更新 Linux 核心分区表. \(重启也行\)

```bash
$partprobe   -s      #直接执行该命令就可以更新了.

$lsblk   /dev/sda      #查看实际的磁盘分区状态

$cat  /proc/partitions   #核心的分区记录
```

#### gdisk  删除一个分区

```bash
在删除分区前, 需要确认该分区已经被卸载了,并且没有在使用.
删除一个已有分区:
$gdisk /dev/vda
Command (? for help): p     #首先查看分区表 ,  假设有6号分区(sda6), 并删除它.
Command (? for help): d     #执行删除
Partition number (1-6): 6     #选择6号分区 (/dev/sda6)
Command (? for help): w     #保存修改, 并且后面会有个确认提示, 给y就好了.

#gdisk 命令执行完毕后,使用下面的命令来更新核心分区表.
$partprobe   -s      #直接执行该命令更新核心分区列表
```

### fdisk  \(MSR 分区\)

```text
适用方法和 gdisk 相同,  只不过 ? 帮助,变成了 m .
```

### 磁盘格式化\(创建文件系统\)

**在分区完成后 就可以进行磁盘格式化\(创建文件系统\), 随后就可以开始正常的使用该磁盘了.**

* **按照文件系统来进行正确的格式化.**
  * **$mkfs.xfs       \#CentOS7 所使用的 xfs文件系统的格式化指令.**
  * **$mkfs.ext4     \#Linux 所使用的 ext4文件系统的格式化指令.**
  * **$mkfs -t  文件系统   块设备     \#综合指令,可以初始化系统支持的文件系统**
    * **$mkfs -t  vfat  /dev/sda5**       

#### **mkfs.xfs    \(CentOS7 的 xfs文件系统格式化指令\)**

```bash
$mkfs.xfs  选项  参数   设备名称 (/dev/sda4 )
选项与参数:关于单位:
#下面只要谈到“数值”时，没有加单位则为 Bytes 值，可以用 k,m,g,t,p (小写)等来解释
#比较特殊的是 s 这个单位，它指的是 sector 的“个数”.
 -b :后面接的是 block 容量，可由 512 到 64k，不过最大容量限制为 Linux 的 4k
 -d :后面接的是重要的 data section 的相关参数值，主要的值有:
      agcount=数值 :设置需要几个储存群组的意思,就是CPU核心数.( 可以通过 $grep 'processor' /proc/cpuinfo 命令获得)
      agsize=数值  :每个 AG 设置为多少容量的意思，通常 agcount/agsize 只选一个设置即可
      file        :指的是“格式化的设备是个文件而不是个设备”的意思!(例如虚拟磁盘)
      size=数值    :data section 的容量，亦即你可以不将全部的设备容量用完的意思
      su=数值      :当有 RAID 时，那个 stripe 数值的意思，与下面的 sw 搭配使用
      sw=数值      :当有 RAID 时，用于储存数据的磁盘数量(须扣除备份碟与备用碟)
      sunit=数值   :与 su 相当，不过单位使用的是“几个 sector(512Bytes大小)”的意思
      swidth=数值  :就是 su*sw 的数值，但是以“几个 sector(512Bytes大小)”来设置
 -f :如果设备内已经有文件系统，则需要使用这个 -f 来强制格式化才行!
 -i :与 inode 有较相关的设置，主要的设置值有:
      size=数值   :最小是 256Bytes 最大是 2k，一般保留 256 就足够使用了!
      internal=[0|1]   :log 设备是否为内置?默认为 1 内置，如果要用外部设备，使用下面设置
      logdev=device    :log 设备为后面接的哪个设备上头的意思，需设置 internal=0 才可!
      size=数值    :指定这块登录区的容量，通常最小得要有 512 个 block，大约 2M 以上才行!
-L :后面接这个文件系统的标头名称 Label name 的意思!
-r :指定 realtime section 的相关设置值，常见的有:
      extsize=数值 :就是那个重要的 extent 数值，一般不须设置，但有 RAID 时，
                    最好设置与 swidth 的数值相同较佳!最小为 4K 最大为 1G. ( extsize=su*sw )
                    
范例: 使用默认值来将 /dev/sda4 初始化为一个 xfs 文件系统
$mkfs.xfs  /dev/sda4
输出:
meta-data=/dev/sda4              isize=512    agcount=4, agsize=65536 blks
         =                       sectsz=4096  attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=262144, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=4096  sunit=1 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
# bsize * blocks /1024/1024/1024 = 该磁盘block 总大小(GB)

使用 blkid  来查看一下是否真正完成了.
$blkid /dev/sda4
输出:
/dev/sda4: UUID="612da62a-5268-4a2a-b46c-4f982a3d0967" TYPE="xfs" 
PARTLABEL="Linux filesystem" PARTUUID="fbde563e-1d3e-49f3-b1d2-ac002096dbbe"
```

#### mkfs.ext4 \(Linux 默认的文件系统 ext4\)

```bash
$mkfs.ext4  选项 参数 块设备
选项与参数:
-b    :设置 block 的大小, 有1K ,2K ,4K 的容量.
-L    :后面接这个设备的标头名称.

范例:  将 /dev/sda5 格式化为 ext4 文件系统( sad5大小为 1G,已经分区,GPT格式).
$mkfs.ext4  /dev/sda5

```

#### mkfs  -t   文件系统    块设备

```bash
这是个综合指令, 可以用来初始化系统支持的文件系统
$  mkfs -t  文件系统    块设备
范例:
$mkfs -t ext4  /dev/sda4
```

#### 最后 通过  $parted   /dev/sda print  命令来查看文件系统是否正确 .

## 文件系统校验

**当系统异常关机 或者硬件出现问题时  进行 文件系统救援的指令.**

**出现异常的文件系统 在修复前必须卸载.**

### xfs\_repair   处理  xfs文件系统

```bash
$xfs_repair  选项  块设备
选项和参数:    
-f   :后面的块设备其实是一个文件而不是实体设备
-n   :单纯检查并不修改文件系统的任何数据 (检查而已)
-d   :通常用在单人维护模式下, 针对根目录(/) 进行检查与修复的动作! 非常危险 !不要随意使用.

范例:  检查 /dev/sda4 文件系统
$xfs_repair  /dev/sda4
Phase 1 - find and verify superblock...
Phase 2 - using internal log
        - zero log...
        - scan filesystem freespace and inode maps...
        - found root inode chunk
Phase 3 - for each AG...
        - scan and clear agi unlinked lists...
        - process known inodes and perform inode discovery...
        - agno = 0
        - agno = 1
        - process newly discovered inodes...
Phase 4 - check for duplicate blocks...
        - setting up duplicate extent list...
        - check for inodes claiming duplicate blocks...
        - agno = 0
        - agno = 1
Phase 5 - rebuild AG headers and trees...
        - reset superblock...
Phase 6 - check inode connectivity...
        - resetting contents of realtime bitmap and summary inodes
        - traversing filesystem ...
        - traversal finished ...
        - moving disconnected inodes to lost+found ...
Phase 7 - verify and correct link counts...
done
#会自动检查上面这7项,并且修复,但是 sda4 必须在修复前 被卸载.
```

#### fsck.ext4  处理 EXT4 文件系统

```bash
检查之前首先进行 超级区块(superblock)  的寻找, 使用下面的命令来进行. 
        $dumpe2fs -h /dev/sda5 | grep 'Blocks per group'
        输出:  Blocks per group:         32768
# 看起来每个 block 群组会有 32768 个 block，因此第二个 superblock 应该就在 32768 上
# 因为 block 号码为 0 号开始编的

$fsck.ext4  选项 参数  块设备
选项和参数:
-p    :当文件系统在修复时, 若有需要回复 y 的动作时,自动回复 y  来继续修复(无人看守模式)
-f    :强制检查(修复的更加细致)
-D    :针对文件系统下的目录进行最优化配置.
-b    :后面接 超级区块(superblock) 的位置, 当原有的 超级区块 损坏时,通过这个参数可以利用文件系统
        内备份的 超级区块 来尝试救援. 一般来说 超级区块备份在:  1K block  放在 8193, 
         2K block 放在16384  ,4K block 放在 32768
        
范例: 找出  /dev/sda5 的另一块 超级区块 的备份,并据以检测系统.
$dumpe2fs  -h /dev/sda5 | grep 'Blocks per group'
        输出:   Blocks per group:         32768    
$fsck.ext4  -b 32768  /dev/sda5
        #接下里的输出会提示出现的错误, 还会提问是否进行修复.

范例: 强制检查一次
$fsck.ext4   -p -f /dev/sda5
```

## 文件系统挂载与卸载

**挂载点是目录, 而这个目录是进入磁盘分区\(文件系统\) 的入口.**

* **挂载前需要先确定好的事情:**
  * **但一文件系统不应该被重复挂载在不同的挂载点\(目录\)中;**
  * **但一目录不应该重复挂载多个文件系统;**
  * **要作为挂载点的目录, 理论上应该是空目录才是;**
    * **`如果挂载点目录并不是空的,那么挂载了文件系统 之后,原目录下的东西就会暂时消失. 卸载了文件系统之后,原目录下的东西就会出现了.`**
* **`/etc/filesystems`**  :**系统指定的测试挂载文件系统类型的优先顺序;**
* **`/proc/filesystems:Linux`**   **系统已经载入的文件系统类型**
* **`/lib/modules/$(uname -r)/kernel/fs/`**    **系统支持的文件系统的驱动程序都在这目录中.**
* **使用UUID来识别文件系统, 会比设备名称与标头还要更可靠.\( 因为UUID是独一无二的\)**

### **挂载 \(mount\)**

```bash
$mount  -a
$mount  -l
$mount  -t  文件系统  LABEL=''   挂载点目录
$mount  -t  文件系统  UUID=''    挂载点目录    #一般使用这种,uuid比设备名可靠
$mount  -t  文件系统  设备文件名  挂载点目录
选项和参数:
-a   :依照配置文件 /etc/fstab 的数据将所有为挂载的磁盘都挂载上来
-l   :单纯的输入 mount 会显示目前挂载的信息。加上 -l 可增列 Label 名称!
-t :可以加上文件系统种类来指定欲挂载的类型。常见的 Linux 支持类型有:xfs, ext3, ext4,reiserfs,
     vfat, iso9660(光盘格式), nfs, cifs, smbfs (后三种为网络文件系统类型)
-n :在默认的情况下，系统会将实际挂载的情况实时写入 /etc/mtab 中，以利其他程序的运行。
     但在某些情况下(例如单人维护模式)为了避免问题会刻意不写入。此时就得要使用 -n 选项。
-o :后面可以接一些挂载时额外加上的参数!比方说帐号、密码、读写权限等:
     async, sync   :此文件系统是否使用同步写入 (sync) 或非同步 (async) 的内存机制，
                     请参考[文件系统运行方式] , 默认值是 async 
     atime,noatime  :是否修订文件的读取时间(atime)。为了性能，某些时刻可使用noatime
     ro, rw   :挂载文件系统成为只读(ro) 或可读写(rw)
     auto, noauto   :允许此 filesystem 被以 mount -a 自动挂载(auto)
     dev, nodev     :是否允许此 filesystem 上，可创建设备文件? dev 为可允许
     suid, nosuid   :是否允许此 filesystem 含有 suid/sgid 的文件格式?
     exec, noexec  :是否允许此 filesystem 上拥有可执行 binary 文件?
     user, nouser  : 是否允许此 filesystem 让任何使用者执行 mount ?
                    一般来说，mount 仅有 root 可以进行，但下达 user 参数，则可让一般 user 也能够对此 partition 进行 mount 。
     defaults   : 默认值为:rw, suid, dev, exec, auto, nouser, and async
     remount   : 重新挂载，这在系统出错，或重新更新参数时，很有用!
```

#### 挂载 xfs 和 ext4 硬盘

{% hint style="info" %}
挂载/dev/sda4 \(xfs\) 到 /data/xfs 目录下

* **`$blkid /dev/sda4`**       \#获得uuid.
  * 输出: /dev/sda4: **UUID="cc8a2665-3fef-43b2-be41-d2f11c2dee11" TYPE="xfs"** PARTLABEL="Linux filesystem" PARTUUID="fbde563e-1d3e-49f3-b1d2-ac002096dbbe"
* **`$mkdir -p /data/xfs ; mount UUID='cc8a2665-3fef-43b2-be41-d2f11c2dee11' /data/xfs`**
* **`$df usb -h #用df 查看是否正确`**
{% endhint %}

#### 挂载光盘

{% hint style="info" %}
挂载光盘 \( 一般光盘是 sr0 \)

* **`$blkid /dev/sr0`**      \#我这个是第一张光盘, 如果不知道是第几张,可以不带后面这个参数来寻找
  * 输出 :/dev/sr0: **UUID="2019-09-11-18-50-31-00" LABEL="CentOS 7 x86\_64"** TYPE="iso9660" PTTYPE="dos"
* **`$mkdir -p /data/cdrom ; mount /dev/sr0 /data/cdrom`**
  *  **\#写UUID也是可以的**
* **`$df usb -h #用df 查看是否正确`**
{% endhint %}

#### 挂载USB\(U盘\)

{% hint style="info" %}
挂载 U盘

* **`$blkid`**    \#usb 有可能是/dev/sdb1 还有可能是其他的. 我这里就默认是/dev/sdb2了
  * 输出: ``**`/dev/sdb2: LABEL="KK" UUID="B23A-12FC" TYPE="vfat"`** \#LABEL是标签 PARTUUID="649ff936-6271-44ea-8e2f-cddad96c6b7f"
* **`$mkdir -p /data/usb ; mount UUID='B23A-12FC' -o codepage=950,iocharset=utf8 /data/usb`**
  * **-o 后面的 codepage=950表示中文语系,iocharset=utf8表示万国码, 用逗号链接.**
* **`$df usb -h #用df 查看是否正确.`**
  * 文件系统 容量 已用 可用 已用% 挂载点 
  * /dev/sdb2 58G 30M 58G 1% /data/usb
{% endhint %}

#### 重新挂载根目录与挂载不特定目录

{% hint style="info" %}
* **重新挂载根目录 `(只有在单人维护模式下, 并且根目录是只读的,才会使用重新挂载根目录的命令)`**
  * **`$mount  -n -o  remount,rw,auto  /`**
* **将一个目录挂载到另一个目录  `(一般是某些程序无法使用软连接或硬链接,才会有的这种折中办法)`**
  * **`$mkdir -p /data/var ; mount --bind /var  /data/var`**
    * **`两个内容完全一样,就当成硬链接看就好了`**
    * **`详细信息查询:   $mount | grep var`**
{% endhint %}

### 卸载 \(umount\)

**如果卸载失败,则说明你正在使用这个卸载设备,  或者网络不通畅\(网络文件系统\).**

```bash
$umount   选项  设备文件名或挂载点
选项与参数:
-f :强制卸载!可用在类似网络文件系统 (NFS) 无法读取到的情况下;
-l :立刻卸载文件系统，比 -f 还强!
-n :不更新 /etc/mtab 情况下卸载。

#写在完成后,可以使用 $df 或 $mount 看看是否还存在目录树中.
范例: 卸载上面所有已经挂载的东西
$umount  /dev/sda4     #用块设备文件名来卸载
$umount  /data/ext4    #用挂载点来卸载
$umount  /data/cdrom    #卸载光盘
$umount  /data/usb
$umount  /data/var      #卸载一个挂载的目录,这里必须使用 挂载点.
```

## 磁盘/文件 系统参数修订

```bash
$mknod  设备文件名  参数  主要设备码  次要设备码
参数:
    b   :设置设备名称成为一个 周边存储设备文件(硬盘)
    c   :设置设备名称成为一个 周边输入设备文件, 键盘鼠标等.
    p   :设置设备名称成为一个 FIFO文件(管道文件)
主要设备码 和 次要设备码 :  依照 $lsblk 和 $ll /dev/sda*   来进行设置,  但不要胡乱设置.
一般的设备码为: 
    磁盘名      主要设备码(Major)    次要设备码(Minor)
   /dev/sda        8                0-15
   /dev/sdb        8                16-31
   /dev/loop0      7                0
   /dev/loop1      7                1
   
范例: 上述介绍可以  /dev/sda10 的设备码是 8,10    创建并查阅这个设备,(这个设备目前还不存在)
$mknod   /dev/sda10 b  8 10 
$ll  /dev/sda10 
输出: brw-r--r--. 1 root root 8, 10 10月 14 11:00 /dev/sda10

#如果是无用的, 不要忘记删除它,  $rm /dev/sda10
    
```

### xfs\_admin  修改XFS 文件系统的 UUID 与 LABEL name  \(就是标签重命名\)

**如果你当初格式化的时候忘记加上标头名称，后来想要再次加入时，不需要重复格式化!直接使用这个 xfs\_admin 即可。 这个指令直接拿来处理 LABEL name 以及 UUID 即可啰!**

```bash
# 修改前,需要先进行卸载. 修改的文件系统必须是 xfs 格式.

$xfs_admin   选项  参数  设备文件名
选项和参数:
-l    :列出这个设备的 label name
-u    :列车这个设备的  UUID
-L    :设置这个设备的 Label name
-U    :设置这个设备的 UUID

范例:  设置 /dev/sda4 的 label name (标签重命名) 为 vbird_xfs, 并测试挂载.
$umount  /dev/sda4             #修改前需要先卸载.
$xfs_admin  -L vbird_xfs  /dev/sda4 
$mount  LABEL=vbird_xfs  /data/xfs            #可以通过label 进行挂载

范例:  修改  /dev/sda4 的 UUID
$umount  /dev/sda4             #修改前需要先卸载.
$uuidgen                         #这个会得到一个新的随机UUID. 并且不会重复
$xfs_admin -U $(uuidgen) /dev/sda4        #也可以这么写,来直接得到UUID

```

### tune2fs  修改 ext4 的 label name 与 UUID

```bash
# 修改前,需要先进行卸载. 修改的文件系统必须是 ext4 格式.

$tune2fs  选项  参数   设备文件名
选项和参数:
-l   :类似 dumpe2fs  -h  的功能. 将 superblock 内的数据读出来
-L   :修改 LABEL  name
-U   :修改 UUID

范例: 列出 /dev/sda5 的  label name 之后, 将它改成 vbird_ext4
$dumpe2fs -h /dev/sda5 | grep  name
输出:dumpe2fs 1.42.9 (28-Dec-2013)
     Filesystem volume name:   <none>
$tune2fs  -L vbird_ext4  /dev/sda5          #修改
$tune2fs  -l  /dev/sda5  | grep name       #和dumpe2fs -h  效果相同
$mount  LABEL=vbird_ext4  /data/ext4       #挂载
```

## 设置开机挂载

* **开机挂载的限制**
  * 根目录 / 是必须挂载的,而且一定要先于其它 mount point 被挂载进来
  * 其它 mount point 必须为已创建的目录,可任意指定,但一定要遵守必须的系统目录架构 原则 \(FHS\)
  * 所有 mount point 在同一时间之内,只能挂载一次。
  * 所有 partition 在同一时间之内,只能挂载一次。 如若进行卸载,您必须先将工作目录移到 mount point\(及其子目录\) 之外

**开机挂载的配置文件  `/etc/fstab`**

{% code-tabs %}
{% code-tabs-item title="fstab" %}
```bash
#设备 或 UUID 等          挂载点        文件系统   文件系统参数                dump  fack
/dev/mapper/centos-root  /              xfs     defaults                     0 0
UUID=670c24ae-e100-445   /boot          xfs     defaults                     0 0
UUID=7AD0-C59C           /boot/efi      vfat    umask=0077,shortname=winnt   0 0
/dev/mapper/centos-home  /home          xfs     defaults                     0 0
/dev/mapper/centos-swap  swap           swap    defaults                     0 0
```
{% endcode-tabs-item %}
{% endcode-tabs %}

* 配置文件 **`/etc/fstab`**详解:
  * **第一栏:  磁盘设备文件名  /UUID/LABEL name**
    * 这个字段有三个项目,  设备文件名\(/dev/sda3\), UUID, LABEL  等.
    * **`可以使用 $blkid 或 xfs_admin 来查询 UUID.`**
  * **第二栏: 挂载点 \(就是目录\)**
  * **第三栏: 磁盘分区的文件系统**
    * 包括xfs, ext4, vfat, reiserfs , nfs 等
  * **第四栏: 文件系统参数** 
    *  具体的设置在 **`$mount 命令的 -o`** 选项中, 中间用逗号区分就行**.**
    * 默认给  **`defaults`** 即可
  * **第五栏: 能否被 dump 备份指令作用.** 
    * 目前没什么用, 直接给0 忽略就好.
  * **第六栏: 是否以 fsck 检验扇区.**
    * xfs文件系统无法使用这个选项. 直接给0就好
* **当修改完配置文件后,尽量使用  `$mount -a`  来进行一次自动挂载. 然后查看是否挂载正确\(`$blkid`\).才可以使用这个配置文件.**

**当配置完成后, 开机就可以实现自动挂载了, 也可以进行 $mount -a 进行自动挂载\(配置文件\).**

**如果配置文件修改出现了错误, 并且无法进入系统, 那么可以进入单人模式 , 使用命令 `$mount -n -o remount,rw /` 来进行更目录的可读可写挂载,然后再将错误的配置文件修改正确.**

## 特殊文件 loop 挂载 \(镜像文件不烧录就挂载使用\)



























