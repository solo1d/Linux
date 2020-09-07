# 软件安装 RPM, SRPM 与 YUM
**在 Linux 上面至少就有两种常见的这方面的软件管理员， 分别是 RPM与 Debian 的 dpkg**
**CentOS 就是使用的 RPM**
- 在 Linux 界软件安装方式最常见的有两种,分别是:
  - **`dpkg`** ： 这个机制最早是由 Debian Linux 社群所开发出来的， 通过 dpkg 的机制，Debian 提供的软件就能够简单的安装起来， 同时还能提供安装后的软件信息， 实在非常不错。 只要是衍生于 Debian 的其他 Linux distributions 大多使用 dpkg 这个机制来管理软件的， 包括 B2D, Ubuntu 等等。
    - **本地指令是:  dpkg**
    - **线上升级指令是:  apt-get**
    - **检查有哪些版本可以安装**  `apt-cache search aarch64`
  - **`RPM`**： 这个机制最早是由 Red Hat 这家公司开发出来的， 后来实在很好用， 因此很多distributions 就使用这个机制来作为软件安装的管理方式。 包括 Fedora, CentOS, SuSE等等知名的开发商都是用这咚咚。
    - **本地指令是 : rpm, rpmbuild    . 安装包的后缀名是 `.rpm`**
    - **线上升级指令是 : yum**
    - **RPM 是以一种数据库记录的方式来将你所需要的软件安装到你的 Linux 系统的一套管理机制**
      - **优点:**
      - 由于已经编译完成并且打包完毕， 所以软件传输与安装上很方便 （ 不需要再重新编译）;
      - 由于软件的信息都已经记录在 Linux 主机的数据库上， 很方便查询、 升级与反安装
  - **SRPM 也是RPM的一种,后缀名是 `.src.rpm`,区别是 它会下载软件的源码,而且是没有编译的版本,可以让用户进行修改后,使用rpm进行安装.**
  
- **Linux开发商提供的 线上升级 机制,通过网络提供任何软件.**
  - **在 dpkg 管理机制上就开发出 APT 的线上升级机制**
  - **RPM 则依开发商的不同， 有 Red Hat 系统的 yum ， SuSE 系统的 Yast Online Update （ YOU） 等.**

### i386, i586, i686, noarch, x86_64
```bash
通过文件名,例如  rp-pppoe-3.11-5.el7.x86_64.rpm  ,可以获得 软件的版本、 适用的平台、 编译释出的次数信息
rp-pppoe	-	3.11	-		5				.el7.x86_64                .rpm 
软件名称		软件版本信息	释放出次数		适合的硬件平台          扩展名

解释：
软件名称： 当然就是每一个软件的名称了！ 上面的范例就是 rp-pppoe 。
版本信息： 每一次更新版本就需要有一个版本的信息，判别这一版是新是旧. 
                   这里通常又分为主版本跟次版本。 以上面为例， 主版本为 3 ， 在主版本的架构下更动部分源代码内容， 而释出一个新的版本， 就是次版本. 也就是 11 ,所以版本名就为 3.11
释出版本次数： 通常就是编译的次数,进行小幅度的 patch或重设一些编译参数。 设置完成之后重新编译并打包成 RPM 文件.
操作硬件平台：RPM 可以适用在不同的操作平台上， 但是不同的平台设置的参数还是有所差异性！
                         我们可以针对比较高阶的 CPU 来进行最优化参数的设置， 这样才能够使用高阶 CPU 所带来的硬件加速功能。 
                         所以就有所谓的 i386, i586, i686, x86_64 与 noarch 等的文件名称出现了！
```

|平台名称|适合平台说明|
| --- | --- |
|i386|适用于所有x86平台,i指的是inter相融的CPU,386指的是CPU等级|
|i586|适用于CPU等级为586的CPU|
|i686|适用于CPU等级为686的CPU|
|x86_64| 针对 64 位的 CPU 进行最优化编译设置 |
|noarch|没有任何硬件等级上的限制 |


## RPM 软件管理程序： rpm
**软件相关的信息就会被写入 /var/lib/rpm/ 目录下的数据库文件中**

|目录|作用|
| --- | --- |
|/usr/bin|可执行文件|
|/usr/lib|可执行程序使用的动态函数库|
|/usr/share/doc| 一些基本的软件使用手册与说明文档 |
|/usr/share/man|一些 man page 文件|
|/var/lib/rpm|RPM数据库,保存软件相关信息|

