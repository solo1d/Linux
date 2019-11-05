# Linux 账号管理与 ACL 权限设置

- 在登录界面输入帐号密码后,系统所处理的内容:

  - 先找寻`/etc/passwd`里面是否有你输入的帐号,如果没有则跳出，如果有的话则将该帐号 对应的 UID 与 GID (在 `/etc/group` 中) 读出来，另外，该帐号的主文件夹与 shell 设置 也一并读出; 

  - 再来则是核对密码表啦!这时Linux会进入`/etc/shadow`里面找出对应的帐号与UID，然 

    后核对一下你刚刚输入的密码与里头的密码是否相符? 

  - 如果一切都OK的话，就进入Shell控管的阶段

- 登陆你的 Linux 主机的时候，那个` /etc/passwd` 与` /etc/shadow` 就必须要让系统读取.

## 使用者账号

#### /etc/passwd 文件结构

 程序的运行都和权限有关, 而权限与 UID/GID 有关, 因此各程序需要读取 /etc/passwd 来了解不同账号的权限.

```bash
/etc/passwd:
root:  x:  0:  0:  root:  /root:  /bin/bash

#一共七个字段, 挨个说明:
1. root : 帐号名称, 它对应于 UID
2. x    : 早期 UNIX 系统的密码段, 但是目前内容已经移动到 /etc/shadow 中, 这里只是占位符
3. 0    : UID ,使用者识别码,  0是管理员, 1~999 是系统账号(不可登录), 1000~60000 为可登入账号
4. 0    : GID , 这个于 /etc/group 有关. (组群名称 于 GID 的对应)
5. root : 使用者信息说明栏,没什么用. ( $chfn 指令可以来解释这字段)
6. /root: 主文件夹,使用者登入后 就会立即进入到 该目录下.(可修改)
7./bin/bash : 这个是 登入后默认使用的 Shell . (如果是 /sbin/nologin 则代表不可登录)
```

#### /etc/shadow  文件结构 

shadow 文件是用来保存密码和一些密码相关设置的.

- root 密码遗忘的解决方法, (都必须操作主机,而不是网络操作)
  - 进入单人维护模式, 系统会自动的给予 root 权限的bash 接口,在以 passwd 修改密码即可
  - 或者以 Live CD 开机,挂载根目录 去修改 /etc/shadow ,将里面的 root 的密码字段情况,再次开机之后, root 将不用密码即可登录.

查看目前 shadow 使用的哪种账号密码机制 命令:  **`$ authconfig --test | grep hashing `**

```bash
root: $6$AcvdhTi9i0:  : 0: 99999: 7:  :  :
dmtsai:$6$IyhtHAG6B:  : 0: 99999: 7:  :  :
1   : 2            :3 :4 :   5  : 6: 7: 8: 9
#一共9个字段
1. 账号名称, 必须和 /etc/passwd 相同
2. 通过编码的密码,在这个字段加入 ! 或 * 可以使密码失效,无法验证,也就表示无法登录.
3. 最近更改密码那一天 距离 1970年1月1日(作为1) 过去了多少天.没有修改过密码则为空.
4. 密码在最近一次被更改后还需要几天才可以在被改变,如果是0 则表示密码可以随时改动. 如果是20,则表示	   今天修改过密码后,那么20天之内都无法再次修改密码了.
5. 强制要求在多少天之内必须修改密码, 99999(273年) 则表示密码的变更没有强制之意.
6. 密码需要变更期限前的警告天数. 以上次修改密码的时间为基准.
7. 密码过期后的宽限日期(密码失效倒计).
8. 账户失效日期,也是距离 1970年的天数为单位,账户到达规定日期后,就无法登录和使用了(常用在收费服务)
9. 保留字段.暂时没有功能.
```



#### /etc/group  文件结构

**这个文件记录了  GID  与群组名称的对应关系**

```bash
root   :x : 0    :
dmtsai :x : 1000 : dmtsai,alex

#一共4个分段
1. 群组名称, 就是群组名,给人看的,需要与第三个字段 GID 对应
2. 群组密码, 通常不需要设置,这设置是给 "群组管理员"使用的, 需要与第三个字段 GID 对应,废弃字段.
3. GID , 就是群组 ID , /etc/passwd 第四个字段使用的GID对应的群组名就是由这里对应出来的.
4. 此群组支持的账号名称,也就是同组的用户, 用逗号分隔,不可以有空格.
```

