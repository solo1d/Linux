# 认识系统服务(daemons守护进程)
## 守护进程daemons 与服务serivce
**系统为了某些功能必须要提供一些服务(无论是系统本身还是网络方面),这个服务就称为 service .**
**service的提供总是需要进程的运行,所以达成这个 service 的进程 就称呼他为 daemons 守护进程**
就是说 需要有 daemons 的支持,才可以得到 service 服务的支持. 两者没什么区别.
**系统所有的功能都是某些进程所提供的,而进程则是通过触发程序而产生的.**

一般在服务的名称后面都会加上一个 d 来表示这是一个守护进程或者说是服务.

#### systemd  使用unit服务单位 分类
Centos 7.x之后, 放弃了 init 启动脚本的方法,改用 systemd 这个启动服务管理机制.
- systemd 所带来的好处
  - 平行处理所有服务,加速开机流程,使用多核心的方式来让所有服务启动
  - 一经要求就回应的 on-demand 启动方式. systemd 只有一个 systemd 服务搭配 `systemctl`来处理,方便管理
  - 服务依赖性的自我检查
  - 依 daemon(守护进程)功能分类,systemd定义了所有服务为一个服务单位(unit),并将unit归类到不同的服务类型中去(type)
	  - systemd 将服务单位unit 区分为  service ,socket , target, path,snapshot,timer 等.
  - 将多个 守护进程 集合为一个群组.
  - 向下兼容旧有版本的 init 服务脚本.

### systemd 配置文件放置目录

- **在系统启动阶段, 许多守护进程由系统初始化脚本启动, 拥有超级用户特权**

  - ==**系统的关键服务的脚本都放在这里`/lib/systemd/system/`**==
    - ==**如果是开机启动的话会创建软连接到`/etc/systemd/system/multi-user.target.wants/` 目录下.**==
      - ==**并且会传递参数给 `/lib/systemd/systemd-sysv-install disable 服务` 这个脚本文件格式`(systemctl 命令来做)`**==
  - ==**用户自定义的脚本应该放在 `/usr/lib/systemd/system/` 目录下**==
    - **如果想开机启动,那么就创建软连接到 `/etc/systemd/system/multi-user.target.wants/`这个目录下**

  - **`/etc/systemd/system` 目录下的内容都是 `/lib/systemd/system/` 的软连接, 开机启动**

- **`/usr/lib/systemd/system/`**  :每个服务最主要的启动脚本设置.类似于 /etc/init.d 下面的脚本.
  - 系统开机会不会执行某些服务,就是看这个目录下的设置,所以这个目录下都是链接文件.
  - 修改某个服务启动的设置,应该去`/usr/lib/systemd/system` 下面修改才对.
  - ==**系统的关键服务的脚本都放在这里`/lib/systemd/system/`**==
  - ==**用户自定义的脚本应该放在 `/usr/lib/systemd/system/` 目录下**==
- **`/run/systemd/system/`** :系统执行过程中产生的服务脚本,这个脚本的优先级要比 `/usr/lib/systemd/system/`高.
- **`/etc/systemd/system/`** :管理员依据主机系统的需要所创建的执行脚本,优先级比 `/run/systemd/system/`高.
  - **这里面的内容,都是指向 `/lib/systemd/system/` 目录下的内容**

##### systemd 的 unit服务单位 类型分类说明
看文件的拓展名即可知道属于哪种类型.(就是.service 之类的)

**常见的拓展名和主要服务功能**
|拓展名|主要服务功能|
|-|-|
|.service|一般服务类型,主要是系统服务,包括服务器本身所需要的本机服务以及网络服务|
|.socket|套接字,实现进程间通信与网络通信|
|.target|执行环境变量,就是一群unit的集合|
|.mount .automount|文件系统挂载相关的服务|
|.path|侦测特定文件或目录类型|
|.timer|循环执行的服务|