```bash
$rpm   -ivh   package_name         #安装rpm包 软件
选项与参数：
安装:
	-i ： install 的意思
	-v ： 察看更细部的安装信息画面
	-h ： 以安装信息列显示安装进度
	--force  :  强制重新安装某个rpm包,并且覆盖所有的内容.
	—justdb  :  更新后面 rpm包在 RPM 数据库中的信息
	—prefix 新路径     :  要将软件安装到其他非正规目录时,也就是安装到/usr/local 之类的
卸载:
	-e  ; 卸载的意思,要查看好软件的相依关系,然后从上向下进行卸载.
测试:
	—test  : 要测试一下该软件是否可以被安装到使用者的 Linux 环境当中， 可找出是否有属性相依的问题(常用)
升级:
	-U   :升级指定的软件,如果该软件没有安装,那么直接予以安装.
	-F   :升级指定的软件,如果该软件没有安装,则放弃升级.
查询已安装软件的信息:
	-q    : 仅查询后面的软件名称是否已安装
	-qa ： 列出所有的， 已经安装在本机 Linux 系统上面的所有软件名称；
	-qi ： 列出该软件的详细信息 （ information） ， 包含开发商、 版本与说明等；
	-ql ： 列出该软件所有的文件与目录所在完整文件名 （ list） ；
	-qc ： 列出该软件的所有配置文件 （ 找出在 /etc/ 下面的文件名而已）
	-qd ： 列出该软件的所有说明文档 （ 找出与 man 有关的文件而已）
	-qR ： 列出与该软件有关的相依软件所含的文件 （ Required 的意思）
	-qf ： 由后面接的文件名称， 找出该文件属于哪一个已安装的软件；-
	-q   --scripts： 列出是否含有安装后需要执行的脚本档， 可用以 debug .
查询某个 RPM 文件内含有的信息：
	-qp[icdlR]： 注意 -qp 后面接的所有参数以上面的说明一致。 但用途仅在于找出某个 RPM 文件内的信息， 而非已安装的软件信息！ 注意！
RPM验证:(重要)
	-V ： 后面加的是软件名称， 若该软件所含的文件被更动过， 才会列出来, 如果没有更改过,则不会有任何输出.
	-Va ： 列出目前系统上面所有可能被更动过的文件；
	-Vp ： 后面加的是文件名称， 列出该软件内可能被更动过的文件；
	-Vf ： 列出某个文件是否被更动过
重建RPM数据库:
	—rebuilddb   :重建RPM数据库


范例一： 安装原版光盘上的 rp-pppoe 软件 ,光盘挂载在 /mnt 目录下
$rpm  -ivh  /mnt/Packages/rp-pppoe-3.11-5.el7.x86_64.rpm

范例 : 直接由网络上面某个文件安装,也就是网址(下载链接)
$rpm  -ivh  http://website.name/path/pkgname.rpm

范例:  假设我不小心删除了 /etc/crontab 这个目录,也不知道它属于哪个软件, 怎么恢复.
$rpm -qf /etc/crontab      #这样就知道 crontab 目录是属于哪个软件的了, 然后将这个软件重新一次即可
$重装该软件


范例:查询一下， 你的 /etc/crontab 是否有被更动过？
$rpm  -Vf  /etc/crontab
输出:
.......T.   c /etc/crontab
#因为有被更动过， 所以会列出被更动过的信息类型！

范例: 查询一下, 你的 logrotate 软件 所使用的的文件被更改过的内容是什么.
$rpm  -ql  logrotate      #会得到 logrotate 软件的所有文件名与目录名
$rpm  -V  logrotate       #会得到一个更改过内容的文件列表
输出:
...5....T. c /etc/logrotate.conf

最前面的解释: 
	S ： （ file Size differs） 文件的容量大小是否被改变
	M ： （ Mode differs） 文件的类型或文件的属性 （ rwx） 是否被改变？ 如是否可执行等参数已被改变
	5 ： （ MD5 sum differs） MD5 这一种指纹码的内容已经不同
	D ： （ Device major/minor number mis-match） 设备的主/次代码已经改变
	L ： （ readLink（ 2） path mis-match） Link 路径已被改变
	U ： （ User ownership differs） 文件的所属人已被改变
	G ： （ Group ownership differs） 文件的所属群组已被改变
	T ： （ mTime differs） 文件的创建时间已被改变
	P ： （ caPabilities differ） 功能已经被改变
文件名前单个字符的解释:
	c ： 配置文件 （ config file）
	d ： 文件数据文件 （ documentation）
	g ： 鬼文件～通常是该文件不被某个软件所包含， 较少发生！ （ ghost file）
	l ： 授权文件 （ license file）
	r ： 读我文件 （ read me）
```


