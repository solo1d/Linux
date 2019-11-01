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



### 数值运算 :  简单的加减乘除

```bash




```

























