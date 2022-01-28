# 程序管理与 **SELinux** 初探

### 进程  与  程序 (**process & program**) 

- **程序** 存放在磁盘中的二进制可执行文件
- **进程** 在内存中执行,并且拥有PID
- PID   唯一进程标识符
  - 使用 **`ps -l `** 指令,  通过输出的 PPID 可以判断 当前进程的父进程是哪一个.
- 只要是常驻内存的进程,都可以称为是**服务**
  - 服务 的名称一般都是以 d 结尾.便于分辨.
- Linux 下面执行一个指令时，系统会将相关的权限、属性、程序码 与数据等均载入内存， 并给予这个单元一个程序识别码 (PID) 
  - 最终该指令可以进行的任 务则与这个 PID 的权限有关 

### 工作管理 (**job control**) 

**当我们登陆系统取得 bash shell 之后，在单一终端机接口下 `同时进行多个工作的行为`管理**

**进行工作管理的行为中， 其实每个工作都是目前 bash 的子程序，亦即彼此之间是有相关性的。 我们无法以 job control 的方式由 tty1 的环境 去管理 tty2 的 bash**

-  bash 的 job control 必须要注意到的限制 
  - 这些工作所触发的程序必须来自于你 shell 的子程序(只管理自己的 bash); 
  - 前景:  你可以控制与下达指令的这个环境称为前景的工作 (foreground); 
  - 背景:  可以自行运行的工作，你无法使用 [ctrl]+c 终止他，可使用 bg/fg 调用该工作; 
    - 背景里面 的工作状态又可以分为“暂停 (stop)”与“运行中 (running)” 
    - 在不需要交互的指令 最后面加上 ` &`  符号,就可以直接划分入bash背景作业了.
      - 但是当你离线之后, 这个背景作业就会被终止!!
      - 如果背景进程有输出, 那么应该使用 `数据流重定向`  放入某个文件中. (/dev/shm 文件在内存中存储)
    - 当进程在前景执行时, 可以使用组合键 **`[ctrl + z]`**  暂停当前进程,并放入背景.(`fg`回到前台,`bg`放到后台)
  - 背景中“执行”的程序不能等待 terminal/shell 的输入(input) 

```bash
$jobs     [-lrs]
选项与参数:
 -l  :除了列出 job number 与指令串之外，同时列出 PID 的号码;
 -r  :仅列出正在背景 run 的工作;
 -s  :仅列出正在背景当中暂停 (stop) 的工作。
 
 $jobs -l
[1]   已停止               vim a    #无 + - 号的表示很早就已经到背景的进程
[2]-  已停止               vim b    # - 号表示倒数第二个进来的背景进程
[3]+  已停止               vim c    # + 号表示最近加入进来的背景进程
         # fg 或者 bg 指令会从最后一个开始向前恢复 (+)
```

```bash
$fg  %工作号码   #从后台的暂停状态恢复到前台, 工作号码就是jobs所列出来的号码, %1 %2 %3 + - 之类的.(也可以不加), 这个时候 jobs的 + - 号会顺延, 倒是号码不会变化.
$bg  %工作号码   #让背景中暂停状态的进程变为"运行中", 标识符 stopped(暂停) 会变成 running(运行), 并且指令后面会出现 '&' 符号.
```

```bash
$kill   -signal  %jobnumber 
$kill  -l
$kill -9   PID
选项与参数:
 -l  :这个是 L 的小写，列出目前 kill 能够使用的信号 (signal) 列表
signal  :发送给后面的进程什么信号 , 用 kill -l 可知:
      -1  :重新读取一次参数的配置文件 (类似 reload);
      -2  :代表与由键盘输入 [ctrl]-c 同样的动作;
      -9  :立刻强制删除一个工作;
      -15 :以正常的程序方式终止一项工作。与 -9 是不一样的。

范例一:找出目前的 bash 环境下的背景工作，并将该工作“强制删除”。
$jobs -l
[1]-  2161 停止                  vim a
[3]+  2163 停止                  vim c
$kill -9  %3 ; jobs
[1]+  已停止               vim a

```

