# 文件搜索命令 \(which, whereis, locate, find\)

### 命令文件名搜寻以及默认别名 $which

```bash
$which  后面跟在 PATH 变量中的程序名. Bash内置的指令是搜寻不到的.
```

### 搜寻特定目录下的文件 $whereis

```bash
搜寻特定目录下的文件   $whereis  参数  文件名
        参数: -l  :列出 whereis命令会去查询的几个主要目录.
             -b   :只找 binary "可执行文件" 格式的文件,针对 "/bin/sbin"
             -m   :只找在说明文档 manual 路径下的文件
             -s   :只找 source "源文件 /usr/src/ 目录" 来源文件.
```

### 利用数据库来搜索文件名 $locate

```bash
利用数据库来搜索文件名  $locate  参数  文件名
        参数:  -i  :忽略大小写的差异.
              -c   :不输出文件名, 仅计算找到的文件数量.
              -l   :仅输出几行的意思, 后面跟着数量,  "$locate -l 5 passwd "
              -S   :输出 locate 所使用的数据库文件的相关信息,包括该数据库记录的文件/目录数量等.
              -r   :后面可接正则表达式的显示方式.
    利用的数据库是 /var/lib/mlocate 数据库文件.
    因为搜寻的是数据库,所以有可能需要进行数据库更新, 命令是  $sudo updatedb   
    updatedb 会根据 /etc/updatedb.conf 的设置去搜寻系统硬盘内的文件名,并更新 /var/lib/mlocate 内的数据库文件

```

### 硬盘文件搜索命令: $find

```bash
硬盘文件搜索命令:  $find  路径  选项  参数
  选项和参数: 
       -a  :是and 的意思,可以连续使用两次相同的 选项, "$find / -size +50k -a -size -60k"
       !   :取后面条件反向之意(前面要有 -a).   "$find /etc -size 50k -a ! -user root \; 
                                            文件大于50k ,并且文件所属人 不是root "
       -o  :是 or 的意思,和sql 语句相似.
  1.与时间相关的选项和参数:
       -mtime  n  :n天之前的 "那一天" 被改动过内容的文件
       -mtime  +n  :n天之前的被改动过内容的文件,不包括n天本身
       -mtime  -n  :n天之内被改动过内容的文件名
       -mmin   +n  :n分钟之前被改动过内容的文件名
       -mmin   -n  :n分钟之后被改动过内容的文件名
       -newer  文件名 : 为一个存在的文件, 列出比 此文件还要新的文件 文件名.
             "例: $find / -mtime 0   #将过去系统上面24小时内有改动过内容的文件列出"
             "    $find / -mtime 3   #3天前的24小时内有变动过的文件"
             "    $find / -mtime -3  #3天内被改动过的文件的文件名"
             "    $find / -mtime +3  #大于3天前的被改动过的文件名,所有大于3天的"
   2.与使用者或群组名称有关的选项和参数:
       -uid n  :n是数字,这个数字是使用者的账号 ID,就是 UID,记录在/etc/passwd
       -gid n  :n是数字, 对应组群名称ID,就是GID, 记录在 /etc/group
       -user name  : name 为使用者账号名称 !例如 pi
       -group name : name 为群组名称.
       -nouser  :寻找文件的拥有者不存在 /etc/passwd 的人.
       -nogroup :寻找文件的拥有群组不存在于 /etc/group 的文件.
  3.文件权限及名称有关的选项和参数:
       -name filename  :搜寻文件名称为 filename 的文件.
       -size [+-]SIZE  :搜寻比SIZE要大(+) 还是小(-) 的文件,
                         SIZE的规格有: c 表示字节,k表示kb. (-size +50K #比50kb大的文件)
       -type TYPE      :搜寻文件类型为 TYPE 的. 类型主要有 : FIFO(p), 普通文件(f),
                             设备文件(b,c), 目录(d), 链接文件(l), ssocket(s)
       -perm mode    :搜寻文件权限刚好等于mode的文件, (0742或者rwxr-x--x)
       -perm -mode   :搜寻文件必须全部囊括mode的权限的文件, (7777 会将所有其他权限的文件都列出来)
       -perm /mode   :搜寻的文件 有其中任意一个权限和mode相同,就会列出来.
  4.额外可进行的动作 选项和参数:
       -exec command  :command为其他指令, -exec 后面可再接额外指令来处理搜寻到的结果.
       -print         : 将结果打印到屏幕上,  这个是默认动作,不用加.
         
         " 例子  $find / -perm /7000 -exec ls -l {} \;   
            {}表示find搜索到的结果, \; 表示额外动作结束符号, -exec 表示开始额外动作 "
        
        " /etc 下,文件大小 介于50k 到 60k 之间的文件, 并且将权限完整列出.
            $find /etc -size +50k -a -size -60k -exec ls -lh {} \;"
            
        "查找当前目录下的今天新建和修改过内容的文件拷贝到一个指定目录"
         $find ./ -mtime 0 


# 搜索24小时之前的文件  (24*60=1440分钟) ，并删除
find ./  -mmin +1440 -type f  -exec rm -rf {} \;

```