## 通过 systemctl 管理服务
```bash
$systemctl  [控制]  [unit]
控制主要有:
start   :立即启动后面的 unit 服务单位(就是脚本)
stop    :停止
restart :重启(先停止,然后启动)
reload  :不关闭后面接的 unit服务单位 重新载入配置文件,让设置生效.(类似于 kill -1 信号)
enable  :设置开机启动
disable :关闭开机启动
status  :列出 执行状态,开机启动状态,登陆等信息
is-active  :检测目前有没有在运行中
is-enable  :检测是不是开机启动
mask    :强制注销unit服务单元,让启动脚本的配置文件指向 /dev/null, 来达到无法启动服务的目的
umask   :取消强制注销,恢复脚本


范例: 查看目前 cron 这个服务的状态如何
$systemctl  status  cron.service
输出:
● cron.service - Regular background program processing daemon
 Loaded: loaded (/lib/systemd/system/cron.service; enabled; vendor preset: enabled)
 Active: active (running) since Sat 2019-11-16 14:17:02 CST; 7h ago
 Docs: man:cron(8)
 Main PID: 343 (cron)
 Tasks: 1 (limit: 4915)
 Memory: 10.5M
 CPU: 54.854s
 CGroup: /system.slice/cron.service
         └─343 /usr/sbin/cron -f
# Loaded  说明是否开机启动, enabled 启动 ,disabled 不启动,static 需要其他服务来唤醒,mask 无法启动.
# Active   现在这个 unit服务单位 的状态, 
#	      正在执行running ,没有执行 dead, 仅执行一次就正常结束exited,执行并且在等待waiting,没有运行inactive


范例: 关闭 cron 这个服务
$systemctl  stop cron.service
		#虽然这样可以关闭,但是开机还是会自动启动
```

#### 通过 systemctl 观察系统上所有的服务

```bash
$systemctl  [command] [--type=TYPE] [--all]
command :
    list-units       :依据unit服务单位 列出目前有启动的unit, 若加上 --all 才会出现没启动的.
	list-unit-files  :依据/usr/systemd/system/ 内的文件,将所有文件列表说明.
--type=TYPE  :就是unit type类型,主要有 service,socket,target 等.


范例:列出系统上面有启动的 unit服务单位
$systemctl list-units

范例:列出所有以安装的unit 有哪些
$systemctl list-unit-files

范例:列出所有 service 这种类型的守护进程,无论它是否启动
$systemctl list-units --type=service --all

范例:找到以cpu命名的服务
$systemctl --list-units --type=service --all | grep -i cpu
```
#### 通过systemctl 管理不同的操作系统模式 (target unit)
target服务项目 与操作界面有关.
```bash
$systemctl list-units --type=target  --all
输出:
UNIT                   LOAD      ACTIVE   SUB    DESCRIPTION                  
basic.target           loaded    active   active Basic System                 
bluetooth.target       loaded    active   active Bluetooth                    
...省略很多
● syslog.target          not-found inactive dead   syslog.target                
timers.target          loaded    active   active Timers                       
umount.target          loaded    inactive dead   Unmount All Filesystems      
LOAD   = Reflects whether the unit definition was properly loaded.
ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
SUB    = The low-level unit activation state, values depend on unit type.
27 loaded units listed.
To show all installed unit files use 'systemctl list-unit-files'.			
```

- graphical.target  :是文字加上图形界面,这个项目包含下面的 multi-user.target项目
- multi-user.target :纯文本模式
- rescue.target  :在无法使用root登陆的情况下,systemd 在开机时会多加一个额外的暂时系统,与原本系统无关.
- emergency.target  :紧急处理系统的错误,还是需要root登陆的情况,在无法使用rescue.target 时,可以尝试使用.
- shutdown.target  :关机流程
- getty.target  :可以设置你需要几个 tty 之类的,如果想要降低tty项目,可以修改这个东西的配置文件
正常模式是 multi-user.target 以及 graphical.target 这两个.
救援模式是 rescue.target 以及更严重的 emergency.target .

```bash
$systemctl [command] [unit.target]
选项与参数:
command :
	get-default  :取得目前的 target
	set-default  :设置后面接的 target 成为默认的操作模式
	isolate      :切换到后面接的模式

范例: 假设现在默认是 图形模式, 先观察是否真的为图形模式,在将默认模式转换为文字界面
$systemctl get-default
输出:  graphical.target     #是图形模式

$systemctl set-default multi-user.target    #转换为纯文本模式,下面表示成功
输出: Created symlink /etc/systemd/system/default.target → /lib/systemd/system/multi-user.target.

$systemctl get-default
multi-user.target         #纯文本模式


范例: 在不重启的情况下,将目前的操作环境改为纯文本模式,关闭图形界面
$systemctl  isolate  multi-user.target

范例: 重新获取 图形界面
$systemctl isolate graphical.target
```
**在 service部分用 start/stop/restart 才对,在target项目要用 isolate 才可以.**
```bash
$systemctl poweroff  #系统关机
$systemctl reboot    #重新开机
$systemctl suspend   #进入睡眠模式 :数据在内存中,关闭大部分系统硬件,等待唤醒,速度快
$systemctl hibernate #进入休眠模式 :数据在硬盘中,计算机电源关闭,接通电源唤醒,速度慢
$systemctl rescue    #强制进入救援模式
$systemctl emergency #强制进入紧急救援模式
```