## YUM 线上升级机制
```bash
$yum [list|info|search|provides|whatprovides]   参数     #查询功能
$yum  -y   install   软件名          #安装, -y 表示在安装过程中的所有选项都给 yes
$yum   update  软件名             #升级,如果填写软件,则升级指定的软件,否则升级全部
$yum  remove   软件名            #卸载
$yum [option] [查询工作项目] [相关参数]
选项与参数:
[option]： 主要的选项， 包括有：
	-y ： 当 yum 要等待使用者输入时， 这个选项可以自动提供 yes 的回应；
	--installroot=/some/path ： 将该软件安装在 /some/path 而不使用默认路径
[查询工作项目] [相关参数]： 这方面的参数有：
	search ： 搜寻某个软件名称或者是描述 （ description） 的重要关键字；
	list ： 列出目前 yum 所管理的所有的软件名称与版本， 有点类似 rpm -qa；
	info ： 同上， 不过有点类似 rpm -qai 的执行结果；
	provides： 从文件去搜寻软件！ 类似 rpm -qf 的功能！
群组软件：(相当于安装一个IDE,很多依赖和所需的软件都会自动安装,很方便)
	grouplist ： 列出所有可使用的“软件群组组”， 例如 Development Tools 之类的；
	groupinfo ： 后面接 group_name， 则可了解该 group 内含的所有软件名；
	groupinstall： 这个好用！ 可以安装一整组的软件群组， 相当的不错用！
	groupremove ： 移除某个软件群组；



范例一： 搜寻磁盘阵列 （ raid） 相关的软件有哪些？
$yum search raid
输出:
Loaded plugins: fastestmirror, langpacks 		# yum 系统自己找出最近的 yum server
Loading mirror speeds from cached hostfile         # 找出速度最快的那一部 yum server
	* base: ftp.twaren.net 		# 下面三个软件库， 且来源为该服务器！
	* extras: ftp.twaren.net
	* updates: ftp.twaren.net....
(前面省略） ....
dmraid-events-logwatch.x86_64 : dmraid logwatch-based email reporting
dmraid-events.x86_64 : dmevent_tool （ Device-mapper event tool） and DSO
# 在冒号 （ :） 左边的是软件名称， 右边的则是在 RPM 内的 name 设置 （ 软件名）

范例二： 找出 mdadm 这个软件的功能为何
$yum info mdadm
输出:
Installed Packages             #这说明该软件是已经安装的了
Name : mdadm                 #这个软件的名称
Arch : x86_64                    #这个软件的编译架构
Version : 3.3.2                   #此软件的版本
Release : 2.el7                   #释出的版本
Size : 920 k                       #此软件的文件总容量
Repo : installed                  #软件库回报说已安装的
省略....


范例三： 列出 yum 服务器上面提供的所有软件名称
$yum list

范例四： 列出目前服务器上可供本机进行升级的软件有哪些？
$yum  list updates

范例五： 列出提供 passwd 这个文件的软件有哪些
$yum provides passwd

范例六： 列出以 pam 开头的所有软件.
$yum  list  pam*      #看最后一列可以知道 软件是以安装还是需要升级,以及未安装.

范例七： 列出目前 yum server 所使用的软件库有哪些？（用以更新  新的软件库地址)
$yum repolist all

范例八： 删除已下载过的所有软件库的相关数据 (含软件本身与清单),用以更新  新的软件库地址.
$yum clean all


范例九： 安装 “Scientific Support”的软件群组 
$yum groupinstall "Scientific Support"

```
**yum 线上服务器的软件库 地址, 记录在 `/etc/yum.repos.d/` 目录内,如果要添加新地址,那么随便建立个后缀名为 `.repo`的文件,然后按照其他文件的格式填写, 最后再更新一下数据库清单即可.**


### yum 预设值修改(就是远程软件库修改)

```bash
#首先将原本的 yum 预设值备份起来.(预设值就是阿里云的,可以不用改)
$mv   /etc/yum.repos.d/CentOS-Base.repo     /etc/yum.repos.d/CentOS-Base.repo.backup    

#下载阿里云提供的 yum 预设值文件并将其替换掉, 注意,这个只适合Centos7
$wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#清除原本的残留缓存
$yum clean all

#创建新的缓存,
$yum makecache

# 完成.
```


## 基础服务管理(安装服务的流程)

