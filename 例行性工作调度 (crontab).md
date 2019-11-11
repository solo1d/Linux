# 例行性工作调度 (crontab)

所谓的调度就是将这些工作安排执行的流程之意 .

Linux 调度就是通过 crontab 与 at 这两个东西来运作的.



#### **Linux** 工作调度的种类: **at, cron** 

- 工作调度的方式 
  - 一种是**`例行性`**的，就是每隔一定的周期要来办的事项; 
    - **crontab :  这个指令所设置的工作将会循环的一直进行下去.**
      - 循环时间可分为,分钟,小时,每周,每月,每年 等等.
      - 除了指令 crontab 执行外,还可以编辑  **`/etc/crontab`** 来获得相同效果支持.
      - **让 corpntab 可以生效的服务则是  crond 这个服务**
  - 一种是**`突发性`**的，就是这次做完以后就没有的那一种 ( 例如 3C产品大降价...) 
    - **at :   at是个可以处理仅执行一次就结束调度的指令.**
      - **需要启动 atd 这个服务支持才可以.**



## 仅执行一次的工作调度 

#### **atd** 的启动与 **at** 运行的方式 

要使用单一工作调度时，我们的 Linux 系统上面必须要有负责这个调度的服务，那就是 atd 这 个玩意儿 

```bash
首先要开启 atd  这个服务才可以进行 调度.
$systemctl restart atd   # 重新启动 atd 这个服务
$systemctl enable atd   # 让这个服务开机就自动启动
$systemctl status atd   # 查阅一下 atd 目前的状态
输出:
● atd.service - Job spooling tools
   Loaded: loaded (/usr/lib/systemd/system/atd.service; enabled; vendor preset: enabled)           #enabled  代表了开机启动
   Active: active (running) since 六 2019-11-09 21:33:55 CST; 8s ago  #是否正在运行中(running 代表正在运行)
 Main PID: 3330 (atd)
    Tasks: 1
   CGroup: /system.slice/atd.service
           └─3330 /usr/sbin/atd -f
11月 09 21:33:55 study.centos.vbird systemd[1]: Started Job spooling tools.

#要确保 enabled 和 running 的存在
```

**使用 `at` 这个指令来产生所要运行的工作, 并将这个工作以文本的方式写入 `/var/spool/at` 目录内, 该工作便能等待 atd 这个服务取用与执行了.**

- 使用  `/etc/at.allow`  与  `/etc/at.deny`   这 **两个文件中的一个 **来进行 at  的使用限制.
  - 先找寻**`/etc/at.allow`**这个文件，写在这个文件中的使用者才能使用at，没有在这个文件 中的使用者则不能使用 at (即使没有写在 at.deny 当中); 
  - 如果**`/etc/at.allow`**不存在，就寻找**`/etc/at.deny`**这个文件，若写在这个 `at.deny`的使用者 则不能使用 at ，而没有在这个 at.deny 文件中的使用者，就可以使用 at . 
  - **如果两个文件都不存在，那么只有root可以使用at这个指令 **
- **上面两个文件,同时只可以存在一个!!! **  
- **文件格式都是  一个用户名 占一行**

