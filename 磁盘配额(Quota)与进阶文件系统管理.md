# 磁盘配额(**Quota**)与进阶文件系统管理 

## 磁盘配额 (**Quota**) 的应用与实作 

我们可以使用 quota 来让磁盘的容量使用较为公平.

quota 就是在回报管理员磁盘使用率以及让管理员管理磁盘使用情况的一个工具.

- quota 比较常使用的几个情况是: 
  - 针对 WWW server ，例如:每个人的网页空间的容量限制!
  - 针对 mail server，例如:每个人的邮件空间限制。
  - 针对 file server，例如:每个人最大的可用网络硬盘空间 ( 教学环境中最常见!) 

- linux 系统主机上面进行的设置

  - 限制某一群组所能使用的最大磁盘配额 (使用群组限制)

  - 限制某一使用者的最大磁盘配额 (使用使用者限制)

  - 限制某一目录(directory, project) 的最大磁盘配额

#### quota 的使用限制

  - 在 EXT 文件系统家族仅能针对整个 filesystem 
  - 核心必须支持 quota  
  - 只对一般身份使用者有效 
  - 若启用 SELinux，并非所有目录均可设置 quota  ,似乎仅能针对 /home 进行设置而已 
    - 如果关闭  SElinux ,则就不存在这种限制了.
  - 在使用 quota 之前, 一定要确定好所使用的文件系统和核心是否支持,以及支持到什么程度.

#### quota  的规范设置项目:

-  限制项目主要分为下面几个部分:
  - 分别针对  使用者,  群组 或个别 目录 (user, group  & project )
    - `容量限制`  或 `文件数量限制` (block  或 inode )
      - 限制 inode 用量 :  可以管理使用者可以创建的"文件数量"
      - 限制 block 用量 :  可以管理使用者磁盘容量的限制, 较常见为这种方式.
    - **柔性劝导与硬性规定 (soft/hard) **
      - **会倒数计时的宽限时间 (grace time): **
        - 当你的磁盘用量即 将到达 hard 且超过 soft 时，系统会给予警告，但也会给一段时间让使用者自行管理磁盘。 一般默认的宽限时间为七天，如果七天内你都不进行任何磁盘管理，那么 soft 限制值会即刻 取代 hard 限值来作为 quota 的限制 
      - **hard:  表示使用者的用量绝对不会超过这个限制值**
      - **soft:  表示使用者在低于 soft 限值时 (此例中为 400MBytes)，可以正常使用磁盘，**
        - 但若超过 soft 且低于 hard 的限值 (介于 400~500MBytes 之间时)，每次使用者登陆系统时，系统会主动发出磁盘即将爆满的警告讯息， 且会给予一个宽限时间, 不过，若使用者在宽限时间倒数期间就将容量再次降低于 soft 限值之下， 则宽限时间会停止。 

### 一个 XFS 文件系统的 Quota 实作范例

- 设置流程:
  - **目的与账号**
  - **账号的磁盘容量限制值**
  - **群组的限额 (option 1)**  : 整个群组可以使用的容量,组内所有用户使用容量相加,不可以高于这限额.
  - **共享目录限额 (option 2 ) :** 
  - **宽限时间的限制**

```bash
启动文件系统的 Quota 磁盘配额功能, 需要修改文件 /etc/fstab , 寻找想要限制配额的分区 (filesystem)
$vim /etc/fatab 
#进行范例添加:  比如我想要将 /home 分区支持磁盘配额功能.在第四个字段添加两个参数 usrquota,grpquota
	 /dev/mapper/centos-home  /home    xfs  default,usrquota,grpquota  0  0

#随后进行设置目录的重新挂载
$umount /home 
$mount -a           #检测是否挂载成功, 否则继续修改配置文件.
```