### 离线管理  (系统后台)

```bash
$nohup [指令与参数]      #在终端机前景中工作 
$nohup [指令与参数] &    #在终端机背景中工作
$patree                 #可以查询到, nohup 设定的离线工作

上面两个,当你离线后,进程还会继续进行,不会因为你的离线 而导致程序出现终止等情况. (不支持bash内置指令)
```



## 进程管理 

#### ps :将某个时间点的程序运行情况摘取下来  ( 静态)

```bash
$ps  aux    #能够观察系统所有的进程数据
$ps  -lA    #也能够观察系统的数据
$ps  axjf   #连同部分进程树状态

选项与参数:
-A   :所有的 process(进程) 均显示出来, 与 -e 具有相同的效果.
-a   :不与 terminal(终端) 有关的所有 进程.
-u   :有效使用者(effective user) 相关的 进程.
x    :通常与 a 这个参数一起使用, 可列出较完整的信息
输出格式规则:
		l   :较长, 较详细的将该 PID 的信息列出.
		j   :工作的格式 (jobs format)
		-f  :做一个较为完整的输出.

常用的:   只查询自己 bash 进程的 $ps  -l
		     查询所有系统运行的进程  $ps aux

范例:  就将目前属于这次登录的 PID 与相关信息显示出来 (只与自己的 bash 有关的)
$ps -l
F S   UID   PID  PPID  C PRI  NI   ADDR     SZ   WCHAN   TTY          TIME  CMD
4 S     0  2673  2667  0  80   0   -     29122   do_wai  pts/0    00:00:00  bash
0 R     0  3013  2673  0  80   0   -     38312   -       pts/0    00:00:00  ps
#第一个: 进程标志是4, 该程序正在等待,root执行的,该进程PID是2673,父进程PID是2667,CPU使用率是0,流程优先级是80(很低),调度优先级是0,正在运行不知道内存位置,占用 29122 字节内存,该程序正在等待,下达命令的终端接口为pts/0,占用CPU时间是0秒,执行的命令是 bash


解释:
F  :代表这个进程标志 (process flags)，说明这个进程的执行权限，常见号码有:
		若为 4 表示此程序的权限为 root ;
		若为 1 则表示此子程序仅进行复制(fork)而没有实际执行(exec)。
S  :代表这个程序的状态 (STAT) ,主要状态有
		R (running)该程序正在运行中
		S (sleep)  该程序目前正在睡眠(idle), 但可以被唤醒(signal)
		D          不可被唤醒的睡眠状态, 通过这个进程可能在等待 I/O 情况 (ex>打印 之类的)
		T          停止状态(stop) ,可能是工作控制(后台暂停) 或排错(traced) 状态.
		Z (Zombie) 僵尸状态, 进程已经终止  但却无法释放内存.
UID  :执行该进程用户的UID
PID  :进程的 唯一标识符
PPID :此进程的父进程PID 号码
C    :代表 CPU使用率
PRI  :优先执行顺序。数字越大意味着优先级越低。
NI   :调度优先级,数值越小 优先级越高, -20最高, 19最低
ADDR :内核功能,和内存有关,指出该进程在内存的那个部分. 如果是运行中的进程,那么会显示 - 
SZ   :占用多少内存,单位字节
WCHAN:表示目前程序是否运行中, 如果正在运行 那么显示 - 
TTY  :登录者的终端机位置, 若为远程登录 则使用动态终端接口 (pts/n)
TIIME:使用掉的CPU时间, 实际花费的CPU运行时间,并不是系统时间
CMD  :触发该进程的指令,也就是该进程所运行的指令.如果后面有个 <defunct> 的时候,代表这是个僵尸进程




范例: 观察系统的所有程序
$ps aux
输出:
USER PID %CPU %MEM    VSZ  RSS TTY STAT  START  TIME  COMMAND
root  1   0.0  0.5 128252 6948  ?    Ss  10:53  0:02  /usr/lib/systemd/systemd --s
root  2   0.0  0.0      0    0  ?    S   10:53  0:00  [kthreadd
...省略...
解释:
USER  :该 进程 属于那个使用者帐号
PID   :该 进程 的程序识别码。
%CPU  :该 进程 使用掉的 CPU 资源百分比;
%MEM  :该 进程 所占用的实体内存百分比;
VSZ   :该 进程 使用掉的虚拟内存量 (KBytes)
RSS   :该 进程 占用的固定的内存量 (KBytes)
TTY   :该 进程 是在那个终端机上面运行，若与终端机无关则显示 ?，
			 另外， tty1-tty6 是本机上面的登陆者程序，若为 pts/0 等等的，则表示为由网络连接进主机的程序。 
STAT  :该程序目前的状态，状态显示与 ps -l 的 S 旗标相同 (R/S/T/Z)
START :该 进程 被触发启动的时间;
TIME  :该 进程 实际使用 CPU 运行的时间。 
COMMAND   :该程序的实际指令为何, 如果后面有个 <defunct> 的时候,代表这是个僵尸进程
```



