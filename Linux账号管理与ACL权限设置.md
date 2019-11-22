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
-s  :后面接一个 shell ，若没有指定则默认是 /bin/bash ,如果不想让用户登录 则设置/sbin/nologin
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
  - **使用者群组相关设置**:  `/etc/group`  ,  `/etc/gshadow`
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

**群组的内容都与这两个文件有关:  `/etc/group`, `/etc/gshadow`**

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



### gpasswd  群组管理员 功能  和添加删除组中用户

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

### 如果多人同时在一个目录内进行开发,并且相互之间可以修改任何文件, 那么这么用户都必须加入一个相同的组,  开发的目录权限必须是  2770 ,也就是SGID , 也必须属于加入的组, 这样才可以进行对所有文件的修改.



# 主机的细部权限规划:**ACL** 的使用 

ACL 是 `Access Control List(访问控制列表) `的缩写，主要的目的是在提供传统的 owner,group,others 的 read,write,execute 权限之外的细部权限设置 .

ACL 可以针对 **`单一使用者，单一文件或目录来 进行 r,w,x 的权限规范`** ，对于需要特殊权限的使用状况非常有帮助 

- 针对下面三个方面来进行权限控制
  - 使用者 (user) :可以针对使用者来设置权限.
  - 群组 (group) : 针对群组为对象来设置其权限.
  - 默认属性(mask) : 还可以针对在该目录下创建 新文件/目录 时, 规范新数据的默认权限.

### getfacl  和  setfacl

**`getfacl`:取得某个文件/目录的 ACL 设置项目;**

**`setfacl`:设置某个目录/文件的 ACL 规范.**

```bash
$setfacl [-bkRd]  [ { -m | -x } acl参数 ]  目标文件名
选项与参数:
 -m :设置后续的 acl 参数给文件使用，不可与 -x 合用;
 -x :删除后续的 acl 参数，不可与 -m 合用;
 -b :移除“所有的” ACL 设置参数;
 -k :移除“默认的” ACL 参数，关于所谓的“默认”参数于下面范例中介绍;
 -R :递归设置 acl ，亦即包括次目录都会被设置起来;
 -d :设置“默认 acl 参数”的意思!只对目录有效，在该目录新建的数据会引用此默认值

1. 针对特定使用者的方式:
	设置规范:  u:[使用者账号列表]:[rwx]    #u代表用户级别
			  例如针对 vbird1 的权限规范 rx:
		            $setfacl -m u:vbird1:rx  acl_test    #文件  
		            		#在设置后的文件或目录 的权限部分,会出现一个 + 号,而且原本权限会变化.
		            			#可以通过  gitfacl 命令来观察权限.
2. 针对特定群组的方式:
	设置规范:   g:[群组列表]:[rwx]     #g代表用户

3. 开放文件的最大权限限制(和mask相反):
	 设置规范:  m:[rwx]       #m代表mask , 表示设置acl的允许用户设置权限有哪几种.

4.针对默认权限设置目录未来文件的 ACL 权限继承:
	 设置规范:  d:[u|g]:[用户名列表|群组列表]:[rwx]       #d表示默认继承,其他的是二选一
	 	         例如: 让 vbird1 在 /srv/project 下面一直具有rx的默认权限(包括未来的新文件)
	 	         	   $setfacl  -m  d:u:vbird1:rx  /srv/project    #设置完成.
	 	         	     #如果要是想取消的话, $setfacl  -b  /srv/project  即可.
5. 取消某个账号的 ACL 权限:
	  设置规范:  u:用户列表           #不给出权限即可.
```

```bash
$getfacl   filename
选项与参数:
gitfacl 的选项几乎与 setfacl相同.

列出 刚刚设置过的 acl_test 文件的属性.
$gitfacl  acl_test
输出:
# file: acl_test1    #说明文档名, 这是文件默认属性
# owner: root        #说明此文件的拥有者，亦即 ls -l 看到的第三使用者字段 ,这是文件默认属性
# group: root        #此文件的所属群组，亦即 ls -l 看到的第四群组字段, 这是文件默认属性
user::rwx            #使用者列表栏是空的，代表文件拥有者的权限
user:vbird1:r-x      #针对 vbird1 的权限设置为 rx ，与拥有者并不同!
group::r--           #针对文件群组的权限设置仅有 r
mask::r-x            #此文件默认的有效权限 (mask)
other::r--           #其他人拥有的权限

以 '#' 开头的 都是文件的默认属性,包括文件名,文件所有者,文件所属组.
下面的就是属于不同使用者,群组与有效权限(mask) 的设置值.
```