```bash
$xfs_quota  -x  -c  "指令"  [挂载点]
选项与参数:
 -x  :专家模式，只有进入专家模式后续才能够加入 -c 的指令参数
 -c  :表示后面加的就是指令
  指令:
	  print  :单纯的列出目前主机内的文件系统参数等数据
		df     :与原本的 df 一样的功能，可以加上 -b (block) -i (inode) -h (加上单位) 等
		report :列出目前的 quota 项目，有 -ugr (user/group/project) 及 -bi 等数据
    state  :说明目前支持 quota 的文件系统的信息，有没有起动相关项目等
 
 
范例一:列出目前系统的各的文件系统，以及文件系统的 quota 挂载参数支持
$xfs_quota   -x -c "prinit"
输出:
Filesystem          Pathname
/                   /dev/mapper/centos-root
/boot               /dev/sda2
/home               /dev/mapper/centos-home (uquota, gquota)  #这是支持的参数,组和用户


范例二:列出目前 /home 这个支持 quota 的载点文件系统使用情况
$xfs_quota -x -c "df -h" /home
Filesystem     Size   Used  Avail Use% Pathname
/dev/mapper/centos-home
               5.0G 113.2M   4.9G   2% /home
# 如上所示，其实跟原本的 df 差不多! 只是会更正确就是了。
 
 
 范例三:列出目前 /home 的所有用户的 quota 限制值
 $ xfs_quota -x -c "report -ubih" /home
User quota on /home (/dev/mapper/centos-home)
                        Blocks                            Inodes              
User ID      Used   Soft   Hard Warn/Grace     Used   Soft   Hard Warn/Grace  
---------- --------------------------------- --------------------------------- 
root          16K      0      0  00 [------]     12      0      0  00 [------]
vbird3          0      0      0  00 [------]      1      0      0  00 [------]
dmtsai      80.3M      0      0  00 [------]    480      0      0  00 [------]
alex          20K      0      0  00 [------]     13      0      0  00 [------]
arod          24K      0      0  00 [------]     14      0      0  00 [------]
vbird1        24K      0      0  00 [------]     14      0      0  00 [------]
agetest       12K      0      0  00 [------]      7      0      0  00 [------]
pro1          12K      0      0  00 [------]      7      0      0  00 [------]
pro2          12K      0      0  00 [------]      7      0      0  00 [------]
pro3          32K      0      0  00 [------]     16      0      0  00 [------]
myquota1      12K      0      0  00 [------]      7      0      0  00 [------]
myquota2      12K      0      0  00 [------]      7      0      0  00 [------]
myquota3      12K      0      0  00 [------]      7      0      0  00 [------]
myquota4      12K      0      0  00 [------]      7      0      0  00 [------]
myquota5      12K      0      0  00 [------]      7      0      0  00 [------]
# 所以列出了所有用户的目前的文件使用情况，并且列出设置值。注意，最上面的 Block
# 代表这个是 block 容量限制，而 inode 则是文件数量限制喔。另外，soft/hard 若为 0，代表没限制



范例四:列出目前支持的 quota 文件系统是否 启动了 quota 功能?
  $xfs_quota   -x  -c "state"
User quota state on /home (/dev/mapper/centos-home)
  Accounting: ON				# 有启用计算功能
  Enforcement: ON			  # 有实际 quota 管制的功能
  Inode: #1711 (4 blocks, 4 extents)				# 上面四行说明的是有启动 user 的限制能力
Group quota state on /home (/dev/mapper/centos-home)
  Accounting: ON
  Enforcement: ON
  Inode: #1712 (4 blocks, 4 extents)	  		# 上面四行说明的是有启动 group 的限制能力
Project quota state on /home (/dev/mapper/centos-home)
  Accounting: OFF
  Enforcement: OFF
  Inode: #1712 (4 blocks, 4 extents)				# 上面四行说明的是 project 并未支持
Blocks grace time: [7 days]								  #下面则是 grace time 的项目
Inodes grace time: [7 days]					
Realtime Blocks grace time: [7 days]
```

#### quota 限制值设置方式