#### top:动态观察程序的变化

```bash
$top  [-d 数字] 
$top  [-bnp]
选项与参数:
-d  :后面可以接秒数，就是整个程序画面更新的秒数。默认是 5 秒;
-b  :以批次的方式执行 top ,通常会搭配数据流重导向来将批次的结果输出成为文件。
-n  :与 -b 搭配，意义是，需要进行几次 top 的输出结果。
-p  :指定某些个 PID 来进行观察监测而已。
在 top 执行过程当中可以使用的按键指令:
		? :显示在 top 当中可以输入的按键指令;
		P :以 CPU 的使用资源排序显示;
		M :以 Memory 的使用资源排序显示;
		N :以 PID 来排序
		T :由该 进程 使用的 CPU 时间累积 (TIME+) 排序。
		k :给予某个 PID 一个信号 (signal)
		r :给予某个 PID 重新制订一个 NI值 (越小 执行的越早)。
		q :离开 top 软件的按键。



$top -d 1  #每一秒就刷新一次
输出:
top - 13:07:55 up  2:14,  1 user,  load average: 0.00, 0.01, 0.05
Tasks: 184 total,   1 running, 183 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni,100.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem :  1163428 total,   435872 free,   397396 used,   330160 buff/cache
KiB Swap:  1048572 total,  1048572 free,        0 used.   609408 avail Mem

解释:
第一行: 当前时间13:07:55 ,开机到目前为止经过的时间2:14 ,1一个用户在线, 系统在1 5 15分钟的平均负载.
第二行: 目前进程的总量184个 , 1个进程在运行, 183个进程在睡眠, 0个进程已暂停, 0个僵尸和孤儿进程.
第三行: 用户占用CPU总负载的 0.0% ,系统占用0.0%, 调度优先级 0 ,CPU空闲100%, I/O等待0.0
第四行: 内存总共1163428字节, 可用内存435827字节,已用397396字节，内存高速缓冲区总共330160字节.
第五行: 虚拟内存交换空间总共1048572字节,可用1048572字节,已用0字节,使用虚拟内存缓冲区609408字节.
第六行: 是在top 当中输入指令时显示的部分.



范例: 我们自己的 bash PID 可由 $$ 变量取得, 使用 top 持续观察该PID
$echo $$          #这里假设输出了 10909 这个PID值
top -d 2 -p 10909 # -p 后面跟的是 PID
```

#### pstree 程序相关性
```bash
$pstree [-A|U]  [-up]
选项与参数:
-A   :各进程之间的连接以 ASCII 字符来连接
-U   :各进程之间的连以万国码(unicode)来连接,在某些终端接口下可能会有错误.
-p   :并同时列出每个 进程的 PID
-u   :并同时列出每个 进程的 所属账号名称
```


