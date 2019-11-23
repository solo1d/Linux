# 软件安装： 源代码与 Tarball
## 开放源码的软件安装与升级简介
当执行 make 时, make 会在当时的目录下搜寻 Makefile （ or makefile） 这个文本文件, 而Makefile 里面则记录了源代码如何编译的详细信息.
通常软件开发商都会写一支侦测程序来侦测使用者的作业环境, 以及该作业环境是否有软件开发商所需要的其他功能,该侦测程序侦测完毕后, 就会主动的创建这个 Makefile 的规则文件啦！ 通常这支侦测程序的文件名为 configure 或者是 config
- 侦测程序 `configure` 会侦测的数据:
  - 是否有适合的编译器可以编译本软件的程序码；
  - 是否已经存在本软件所需要的函数库, 或其他需要的相依软件；
  - 操作系统平台是否适合本软件:
    - 包括 Linux 的核心版本；核心的表头定义文件 （ header include） 是否存在 （ 驱动程序必须要的侦测）

**使用 `configure` 来创建Makefile 文件,并且确保成功,然后使用 `make` 来调用所需要的数据来编译即可.**


- Tarball 是一个软件包(tar.gz)， 你将他解压缩之后， 里面的文件通常就会有：
  - 原始程序码文件；
  - 侦测程序文件 （ 可能是 configure 或 config 等文件名） 
  - 本软件的简易说明与安装说明 （ INSTALL 或 README） 。
```bash 
yum groupinstall 'Development Toole'   #来安装所有的工具包
```
## make
**make 的功能是简化编译过程里面所下达的指令**
**make 主要调用的是makefile 文件**
```bash
创建一个 makefile 文件,格式如下

mian: main.o a.o b.o
	gcc -c main  mian.o a.o b.o  -lm

```
- 使用make 的好处如下
- 简化编译时所需要下达的指令；
- 若在编译完成之后， 修改了某个源代码文件， 则 make 仅会针对被修改了的文件进行编译， 其他的 object file 不会被更动；
- 最后可以依照相依性来更新 （ update） 可执行文件。

### makefile 基本语法与变量
- 基本语法
  - 在 makefile 当中的 # 代表注解；
  - <tab> 需要在命令行 （ 例如 gcc 这个编译器指令） 的第一个字符；
  - 标的 （ target） 与相依文件（ 就是目标文件） 之间需以“:”隔开。
- 变量语法
  - 变量与变量内容之间需要用'='分割,并且两边有空格 ( NUM = 123 )
  - 变量与变量内容 中都不允许出现 ':' 这个符号.
  - 变量左边不可以有 <tab> 空格.
  - 变量尽量用大写字母
  - 运用变量时， 以 ${变量} 或 $（ 变量） 使用.(建议使用第一种)
  - 在命令行界面也可以给予变量
  - $@  表示目前的标 (target)
```bash
在这个 makefile 中增加一个动作, clean 可以直接在 make 后面调用.
$vim  makefile

WALL = -Wall 
MAIN = main.o a.o b.o
main: ${MAIN}
	gcc -o $@  ${MAIN} ${WALL}   # $@表示的是 当前的标 main ,看成宏替换即可

clean:
	rm -f main main.o a.o b.o
	#作用是删除清除所有的 .o 和 可执行文件
#调用它: $make clean , 如果无参数调用make ,则默认使用第一个 main 进行动作.
```

### tarball  使用源代码管理软件所需要的基础软件
- gcc 或 cc 等 C语言编译器
- make 与 autoconfig , make依赖于 autoconfig 侦测系统之后生成的 makefile 文件.
- 需要 Kernel 提供的 Library 以及相关的 Include 文件：
  - 动态库一般在 `/lib` 或 `/lib64`  目录下面
  - 头文件在 `/usr/include` 目录下面
- 需要 Kernel 提供的 Library 以及相关的 Include 文件:

## Tarball 安装的基本步骤
1. 取得原始文件： 将 tarball 文件在 /usr/local/src 目录下解压缩；
2. 取得步骤流程： 进入新创建的目录下面， 去查阅 INSTALL 与 README 等相关文件内容（ 很重要的步骤！ ） ；
3. 相依属性软件安装： 根据 INSTALL/README 的内容察看并安装好一些相依的软件 （ 非必要 )
4. 创建 makefile： 以自动侦测程序 （ configure 或 config） 侦测作业环境， 并创建 Makefile这个文件；
  - 也就是执行目录下的 `./configure`  这个脚本, 如果不存在,那么就必然会有 Makefile 这个文件.
  - **使用 `./configure` 的话,一定要先使用 `./configure --help`来得到帮助,这是非常重要的**
    - **一般帮助都会提示给出 `--prefix=PREFIX` 这个范例,表明的是软件安装的目录,非常重要 **
5. 编译： 以 make 这个程序并使用该目录下的 Makefile 做为他的参数配置文件， 来进行make （ 编译或其他） 的动作；
6. 安装： 以 make 这个程序， 并以 Makefile 这个参数配置文件， 依据 install 这个标的（ target） 的指定来安装到正确的路径！
7. 这一步并非必要,需要按照 INSTALL 与 README 的说明来进行, 就是使用root来执行 `make install` 将编译好的可执行文件与配置文件都放入正确的目录内.

**自己安装的软件放置在 /usr/local 下， 至于源代码 （ Tarball）则建议放置在 /usr/local/src （ src 为 source 的缩写） 下面.**
**man 会去搜寻 /usr/local/man 里面的说明文档， 因此， 如果我们将软件安装在 /usr/local 下面的话， 那么自然安装完成之后， 该软件的说明文档就可以被找到了**


- 系统默认安装文件的放置路径
  - /etc/   配置文件
  - /usr/lib     函数库,动态库
  - /usr/bin     可执行文件
  - /usr/share/man    说明文档,帮助文档
- 自己安装的放置路径
  - /usr/local/etc    配置文件
  - /usr/local/bin    可执行文件
  - /usr/local/lib    函数库,动态库
  - /usr/local/man    说明文档,帮助文档

```bash
一个安装范例:   ntp 

#首先下载安装包
$wget  http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-4.2.8p13.tar.gz 

#解压到 /usr/local/src  这个目录就是用来存放源代码的
$tar -zxv -f ntp-4.2.8p13.tar.gz -C /usr/local/src/ntp-4.2.8p13

#进入该目录查看README 与 INSTALL 文件
$cd /usr/local/src/ntp-4.2.8p13 
$vim README
$vim INSTALL

#查看 configure 帮助并准备把这个新软件安装到 /usr/local/ntp 目录下
$./configure  --help       #这里的输出 会有一个提示的选项为  --perfix=PERFIX  这个就是安装目录配置
$mkdir /usr/local/ntp
$./configure  --perfix=/usr/local/ntp   #执行完成后会开始进行生成 makefile

#运行 make 来依据 makefile  进行编译
$make clean ; make

#进行编译之后的校验
$make check

#将编译完成的数据 放入到指定的目录中,也就是 /usr/local/ntp 下面
$make install

#完成
```