```bash
$at   [-mldv] TIME
$at   -c  工作号码
选项与参数:
 -m  :当 at 的工作完成后，即使没有输出讯息，亦以 email 通知使用者该工作已完成。
 -l  :at -l 相当于 atq，列出目前系统上面的所有该使用者的 at 调度;
 -d  :at -d 相当于 atrm ，可以取消一个在 at 调度中的工作;
 -v  :可以使用较明显的时间格式列出 at 调度中的工作列表;
 -c  :可以列出后面接的该项工作的实际指令内容。
TIME :时间格式, 这里可以定义出"什么时候要进行 at 这项工作" 的时间, 格式有:
				 HH:MM    # 时:分 , 在今天 H时M分 执行,如果设定时,时间已超过,则明日 H时M分执行.
				 HH:MM YYYY-MM-DD    #时:分 年-月-日  ,强制在某年某月某日 某时 某分 执行.
				 HH:MM [am|pm] [月] [日]   #和上面相同,只不过区分了上下午, 12小时进制
				 HH:MM[am|pm] + number [minutes|hours|days|weeks]
				 # 例如  now + 5 minutes (现在的5秒之后) , 04pm + 3 days  (三天后的下午4点)


范例: 再过 5 分钟后, 将 /root/.bashrc  寄给 root 自己
$at  now + 5 minutes                 #回车后,会进入 at模式的 shell . 
at>  /bin/mail -s "testing at job" root < /root/.bashrc       #将要执行的指令
at>  EOF       #这个 EOF 是 [ctrl + d] 产生的, 并不是输入字符.


例二:将上述的第 2 项工作内容列出来查阅
$at  -l       # 列出目前系统上面的所有该使用者的 at 调用. 
输出:  8	Sun Nov 10 08:14:00 2019 a root    #表示号码8是一个调度,使用 -c 8 参数来查看具体内容
$at  -c  8
上面会列出非常多的内容,全部省略....
	 mail -s  'test' root < /root/.bashrc       #这是主要的


范例: 定时 2019-11-10 23:00 关机
$at 23:00 2019-11-10
at> /bin/sync
at> /bin/sync
at> /sbin/shutdown -h now
at> <EOT>
输出: job 9 at Sun Nov 10 23:00:00 2019       #工作号码是 9

```

- at 优点:
  - 离线继续工作的任务,  免除短线后的困扰
  - 突发状况导致必须进行的某项工作

#### at 工作的管理

```bash
$atq              #查询目前主机上有多少个 at 工作调度没有执行.  at -l  也会得到相同效果.
$atrm  工作号码    #删除某个工作 ,这个号码可以用 atq 得到,

范例 :查询目前主机上面有多少的 at 工作调度?
$atq        #只有root 会得到全部, 其他的只会得到自己所创建的工作
输出:  9	Sun Nov 10 23:00:00 2019 a root
		#9 是号码, 后面是工作执行时间, root 是工作指令下达者.

范例: 删除上面的 工作调度 9
$atrm  9        # 删除了
```



#### batch  系统有空时 才进行背景任务

**`batch` 会在CPU 工作负载小于 0.8 的时候才进行下达的工作任务. batch 也是使用 atq/atrm 来管理的 **

- **CPU工作负载: **
  - **当一个程序一直使用CPU运算功能,导致CPU使用率达到100% ,这时候 CPU工作负载是趋进于1 的(因为只负责了一个工作), **
    - **当同时执行这种程序两个的话, 那么 CPU工作负载就是 2**

```bash
$batch        #和 at 一样,但是不用参数
$uptime       #可以获得 1 ,5 15 分钟的平均工作负载
$jobs         #可以获得当前 shell 后台执行的命令或进程   (指令结尾有 &  就表示进入后台执行)
$kill  -9   %1    #杀死任务, %1 表示在后台执行的第一个任务.

范例: 假设目前 CPU 工作负载是1, 设定一个在低负载时执行的任务,执行 updatedb 指令.
$batch
at> /usr/bin/updatedb 
at> <EOT>
job 11 at Sun Nov 10 09:20:00 2019

$uptime  ;  atq
 09:21:23 up  1:34,  1 user,  load average: 1.00, 0.33, 0.45    #目前负载是1
 10	Sun Nov 10 09:10:00 2019 b root          #刚刚设定的任务还没有被执行,正在等待

#后台任务完成, 负载下降到了 0.1
$uptime  ;  atq
 09:23:00 up  1:34,  1 user,  load average: 0.10, 0.33, 0.45    #目前负载是0.1
 # atq 并没有输出,   表示刚刚设定的任务已经在负载低的时候执行了.
```



## 循环执行的例行性工作调度 

**循环执行的例行性工作调度则是由` cron `(crond) 这个系统 服务来控制的** 

**使用者控制例行性工作调度的指令 (`crontab` )**



### 使用者的设置

- **`crontab` 使用者限制**
  - **`/etc/cron.allow` : 都可以使用 `crontab` 的账号写入其中, 若不在这个文件内的使用者则不可以使用  `crontab`**
  - **`/etc/cron.deny`  将不可以使用 `crontab` 的帐号写入其中，若未记录到这个文件当中的使用者，就可以使用` crontab ` , (这是默认的设置)**
  - **`/etc/cron.allow`  比 ` /etc/cron.deny`  要优先, 而且这两个配置文件只可以存在一个**