### 进程管理
**进程之间通过信号进行互相管理**
|号码|名称|属性|
| --- | --- | --- | 
|1|SIGHUP|启动被终止的进程，可让该PID重新读取自己的配置文件,类似重新启动|
|2|SIGINT|相当于用键盘输入 [ctrl+c] 来终止一个进程的进行|
|9|SIGKILL|强制中断一个进程|
|15|SIGTERM|以正常的结束进程来终止该进程|
|19|SIGSTOP|暂停一个进程的执行,相当于[ctrl+z]|
```bash
$kill  -信号号码  PID
$kill  -信号号码  @N
对后面PID程序或bash后台进程发送一个信号.

范例: 让 rsyslogd 这个服务进程 重新读取自己的配置文件.
$kill -1 $(ps aux | grep 'resyslogd' | grep -v 'grep' | awk '{print $2}')

$tali -5 /var/log/messages      #参看登陆文件的内容,来确认是否重启的成功.如果有下面这个一行就代表成功了
Nov 15 21:24:37 raspbian liblogging-stdlog:  [origin software="rsyslogd" swVersion="8.24.0" x-pid="360" x-info="http://www.rsyslog.com"] rsyslogd was HUPed
```

```bash
$killall  -信号  [-iIe] [进程名]     #不给信号参数的话，默认是 -9
选项与参数:
-i  :互动式提示模式
-e  :表示后面要接的是进程名, 但是进程名不可以超过15个字符.
-I  :后面的进程名称(可以含参数) 忽略大小写.

注意:命令会终止所有和进程名称相同的进程.


范例: 强制终止所有 httpd 启动程序
$killall -9   httpd 
```

### 进程的执行顺序(优先级)
如果很多的休眠(sleeping)进程被同时唤醒,那么操作系统会考虑 **进程的优先执行序(Priority)** 与 **CPU调度**.

#### Priority 与 Nice 值
CPU一秒钟的指令执行次数的计算方式 : **`(CPU时钟频率*核心线程数)/6`**,(这个6是一条指令会分成6步被CPU执行,包括:取指,译码,执行,访存,写回,PC值更新)
**Linux 会给予进程一个 `执行优先级(priority,PRI)`,这个PRI值越低代表优先级越高.这个PRI是核心动态调整的,使用者无法直接调整PRI值的.**
**PRI 的默认值一般是80**
可以通过 **`ps -l`** 指令来得到每个进程的PRI与NI(Nice) 这两个值.
**可以通过调整 NI(nice) 的值来达到修改进程执行优先级的目的,这个值越低越好**
- 新PRI = PRI(旧) + Nice
  - Nice的值可以影响PRI值,但是最终的PRI还是要经过系统操作系才会决定
  - Nice值的范围是 -20 到 19 ,使用 **`renice`指令**
    - 但是一般用户只可以调整 0到19 ,只有root 才可以调整 -20到19
	- 一般用户只可以让Nice的值变大,却不可以减少Nice的值.
  **还可以通过在执行进程前就设定好 Nice 的值**

#### nice  将即将要执行的命令给予设定的 Nice 值
```bash
$nice [-n 数字]  命令    
选项与参数:
-n   :后面接一个Nice值,范围是 -20到19

范例: 用 root 创建一个 Nice值为 -19的 vim 进程,并且扔到 bash 后台.
$nice -n -19 vim &
$ps -l
输出:
 S   UID   PID  PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
 4 T     0 24489 20696  0  61 -19 -  2877 signal pts/0    00:00:00 vim
#NI 值变化了,PRI也跟着变化了, 因为是使用root执行的,所以才会给这种权限
```
#### renice  将已存在的进程 Nice值  进行重新调整 (top 也可以调整)
```bash
$renice  [数字]  进程的PID   

范例: 找出自己的 bash 的 PID ,并将该 PID 的 nice 调整到 -5
$renice -5 $(ps |grep 'bash' |awk '{print $1}' )
输出:
20696 (process ID) old priority 0, new priority -5
renice: failed to get priority for 27719 (process ID): No such processa
#修改成功
```

### 系统资源的观察

