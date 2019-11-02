# Shell scripts

**shell scripts  程序化脚本, 就是针对 shell 所写的脚本.**

shell script 是利用 shell 的功能所写的一个“程序 (program)”，这个程 序是使用纯文本文件，将一些 shell 的语法与指令(含外部指令)写在里面， 搭配正则表达 式、管线命令与数据流重导向等功能，以达到我们所想要的处理目的 

shell script 提供数组、循环、条件与逻辑判断等重要功能 

she l l script 可以帮助系统管理员快速的管理好主机。 

**使用 ./shell.sh 脚本时,需要权限为 rx , 但是使用 `$sh shell.sh` 执行 脚本时,需要的权限就只有 r  .**

```bash
 $sh   -n  脚本.sh           #可以检查脚本的语法是否正确.
 $sh   -x  脚本.sh           #追踪脚本的语法
 
 在脚本内,可以通过使用  exit 数字  来自定错误信息的返回值.
 使用命令  $echo $?   就可以得到脚本执行完成后, exit 所返回的值
```

### script 的执行方式差异( source ,  sh script ,  ./script )

- **利用直接执行的方式来执行 script(脚本)** , `($bash she.sh )`
  - 执行的脚本是在一个新的 bash 内执行的,也就是子程序. (当子程序执行完成后,子程序内的各项变量动作将会结束, 而不会传回到父进程中.
- 利用 source  来执行脚本 : 在父进程中执行.  `($source  she.sh)`
  - 这个命令可以让脚本在当前进程的bash 中执行, 就像读取配置文件一样. 



#### shell script 脚本规范

```bash
#!/bin/bash
#Program:
#	This program shows "Hello World!" in tou screen.
#History:
#2019/11/1	VBird	First release

PATH=/bin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.utf8
export LANG

echo -e "Hello World! \a \n"
exit 0



#解释: 
#第一行  #!/bin/bash 是在宣告这个 script 所使用的 shell 名称,也就是要使用bash 运行
#第二行到最后一行#注释, 说明的是: 内容与功能,版本信息,作者与联络方式,创建日期,历史记录 等等.
# PATH 部分 主要环境变量和重要语言环境 信息.这个很重要
# echo 部分 才是主要的程序执行模块
# 使用 exit 数字  来进行返回值的错误信息传递.  可以用来检测错误.和 debug
		# 在外部,可以通过输入  $echo $?  来获得 exit 所传递的返回值. 
# 可以通过 $sh  脚本.sh  或者  $bash 脚本.sh  来执行这个脚本.(只要有 r读 权限就可以了)
```

- **在每个 script 的文件开始处记录好:** 
  - **script 的功能;** 
  - **script 的版本信息;** 
  - **script 的作者与联络方式;**
  -  **script 的版权宣告方式;**
  -  **script 的 History (历史纪录);**
  -  **script 内较特殊的指令，使用“绝对路径”的方式来下达;**
  -  **script 运行时需要的环境变量预先宣告与设置。** 
- **在较为特殊的指令代码部分, 务必加上注解和说明**



### 获取用户的输入,并放入一个变量 的脚本

```bash
 #!/bin/bash
 # Program:
 # User inputs his first name and last name. Program shows his full name.
 # History:
 # 2015/07/16    VBird    First release
 PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
read -p "Please input your first name: " firstname # 提示使用者输入
read -p "Please input your last name: " lastname # 提示使用者输入
echo -e "\nYour full name is: ${firstname} ${lastname}" # 结果由屏幕输出

# read -p 可以提示使用者一些信息
#echo -e  可以解释转义字符
```

### 创建3个文件, 以 前天,昨天,今天为文件名, 还可以自定义文件名开头

```bash
#!/bin/bash
# Program:
#	Program creates three files, which named by user's input and date command.
# History:
# 2015/07/16	VBird	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# 1\. 让使用者输入文件名称，并取得 fileuser 这个变量;
echo -e "I will use 'touch' command to create 3 files." # 纯粹显示信息
read -p "Please input your filename: " fileuser         # 提示使用者输 

# 2. 2\. 为了避免使用者随意按 Enter ，利用[变量功能] 分析文件名是否有设定
filename=${fileuser:-"filename"}           # 开始判断有否配置文件名,如果没配置则默认 filename
 
# 3\. 开始利用 date 指令来取得所需要的文件名了;
date1=$(date --date='2 days ago' +%Y%m%d)  # 前两天的日期
date2=$(date --date='1 days ago' +%Y%m%d)  # 前一天的日期
date3=$(date +%Y%m%d)                      # 今天的日期
file1=${filename}${date1}                  # 下面三行在配置文件名
file2=${filename}${date2}
file3=${filename}${date3}

# 4. 将文件名创建吧!
touch "${file1}"                           # 下面三行在创建文件
touch "${file2}"
touch "${file3}"
```



### 数值运算 :  简单的加减乘除  (整数)

```bash
#!/bin/bash
#Program
#	Read the two numbers input by the user and perform the operation
#History: 
#2019/11/01		ns		First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo -e "You SHOULD input 2 numbers, I will multiplying them! \n"
read -p "first number:  " firstnu
read -p "second number: " secnu
total=$((${firstnu}*${secnu}))
echo -e "\nThe result of ${firstnu} x ${secnu} is ==> ${total}"

# 解释 total 的等式 , 写成下面的样式,就可以进行运算了.
	#	 变量=((运算内容)) 	  #绝对不可以添加空格, 可以使用转义字符来添加空格.
	# 除了上面的办法,还可以使用 " declare -i total=${firstnu}*${secnu} "  来代替.

```

#### 数值运算:  通过 bc 来计算浮点数  (浮点数)

**可以通过使用 `bc` 命令来进行浮点数计算, 而 `bc`  就是一个 任意精度的浮点计算器 .**

```bash
#!/bin/bash
#Program:
#		User input a scale number to calculate pi number.
#History: 
#2019/11/01		ns		First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

read -p '计算到小数点后多少位 (10-10000): ' checking
num=${checking:-"10"}					# 开始判断有否有输入数值
time echo "scale=${num}; 4*a(1)" | bc -lq
		# scale 是要求 bc 计算小数点位数精度的数值,也就是计算小数点后几位
		#  4*a(1)  是给 bc 主动提供的一个计算pi(圆周率)的函数. 用来测试系统性能.
```



### test  指令的测试功能 (条件判断)

| 测试的标志 |                      代表意义                      |
| :--------: | :------------------------------------------------: |
|   |    **1.关于某个文件名的“文件类 型”判断，如 $test -e file  表示测试 file 文件是否存在**    |
|     -e     |               **该名称的文件是否存在,存在则返回true (常用)**               |
|     **`-f`**     |      **该“文件名”是否存在且为文件(file)?(常用)**      |
|     **`-d`**     |   **该“文件名”是否存在且为目录(directory)?(常 用)**   |
|     -b     |   该“文件名”是否存在且为一个 block device 设备?    |
|     -c     | 该“文件名”是否存在且为一个 character device 设 备? |
|     -S     |      该“文件名”是否存在且为一个 Socket 文件?       |
|     -p     |    该“文件名”是否存在且为一个 FIFO (pipe) 文件?    |
|     -L     |        该“文件名”是否存在且为一个链接文件?         |
|            |                                                    |
|            | **2. 关于文件的权限侦测，如 $test -r filename 表示可读否 (但 root 权限常有例外)** |
| -r | 侦测该文件名是否存在且具有“可读”的权限? |
| -w | 侦测该文件名是否存在且具有“可写”的权限? |
| -x | 侦测该文件名是否存在且具有“可执行”的权限? |
| -u | 侦测该文件名是否存在且具有“SUID”的属性? |
| -g | 侦测该文件名是否存在且具有“SGID”的属性? |
| -k | 侦测该文件名是否存在且具有“Sticky bit”的属性? |
| -s | 侦测该文件名是否存在且为“非空白文件”? |
|            |                                                    |
|            | **3. 两个文件之间的比较，如: test file1 -nt file2** |
| -nt | (newer than)判断 file1 是否比 file2 新 |
| -ot | (older than)判断 file1 是否比 file2 旧 |
| -ef | 判断 file1 与 file2 是否为同一文件，可用在判断 hard link 的判定上。 主要意义在判定，两个文件是 否均指向同一个 inode |
| |  |
| | **4. 关于两个整数之间的判定，例 如 test n1 -eq n2** |
| -ep | 两数值相等 (equal) |
| -ne | 两数值不等 (not equal) |
| -gt | n1 大于 n2 (greater than) |
| -lt | n1 小于 n2 (less than)   `$[ "${#}" -lt 2 ]` |
| -ge | n1 大于等于 n2 (greater than or equal) |
| -le | n1 小于等于 n2 (less than or equal) |
|  |  |
|  | **5. 判定字串的数据** |
| test -z string | 判定字串是否为 0 ?若 string 为空字串，则为 true |
| test -n string | 判定字串是否非为 0 ?若 string 为空字串，则为 false。 -n 亦可省略 |
| test str1 == str2 | 判定 str1 是否等于 str2 ，若相等，则回传 true |
| test str1 != str2 | 判定 str1 是否不等于 str2 ，若相等，则回传 false |
|  |  |
|  | **6. 多重条件判定，例如: test -r filename -a -x filename** |
| -a | (and)两状况同时成立!例如 test -r file -a -x file, 则 file 同时具有 r 与 x 权限时，才回传 true。 |
| -o | (or)两状况任何一个成立!例如 test -r file -o -x file，则 file 具有 r 或 x 权限时，就可回传 true。 |
| ! | 反相状态，如 test ! -x file ，当 file 不具有 x(可执行权限) 时，回 传 true |

```bash
 #!/bin/bash
# Program:
#    User input a filename, program will check the flowing:
#     测试文件或目录的存在,以及文件属性.
# 1.) exist? 2.) file/directory? 3.) file permissions
# History:
# 2015/07/16    VBird    First release
 PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
 export PATH
# 1\. 让使用者输入文件名，并且判断使用者是否真的有输入字串?
echo -e "Please input a filename, I will check the filename's type and permission. \n\n"
read -p "Input a filename : " filename
test -z ${filename} && echo "You MUST input a filename." && exit 0
# 2\. 判断文件是否存在?若不存在则显示讯息并结束脚本, 下面的指令便于判断,但不便于阅读.
test ! -e ${filename} && echo "The filename '${filename}' DO NOT exist" && exit 0
# 3\. 开始判断文件类型与属性
test -f ${filename} && filetype="regulare file"
test -d ${filename} && filetype="directory"
test -r ${filename} && perm="readable"
test -w ${filename} && perm="${perm} writable"
test -x ${filename} && perm="${perm} executable"
# 4\. 开始输出信息!
echo "The filename: ${filename} is a ${filetype}"
echo "And the permissions for you are : ${perm}"
```

### 利用判断符号  [ ]    进行数据判断

[ ] 中括号的使用方式和 $test 相同,  参数也可以适用.

**中括号 [ ] 中的空格是非常值得注意的.**

- 在中括号 [] 内的每个元素都需要有空白键来分隔 
- 在中括号内的变量 ,常数，最好都以双引号括号起来

```bash
$ name="VBird"
$[ "${name}" ==  "Vbird" ]    #空格是非常值得注意的地方
$ echo $?    #获得返回值,  条件成立 返回1, 不成立 则返回0

还可以使用 -o 参数 来链接多个判断条件
```

```bash
 #!/bin/bash
 # Program:
 #     This program shows the user's choice
 # History:
 # 2015/07/16    VBird    First release
 PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
 export PATH
read -p "Please input (Y/N): " yn
 [ "${yn}" == "Y" -o "${yn}" == "y" ] && echo "OK, continue" && exit 0
 [ "${yn}" == "N" -o "${yn}" == "n" ] && echo "Oh, interrupt!" && exit 0
 echo "I don't know what your choice is" && exit 0
```



### Shell script 的默认变量,( $0 ,$1 ...  类似于 C 的 char argv[])

**变量的功能是由 script 提供的**

- **`$0`  表示的是 运行脚本时使用的路径.  ** 调用:   ${0}
  - 使用命令  `$bash  ~/bin/a.sh`   运行脚本时,  $0 则显示为  /home/dmtsai/bin/a.sh
  - 使用路径来直接运行的话,  就会直接给出路径了.   ~ 会被翻译成从  根 开始的路径.
- **`$1`   表示在命令行执行时给出的第一个参数.** 剩下的依次排列下去即可.  调用 : ${1}  
- **`$#`**   表示 传入参数的总个数. 就是有多少个参数从命令行传入, 调用:  ${#}
- **`$@`**   表示所有的参数. ` echo ${@} `   会打印所有的传入参数 (从 $1 开始), "$1" "$2" "$3" ....
- **`$*`**   表示所有的参数 .  (从 $1 开始) ,  "$1 $2 $3 ...."  有空白键分隔.

```bash
#!/bin/bash
# Program:
#	Program shows the script name, parameters...
# History:
# 2015/07/16	VBird	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "The script name is        ==> ${0}"
echo "Total parameter number is ==> $#"
[ "$#" -lt 2 ] && echo "The number of parameter is less than 2.  Stop here." && exit 0
echo "Your whole parameter is   ==> '$@'"
echo "The 1st parameter         ==> ${1}"
echo "The 2nd parameter         ==> ${2}"
```



## 条件判断式

###  利用  if .....  then

#### 单层,简单的条件判定式

```bash
if  [ 条件判断式1 ] || [ 条件判断式2 ];   then				#if [这个当中还可以出现 &&AND  ||OR]
			这中间是 当判断式条件成立时, 可以进行的指令工作内容; 
fi	   #这个是结束 if 条件判断式的意思
```

#### 多重、复杂条件判断式 

```bash
#普通的形式
if [ 条件判断式 ]; then
      当条件判断式成立时，可以进行的指令工作内容;
else							# 这个后面是不可以出现 then 的.
   	当条件判断式不成立时，可以进行的指令工作内容;
fi


#更加复杂的情况
# 多个条件判断 (if ... elif ... elif ... else) 分多种不同情况执行
if [ 条件判断式一 ]; then
      当条件判断式一成立时，可以进行的指令工作内容;
elif [ 条件判断式二 ]; then									#elif 可以拥有非常多个.
	   当条件判断式二成立时，可以进行的指令工作内容;
elif [ 条件判断式三 ]; then
	   当条件判断式三成立时，可以进行的指令工作内容;
else
	   当条件判断式一与二和三均不成立时，可以进行的指令工作内容;
fi
```

#### 判断本主机的 21,22,25,80 端口服务是否已开放的脚本

```bash
#!/bin/bash
#Program:
#	network
#History:
#	2019/11/02	ns	First release
PATH=/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
																						#/dev/shm 这个目录的内容全在内存上,速度非常快
testfile=/dev/shm/netstat_checking.txt		  #将数据放到内存中.就不需要总是执行下面的命令了
netstat -tuln > ${testfile}					#这个命令会得到 目前已开放的服务的信息列表

testing=$(grep ":80" ${testfile})			#找到 80端口
if [ "${testing}" != "" ]; then		      #如果字符串非空, 则执行 then 下面的命令
	echo "WWW is runing in your system."
fi

testing=$(grep ":21" ${testfile})
if [ "${testing}" != "" ]; then
	echo "FTP is runing in your system."
fi

testing=$(grep ":22" ${testfile})
if [ "${testing}" != "" ]; then
	echo "SSH is runing in your system."
fi 

testing=$(grep ":25" ${testfile})
if [ "${testing}" != "" ]; then
	echo "MAIL is runing in your system."
fi
```



#### 计算退伍的天数

```bash
#!/bin/bash
# Program:
# You input your demobilization date, I calculate how many days before you demobilize.
# History:
# 2015/07/16    VBird    First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

read -p '输入退伍日期(YYYYMMDD): ' date2
date2=$(echo ${date2} | grep '[0-9]\{8\}')
#通过正则表达式来确认用户的输入.

if [ "${date2}" == "" ]; then
	echo "日期输入错误" ; exit 1
fi

date_dem=$(date --date="${date2}" +%s)    #退伍的那天距离19700101秒数
date_now=$(date  +%s)         #当前距离19700101秒数

date_d=$((${date_dem}-${date_now}))    #计算差,退伍-当前

date_d=$((${date_d}/60/60/24))	    #将秒换算成以日为单位的天数

#判断是否已退伍,还有天数.
if [ "${date_d}" -lt "0" ]; then
	echo  "你已经退伍了,并且过去了" $((-1*${date_d})) "天了." 
	exit 0
else
	echo "还需要 $date_d 天 ,才可以退伍 "
fi
```



### 利用  case  .... sac 判断

