```bash
限制值: 每个用户 250M/300M 的容量限制，群组共 950M/1G 的容量限制，同时 grace time 设置为 14 天

$xfs_quota  -x  -c "limit [-ug]  b[soft | hard]=N  i[soft | hard]=N username"
$xfs_quota  -x  -c "timer [-ug]  [-bir] Ndays"
选项与参数:
limit: 实际限制的项目, 可以针对 user/group 来限制, 限制的项目有:
				 bsoft/bhard : block 的 soft/hard 限制值，可以加单位(kb,mb,gb)
				 isoft/ihard : inode 的 soft/hard 限制值
				 name : 就是用户/群组的名称
 timer :用来设置 grace time 的项目喔，也是可以针对 user/group 以及 block/inode 设置


范例一:设置好用户们的 block 限制值 (题目中没有要限制 inode ),用户:muquta1 - 5
$xfs_quota -x -c "limit -u bsoft=250M bhard=300M  myquota1" /home
$xfs_quota -x -c "limit -u bsoft=250M bhard=300M  myquota2" /home
$xfs_quota -x -c "limit -u bsoft=250M bhard=300M  myquota3" /home
$xfs_quota -x -c "limit -u bsoft=250M bhard=300M  myquota4" /home
$xfs_quota -x -c "limit -u bsoft=250M bhard=300M  myquota5" /home
$xfs_quota -x -c "report -ubih" /home 			#查看目前 /home 的所有用户的 quota 限制值
输出:
User quota on /home (/dev/mapper/centos-home)
                        Blocks                            Inodes              
User ID      Used   Soft   Hard Warn/Grace     Used   Soft   Hard Warn/Grace  
---------- --------------------------------- --------------------------------- 
root          16K      0      0  00 [------]     12      0      0  00 [------]
vbird3          0      0      0  00 [------]      1      0      0  00 [------]
dmtsai      80.3M      0      0  00 [------]    480      0      0  00 [------]
alex          20K      0      0  00 [------]     13      0      0  00 [------]
arod          24K      0      0  00 [------]     14      0      0  00 [------]
vbird1        24K      0      0  00 [------]     14      0      0  00 [------]
agetest       12K      0      0  00 [------]      7      0      0  00 [------]
pro1          12K      0      0  00 [------]      7      0      0  00 [------]
pro2          12K      0      0  00 [------]      7      0      0  00 [------]
pro3          32K      0      0  00 [------]     16      0      0  00 [------]
myquota1      12K   250M   300M  00 [------]      7      0      0  00 [------]
myquota2      12K   250M   300M  00 [------]      7      0      0  00 [------]
myquota3      12K   250M   300M  00 [------]      7      0      0  00 [------]
myquota4      12K   250M   300M  00 [------]      7      0      0  00 [------]
myquota5      12K   250M   300M  00 [------]      7      0      0  00 [------]


范例三:设置一下 grace time 变成 14 天
$xfs_quota -x -c "timer -g -bir 14days" /home
$xfs_quota -x -c "timer -u -bir 14days" /home
$xfs_quota -x -c "state" /home
输出:
User quota state on /home (/dev/mapper/centos-home)
  Accounting: ON
  Enforcement: ON
  Inode: #1711 (4 blocks, 4 extents)
Group quota state on /home (/dev/mapper/centos-home)
  Accounting: ON
  Enforcement: ON
  Inode: #1712 (4 blocks, 4 extents)
Project quota state on /home (/dev/mapper/centos-home)
  Accounting: OFF
  Enforcement: OFF
  Inode: #1712 (4 blocks, 4 extents)
Blocks grace time: [14 days]			#这里更改了
Inodes grace time: [14 days]			#这里更改了
Realtime Blocks grace time: [14 days]
```

#### project 的限制 (针对目录的限制)

`project` 限制不可以和 group 同时设置,必须先取消 `group` 参数

- 首先修改 `/etc/fstab` 内的文件系统支持参数
  - 将原先添加的  `grpquota` 的参数取消, 然后加入 `prjquota` , 并且卸载 `/home` 再重新挂载才行.

```bash
#/etc/fstab 设置之后,重新挂载, 那么输出应该是下面的样子.
$xfs_quota -x -c "state"
User quota state on /home (/dev/mapper/centos-home)
  Accounting: ON
  Enforcement: ON
  Inode: #1711 (4 blocks, 4 extents)
Group quota state on /home (/dev/mapper/centos-home)
  Accounting: OFF
  Enforcement: OFF
  Inode: #1712 (4 blocks, 4 extents)
Project quota state on /home (/dev/mapper/centos-home)
  Accounting: ON		              #已经开启了
  Enforcement: ON
  Inode: #1712 (4 blocks, 4 extents)
Blocks grace time: [14 days]
Inodes grace time: [14 days]
Realtime Blocks grace time: [14 days]
```