##### 内存查看 free
```bash
$free  [-h] [-t]  [-s N -c N]
选项与参数:
-h  :系统自动指定显示出来的容量单位,可以自己指定(-g -m -b -k)
-t  :显示实体内存与 swap(交换分区) 的总量
-s  :可以让系统每几秒钟输出一次,不间断的意思.
-c  :与-s 一起使用,让 free列出多少次(相当于循环次数)

范例:显示系统内存和swap 使用信息
$free -t -m
			  total        used        free      shared  buff/cache   available
Mem:            955         102         659          16         193         777
Swap:          1023           0        1023
Total:         1979         102        1683

#total 是总容量,used是已用容量,free可用容量,
#shard/buff/cache已用容量中被用作高速缓存的容量,当系统繁忙时,这些空间可被释放,另作他用
#available释放高速缓存之后的总体可用容量.
#swap 是虚拟内存交换分区,这块容量是在硬盘上的,性能最差,尽量不要使用,否则增加内存条.
```

##### 查阅系统与核心的信息  uname
```bash
$uname [-asrmpi]
选项与参数:
-a  :所有系统相关的信息全部列出,包括下面所有选项的信息
-s  :系统核心名称,(一般都是 Linux)
-r  :核心版本 (就是 Linux 核心版本)
-m  :本系统的硬件名称 (i686 ,x86_64, aarch64 )
-p  :CPU 的类型, (x86_64, x86 ,arm )
-i  :硬件平台(ix86)
```

##### 追踪网络或套接字 netstat

```bash
$netstat    -[atunlp]
选项与参数
-a   :列出目前系统上所有的连接,监听(listen),套接字(socket) 数据.
-t   :列出tcp网络封包数据
-u   :列出udp网络封包数据
-n   :以 port 端口号 来显示
-l   :列出目前正在 监听(listen) 的服务
-p   :列出该网络服务的进程PID



范例: 列出目前系统已经创建的网络连接与 unix socket 状态
$netstat 
输出:
Active Internet connections (w/o servers)   #与网络相关的部分
Proto Recv-Q Send-Q Local Address           Foreign Address         State      
tcp        0      0 bogon:ssh               bogon:43231             ESTABLISHED
tcp        0    176 bogon:ssh               bogon:53925             ESTABLISHED
Active UNIX domain sockets (w/o servers)	#本地套接字文件的信息(非网络,用于本地进程间的通信)
Proto RefCnt Flags       Type       State         I-Node   Path
unix  2      [ ]         DGRAM                    746511   /run/user/1000/systemd/notify
unix  3      [ ]         DGRAM                    235      /run/systemd/notify
unix  2      [ ]         DGRAM                    236      /run/systemd/cgroups-agent


范例: 找出目前系统上已在监听的网络连接及其PID
$netstat -tulnp
Active Internet connections (only servers)
	Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
	tcp        0      0 0.0.0.0:53              0.0.0.0:*               LISTEN      686/dnsmasq         
	tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      734/sshd            
	tcp        0      0 0.0.0.0:445             0.0.0.0:*               LISTEN      1202/smbd      
```
netstat 字段说明
- Internet connections 网络连接部分
  - Proto :网络封包协议, 主要是TCP 和 UDP 
  - Recv-Q:建立socket连接的发送者,连接到远程主机 共复制的 字节数
  - send-Q:远程主机未确认到的字节数.
  - Local Address :远程服务器的本地IP和端口(被连接者),bogon表示DNS解析失败,可以通过 who 来获得IP,ssh表示端口22
  - Foreign Address :远程客户端连接的IP和端口(连接者).
  - state :连接状态,连接中(ESTABLISED) ,监听(LISTEN)
- UNIX domain socket  本地套接字的文件信息
  - Proto   :一般是unix
  - RefCnt  :连接到此 socket 的进程数量
  - Flags   :连接标志, 连接成功会显示 [*] ,否则是空 [ ]
  - Type    :socket套接字存储的类型, 主要需要确认连接的 STREAM(流式)与不需要确认的DGRAM(报文)两种
  - State   :状态,若为 CONNECTED 表示多个进程间已经创建了连接.
  - Path    :连接到此 socket 的相关程序的路径,或者是相关数据输出的路径.

##### 分析核心产生的信息 dmesg 
显示的系统在开机时产生的硬件侦测信息,以及所有的核心侦测信息 和系统运行过程中核心产生的信息都会记录到 **`内存中的某个保护区段`**  `dmesg` 命令可以将这些讯息读取出来.