## 使用者身份切换

- $su   会直接将身份变成 root, 要求输入 root 账号的密码.
- $sudo   执行root的指令串, 要求输入使用者自己的密码.

 ```bash
$su [-lm] [-c 指令] [username]
选项与参数:             #无法使用su 去切换系统账号,但是可以用系统账号的身份去执行命令.sudo
 - :单纯使用 - 如“ su - ”代表使用 login-shell 的变量文件读取方式来登陆系统;
     若使用者名称没有加上去，则代表切换为 root 的身份。 差别是环境变量和很多差异.
 -l :与 - 类似，但后面需要加欲切换的使用者帐号!也是 login-shell 的方式。
 -m :-m 与 -p 是一样的，表示“使用目前的环境设置，而不读取新使用者的配置文件”
-c :仅进行一次指令,随后就退出切换的身份，所以 -c 后面可以加上指令
				如果指令有很多条,可以使用  sh -c "多条指令"  来进行执行

使用su 变成root 时, 尽量使用 su -  来进行.这样会得到完整的新使用者环境.
 ```

仅有规范到  /etc/sudoers 内的用户才能够执行 sudo 这个指令,还可以设置不需要密码即可执行sudo 命令.

能否使用 sudo 必须要看 /etc/sudoers 的设置值， 而可使用 sudo 者是通过输入使用者自己的密码来执行后续的指令串 

一般用户能够具有 sudo 的使用权，就是管理员事先审核通过后，才开放 sudo 的使用权的!因此，除非是信任用户，否则一般用户默认是不能操作 sudo 的.

```bash
$sudo   [-b]  [-u 新使用者账号]   指令
选项与参数:
 -b :将后续的指令放到背景中让系统自行执行，而不与目前的 shell 产生影响
 -u :后面可以接欲切换的使用者，若无此项则代表切换身份为 root 。再后面还可以填写切换用户需要执行的指令
如果指令有很多条,可以使用  sh -c "多条指令"  来进行执行
 
 范例: 以 sshd 的身份在 /tmp 下面创建一个名为 mysshd 的文件
 $sudo -u sshd  touch /tmp/mysshd
 
 范例: 以 vbird1 的身份创建  ~vbird1/www 并在其中创建 index.html 文件.
 $sudo -u  vbird1  sh -c "mkdir ~vbird1/www ; touch ~vbird1/www/index.html"
 
```

#### 使用  visudo  来修改 /etc/sudoers 文件.(可执行sudo命令的用户列表)

除了 root 之外的其他帐号，若想要使用 sudo 执行属于 root 的 权限指令，则 root 需要先使用 visudo 去修改 /etc/sudoers ，让该帐号能够使用全部或部分的 root 指令功能 

visudo 也是调用 vi 来进行文件 /etc/sudoers 的编辑, 只不过有语法校验而已.

想开启或关闭某项功能, 可以在行首删除或添加  # 符号即可.

- **单一使用者可进行root 所有指令, 与 sudoers 文件语法:**
  - **使用 `$visudo`  命令,找到 `root ALL=(ALL)   ALL` 这一行, 然后按照下面格式进行添加.**
    - root  使用者账号,哪个账号可以使用sudo这个指令的意思.
    - ALL=(ALL)     登录者的来源主机名称或IP = (可切换的身份, ALL就是全部账号)
    - 最后的 `ALL`  则是可下达的指令.也可以写 绝对路径的命令.
      - 例如:  把passwd 这个命令给予 pro1 执行权限:
        - $visudo       
        - 输入:  `pro1     ALL=(root)   !/usr/bin/passwd, /usr/bin/passwd [A-Za-z]* , !/usr/bin/passwd  root  `
          - 上面输入表示,  pro1可以执行passwd A-Za-z 参数的命令,  但不可以执行 passwd 和 passwd root 这两种命令.   ! 表示不可以执行.
      - 例如: 让使用者(pro1 和 pro2)输入自己的密码 就可以变身成为  root . (危险)
        - $visudo
        - 输入以下两行内容 就可以了:    (可以保证 root 密码不外泄)
          -  `User_Alias  ADMINS = pro1, pro2 `
          - `ADMINS   ALL=(root)   /bin/su  -`