##### 目录的设置比较奇怪，他必须要指定一个所谓的“专案名称、专案识别码”来规范才行 ,而且还 需要用到两个配置文件 

```bash
要规范的目录是 /home/myquota 目录，这个目录我们给个 myquotaproject 的专案名称， 这个专案名称给个 11 的识别码，这个都是自己指定的，若不喜欢就自己指定另一个

#指定专案识别码与目录的对应在 /etc/projects
$echo "11:/home/myquota" >> /etc/projects	  #这个文件原本是不存在的,需要新建

#规范专案名称与识别码的对应在 /etc/projid
$echo "myquotaproject:11"  >> /etc/projid    #这个文件原本也不存在

#初始化专案名称
$xfs_quota  -x  -c "project -s myquotaproject"
	输出: 
	Setting up project myquotaproject (path /home/myquota)...
	Processed 1 (/etc/projects and cmdline) paths for project myquotaproject with 
  recursion depth infinite (-1).
   .... 下面省略.      #这些信息是 OK 的.


$xfs_quota   -x -c "print" /home
 Filesystem          Pathname
 /home /dev/mapper/centos-home (uquota, pquota)
 /home/myquota /dev/mapper/centos-home (project 11, myquotaproject)
 # 这个 print 功能可以完整的查看到相对应的各项文件系统与 project 目录对应!
 
$xfs_quota -x -c "report -pbih " /home
Project quota on /home (/dev/mapper/centos-home)
                        Blocks                            Inodes              
Project ID       Used   Soft  Hard Warn/Grace     Used   Soft   Hard  Warn/Grace  
---------- ----------------------------------- ---------------------------------- 
myquotaproject      0      0     0  00 [------]      1      0     0   00 [------]
	#确定有抓到这个专案名称!接下来就可以准备设置了.
```

```bash
#实际设置规范与测试:
# 先来设置好这个 project ,设置的方式同样使用 limit 的 bsoft/bhard 
$xfs_quota  -x  -c "limit -p bsoft=450M bhard=500M myquotaproject" /home
$xfs_quota -x -c "report -pbih " /home	 #查看一下 是否设置成功
Project quota on /home (/dev/mapper/centos-home)
                        Blocks                            Inodes              
Project ID       Used   Soft   Hard Warn/Grace     Used   Soft   Hard Warn/Grace  
---------- --------------------------------- --------------------------------- 
myquotaproject      0   450M   500M  00 [------]      1      0      0  00 [------]

#设置完成了, 在 /home/mypuota  目录下的文件总大小不允许超过 500M
#如果想要修改限制,那么直接修改 /etc/projects 和 /etc/projid 文件,然后直接处理目录的初始化与设置即可.	
```

#### xfs_quota 的管理与额外指令对照表

- disable:暂时取消 quota 的限制，但其实系统还是在计算 quota 中，只是没有管制而 已!应该算最有用的功能啰!

- enable:就是回复到正常管制的状态中，与 disable 可以互相取消、启用! 
- off:完全关闭 quota 的限制，使用了这个状态后，你只有卸载再重新挂载才能够再次的 启动 quota 喔!
  - 也就是说， 用了 off 状态后，你无法使用 enable 再次复原 quota 的管制 喔!注意不要乱用这个状态!一般建议用 disable 即可，除非你需要执行 remove 的动 作! 

- remove:必须要在 off 的状态下才能够执行的指令~这个 remove 可以“移除”quota 的限 制设置，例如要取消 project 的设置， 无须重新设置为 0 喔!只要 remove -p 就可以 了! 