**当使用者使用 `crontab` 这个指令来创建工作调度之后，该项工作就会被纪录到 `/var/spool/cron/用户名 `这个文件内，而且是以帐号来作为判别的 **

**cron 执行的每一项工 作都会被纪录到 /var/log/cron 这个登录文件中，所以啰，如果你的 Linux 不知道有否被植入 木马时，也可以搜寻一下 /var/log/cron 这个登录文件 **

```bash
$crontab   [-u username] [-l | -e | -r]
选项与参数:
 -u  :只有 root 才能进行这个任务，亦即帮其他使用者创建/移除 crontab 工作调度;
 -e  :编辑 crontab 的工作内容
 -l  :查阅 crontab 的工作内容
 -r  :移除所有的 crontab 的工作内容，若仅要移除一项，请用 -e 去编辑。
 
范例一:用 dmtsai 的身份在每天的 12:00 发信给自己
$crontab  -e     #使用这个命令来进行设定, 执行后会进入VI 编辑模式.添加如下内容.
 03  10  *   *  *  mail -s "at 12:00" dmtsai < /home/dmtsai/.bashrc
#分  时  日  月  周  <指令段>
#每项工作都是一行. 复杂的指令可以靠 sh 去调用脚本去完成.

*  (星号) 代表任何时刻都接受的意思,  日 是* 的话,就表示每天, 分钟不能给 *
,  (逗号) 代表分隔时段 10,20 10,12,13  * * *  代表:每天10点,12点,13点的 10分和20分 都执行一次
-  (减号) 代表范围段  0 0 10-20 * *  代表:每月 10号到20号 之内的每天 0点0分 都会执行一次
\N (斜线) N是数字,代表间隔,  */5 * 1 * *  代表:每月1日 从0点0分开始 ,每5分钟就执行一次,直到2号0:0
```

#### 系统配置文件   /etc/crontab  , /etc/cron.d/*

`cron` 这个服务的最低侦测限制是**分钟**，` cron` 会每分钟去读取一次 `/etc/crontab` 与 `/var/spool/cron` 里面的数据内容

**`/etc/crontab`**  配置文件修改完成后, 可以使用 **`systemctl  restart crond`**   来重启服务 读取配置文件.

```bash
$cat   /etc/crontab        #配置文件  /etc/crontab 内容

SHELL=/bin/bash    #使用哪种 shell 接口
PATH=/sbin:/bin:/usr/sbin:/usr/bin    #可执行文件搜寻路径
MAILTO=root        #若有额外STDOUT，以 email将数据送给谁

02 00 0 0 7   root  /bin/sh /root/a.sh    #每周日的0点 2分用身份root 执行一次指令
```

- crond  服务 读取配置文件的位置
  - crond 默认有三个地方会存在**执行脚本**配置文件, 分别是
    - **`/etc/crontab`**
    - **`/etc/cron.d/*`**
    - **`/var/spool/cron/*`**
      - **与系统的运行比较有关系的两个配置文件是放在 `/etc/crontab` 文件内以及 `/etc/cron.d/*` 目录内的文件**
      - **与用户自己的工作比较有关的配置文件，就是放在 `/var/spool/cron/` 里面的文件群**
  - **`/etc/cron.d/` 目录下也是可运行脚本,格式和 crontab 命令相同. 适用于开发脚本放置,或是周期性的系统维护脚本**
  - **`/etc/cron.d/0hourly` 每个小时会执行一次 `run-parts  /etc/cron.hourly` 命令**
    - **`run-parts` 是一个shell script 脚本 ,这脚本会在 `每小时的5分钟内`来执行 `/etc/cron.hourly` 目录下的所有可执行文件或脚本**
    - **`/etc/cron.hourly/`  目录下的所有脚本, 都会在每小时运行一次**
    - **放在 `/etc/cron.hourly/ `的文件，必须是能被直接执行的指令脚本， 而不是分、时、日、月、周的设置值 **

```bash
/etc/cron.d/0hourly 脚本格式

# Run the hourly jobs    运行每小时的工作
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
01 * * * * root run-parts /etc/cron.hourly
# 分 时 日 月 周 身份 指令
# 每个小时都会执行一次  run-parts  /etc/cron.hourly 指令
```