#### 通过systemctl 分析各服务之间的相依性
```bash
$systemctl list-dependencies  [unit] [--reverse]
选项与参数:
--reverse  :反向追踪谁使用这个 unit 的意思

范例: 列出目前 target操作环境 下,用到什么特别的 unit服务单位
$systemctl list-dependencies       #目前是纯文本模式 multi-user.target

范例: 列出谁会用到 multi-user.target 这个服务单位呢
$systemctl  list-dependencies  --reverse
输出:
default.target
● └─graphical.target    #主要是被他使用
```

#### 与 systemd 的 daemon 运行过程相关的目录简介
- **`/usr/lib/systemd/system/`** :默认启动脚本配置文件.(尽量不要修改)
- **`/run/systemd/system/`** :系统执行过程中所产生的服务脚本,这些脚本的优先级比`/usr/systemd/system/`高
- **`/etc/systemd/system/`** :管理员依据主机系统的需要所创建的执行脚本,优先级比`/run/systemd/system/`高
- **`/etc/sysconfig/*`** :几乎所有的服务都会将初始化的一些选项设置写入到这个目录下.
- **`/var/lib/`** :一些会产生数据的服务都会将他的数据写入到这里的文件夹内.
- **`/run/`** :放置了很多daemon守护进程 的暂存盘, 包括lock file 以及 PID file等。

```bash
$systemctl  list-sockets     #socket服务产生的 socket file 
LISTEN                          UNIT                            ACTIVATES
/run/systemd/fsck.progress      systemd-fsckd.socket            systemd-fsckd.service
...中间省略
kobject-uevent 1                systemd-udevd-kernel.socket     systemd-udevd.service

12 sockets listed.
Pass --all to see loaded but inactive sockets, too.
```

##### 网络服务与端口对应
**`/etc/services`** 这个文件可以让 网络服务和端口号 对应在一起.
```bash
$cat /etc/services
```

#### 关闭网络服务
会产生网络监听端口的进程 就是网络服务.
```bash
$netstat  -tlunp   #寻找出目前开启了那些端口
输出:
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:4200            0.0.0.0:*               LISTEN      1138/shellinaboxd   
tcp        0      0 192.168.1.1:5353        0.0.0.0:*               LISTEN      972/dnsmasq         
tcp        0      0 0.0.0.0:139             0.0.0.0:*               LISTEN      1177/smbd           
tcp        0      0 0.0.0.0:53              0.0.0.0:*               LISTEN      606/dnsmasq         
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      642/sshd            
tcp        0      0 0.0.0.0:445             0.0.0.0:*               LISTEN      1177/smbd           
tcp6       0      0 :::139                  :::*                    LISTEN      1177/smbd           
tcp6       0      0 :::53                   :::*                    LISTEN      606/dnsmasq         
tcp6       0      0 :::22                   :::*                    LISTEN      642/sshd            
tcp6       0      0 :::445                  :::*                    LISTEN      1177/smbd           
udp        0      0 0.0.0.0:53              0.0.0.0:*                           606/dnsmasq         
udp        0      0 0.0.0.0:67              0.0.0.0:*                           972/dnsmasq         
udp        0      0 0.0.0.0:68              0.0.0.0:*                           762/dhclient        
udp        0      0 0.0.0.0:68              0.0.0.0:*                           430/dhcpcd
#上面至少有 4200,5353,139,53,22,445,67,68 端口是开启的,其中有一部分在进行监听,等到被连接


#干掉5353 这个端口的网络服务

#首先找出 5353 端口对应的服务
$systemctl list-units --all | grep dnsmasq
输出:
dnsmasq.service    loaded active running    dnsmasq - A lightweight DHCP and caching DNS server
    #正在运行中,只有这一个服务
#关闭它
$systemctl  stop dnsmasq.service
$systemctl  disable  dnsmasq.service
#完成
```


## systemctl 针对 service 类型的配置文件
### systemctl 配置文件相关目录
systemd 的配置文件大部分放置于 **`/usr/lib/systemd/system/`** 目录内,但是不应该修改这里.应该修改 **`/etc/systemd/system/`** 目录内的配置文件.
- **`/usr/lib/systemd/system/vsftpd.service`**  :官方释出的默认配置文件.
- **`/etc/systemd/system/new.d/new.conf`** : 这样来创建配置文件和同名的配置文件目录,目录需要有.d标识
- **`/etc/systemd/system/new.service.wants/`** :此目录内的文件为链接文件,设置相依服务的链接,也就是启动了new.service 之后,目录里面的服务也会启动.
- **`/etc/systemd/system/new.service.requires/`**  :此目录内的文件为链接文件,设置相依服务的链接,在启动 new.service 之前,里面的服务要率先启动.
- **`/lib/systemd/system/`**   :如果上面与系统有出入,那么系统的配置文件都应该在这个目录里.
### systemctl 配置文件的设置项目简介