```bash
输出所有的核心开机时的信息
$dmesg  | more     #因为读取出来的信息量太大,所以要使用 more来分页

搜寻开机的时候,硬盘的相关信息
$dmesg | grep -i sda
[    1.315625] mmcblk0: mmc0:aaaa SL32G 29.7 GiB
[    1.317360] sda : sda1 sad2 
[    1.332955] EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
[    3.071890] EXT4-fs (sda2): re-mounted. Opts: (null)
```

##### 侦测系统资源变化  vmstat
vmstat 可以侦测 CPU,内存,磁盘,输入输出状态 等等.
```bash
$vmstat [-a] [延迟 [总侦测次数]]      #CPU/内存等信息
$vmstat [-fs]        #只显示内存相关
$vmstat [-S 单位]    #设置显示数据的单位
$vmstat [-d]         #显示磁盘有关信息
$vmstat [-p 分区]    #也是与磁盘有关
选项与参数:
-a  :使用 inactive/active(活跃/不活跃) , 取代 buffer/cache 的内存输出信息
-f  :开机到目前为止,系统创建的进程数(fork)
-s  :将一些事件(开机至目前为止) 导致内存变化情况列表说明
-S  :后面接单位,当现实的数据有单位, 例如 K/M/G
-d  :列出磁盘的读写总量统计
-p  :后面列出分区,可显示该分区的读写总量统计表


范例: 统计目前主机 CPU 状态， 每秒一次，共计3次, 显示容量单位是 M
$vmstat 1 3 -S M
输出:
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
2  0      0    141     51    663    0    0     1     4    7   99  0  1 99  0  0
0  0      0    141     51    663    0    0     0    56 8195  439  0  0 99  0  0
0  0      0    141     51    663    0    0     0     8 8419  584  1  1 99  0  0

# procs 进程字段: r 等待运行中的进程数量,b 不可被唤醒进程数量,越多系统越忙
# memory内存字段: swpd 虚拟内存被使用容量，free 未被使用的内存容量,buff用于缓冲内存
#                 cache 用于高速缓存内存.
# swap 内存交换分区: si 由磁盘中将进程取出的量,so 由于内存不足而将没用到的进程写入到磁盘的swap容量
#                     如果si/so 的数值过大,表示内存的数据需要在磁盘与内存之间传来传去,性能差
#io 磁盘读写 : bi 如磁盘写入的区块数量, bo 写入到磁盘去的区块数量, 如果这个值过高 表示系统I/O很忙碌
#system 系统: in 每秒被中断的进程次数, cs 每秒钟进行的事件切换次数, 数值越大 表示系统与周边设备的沟通
#             非常频繁,周围设备包括 磁盘,网卡,时钟.
#cpu  : us 非核心层的CPU使用状态, sy 核心层所使用的CPU状态, id 闲置的状态, wa 等待 I/O 所耗费的CPU状态,
#       st 被虚拟机(virtual machine)所盗用的CPU使用状态.


范例: 系统上面所有的磁盘的读写状态
$vmstat  -d
输出:
disk- ------------reads------------ ------------writes----------- -----IO------
       total merged sectors      ms  total merged sectors      ms    cur    sec
ram0       0      0       0       0      0      0       0       0      0      0
ram1       0      0       0       0      0      0       0       0      0      0
loop0      0      0       0       0      0      0       0       0      0      0
loop1      0      0       0       0      0      0       0       0      0      0
sda       4884   3300  369621   63575 119158  77519 2479817 17374813   0     1593
```


## 特殊文件与进程
### 具有SUID/SGID 权限的指令执行状态
**SUID 的权限其实与进程的相关性非常大.**
- SUID 权限仅对二进制程序(binary program) 有效
- 执行者对于该程序需要具有 x 的可执行权限
- 本权限仅在执行该程序的过程中有效 (run time)
- 执行者将具有该程序拥有者(owner) 的权限
**SUID的权限生效是由`具有该权限的程序被触发` 从而变成进程的那个时候**