- **个人化的行为使用 `crontab -e`**
- **系统维护管理使用`vim /etc/crontab`**
- **自己开发软件使用` vim /etc/cron.d/newfile`**
- **固定每小时、每日、每周、每天执行的特别工作:** 
  - **与系统维护有关 则放置 到 `/etc/crontab` 中来集中管理较好**
  - **一定要再某个周期内进行的 任务，也可以放置到上面谈到的几个目录中 直接写入指令即可! **



### 一些注意事项 

- 资源分配不均的问题

- 取消不要的输出项目 

  - 有执行成果或者是执行的项目中有输出的数据时，该数据将会 mail 给 MAILTO 设置的帐号 
  - MAILYO 设置在 ,` /etc/crontab 文件`  和 `/etc/cron.d/ 目录下`
  - 如果不需要错误信息,那么可以用 输出重定向 来将错误结果输出到 /dev/null

- 安全的检验

  - 多时候被植入木马都是以例行命令的方式植入的，所以可以借由检查 /var/log/cron 的内容 

    来视察是否有“非您设置的 cron 被执行了?” 

- **周与日月不可同时并存 **

  



## 可唤醒停机期间的工作任务 

anacron 并不是用来取代 crontab 的，anacron 存在的目的就在于我们上头提到的，在处理非 24 小时一直启动的 Linux 系统的 crontab 的执行! 以及因为某些原因导致的超过时间而没有 被执行的调度工作。 

anacron 会去分析现在的时间与时间记录文件所记载的上次执行 anacron 的时间，两者比较后若发现有差异， 那就是在某些时刻没有进行 crontab   此时 anacron 就会开始执行未进行的 crontab 任务了! 



### **anacron** 与 **/etc/anacrontab** 

**anacron 其实是一支 程序并非一个服务**

**这支程序在 CentOS 当中已经进入 crontab 的调度 , 同时 anacron 会每个小时被主动执行一次 .**

**anacron 的配置文件放置在 `/etc/cron.hourly/ `目录下 **

**anacron  是否执行的依据就是` /var/spool/anacron/cron.daily `这个时间戳记录文件的内容(YYYYmmdd)**

```bash
/etc/cron.hourly/0anacron 内容如下, 每个小时都会被 crontab 调用一次

#!/bin/sh
# Check whether 0anacron was run today already
if test -r /var/spool/anacron/cron.daily; then
    day=`cat /var/spool/anacron/cron.daily`
fi
if [ `date +%Y%m%d` = "$day" ]; then
    exit 0;
fi

# Do not run jobs when on battery power
if test -x /usr/bin/on_ac_power; then
    /usr/bin/on_ac_power >/dev/null 2>&1
    if test $? -eq 1; then
    exit 0
    fi
fi
/usr/sbin/anacron -s
# 所以其实也仅是执行 anacron -s 的指令, 这个才是核心
```

```bash
$anacron   [-sfn]  [job] ...
$anacron   -u  [job] ...
选项与参数:
 -s  :开始一连续的执行各项工作 (job) ,会根据时间记录文件的数据判断是否进行.
 -f  :强制进行, 而不去判断时间记录文件的时间戳标记.
 -n  :立即进行未进行的任务, 而不延迟任何工作.
 -u  :仅更新时间记录文件的时间戳内容,并不进行任何工作(job)
job  :由 /etc/anacrontab 定义的各项工作名称.
```



#### 配置文件 :/etc/anacrontab

```bash
# /etc/anacrontab: configuration file for anacron
# See anacron(8) and anacrontab(5) for details.

SHELL=/bin/sh												#使用哪种 shell 接口
PATH=/sbin:/bin:/usr/sbin:/usr/bin  #路径
MAILTO=root                         #额外的输出通过邮件的方式传递给root
RANDOM_DELAY=4     #添加作业基本延迟的最大随机延,单位是分钟
START_HOURS_RANGE=3-22   #多少个小时内应该要执行的任务的时间

#天数   延迟几分钟   工作名称(自定)    实际要进行的指令串(通常与 crontab 的设置相同
1	        5	       cron.daily	  	nice run-parts /etc/cron.daily       #每天执行一次
7     	  25       cron.weekly		nice run-parts /etc/cron.weekly      #一周执行一次
@monthly  45	     cron.monthly	  nice run-parts /etc/cron.monthly     #每月执行一次
#这个天数是目前时间与/var/spool/anacron/* 内的时间记录的 相差的天数, 若超过此天数,就准备开始执行.
#工作执行后, 工作名称就会记录在 /var/log/cron 里面.

$more  /var/spool/anacron/*
输出:

/var/spool/anacron/cron.daily
20191111

/var/spool/anacron/cron.monthly
20191107

/var/spool/anacron/cron.weekly
20191110
# 上面则是三个工作名称的时间记录文件以及记录的时间戳记
```