#### 有效群组, 主要体现在创建文件时,文件的所属组

```bash
$groups          #该命令会得到当前用户的所属群组, 第一个就是有效群组.
$newgrp	 群组		  #有效群组的切换.只可以切换到该用户已经支持的群组.这个切换是进入了一个新的bash			             #需要使用 exit 来退出 切换的群组环境. 要不然会出现很多问题.
```



### /etc/gshadow    群组管理员

这个文件最大的功能就是 创建群组管理员.(将某个使用者加入到某些群组)

群组管理员可以通过  $gpasswd  命令. 来将某个账户添加到管理的组下.

```bash
root  :   : :
dmtsai: !!: :dmtsai

#4个分段,  和/etc/group 差不多
1. 群组名称
2. 密码栏, 如果为空 或 !则表示 无合法密码, 所以无群组管理员
3. 群组管理员的账号.( 在 /etc/gpasswd 文件中有记录 )
4. 在该群组的下的用户 ( 与 /etc/group 内容相同)
```



## 账号管理

### 新增与移除使用者:   useradd , 相关文件配置 和  passwd ,usermod, userdel

#####  useradd   创建使用者

由于系统帐号主要是用来进行运行系统所需服务的权限设置， 所以 系统帐号默认都不会主动创建主文件夹的 

useradd  这个命令在创建Linux账号时会参考下面几个文件的内容 : `/etc/default/useradd` , `/etc/login.defs ` , `/etc/skel/*`

```bash
$useradd  [-u UID]  [-g 初始化群组] [-G 次要群组]  [-mM] [-c 说明栏] [-d 主文件夹绝对路径] 	         [-s 默认shell ]  使用者账号名

选项和参数:
-u  :后面接的是 UID ，是一组数字。直接指定一个特定的 UID 给这个帐号;
-g  :后面接的那个群组名称就是初始化群组,默认创建文件或文件夹都是这个组名
	     该群组的 GID 会被放置到 /etc/passwd 的第四个字段内。
-G  :后面接的群组名称则是这个帐号还可以加入的群组。
       这个选项与参数会修改 /etc/group 内的相关数据
-M  :强制! 不要创建使用者主文件夹!(系统帐号默认值)
-m  :强制! 要创建使用者主文件夹!(一般帐号默认值)
-c  :这个就是 /etc/passwd 的第五栏的说明内容, 可以随便设置
-d  :指定某个目录成为主文件夹，而不要使用默认值。务必使用绝对路径!
-r  :创建一个系统的帐号，这个帐号的 UID 会有限制 (参考 /etc/login.defs)
-s  :后面接一个 shell ，若没有指定则默认是 /bin/bash 的啦~
-e  :后面接一个日期，格式为“YYYY-MM-DD”此项目可写入 shadow 第八字段,亦即帐号失效日的设置项目
-f  :后面接 shadow 的第七字段项目，指定密码是否会失效。
	     0为立刻失效，-1  为永远不失效(密码只会过期而强制于登陆时重新设置而已。), 1 为一天后失效.
-D  :显示 useradd  创建用户的默认参考值, 默认的群组,默认shell ,默认主文件夹内容,默认邮件信息..
				这些数据都存在于  /etc/default/useradd  和 /etc/login.defs 中

范例: 完全参考默认值创建一个使用者，名称为 vbird1
$useradd  vbird1    #执行完成后, 会在 /home 目录下出现 vbird1 文件夹. (MAC则是 /Users 下)

# 在默认情况下创建用户,系统会帮我们处理的几个项目.(都记录在 /etc/login.defs 文件内)
     #1. 在 /etc/passwd 里面创建一行与帐号相关的数据，包括创建 UID/GID/主文件夹等; 
     #2. 在 /etc/shadow 里面将此帐号的密码相关参数填入，但是尚未有密码;
     #3. 在 /etc/group 里面加入一个与帐号名称一模一样的群组名称;
	   #4 .在 /home 下面创建一个与帐号同名的目录作为使用者主文件夹，且权限为 700

范例二:假设我已知道我的系统当中有个群组名称为 users ，且 UID 1500 并不存在,
		  请用 users 为初始群组，以及 uid 为 1500 来创建一个名为 vbird2 的帐号
$useradd   -u 1500 -g users  vbird2


范例三:  创建系统账号,  名称为 vbird3
$useradd -r vbird3
```