```bash
暂时关闭 xfs 文件系统的 quota 限制功能
$xfs_quota  -x -c "disable -up" /home

启动 quota 限制
$xfs_quota  -x -c "enable -up" /home 

完全关闭
$xfs_quota  -x -c "off -up" /home

在 完全关闭  状态下,保留原有设置 并重启 quota
	$umount /home  ; mount -a       #重新挂载 即可.

移除所有 quota 设置过的限制, 是全部删除
$xfs_quota -x -c "remove -p"  /home
```



####  不更动既有系统的 **quota** 实例 

/var/spool/mail 是邮件目录, 我想要将整个目录也设置 quota ,但是他并不是xfs 文件系统, 就可以用下面的方法来解决:

既然 quota 是针对 filesystem 来进行限制，假设你又已经有 /home 这个 独立的分区了，那么你只要: 

1. 将/var/spool/mail这个目录完整的移动到/home下面; 
2. 利用ln-s/home/mail/var/spool/mail来创建链接数据; 
3.  将/home进行quota限额设置 



## 软件磁盘阵列  (Software RAID)

磁盘阵列全名是“ Redundant Arrays of Inexpensive Disks, RAID ”，英翻中的意思是:**容错式 廉价磁盘阵列 **

- RAID-0 (等量模式, stripe):性能最佳 
  - 将数据分隔成等量块, 然后交错的存入所有磁盘.
- RAID-1 (映射模式, mirror):完整备份 
  - 将数据复制成与磁盘同等的份数, 每个磁盘保留一份.
- RAID 1+0，RAID 0+1 
  - 先将四组磁盘分成  两组RAID1 , 然后让这两组 RAID1 再组成 RAID0.  这就是  RAID1+0 (推荐)
  - 先将四组磁盘分成  两组RAID0 , 然后让这两组 RAID0 再组成 RAID1.  这就是  RAID0+1 
- RAID 5
  - 至少需要三颗以上的磁盘,每个循环写入时，都会有部分的同位检查码 (parity) 被记录起来 ,并且记录 的同位检查码每次都记录在不同的磁盘 
    - 任何一个磁盘损毁时都能够借由其他磁盘的 检查码来重建原本磁盘内的数据.

#### Spare Disk:预备磁盘的功能: 

一颗或多颗没有包含在原本磁盘阵列等级中的磁盘，这颗磁盘平 时并不会被磁盘阵列所使用， 当磁盘阵列有任何磁盘损毁时，则这颗 spare disk 会被主动的拉进磁盘阵列中，并将坏掉的那颗硬盘移出磁盘阵列! 然后立即重建数据系统.

若你的磁盘阵列有支持热拔插那就更完美了! 直接将坏掉的那颗磁盘 拔除换一颗新的，再将那颗新的设置成为 spare disk ，就完成了 .

#### 磁盘阵列的优点

1. 数据安全与可靠性:指的并非网络信息安全，而是当硬件(指磁盘)损毁时，数据是否 还能够安全的救援或使用之意; 

2. 读写性能:例如RAID0可以加强读写性能，让你的系统I/O部分得以改善; 
3. 容量:可以让多颗磁盘组合起来，故单一文件系统可以有相当大的容量。 



### Software 软件, hardware 硬件, RAID 磁盘阵列

- 硬件磁盘阵列 (hardware RAID) 
  - 是通过磁盘阵列卡来达成阵列的目的 
- 软件磁盘阵列 (softare RAID)
  - 主要是通过软件来仿真阵列的任务， 因此会损耗较多的系统资源，比如说 CPU 的运算与 I/O 总线的资源等 
  - 软件磁盘阵列 会以 partition(分区) 或 disk(磁盘) 为磁盘单位进行阵列. (也就是说只要有分区即可)

- 硬件的磁盘阵列 设备文件名一般为  /dev/sd[a-p] 
- 软件的磁盘阵列 设备文件名一般为 /dev/md[0-N]  ,因为是系统仿真的 ,所以使用的是系统的设备文件名.



### 软件磁盘阵列设置

