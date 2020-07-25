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
| **-r** | **侦测该文件名是否存在且具有“可读”的权限?** |
| **-w** | **侦测该文件名是否存在且具有“可写”的权限?** |
| **-x** | **侦测该文件名是否存在且具有“可执行”的权限?** |
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
| -eq | 两数值相等返回1 |
| -ne | 两数值不相等返回1 |
| **-gt** | **n1 大于 n2 (greater than)** |
| **-lt** | **n1 小于 n2 (less than)   `$[ "${#}" -lt 2 ]`** |
| -ge | n1 大于等于 n2 (greater than or equal) |
| -le | n1 小于等于 n2 (less than or equal) |
|  |  |
|  | **5. 判定字串的数据** |
| **test -z string** | **判定字串是否为 0 ?若 string 为空字串，则为 true** |
| test -n string | 判定字串是否非为 0 ?若 string 为空字串，则为 false。 -n 亦可省略 |
| **test str1 == str2** | **判定 str1 是否等于 str2 ，若相等，则回传 true** |
| **test str1 != str2** | **判定 str1 是否不等于 str2 ，若相等，则回传 false** |
|  |  |
|  | **6. 多重条件判定，例如: test -r filename -a -x filename** |
| -a | (and)两状况同时成立!例如 `test -r file -a -x file`, s则 file 同时具有 r 与 x 权限时，才回传 true。 |
| -o | (or)两状况任何一个成立!例如` test -r file -o -x file`，则 file 具有 r 或 x 权限时，就可回传 true。 |
| ! | 反相状态，如 `test ! -x file` ，当 file 不具有 x(可执行权限) 时，回 传 true |

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

- **`$0`  表示的是 运行脚本时使用的路径.** 调用: ${0}
  - 使用命令  `$bash  ~/bin/a.sh`   运行脚本时,  $0 则显示为  /home/dmtsai/bin/a.sh
  - 使用路径来直接运行的话,  就会直接给出路径了.   ~ 会被翻译成从  根 开始的路径.