### passwd  修改密码

```bash
$passwd  [--stdin] [账号名称]     #所有人均可使用来修改自己的密码
$passwd  [-l] [-u]  [--stdin]  [-S] [-n 天数] [-w 天数] [-i 日期] 账号  #root 可用
选项参数:
--stdin  :可以通过来自前一个管道的数据,作为密码输入,对 shell script脚本有帮助
-l       :是 lock 的意思, 会将 /etc/shadow 第二栏最前面加上 ! 使密码失效,从而无法登录.
-u	     :与 -l 作用相反, 会取消密码失效的状态.
-S	     :列出密码相关参数, 亦即 shadow 文件内的大部分信息
-n       :后面接天数, shadow 第4字段, 多久不可修改密码的天数.
-x			 :后面接天数, shadow 第5字段, 多久内必须更改密码的天数.
-w       :后面接天数, shadow 第6字段,  密码过期前的警告天数
-i       :后面接 "日期"  , shadow 第7字段,密码过期后的宽限天数.(这个天数与第5字段有很大关系)
					  也就是说 -i 2 -x 5  表示密码在5天内必须修改,如果不修改那么在7天后账户密码就过期了.

如果不加任何参数就直接执行 passwd  ,则会默认修改执行者本身的密码.


范例一:请 root 给予 vbird2 密码
$passwd  vbird2
输出:
Changing password for user vbird2.
New UNIX password:           #写入新密码
Retype new UNIX password:	   #再次输入新密码,是为了验证.


范例二: 使用管道来输入和设定 vbird2 的密码, 新密码是 newpasswd
$echo  "newpasswd" | passwd --stdin vbird2	      #这个内容常用在 脚本内

范例三: 让 vbird2 每60天需要更改一次密码, 密码过期后10天就宣告账号失效.
 $passwd -i 10 -x 60 vbird2
 
范例四:  让 vbird2 账户失效,无法登录.
$passwd  -l vbird2		 #这样就无法登录了, 只是在修改 /etc/passwd 文件的第二个字段

```



### chage   更详细的密码参数显示和修改

```bash
$chage  [-ldEmMW]  账号名
选项与参数:
 -l :列出该帐号的详细密码参数;
 -d :后面接日期，修改 shadow 第三字段(最近一次更改密码的日期)，格式 YYYY-MM-DD
 -m :后面接天数，修改 shadow 第四字段(密码最短保留天数)
 -M :后面接天数，修改 shadow 第五字段(密码多久需要进行变更)
 -W :后面接天数，修改 shadow 第六字段(密码过期前警告日期) 
 -I :后面接天数，修改 shadow 第七字段(密码失效日期)
 -E :后面接日期，修改 shadow 第八字段(帐号失效日)，格式 YYYY-MM-DD
 
 
范例1 : 列出 vbird2 的详细密码信息,
$chage  -l  vbird2
最近一次密码修改时间					 ：从不
密码过期时间				     	   ：从不
密码失效时间				 	       ：从不
帐户过期时间						     ：从不
两次改变密码之间相距的最小天数  ：0
两次改变密码之间相距的最大天数	 ：99999
在密码过期之前警告的天数	     ：7

范例2:  修改 vbird2 用户的账号失效日,让他在5天后失效
$chage -E $(date --date='5 day' +%Y-%m-%d) vbird2 
 	      #date --date='5 day' +%Y-%m-%d 会得到第5天之后时间. 如果加上%T 会得到具体小时和分钟

范例3:  添加以新账户, 然后初始化的他密码,并且要求他在登录之后就必须修改密码.
$useradd  agetest
$echo 'agetest' | passwd --stdin agetest
$chage -d 0 agetest           #这个时候 最近修改密码字段就变成了0. 必须修改密码
$chage -l   agetest
最近一次密码修改时间		：密码必须更改
密码过期时间					：密码必须更改
密码失效时间					：密码必须更改
```