- **利用 wheel  群组来进行整个群组的成员sudo 权限添加.** (很危险)
  - **还是使用 $visudo 命令,找到  ` %whell   ALL=(ALL)  ALL`  这一行,然后按照下面格式进行添加**
    - %  代表后面跟的是群组.
    - whell   是一个群组,   可以自定义目前已存在的群组, 但是一定要注意权限.
    - 后面的其他内容和上面的一样.
- **免密码的功能处理,即可以无密码使用 sudo**
  - **还是使用 $visudo 命令,找到  ` %whell   ALL=(ALL)  ALL  NOPASSWD: ALL`  这一行**
  - 重点就是 NOPASSWD 这一行, 后面的 ALL 则代表所有指令.
- 使用别名来进行添加和设置,  很便捷
  - 使用 $visudo 命令 ,  进入到编辑界面,选择性的添加如下内容: (别名必须大写 )
    - `User_Alias  ADMPW  = 用户1, 用户2, 用户3`     #这是用户别名,添加用户时候使用, ADMPW 就是自定义的别名
    - `Comnd_Aias  ADMPWCON =  命令1,  命令2`   #这是命令别名,可以多个设置
    - `Hose_Alias   ADMHOST = IP地址或者主机名`   #来源主机名称别名



## 使用者的特殊 Shell  与 PAM 模块

因为系统帐号是不需要登陆的, 所以我们就给他这个`无法登陆`的`合法shell`   (` /sbin/nologin` )

`无法登录` 指的是:**系统帐号是不需要登陆的!所以我们就给他这个无法登陆的合法 shell**

但是这不妨碍系统账号使用其他系统资源.

系统账号是无法登录的, 当我们进行系统账号登录时会提示无法登录, 可以修改和创建 ` /etc/nologin.txt` 的内容来显示自定义的提示内容. `($su - mail )`

### PAM模块

PAM 可以说是一套应用程序接口 (Application Programming Interface, API)，他提供了一 连串的验证机制，只要使用者将验证阶段的需求告知 PAM 后， PAM 就能够回报使用者验证 的结果 (成功或失败)。

由于 PAM 仅是一套验证的机制，又可以提供给其他程序所调用引 用，因此不论你使用什么程序，都可以使用 PAM 来进行验证，如此一来，就能够让帐号密码 或者是其他方式的验证具有一致的结果 

PAM 用来进行验证的数据称为**模块 (Modules)**，每个 PAM 模块的功能都不太相同 

- 详细的模块信息
  - `/etc/pam.d/`*:每个程序相关的 PAM 配置文件;*
  - `/lib64/security/`* :PAM 模块文件的实际放置目录;*
  - `/etc/security/`*:其他 PAM 环境的配置文件;*
  - `/usr/share/doc/pam-*/`:详细的 PAM 说明文档 
  - `/lib64/secuurity/`;   模块实际存在的目录
  - `/var/log/secure ` 发生任何无法登录或是产生无法预期的错误时, PAM模块会将数据记录在这里



## Linux 主机上的使用者讯息传递 

### 查询使用者: **w, who, last, lastlog** 

```bash
$w					#目前谁在线,用的是什么终端,什么IP
 09:08:35 up  1:00,  1 user,  load average: 0.00, 0.01, 0.05
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU   WHAT
dmtsai   pts/0    192.168.2.2      08:09    3.00s  0.12s  0.03s  w

# 第一行显示目前的时间、开机 (up) 多久，几个使用者在系统上平均负载等;
# 第二行只是各个项目的说明，
# 第三行以后，每行代表一个使用者。如上所示，dmtsai 登陆并取得终端机名 pts/0(远程连线) 之意。

$who 	      #目前谁在线,什么终端,什么IP
dmtsai   pts/0        2019-11-07 08:09 (192.168.2.2)

$lastlog   # 会列出一张表,显示所有用户的最后一次登录日期
```

### 使用者互相通信: **write, mesg, wall**   

下面这三个命令只可以和在线的用户进行交谈和发送信息.