```bash
cat  /usr/lib/systemd/system/ssh.service
输出:
[Unit]       #unit本身说明,其他相依daemon守护进程的设置,包括在什么服务之后才启动此unit之类的设置值
Description=OpenSSH  server daemon        #使用systemctl list-units 时,输出的简易说明
Documentation=man:ssh(8)                  #提供进一步文件查询的功能,可以是网页或文件.
After=network.target sshd-keygen.service  #此unit 在哪些守护进程 启动之后,才可以启动的意思
Before= 								  #在哪些守护进程启动之前,先启动这个unit
Requires=								  #必须在某些服务启动之后才能启动该unit
Wants=sshd-keygen.service                 #在某些服务启动前,必须要先启动这个 unit
Conficts=								  #冲突的服务,当某些服务运行时,这个unit就不允许启动.

[Service]     #这个项目与实际执行的指令参数有关,启动的脚本,范围配置文件的文件名,重新启动方式等等.
EnvironmentFile=/etc/sysconfig/sshd		 #启动脚本的环境配置文件,也可以直接写多个不同的 shell变量来给予
ExecStart=/usr/sbin/sshd -D $OPTIONS     #实际执行此守护进程的指令或脚本.(重要)
ExecStop=/usr/sbin/sshd -T $STOPONS      #与 systemctl stop 的执行有关,会关闭当前服务,一般也是脚本
ExecReload=/bin/kill -HUP $MAINPID       #与 systemctl reload 有关的指令,不关闭,但重新读取配置文件
KillMode=process            #只会终止进程
Restart=on-failure          #如果设置该值=1时,当结束掉当前守护进程后,会自动重启
RestartSec=42s              #该unit重启的时间间隔

[Install]     #这个项目说明此 unit要挂在到哪个 target下面 ,也就是在哪种操作界面可以使用.
WantedBy=multi-user.target      #unit本身是附挂在 multi-user.target 纯文本界面下面的
alias=sshd.service    #别名
```

## 默认启动的服务建议说明
|服务名称|说明|
|-|-|
|alsa-X|开头为alsa的服务有很多,大部分都与音效有关.一般来说可关闭|
|cpupower|提供CPU的运行规范|
|cups|管理打印机,可关闭|
|dm-event multipathd|监控设备对应表的主要服务,可以让Linux使用周边设备与存储设备|
|dmraid-activation mdmonitor|用了启动 软件RAID 的重要服务|
|ebtables|网络防火墙规则设置,在firewalld 启动后,这个就无法启动了,也不应该启动|
|emergency rescue| 进入紧急模式或者是救援模式的服务|
|firewalld|防火墙|
|irqbalance|自动分配系统中断之类的硬件资源,尤其是多核心处理器|
|iscsi*|挂载网络磁盘的服务,SAM网络磁盘的挂载需要他|
|smartd|自动侦测硬盘状态,如果硬盘发生问题,会自动回报给系统管理员|
|systemd-*|是系统运行过程所需要的服务|



## 小结
- 早期的服务管理使用 systemV 的机制,通过 /etc/init.d/* , service ,chkconfig ,setup 等指令来管理服务的启动/关闭/开机启动 等
- 目前采用 systemd 的机制来管理服务。
- systemd 将各服务定义为 unit服务单位 ,则 unit 又分类为 service,socket,target,path,timer 等
  - 设置 启动/关闭/重启 的方式 : systemctl start/stop/restart  unit.service
  - 设置 开机启动/开机不启动 的方式: systemctl enable/disable  unit.service
- 查询系统所有启动的服务用 **`systemctl list-units --type=service`** 
- 查询系统所有的服务(包括启动和没有启动)用 **`systenctl list-unit-files --type=service`**
- 常见操作环境为 multi-user.target(纯文本) 与 graphical.target(图形界面)
  - 不重新开机而转不同的操作系统使用 **`systemctl isolate [multi-user.target|graphical.target]`**
  - 设置默认操作环境使用 **`systemctl set-default unit.target`**
  - 显示当前默认的操作环境 **`systemctl get-default`**
- systenctl 系统默认的配置文件主要在 /usr/lib/systemd/system ,若要修改,建议放在 /etc/systemd/system/下