### usermod   账户相关数据的微调

```bash
$usermod  [-cdegGlsuLU] username 
选项与参数:
-c :后面接帐号的说明，即 /etc/passwd 第五栏的说明栏，可以加入一些帐号的说明。
-d :后面接帐号的主文件夹，即修改 /etc/passwd 的第六栏;
-e :后面接日期，格式是 YYYY-MM-DD 也就是在 /etc/shadow 内的第八个字段数据.账号失效日期
-f :后面接天数，为 shadow 的第七字段。密码过期后的宽限日期
-g :后面接初始群组，修改 /etc/passwd 的第四个字段，亦即是 GID 的字段!
-G :后面接次要群组，修改这个使用者能够支持的群组，修改的是 /etc/group 
-a :与 -G 合用，可“增加次要群组的支持”而非“设置”
-l :后面接帐号名称。亦即是修改帐号名称， /etc/passwd 的第一栏!
-s :后面接 Shell 的实际文件，例如 /bin/bash 或 /bin/csh 等,用户默认shell
-u :后面接 UID 数字啦!即 /etc/passwd 第三栏的数据;
-L :暂时将使用者的密码冻结，让他无法登陆。其实仅改 /etc/shadow 的密码,添加了!
-U :将 /etc/shadow 密码栏的 ! 拿掉，解冻账号

范例:让账号  vbird2 在 2019-11-10 失效
$usermod  -e  "2019-11-10" vbird2

范例: 创建 vbird3 账号的时候并没有给予主文件夹, 请将其创建出来.
$ll -d   ~vbird3        #确认是否存在 vbird3 目录. 如果没有则向下执行. 
$cp -a /etc/skel   /home/vbird3          #/etc/skel 是用户主目录内容的模版
$chown  -R  vbird3:vbird3  /home/vbird3      #修正权限,给予目录的所有者个所属组
$chmod  700   /home/vbird3
$usermod -d /home/vbird3 vbird3			  #设置账号的主文件目录
```



### userdel   删除使用者 和相关数据

- **使用者的相关数据有:**
  - **使用者账号/密码相关参数**:  `/etc/passwd`  , `/etc/shadow`
  - **使用者群组相关设置 **:  `/etc/group`  ,  `/etc/gshadow`
  - **使用者个人文件数据** :  `/home/username `  , `/var/spool/mail/username`

```bash
$userdel  [-r]  username
选项和参数:
-r   连同使用者的主目录文件也一起删除

范例:  删除 vbird2 用户, 以及他的主目录文件.
$userdel -r vbird2

#在删除某个用户前,最好 $find / -user username 来删除整个系统内属于username的文件.
```



### id  查询某人或自己的相关 UID/GID 的信息

```bash
$id   账号名      #直接运行即可, 不需要什么参数,不填写用户名就代表自身.
```

### finger   查阅使用者相关的信息(大部分都是 /etc/passwd 文件中的信息

```bash
$finger    [-s]  username 
选项与参数:
-s   :仅列出使用者的账号, 全名, 终端就机代号, 登录时间. 计划 等等.

范例一:观察 vbird1 的使用者相关帐号属性
$finger vbird1	             #这样的指令只可以 vbiird1 或 root 来执行.
输出:
Login: dmtsai         			Name: dmtsai
Directory: /home/dmtsai             	Shell: /bin/bash
On since 二 11月  5 20:31 (CST) on pts/0 from 192.168.2.2
   2 seconds idle
No mail.
No Plan

# Login:为使用者帐号，亦即 /etc/passwd 内的第一字段; 
# Name:为全名，亦即 /etc/passwd 内的第五字段(或称为注解); 
# Directory:就是主文件夹了;
# Shell:就是使用的 Shell 文件所在;
# Never logged in.:figner 还会调查使用者登陆主机的情况 
# No mail.:调查 /var/spool/mail 当中的信箱数据;
# No Plan.:调查 ~vbird1/.plan 文件，并将该文件取出来说明!


范例二:  建立自己的计划档
$echo  "新的计划档" > ~/.plan            #计划档必须是 .plan 文件
$finger   vbird1
输出: 
Login: dmtsai         			Name: dmtsai
Directory: /home/dmtsai             	Shell: /bin/bash
On since 二 11月  5 20:31 (CST) on pts/0 from 192.168.2.2
   6 seconds idle
No mail.
Plan:
新的计划档


范例三,  找出目前在系统上面登录的使用者与登录时间.
$finger                 #这样直接输出即可.
输出:
Login  ,Name   ,Tty   ,Idle, Login Time  ,Office , Office Phone,  Host
dmtsai ,dmtsai ,pts/0        Nov  5 20:31                         (192.168.2.2)
```