- **`$1`   表示在命令行执行时给出的第一个参数.** 剩下的依次排列下去即可.  调用 : ${1}  
- **`$#`**   表示 传入参数的总个数. 就是有多少个参数从命令行传入, 调用:  ${#}
- **`$@`**   表示所有的参数. ` echo ${@} `   会打印所有的传入参数 (从 \$1 开始), "\$1" "\$2" "\$3" ....
- **`$*`**   表示所有的参数 .  (从 \$1 开始) ,  "$1 \$2 \$3 ...."  有空白键分隔.

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



### 利用  case  .... esac 判断

```bash
语法格式:				#类似于 switch (变量)     case 变量:   default :
case $变量名称  in				#关键字 case , 还有变量前有 $ 符号
  "第一个变量内容")        #每个变量内容建议用双引号括起来，关键字则为小括号)
  	程序段
  ;;										#每个程序段结束,都必须要用 ;; 两个分号来处理.
  "第二个变量内容")
  	程序段
  ;;
  *)										#类似于 C 的 default
  不包含第一个变量内容与第二个变量内容的其他程序执行段
  exit 1
  ;;	
esac					#case 判断结束标志, 就是反过来写
```

- `case  $变量  In`    这个语法中, 中间的` $变量 `有两种取得方式:
  - **直接下达式 ,   直接给予 ${1} 这个变量的内容 (也是主要设计的方式)**
  - **互动式 ,  通过  read 这个指令来让使用者输入变量的内容.**

```bash
 #!/bin/bash
 # Program:
 # Show "Hello" from $1.... by using case .... esac
 # History:
 # 2015/07/16    VBird    First release
 PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
 export PATH
 case ${1} in
	  "hello")
	     echo "Hello, how are you ?"
	     ;;
     "")
	     echo "You MUST input parameters, ex&gt; {${0} someword}"
	     ;;
	   *)    # 其实就相当于万用字符，0~无穷多个任意字符之意!
	     echo "Usage ${0} {hello}"
	     ;;
esac
```

```bash
#!/bin/bash
#Program:
#	This: script only accepts the flowinig parameter: one, two, or three
#History:
#	2019/11/03	VBird	Fiirst release

PATH=/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:/bin:/sbin
export PATH

echo "只可以输入 one two three"
read -p "Please input number : " number

case ${number} in
  "one")
  	echo "user input  one"
	;;
  "two")
  	echo "user input  two"
	;;
  "three")
  	echo "user input three"
	;;
  *)
  	echo "only input one | two | three"
	;;
esac
```



### 利用 function  功能

```bash
function fname() { 			#和C的函数没区别,里面还可以有参数,在函数内可以使用 $1 来得到第一个参数
 	程序段							    # 参数 $0 就是函数名,   这里和函数外的 $0脚本名 是不一样的.
}

调用         带参数调用(参数是 1)
fname		     fname 1 
```

```bash
#!/bin/bash
# Program:
#	Use function to repeat information.
# History:
# 2015/07/17	VBird	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

function printit(){
	echo "Your choice is ${1}"   # 这个 $1 必须要参考下面指令的下达,也就是第一个函数参数. 
}

echo "This program will print your selection !"
case ${1} in
  "one")
	  printit 1        #注意， printit 指令后面还有接参数!
	  ;;
  "two")
	  printit 2		    #当输入是 two 时,会输出 Your choice is 2 
	  ;;
  "three")
	  printit 3
	  ;;
  *)
	  echo "Usage ${0} {one|two|three}"
	  ;;
esac
```



## 循环 (loop)

**循环 分为 `不定循环`和`固定循环` 两种.**

### while do done ,   until do done  (不定循环)

```bash
while  [ 条件判断式 ]				#当条件成立时, 则进入循环
do                 #代表循环开始, 可以看成 { 表示循环体开始
	  程序代码段
done	             #代表循环结束, 可以看成 } 表示循环体结尾
```

```bash
until   [ 条件判断式  ]     #和 while 相反, 当条件不成立时,就进入循环
do
	  程序代码段
done
```

##### while  循环脚本

```bash
#!/bin/bash
# Program:
# Use loop to calculate "1+2+3+...+100" result.
# History:
# 2015/07/17    VBird    First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
sum=0
i=1
while [ "${i}" != "101" ]
do
	sum=$(($sum+${i}))
	i=$((${i}+1))
#	echo "sum = " ${sum} " i = " ${i}
done
echo " 计算结束 sum = " ${sum} " i = " ${i}
```

##### until  循环脚本

```bash
#!/bin/bash
#Program:
#	program of user input YES or yes to stop 
#History:
#	2019/11/03	ns	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

read -p "Please input yes OR YES  to stop program:"  comit
until [ "${comit}" == "YES" -o "${comit}" == "yes" ]
do
	read -p "Please input yes OR YES:" comit
done
```



### for ... do ... done  (固定循环)

```bash
for   var in con1 con2  con3 .....   #var 是变量, 可以不需要 $来解释, 
do	                             #后面 con1 是每次循环后 var 被赋予的值. (也可以是变量)
	程序段
done
```

```bash
#!/bin/bash
# Program
#       Use id, finger command to check system account's information.
# History
# 2015/07/17    VBird   first release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
users=$(cut -d ':' -f1 /etc/passwd)    # 摘取账号名称
for username in ${users}               # 开始循环. 每次从users提取一行,赋值给 username
do		                                   #当username 最后一行被读取并且完成后,就结束循环
        id ${username}								#id 命令会输出 该用户的 UID等信息.
done
```

```bash
#!/bin/bash
#Porgram:
#	Use ping command to check the network`s PC state
#History:
#	2019/11/03	ns	First release

PATH=/bin:/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:~/bin
export PATH

network="192.168.0"

#命令 seq 是连续命令,会输出 100 到200 之间的数字,每个占一行
#除 seq之外,还可以使用 bash 内置机制代替:  {100..200} 也是同样的输出
# for sitenu in  {100..200}   #效果相同.  ( $echo  {100..200} )
for sitenu in 	$(seq 100 200)
do
	#下面在取得 ping 的回传值是正确的还是失败的
	ping -c 1 -w 1 ${wetwork}.${sitenu} &> /dev/null && result=0 || result=1
	#开始显示结果是正确的启动(UP) 还是错误的没有链接 (DOWN)
	if [ "${result}" == 0 ]; then
		echo "Server ${network}.${sitenu} is UP."
	else
		echo "Server ${network}.${sitenu} is DOWN."
	fi
done
```

```bash
#!/bin/bash
#Program:
#
#History:
#	2019/11/03	ns	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

read -p "Please file name or dirname: " name

#测试输入是否 为空, 以及 该目录是否存在 -d  !表示非,存在会返回1的.
if [ "${name}" == "" -o ! -d "${name}" ]; then
	echo "你的系统不存在 ${name} 目录"
	exit 1
fi

#开始测试文件,   通过ls 命令来得到 该目录下的文件名称
filelist=$(ls ${name})
for filename in ${filelist}
do
	perm=""
	test -r "${dir}/${filename}" && perm="${perm} readable"
	test -w "${dir}/${filename}" && perm="${perm} writeable"
	test -x "${dir}/${filename}" && perm="${perm} execuutable"
	echo "The file ${dir}/${filename}\`s permission is ${perm} "
done
```

### for ... do .. done   的数值处理

```bash
另一种写法:
for   (( 初始值  ; 限制值  ; 执行步阶 )) #例如 for (( i=1;i<10;i=i+1 ))
do
		程序段
done
```

```bash
#!/bin/bash
#Program:
#	try do calculate 1+2+....+${your_input}
#History:
#	2019/11/03	ns	First release

 PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
  export PATH

  read -p "Please input a number, I will count for 1+2...+your_iinput: " nu

  s=0
  for(( i=1; i<=${nu};i++))
  do
	s=$((${s}+${i}))
  done
  echo  "The result of '1+2+3+...+${nu}' is  ==> ${s}"
```

#### 搭配乱数与阵列的实验

```bash
#!/bin/bash
# Program:
# 	Try do tell you what you may eat.
# History:
# 2015/07/17	VBird	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
eat[1]="卖当当漢堡包"
eat[2]="肯爷爷炸鸡"
eat[3]="彩虹日式便当"
eat[4]="越油越好吃大雅"
eat[5]="想不出吃啥学餐"
eat[6]="太师父便当"
eat[7]="池上便当"
eat[8]="怀念火车便当"
eat[9]="一起吃方便面" 
eatnum=9

eated=0
while [ "${eated}" -lt 3 ]; do
  check=$(( ${RANDOM} * ${eatnum} / 32767 + 1 ))
  mycheck=0
     if [ "${eated}" -ge 1 ]; then
      for i in $(seq 1 ${eated} )
          do
          #if [ ${eatedcon[$i]} == $check ]; then
	  if [ ${eatedcon[$i]} == $check ]; then
              mycheck=1
	  fi
      done
      fi
      if [ ${mycheck} == 0 ]; then
          echo "your may eat ${eat[${check}]}"
          eated=$(( ${eated} + 1 ))
          eatedcon[${eated}]=${check}
       fi
done
```



## Shell script  的追踪与 debug

```bash
$sh   [-nvx]  script脚本.sh        #实际sh 是符号链接,它链接到 bash 程序(软连接,有l )
选项与参数:
 -n :不要执行 script，仅查询语法的问题, 如果没有问题,则什么都不会显示.
 -v :执行 script ，并且先将 scripts 的内容输出到屏幕上;
 -x :执行 script 并且将使用到的 script 内容显示到屏幕上，这是很有用的参数!

范例: 将 show_animal.sh 的执行过程全部列出来.
$sh  -x show_animal.sh
出现 + 号,则代表的是指令串.
```



## 小结

- shell script 是利用 shell 的功能所写的一个“程序 (program)”，这个程序是使用纯文本 文件，将一些 shell 的语法与指令(含外部指令)写在里面， 搭配正则表达式、管线命令与数据流重导向等功能，以达到我们所想要的处理目的
- shell script 用在系统管理上面是很好的一项工具，但是用在处理大量数值运算上，就不够好了，因为 Shell scripts 的速度较慢，且使用的 CPU 资源较多，造成主机资源的分配不良。
- 在 Shell script 的文件中，指令的执行是从上而下、从左而右的分析与执行;
- shell script 的执行，至少需要有 r 的权限，若需要直接指令下达，则需要拥有 r 与 x 的权限; 
- 良好的程序撰写习惯中，第一行要宣告 shell (#!/bin/bash) ，第二行以后则宣告程序用 途、版本、作者等
- 对谈式脚本可用 read 指令达成;
- 要创建每次执行脚本都有不同结果的数据，可使用 date 指令利用日期达成;
- script 的执行若以 source (就是 $source 命令)来执行时，代表在父程序的 bash 内执行之意! 
- 若需要进行判断式，可使用 test 或中括号 ( [  ]  ) 来处理;
- 在 script 内，$0, $1, $2..., $@ 是有特殊意义的!
  - $0  是运行脚本时所使用的脚本路径
  - $1  是运行脚本前  所写在后面的第一个参数
  - `$#` 参数的总个数 ,从`$1` 开始计算
  - $@ 代表所有的输入参数.
- 条件判断式可使用 if...then 来判断，若是固定变量内容的情况下，可使用 case $var in ... esac 来处理
- 循环主要分为不定循环 (while, until) 以及固定循环 (for) ，配合 do, done 来达成所 需任务!
- 我们可使用 sh -x script.sh 来进行程序的 debug 