```bash
$mdadm  --detail   /dev/md0          #后面的设备文件名,是将要创建的或已经创建好 RAID的
$mdadm  --create   /dev/md[0-9]  --auto=yes --level=[015] --chunk=NK    \
>  --raid-devices=N --spare-devices=N  /dev/sdx /dev/hdx...

选项与参数:
--create     :为创建 RAID 的选项;
--auto=yes   :决定创建后面接的软件磁盘阵列设备，亦即 /dev/md0, /dev/md1...
--level=[015]   :设置这组磁盘阵列的等级。支持很多，不过建议只要用 0, 1, 5 即可
--chunk=Nk   :决定这个设备的 chunk 大小，也可以当成 stripe 大小，一般是 64K 或 512K。
--raid-devices=N    :使用几个磁盘 (partition) 作为磁盘阵列的设备
--spare-devices=N   :使用几个磁盘作为备用 (spare) 设备
--detail   :后面所接的那个磁盘阵列设备的详细信息
设备文件名 可以是分区 , 也可以是整颗磁盘.
最后面的设备文件名的总数 必须等于  --raid-devices 与 --spare-devices 的个数总和才行


范例: 利用4个partiton分区 组成RAID5 , 每个分区约为1GB大小. 利用一个分区设置为 spare disk.
	    chunk块 设置为 256K 大小, spare 大小与 组成RAID的分区一样大. 将RAID5挂载到 /srv/raid 下.
流程为: 分区, 创建RAID5, 查询是否创建完成, 格式化文件系统, 挂载使用.

#首先分出5个 1GB分区(FD00 LINUX RAID )
$gidsk -l /dev/sda           #省略分区步骤, 直接查看了.
   4        65124352        67221503   1024.0 MiB  FD00  Linux RAID
   5        67221504        69318655   1024.0 MiB  FD00  Linux RAID
   6        69318656        71415807   1024.0 MiB  FD00  Linux RAID
   7        71415808        73512959   1024.0 MiB  FD00  Linux RAID
   8        73512960        75610111   1024.0 MiB  FD00  Linux RAID

$partprobe       #更新核心分区列表, 否则无法继续进行.
$lsblk           #得到设备名 和更多详细信息.
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
...这部分内容省略, 主要是下面的这5条.
├─sda4            8:4    0    1G  0 part 
├─sda5            8:5    0    1G  0 part 
├─sda6            8:6    0    1G  0 part 
├─sda7            8:7    0    1G  0 part 
└─sda8            8:8    0    1G  0 part


#接着用 mdadm  创建 RAID5,  最后的设备文件名用到了 bash 的功能
$mdadm --create /dev/md0 --auto=yes --level=5 --chunk=256 --raud-devices=4 \
> --spare-devices=1  /dev/sda{4,5,6,7,8}
输出:
mdadm: /dev/sda5 appears to contain an ext2fs file system
       size=1048576K  mtime=Mon Oct 14 11:48:08 2019
Continue creating array? y	       #上面是旧系统的提示,直接 y 确认删除就好.
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.

#创建完成, 新的 RAID5 设备文件名是 /dev/md0



# 下面是创建完成后查询的详细信息. (创建完成后,等待几分钟再查询)
$mdadm  --detail /dev/md0
输出:
/dev/md0:			                                           # RAID 的设备文件名
           Version : 1.2
     Creation Time : Fri Nov  8 15:48:12 2019	          # 创建 RAID 的时间
        Raid Level : raid5	        	        	        # 这是 RAID5 等级
        Array Size : 3139584 (2.99 GiB 3.21 GB)         # 整组RAID 的可用容量
     Used Dev Size : 1046528 (1022.00 MiB 1071.64 MB)   # 组成RAID的每颗磁盘(设备) 的容量
      Raid Devices : 4                                  # 组成RAID的磁盘数量(不包括spare)
     Total Devices : 5                                  # 包括 spare 的总磁盘数量
       Persistence : Superblock is persistent

       Update Time : Fri Nov  8 15:48:20 2019
             State : clean                           # 目前这个磁盘阵列的 容量使用状态
    Active Devices : 4                               # 启动(active)的设备数量
   Working Devices : 5                               # 目前使用于此阵列的设备数
    Failed Devices : 0                               # 损坏的设备数
     Spare Devices : 1                               # 预备磁盘的数量

            Layout : left-symmetric
        Chunk Size : 256K                         	# 就是 chunk 的小区块容量

Consistency Policy : resync

              Name : study.centos.vbird:0  (local to host study.centos.vbird)
              UUID : a03fe550:dd6bbb20:c696c3bb:7745ac93
            Events : 18

    Number   Major   Minor   RaidDevice State
       0       8        4        0      active sync   /dev/sda4
       1       8        5        1      active sync   /dev/sda5
       2       8        6        2      active sync   /dev/sda6
       5       8        7        3      active sync   /dev/sda7

       4       8        8        -      spare   /dev/sda8
		#最后这5行就是5个设备目前的情况, 包括四个 active sync 和一个 spare
		# 至于 RaidDeevice 列指的则是此 RAID  内的磁盘顺序.
		
		
#第二种查询方法
$cat /proc/mdstat
输出:
md0 : active raid5 sda7[5] sda8[4](S) sda6[2] sda5[1] sda4[0]    #第一行
      3139584 blocks super 1.2 level 5, 256k chunk, algorithm 2 [4/4] [UUUU]   #第二行
unused devices: <none>

#第一行部分指出 md0 是RAID5, 使用了 sda4 ,sda5, sda6 ,sda7 ,sda8 等5颗磁盘, 
#    [N] 内的数字是此磁盘在 RAID 中的顺序,  sda8[4](S) 后面的S 代表 sda8是spare
#第二行支持 磁盘阵列拥有 3139584 个block(每个block单位是1K),总容量为3GB, 使用RAID5等级.
#	   写入磁盘的小区块(chunk)大小为 256K, 使用algorithm2 磁盘阵列演算法. 
#    [4/4] 表示此磁盘阵列需要4个设备(前), 且有4个设备正常运行(后)
#    [UUUU]  4个磁盘设备正常运行, 如果出现 _ 则表示不正常,应该检查或更换新设备.



格式化与挂载使用 RAID
#srtipe(chunk)容量256K, 4颗盘组RAID5,因此少一颗,剩下3颗盘,数据宽度256*3=768K
$mkfs.xfs -f -d su=256k,sw=3 -r extsize=768k  /dev/md0     
输出:
         =                       sectsz=4096  attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=784384, imaxpct=25
         =                       sunit=64     swidth=192 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=4096  sunit=1 blks, lazy-count=1
realtime =none                   extsz=786432 blocks=0, rtextents=0


格式化完成, 可以挂载并且进行使用了
$partprobe       #先更新一下核心分区列表
$mkdir /srv/raid;  mount /dev/md0  /srv/raid       #挂载
$df  -Th /srv/raid        #查看一下属性
文件系统       类型  容量  已用  可用 已用% 挂载点
/dev/md0       xfs   3.0G   33M  3.0G    2% /srv/raid
#挂载成功.
```