### anacron 的执行流程

1. **由`/etc/anacrontab`分析到`cron.daily`这项工作名称的天数为1天;**

2. **由`/var/spool/anacron/cron.daily`取出最近一次执行`anacron`的时间戳记;** 

3. **由上个步骤与目前的时间比较，若差异天数为1天以上(含1天)，就准备进行指令; **

4. **若准备进行指令，根据`/etc/anacrontab`的设置，将*延迟5分钟+3小时*(看** 

   **`START_HOURS_RANGE` 的设置);** 

5. **延迟时间过后，开始执行后续指令，亦即“`run-parts  /etc/cron.daily`”这串指令(`run-parts` 是个脚本);** 

6. **执行完毕后，anacron程序结束 **

**放置在 /etc/cron.daily/ 内的任务就会在一天后一定会被执行的 .因为 anacron 是 每个小时被执行一次** 



### crond 与 anacron 的关系 

- **`crond`会主动去读取  *`/etc/crontab`* ,*`/var/spool/cron/`*,  *`/etc/cron.d/`*等配置文件，并依据“分、 时、日、月、周”的时间设置去各项工作调度;** 
- **根据 `/etc/cron.d/0hourly` 的设置，主动去 `/etc/cron.hourly/` 目录下，执行所有在该目录下 的可执行文件;** 
- **因为  `/etc/cron.hourly/0anacron` 这个指令档的缘故，主动的每小时执行  `anacron`，并调用` /etc/anacrontab `的配置文件;** 
- **根据 `/etc/anacrontab` 的设置，依据每天、每周、每月去分析 `/etc/cron.daily/ `,  `/etc/cron.weekly/`,  `/etc/cron.monthly/`  内的可执行文件，以进行固定周期需要执行的指令。** 

**如果你每个周日的需要执行的动作是放置于` /etc/crontab` 的话，那么该动作只要过 期了就过期了，并不会被抓回来重新执行。但如果是放置在 `/etc/cron.weekly/` 目录下，那么 该工作就会定期，几乎一定会在一周内执行一次~如果你关机超过一周，那么一开机后的数 个小时内，该工作就会主动的被执行 **



**crontab 与 at 都是“定时”去执行，过了时间就过了!不会重新来一遍~那 anacron 则是“定期”去执行，某一段周期的执行~ 因此，两者可以并行，并不会互相冲突 **



## 小结

- 系统可以通过 at 这个指令来调度单一工作的任务! `at TIME`为指令下达的方法，当 at 进入调度后， 系统执行该调度工作时，会到 ***下达时的目录*** 进行任务;
- at 的执行必须要有 atd 服务的支持，且 `/etc/at.deny `为控制是否能够执行的使用者帐号; 
- 通过 atq, atrm 可以查询与删除 at 的工作调度; 
- batch 与 at 相同，不过 batch 可在 CPU 工作负载小于 0.8 时才进行后续的工作调度 
- 系统的循环例行性工作调度使用 crond 这个服务，同时利用 `crontab -e` 及 `/etc/crontab` 进 行调度的安排
- `crontab -e` 设置项目分为六栏，“`分、时、日、月、周、指令`”为其设置依据; 
- `/etc/crontab` 设置分为七栏，“`分、时、日、月、周、执行者、指令`”为其设置依据; 
- `anacron` 配合 `/etc/anacrontab `的设置，可以唤醒停机期间系统未进行的 `crontab` 任务! 
- CentOS 系统默认的例行 性命令都放置在  `/etc/cron.*  `里面，所以，你可以自行去: ` /etc/cron.daily/` ,  `/etc/cron.week/ ` , ` /etc/cron.monthly/`  这三个目录内看一看 