### chsh   可以修改自己默认使用的 shell    (就是修改/etc/passwd 第7个字段)

```bash
$chsh   [-ls]
参数与选项:
-l   :列出目前系统上面可用的 shell , 就是 /etc/shells 文件的内容
-s   :设置修改自己的 shell 

范例: 修改自己默认的shell 为 bash
$chsh -s /bin/bash				#路径要写全 , 修改前最好先使用 -l 来查看一下 shell 有哪些.
```



## 新增与移除群组

**群组的内容都与这两个文件有关:  `/etc/group`, `/etc/gshadow` **

### groupadd    创建群组

```bash
$groupadd     [-g GID]  [-r] 群组名称
选项与参数:
-g   :后面接某个特定的 GID, 用来直接给予 GID,  同时后面的群组名称也要填写
-r   :创建系统群组,  与 /etc/login.defs 内的 GID_MIN 变量 有关.

范例1 : 创建一个群组, 名称为 group1
$groupadd group1 
$grep 'group1' /etc/group /etc/gshadow        #查看一下.
输出:
/etc/group:group1:x:1502:
/etc/gshadow:group1:!::
```



### grouped   修改群组的一些参数

```bash
$groupmod [-g gid] [-n group_name] 群组名
选项与参数:
 -g   :修改既有的 GID 数字;  不要随意动 GID
 -n   :修改既有的群组名称
```

###  groupdel 删除群组 

```bash
$groupdel [groupname]	   #不可以删除某个账号的  初始群组 (除非账号已经删除了)
范例:  删除刚刚创建的 group1 群组
$groupdel  group1
```



### gpasswd  群组管理员 功能

**群组管理员可以管理哪些帐号可以加入/移出该群组 , 群组管理员是一个管理权限,并不是一个账号.**

**每个群组都可以让 一个或多个用户 开通群组管理员权限. 一个账号 可以管理多个群组**

**群组管理员只是权限, 并不一定要求他就在管理的组内**

```bash
#下面是 root 可以执行的动作
$gpasswd   groupname	                #给予群组管理员功能的一个密码
$gpasswd  [-A user1,user2....] [-M user3,user4...] groupname   
$gpasswd  [-rR]  groupname
选项与参数:
     :若没有任何参数时，表示给予 groupname 一个密码(/etc/gshadow)
 -A  :将 groupname 的主控权交由后面的使用者管理(该群组的管理员)
 -M  :将某些帐号加入这个群组当中!
 -r  :将 groupname 的密码移除
 -R  :让 groupname 的密码栏失效
 
#下面是关于 群组管理员 可以执行的动作. (就是root 使用 -A参数后面添加的账户才有权利执行)
$gpasswd  [-ad]  user  groupname
选项与参数:
	 -a  :将某位使用者加入到 groupname 这个群组中.  (add)
	 -d  :将某位使用者移除出 groupname 这个群组.    (del)


范例1 :  创建一个新群组,名称为 testgroup  且群组交由 vbird1 和 dme 两个账户管理 .
root $groupadd testgroup           #先创建群组 ,root可执行
root $gpasswd  testgroup           #设定 testgroup 这个群组的 群组管理员密码
	     #这里会要求输入两次新的设定密码,  假设输入完成.
root $gpasswd  -A vbird1,dme    testgroup       #添加完成, 验证一下.

root $grep testgroup /etc/group /etc/gshadow
输出:
/etc/group:testgroup:x:1502:
/etc/gshadow:testgroup:$6$FgBX45IylaeD:vbird1,dme:	  #这里很关键.


范例2: 使用 vbird1 登录系统,然后将 arod 这个用户添加到 testgroup 组.
vbird1 $gpasswd -a arod testgroup
```

