```bash
$write   使用者账号   [使用者所在的 tty 终端接口]      #不支持 pts 远程连线
		#执行会进入文本框,将要发送的内容输入进去,再使用 [crtl]+d  来结束输入,然后就会发送出去.
	  #执行这个指令的时候,会打断被连接人所做的工作,强制性弹出对话框. 很不好
			
			$mesg  n   #会进入如扰模式,阻止他人使用 write 给自己发信息, 但却无法阻止root
			$mesg  y   #会解除勿扰模式.
```

```bash
广播:
$wall    "广播内容,所有在线的人都会收到"
```

### 使用者邮件信箱: **mail** 

邮件都会放置在 /var/spool/mail 里面 ,一个账户 一个mail信箱.

```bash
寄信: 
$mail   -s "邮件标题"   账户名@IP地址或域名      #寄信,可以寄给本机人员或网络其他计算机人员
$mail   -s  "邮件标题"  账户名      #寄信, 只可以寄给本机用户
#命令输入后,会进入输入模式,可填写邮件内容,当写完邮件后,使用 [回车] . [回车]  来结束输入,并发送邮件
#这个时候就会退出 编辑模式,进入 标准的命令行模式.
#建议使用   < 数据重定向  或 管道 |  来进行邮件内容输入.
		$mail -s '标题'  pro  <  ~/.bashrc
		$echo ~/.bashrc | mail -s '标题' pro
		

收信:
$mail           #直接输入即可进入一个交互页面,
Heirloom Mail version 12.5 7/5/10.  Type ? for help.
"/var/spool/mail/pro3": 3 messages 2 new			  #共有三封邮件, 二封新邮件
    1 dmtsai                Thu Nov  7 09:41  20/613   "hello"
>N  2 dmtsai                Thu Nov  7 09:47  28/833   "标题"	 # > 表示目前处理的信件
 N  3 pro3@study.centos.vb  Thu Nov  7 09:48  18/606   "标题"  # N 表示新邮件
&               #这里会等待你进行输入, 输入 ? 会获得帮助.
动作: 
  h 数字  :列出表头,  h40  列出40封信件的邮件标题
  d 数字  :删除信件,  d10  删除第10封信件,  d10-20 删除10到20封信件
  s [数字] [文件名]  : 保存邮件到文件.   s 2 ~/mail   保存第2封邮件的内容到 ~/mail 文件中
  x    :或者 exit 也可以,  不保存任何更改,退出邮件, (例如删除错误的邮件时,可以用这个丢弃动作)
  q    :离开邮件, 但是会执行你所做的任何操作.
```



## Centos 7  环境下 大量创建账号的方法

### 账号相关的检查工具

```bash
$pwck    
#检查 /etc/passwd 这个帐号配置文件内的信息，与实际的主文件夹是否存在 等信息， 
# 还可以比对 /etc/passwd /etc/shadow 的信息是否一致，
# 另外，如果 /etc/passwd 内 的数据字段错误时，会提示使用者修订

$pwconv
#这个指令主要的目的是在“将 /etc/passwd 内的帐号与密码，移动到 /etc/shadow 当中
# 对手动设置账号很有帮助.
```

### 大量创建账号脚本 (适用 passwd --stdin 选项)

```bash
#!/bin/bash
# This shell script will create amount of linux login accounts for you.
# 1. check the "accountadd.txt" file exist? you must create that file manually.
#    one account name one line in the "accountadd.txt" file.
# 2. use openssl to create users password.
# 3. User must change his password in his first login.
# 4. more options check the following url:
# http://linux.vbird.org/linux_basic/0410accountmanager.php#manual_amount
# 2015/07/22    VBird
export PATH=/bin:/sbin:/usr/bin:/usr/sbin

# 0. userinput
usergroup=""                   # if your account need secondary group, add here.
pwmech="openssl"               # "openssl" or "account" is needed.
homeperm="no"                  # if "yes" then I will modify home dir permission to 711

# 1. check the accountadd.txt file
action="${1}"                  # "create" is useradd and "delete" is userdel.
if [ ! -f accountadd.txt ]; then
	echo "There is no accountadd.txt file, stop here."
        exit 1
fi

[ "${usergroup}" != "" ] && groupadd -r ${usergroup}		 #如果有输入.则创建系统群组
rm -f outputpw.txt
usernames=$(cat accountadd.txt)

for username in ${usernames}
do
    case ${action} in
        "create")
            [ "${usergroup}" != "" ] && usegrp=" -G ${usergroup} " || usegrp=""
            useradd ${usegrp} ${username}               # 新增帐号 或系统账号
            [ "${pwmech}" == "openssl" ] && usepw=$(openssl rand -base64 6) || usepw=${username}
            echo ${usepw} | passwd --stdin ${username}  # 创建密码
            chage -d 0 ${username}                      # 强制登录时修改密码
            [ "${homeperm}" == "yes" ] && chmod 711 /home/${username}
	    echo "username=${username}, password=${usepw}" >> outputpw.txt
            ;;
        "delete")
            echo "deleting ${username}"
            userdel -r ${username}
            ;;
        *)
            echo "Usage: $0 [create|delete]"
            ;;
    esac
done
```