### 仿真  RAID 错误的救援模式

磁盘阵列出现问题的时候进行救援. (raid0  可以直接放弃了)

```bash
$mdadm  --manage /dev/md[0-9] [--add 设备] [--remove 设备] [--fail 设备]
选项与参数:
--add     :会将后面的设备加入到这个 md 中
--remove  :会将后面的设备从这个 md 中移除
--fail    :会将后面的设备设置称为出错的状态


范例: 仿真一下,假设 /dev/sda7 硬盘坏掉了
$mdadm --manage /dev/md0 --fail /dev/sda7
$mdadm --detail /dev/md0         #使用这个命令来获得当前损坏的状态.
...省略
    Failed Devices : 1     #得到1颗坏掉的设备提示
    ...省略
        Number   Major   Minor   RaidDevice State
           5       8        7        -      faulty   /dev/sda7	
           			# faulty 表示坏掉了, 但是原先的 sda8 (spare) 顶替了 sda7 坏掉的位置(真好)


这样一来 sda7 这颗硬盘就表示坏掉了, 需要将出错的硬盘移除并加入新的磁盘.
步骤如下: 
	 1. 先从 /dev/md0 阵列中移除 /dev/sda7 这颗磁盘(坏掉的)
	 2. 整个Linux 系统关机, 拔出 /dev/sda7 这颗磁盘, 并且安装上新的 /dev/sda7 磁盘,开机
	 3. 将新的 /dev/sda7 加入到 /dev/md0  阵列当中.


第一步:
	$mdadm  --manage /dev/md0 --remove /dev/sda7  	
		#移除完成, 可以进行关机了. 然后进行第二步, 最后开机
		
第二个步骤默认省略. (毕竟虚拟环境)
第三步:   #首先寻找到新安装的硬盘是哪个,不要直接填写.
	#省略一部分,假设新设备是 /dev/sda7 ,并且进行了分区(FD00)和格式化(xfs)
	$mdadm  --manage  /dev/md0  --add /dev/sda7     #将这颗磁盘加入进来即可.
	    新加入的磁盘,会默认变成 spare 
```

