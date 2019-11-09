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
```



