## 小结

- Linux 操作系统上面，关于帐号与群组，其实记录的是 UID/GID 的数字而已;

- 使用者的帐号/群组与 UID/GID 的对应，参考 /etc/passwd 及 /etc/group 两个文件 
- /etc/passwd 文件结构以冒号隔开，共分为七个字段，分别是“帐号名称、密码、UID、 GID、全名、主文件夹、shell” 
- UID 只有 0 与非为 0 两种，非为 0 则为一般帐号。一般帐号又分为系统帐号 (1~999) 及可登陆者帐号 (大于 1000)
- 帐号的密码已经移动到 /etc/shadow 文件中，该文件权限为仅有 root 可以更动。
  - 该文件 分为九个字段，内容为“ 帐号名称、加密密码、密码更动日期、密码最小可变动日期、密码最大需变动日期、密码过期前警告日数、密码失效天数、 帐号失效日、保留未使用” 
- 使用者可以支持多个群组，其中在新建文件时会影响新文件群组者，为有效群组。而写 入 /etc/passwd 的第四个字段者， 称为初始群组 
- 与使用者创建、更改参数、删除有关的指令为:useradd, usermod, userdel等，密码创建 则为 passwd; 
- 与群组创建、修改、删除有关的指令为:groupadd, groupmod, groupdel 等; 
- 群组的观察与有效群组的切换分别为:groups 及 newgrp 指令;
- useradd 指令作用参考的文件有: /etc/default/useradd, /etc/login.defs, /etc/skel/ 等等 
- 观察使用者详细的密码参数，可以使用“ chage -l 帐号 ”来处理; 
- 使用者自行修改参数的指令有: chsh, chfn 等，观察指令则有: id, finger 等 
- ACL 的功能需要文件系统有支持，CentOS 7 默认的 XFS 确实有支持 ACL 功能!
- ACL 可进行单一个人或群组的权限管理，但 ACL 的启动需要有文件系统的支持;
- ACL 的设置可使用 setfacl ，查阅则使用 getfacl ;
- 身份切换可使用 su - ，亦可使用 sudo ，但使用 sudo 者，必须先以 visudo 设置可使用的 指令; 
- PAM 模块可进行某些程序的验证程序!与 PAM 模块有关的配置文件位于 /etc/pam.d/ 及 */etc/security/
  \* 
- 系统上面帐号登陆情况的查询，可使用 w, who, last, lastlog 等; 
- 线上与使用者交谈可使用 write, wall，离线状态下可使用 mail 传送邮件! 



```bash
在使用 useradd 的时候，新增的帐号里面的 UID, GID 还有其他相关的密码控制，都是在/etc/login.defs 还有 /etc/default/useradd 里面规定好的


我希望我在设置每个帐号的时候( 使用 useradd )，默认情况中，他们的主文件夹就含 有一个名称为 www 的子目录，我应该怎么作比较好?由于使用 useradd 的时候，会自动 以 /etc/skel 做为默认的主文件夹，所以，我可以在 /etc/skel 里面新增加一个名称为 www 的目录即可


由于种种因素，导致你的使用者主文件夹以后都需要被放置到 /account 这个目录下。 请 问，我该如何作，可以让使用 useradd 时，默认的主文件夹就指向 /account ?最简单的 方法，编辑 /etc/default/useradd ，将里头的 HOME=/home 改成 HOME=/account 即 可。

我想要让 dmtsai 这个使用者，加入 vbird1, vbird2, vbird3 这三个群组，且不影响 dmtsai 原本已经支持的次要群组时，该如何动作?usermod -a -G vbird1,vbird2,vbird3 dmtsai

```