### 开机自启动 RAID 并自动挂载

**其实现在已经不需要进行开机自启动配置了(会自动进行),  但是为了稳妥,还是要配置一下文件.**

```bash
software RAID 是有配置文件的, 是 /etc/mdadm.conf  ,但是Centos 7并没有这个配置文件,需要手动建立.

#首先拿到 /dev/md0 的UUID 
$mdadm --detail /dev/md0 | grep  -i 'UUID'     
输出:       UUID : a03fe550:dd6bbb20:c696c3bb:7745ac93

#开始设置 mdadm.conf 文件,(如果新建的话,请遵循下面的格式来写)
$vim /etc/mdadm.conf
ARRAY  /dev/md0  UUID="a03fe550:dd6bbb20:c696c3bb:7745ac93"
#前面是关键字 不可或缺, 第二个是RAID设备, 第三个是UUID


设置完成, 开机设置开机自动挂载并测试
$blkid /dev/md0         #得到一些需要用到的内容, UUID不一样了,多多注意
输出:	/dev/md0: UUID="1d41f3f0-0404-4e76-8752-b5deb2efcb6e" TYPE="xfs" 


$vim  /etc/fstab      #添加一些内容,按照格式写到这个文件的最下面一行,两个UUID是不一样的,多多注意
UUID=1d41f3f0-0404-4e76-8752-b5deb2efcb6e   /srv/raid   xfs   defaults  0 0

$umount /srv/raid  ; mount -a    #进行卸载和自动挂载测试
$df -Th /srv/raiid         #测试
文件系统       类型  容量  已用  可用 已用% 挂载点
/dev/md0       xfs   3.0G  117M  2.9G    4% /srv/raid
			#成功
```

### 关闭软件  RAID   (重要!)

```bash
1. 先卸载 /dev/md0  并删除配置文件 /etc/fstab 和 /etc/mdadm.conf 当中关于 dev/md0 的设置
$umount  /srv/raid        #卸载
$vim  /etc/fstab     
#删除这个文件中的如下内容:  
       UUID=1d41f3f0-0404-4e76-8752-b5deb2efcb6e   /srv/raid   xfs   defaults  0 0

$vim /etc/mdadm.conf
#注解或删除下面内容即可
       ARRAY /dev/md0 UUID=2256da5f:4870775e:cf2fe320:4dfabbc6



2. 覆盖掉 RAID 的 metabata  以及 XFS 的 superblock (超级区块) , 才关闭 /dev/md0 的方法.
$dd if=/dev/zero  of=/dev/md0  bs=1M  couunt=50    #这个是经过计算的,不是乱写的. 3GB=50MB
$mdadm  --stop  /dev/md0     #这样就关闭了 RAID
输出:  mdadm: stopped /dev/md0
$dd if=/dev/zero  of=/dev/sda4  bs=1M count=10    #这个RAID 是从 sda4 开始的,不可乱写
$dd if=/dev/zero  of=/dev/sda5  bs=1M count=10
$dd if=/dev/zero  of=/dev/sda6  bs=1M count=10
$dd if=/dev/zero  of=/dev/sda7  bs=1M count=10
$dd if=/dev/zero  of=/dev/sda8  bs=1M count=10  
 #完成

$cat /proc/mdstat      #查看一下是否覆盖完全.
Personalities : [raid6] [raid5] [raid4] 
unused devices: <none>	   #确实没有了 
```

