### /proc/*  目录代表的意义
**因为进程是在内存中,而内存当中的数据又都是写入到 /proc/* 目录下的,所以可以直接观察/proc这个目录中的文件**
**基本上主机上面的各个进程的PID都是以目录的形态存在于/proc 当中的,也有是用进程名命名的**
开机所执行的第一支进程`systemd` 它的PID是1,这个PID的所有相关信息都写在 /proc/1/* 当中

```bash
$ls -lh /proc
输出:
dr-xr-xr-x   8 root        root         0 Jan  1  1970 1
dr-xr-xr-x   8 root        root         0 Nov 16 14:17 10
...中间省略


观察PID为1 的 systemd 这个进程的相关信息 
$ls /proc/1
-rw-r--r-- 1 root root 0 Nov 16 15:19 autogroup
-r--r--r-- 1 root root 0 Nov 16 14:17 cmdline    #这个进程被启动的字符串
-r-------- 1 root root 0 Nov 16 14:17 environ    #这个进程的环境变量内容
...省略

$cat /proc/1/cmdline
输出:
/sbin/init

```
|文件名|文件内容|
|-|-|
|/proc/cmdline|载入内核时所下达的相关指令与参数,可了解指令是如何启动的|
|/proc/cpuinfo|本机CPU信息,包括频率,类型与运算功能等|
|/proc/devices|这个文件记录了系统各个主要设备的主要设备代号,与mknod有关|
|/proc/filesystems|目前系统已载入的文件系统|
|/proc/interrupts|目前系统上面的 IRQ分配状态|
|/proc/ioports|目前系统上面各个设备所配置的I/O位址|
|/proc/kcore|这个就是内存大小,不要读|
|/proc/loadevg|1,5,15分钟的平均负载记录|
|/proc/modules|目前Linux已载入的模块列表,就是驱动列表|
|/proc/swaps|记录了各个分区的挂载点|
|/proc/partitions|使用 fddisk -l 会出现目前所有的分区信息 都会在这里记录|
|/proc/uptime|时间信息|
|/proc/version|核心版本,就是uname -a 显示的内容|
|/proc/bus/*|一些总线设备,还有usb 的设备记录|


#### 查询已打开文件或已执行进程打开的文件
##### fuser  借由文件系统找出正在使用该文件的进程
可以解决 卸载分区时出现的 `device is busy`总线忙 的问题,可以找到正在被使用的文件

```bash
$fuser  [-umv] [-k [i] [-signal]] file/dir
选项和参数
-u  :除了进程的PID之外，同时列出该进程的拥有者
-m  :后面接的那个文件名会主动的上提到该文件系统的最顶层,对 umount 执行不成功 很有效
-v  :列出每个文件与进程还有指令的完整相关性
-k  :找出该 文件/目录 的PID , 并试图以 SIGKILL 这个讯号给予 PID
-i  :必须与 -k 配合使用, 在删除PID之前会先询问使用者的意思.也就是交互
-signal :信号 -1 -5 之类的,默认是 -9  kill

范例:找出目前所在目录的使用 PID/使用账号/权限 为何
$fuser -uk .
          USER        PID  ACCESS   COMMAND
/home:    pi        25516  ..c..    (pi)bash
#说明是 有25516这个PID进程,该进程属于pi的,且指令为bash 
#ACCESS 项目代表的意义为:
#	   c: 此程序在当前目录下 (非次目录)
#	   e:可被触发为执行状态
#	   f:是一个被打开的文件   (重要)
#      r:代表顶层目录
#      F:该文件被打开了,不过在等待回应中 (重要)
#	   m:可能为分享的动态函数库


范例: 找到所有使用到 /proc 这个文件系统的进程
$fuser  -uv /proc
/proc: 	   root     kernel   mount  (root)/proc
		   rtkit      768   .rc..   (rtkit)rtkit-daemon
	#进程数量很少,表示不是很繁忙

$fuser  -mvu  /proc
#这里会显示出很多进程, 省略了, 其实这些进程都在对 /proc 这个文件系统进程存取


范例:找出所有使用到 /home 这个文件系统的进程
$fuser  -muv /home
	#当这条指令有输出结果的时候,就代表无法使用 umount 来卸载 /home 文件系统
```

##### 列出被进程所打开的文件 文件名  lsof
```bash
$lsof  [-aUu] [+d]
选项与参数
-a  :多项数据需要 "同时成立" 才显示出结果时.
-U  :仅列出 Unix like 系统的 socket套接字 文件类型
-u  :后接username ,列出该使用者相关程序所打开的文件
+d  :后面接目录, 亦找出某个目录下面已经被打开的文件

范例: 列出目前系统上面所有已经被打开的文件与设备
$lsof       #数据太多了 , 不展示了


范例:仅列出关于 root 的所有程序打开的 socket 文件
$lsof  -u root -a -U
COMMAND     PID USER   FD   TYPE             DEVICE SIZE/OFF   NODE NAME
systemd       1 root   13u  unix 0xffffffccbb0a0000      0t0   9223 /run/systemd/notify type=DGRAM
systemd       1 root   14u  unix 0xffffffccbb0a0480      0t0   9224 /run/systemd/cgroups-agent type=DGRAM
systemd       1 root   15u  unix 0xffffffccbb0a0900      0t0   9225 type=DGRAM


范例: 列出目前系统上面所有的被启动的周边设备
$lsof +d /dev 


范例:找出属于 root 的bash 这个进程所打开的文件
$lsof -u root | grep 'bash'
```


#####找出某个正在执行的进程的PID  pidof
```bash
$pidof [-sx]  程序名      #注意,是程序名  不是进程
选项与参数:
-s   :仅列出一个 PID 而不列出所有PID
-x   :同时列出该 程序名 可能的 PPID 的那个进程的PID

范例: 找出目前系统上面 systemd 以及 rsyslogd 者两个进程的 PID
$pidof  systemd  rsyslogd
输出:
1  253
```


## SELinux 初探
SELinux 就是 安全强化Linux , 是整合到核心的一个模块.
SELinux 是在对进程,文件等细部权限设置依据的一个核心模块.
SELinux 是通过MAC的方式来管控程序的, 它控制的主体是 程序,而目标则是该进程能否读取'文件资源'.
**SELinux 重点在保护进程读取文件系统的权限**
- SELinux 运行模式
  - 主体(Subject) :SELinux主要想管理的就是进程.
  - 目标(Object)  :主体进程能够存取的'目标资源'一般都是文件系统,目标项目和文件系统划等号
  - 政策(Policy)  :依据服务来定制基本的存取安全性政策.
    - targeted  针对网络服务限制较多,针对本机限制较少,这是默认政策
	- minimum   有target修订而来, 针对选择的进程来保护
	- mls       完整的SELinux 限制,限制方面很严格.
  - 安全性文本 (security context) :主体与目标的安全性文本必须一致才能够顺利存取.
    - 安全性文本是存放在 inode 内的.

```bash
SELinux 根据启动与否共有三种模式:
	enforcing : 强制模式.表示SELinux运行中,并已经正确的开始限制 domain/type 了.
	permissive :宽容模式,SELinux运行中只会有警告信息,并不会世纪限制
	disabled   :关闭, SELinux 并没有运行
```



## 小结
- 程序(program) 通常为 binary program(二进制程序), 放置在存储媒体中.为实体文件的型态存在
- 进程(process) 程序触发后,执行者的权限与属性,程序的程序码与所需数据等 都会被载入内容中,操作系统给予这个内存内的单元一个唯一识别码(PID)。
- 进程彼此之间有相关性,有父子进程之分, Linux所有进程的父进程都是 init 这个 PID为1的进程
- 常驻内存并提供功能和服务使用者的各项任务 的进程, 通常被称为 服务(services)
- 进程间的互相通信主要是通过 kill 这个指令在处理
- nice 的给予可以有 : nice ,renice ,top 等指令. (提高进程的执等级)
- vmstat 为相当好用的系统资源使用情况观察指令
- SELinux当初的设计是为了避免使用者资源的误用,而SELinux使用的是MAC委任式存取设置.

