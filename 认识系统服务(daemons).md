# 认识系统服务(daemons守护进程)
## 守护进程daemons 与服务serivce
**系统为了某些功能必须要提供一些服务(无论是系统本身还是网络方面),这个服务就称为 service .**
**service的提供总是需要进程的运行,所以达成这个 service 的进程 就称呼他为 daemons 守护进程**
就是说 需要有 daemons 的支持,才可以得到 service 服务的支持. 两者没什么区别.

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

##### systemd 配置文件放置目录
- **`/usr/lib/systemd/system/`**  :每个服务最主要的启动脚本设置.类似于 /etc/init.d 下面的脚本.
  - 系统开机会不会执行某些服务,就是看这个目录下的设置,所以这个目录下都是链接文件.
  - 修改某个服务启动的设置,应该去`/usr/lib/systemd/system` 下面修改才对.
- **`/run/systemd/system/`** :系统执行过程中产生的服务脚本,这个脚本的优先级要比 `/usr/lib/systemd/system/`高.
- **`/etc/systemd/system/`** :管理员依据主机系统的需要所创建的执行脚本,优先级比 `/run/systemd/system/`高.

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