1. 安装： yum install （ 你的软件）
2. 启动： systemctl start （ 你的软件）
3. 开机启动： systemctl enable （ 你的软件）
4. 防火墙： firewall-cmd --add-service="（ 你的服务） "; firewall-cmd --permanent --addservice="（ 你的服务） "
5. 测试： 用软件去查阅你的服务正常与否～

```bash

# 1. 安装所需要的软件！
$yum install httpd php mariadb-server php-mysql

# 2. 3. 启动与开机启动， 这两个步骤要记得一定得进行！
$systemctl daemon-reload
$systemctl start httpd
$systemctl enable httpd

# 4. 防火墙
$firewall-cmd --add-service="http"
$firewall-cmd --permanent --add-service="http"
$firewall-cmd --list-all
输出:
	public （ default, active）
		interfaces: eth0
		sources:
		services: dhcpv6-client ftp http https ssh       # 这个是否有启动才是重点,也就是 https与http
```

## SRPM 使用 : rpmbuild
### 利用默认值安装 SRPM 文件  ( —rebuild  / —recompile )
```bash
$rpmbuild   —rebuild   SRPM文件.src.rpm      #编译,打包,并生成可安装的 .rpm 包,执行完毕后,会在最后一行输出 该rpm包所生成的位置
$rpmbuild   —recompile   SRPM文件.src.rpm      #编译,打包,并生成可安装的 .rpm 包,执行完毕后,会直接进行安装.
```

### SRPM 使用的路径与需要的软件
**每个用户应该都有能力自己安装自己的软件， 因此 SRPM 安装、 设置、 编译、 最终结果所使用的目录都与操作者的主文件夹有关**
- **SRPM 在进行编译的时候会使用到的目录( 假设使用的是 root 身份进行的操作,tar -ivh x.src.tar 生成出来的内容)**
  - /root/rpmbuild/SPECS
    - **这个目录当中放置的是该软件的配置文件， 例如这个软件的信息参数、 设置项目等等都放置在这里**
  - /root/rpmbuild/SOURCES
    - ** 这个目录当中放置的是该软件的原始文件 （ *.tar.gz 的文件） 以及 config 这个配置文件**
  - /root/rpmbuild/BUILD
    - ** 在编译的过程中， 有些暂存的数据都会放置在这个目录当中；**
  - /root/rpmbuild/RPMS
    - ** 经过编译之后， 并且顺利的编译成功之后， 将打包完成的文件放置在这个目录当中,里头有包含了 x86_64, noarch....等等的次目录**
  - /root/rpmbuild/SRPMS
    - ** 与 RPMS 内相似的， 这里放置的就是 SRPM 封装的文件啰！ 有时候你想要将你的软件用 SRPM 的方式释出时， 你的 SRPM 文件就会放置在这个目录中了**

**在编译的过程当中， 可能会发生不明的错误， 或者是设置的错误， 这个时候就会在 `/tmp` 下面产生一个相对应的错误文件， 你可以根据该错误文件进行除错的工作**


## 小结
- 为了避免使用者自行编译的困扰， 开发商自行在特定的硬件与操作系统平台上面预先编译好软件， 并将软件以特殊格式封包成文件， 提供终端用户直接安装到固定的操作系统上， 并提供简单的查询/安装/移除等流程。 此称为软件管理员。 常见的软件管理员有RPM 与 DPKG 两大主流。
- RPM 的全名是 RedHat Package Manager， 原本是由 Red Hat 公司所发展的， 流传甚广；
- RPM 类型的软件中， 所含有的软件是经过编译后的 binary program ， 所以可以直接安装在使用者端的系统上， 不过， 也由于如此， 所以 RPM 对于安装者的环境要求相当严格；
- RPM 除了将软件安装至使用者的系统上之外， 还会将该软件的版本、 名称、 文件与目录配置、 系统需求等等均记录于数据库 （ /var/lib/rpm） 当中， 方便未来的查询与升级、 移除；
- RPM 可针对不同的硬件等级来加以编译， 制作出来的文件可于扩展名 （ i386, i586, i686,x86_64, noarch） 来分辨；
- RPM 最大的问题为软件之间的相依性问题；
- SRPM 为 Source RPM ， 内含的文件为 Source code 而非为 binary file ， 所以安装SRPM 时还需要经过 compile ， 不过， SRPM 最大的优点就是可以让使用者自行修改设置参数 （ makefile/configure 的参数） ， 以符合使用者自己的 Linux 环境；
- RPM 软件的属性相依问题， 已经可以借由 yum 或者是 APT 等方式加以克服。 CentOS使用的就是 yum 机制。
- yum 服务器提供多个不同的软件库放置个别的软件， 以提供用户端分别管理软件类别。










