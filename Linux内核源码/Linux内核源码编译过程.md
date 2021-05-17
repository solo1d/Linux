**Linux源码版本为4.9.229**



**源码编译需要 Makefile 的支持**

- [跳转到 Makefile语法](makefile语法)
  - [源码根目录的Makefile文件解读](#源码根目录的 Makefile文件解读)
    - [drivers中tty下Makefile解读](#drivers中tty下Makefile解读)
  - [Kconfig文件](#Kconfig文件)
  - [将built-in文件编译成完整的内核镜像](#将built-in文件编译成完整的内核镜像)
  - 





```make
# 执行如下命令编译内核, 再给出一个参数, 就可以得到  内核在编译的过程中, 编译和链接的细节信息
make V=1



```





## 源码根目录的Makefile文件解读

**顶层的Makefile文件通过 去 include 各个子目录里面的 Makefile文件就可以把整个内核源码全部囊括进来**

```makefile
262:  SRCARCH 	:= $(ARCH)     #设置处理器的体系结构, export ARCH=x86
546:  include arch/$(SRCARCH)/Makefile   #该代码去包含体系相关的 Makefile文件, 也就是调用

982:  export KBUILD_LDS          := arch/$(SRCARCH)/kernel/vmlinux.lds
     #链接文件, 指导编译器 将这些 built-in.o 文件, 链接成一个最终的内核镜像文件  .img
     
963:  vmlinux-dirs	:= $(patsubst %/,%,$(filter %/, $(init-y) $(init-m) \
		                    $(core-y) $(core-m) $(drivers-y) $(drivers-m) \
                		     $(net-y) $(net-m) $(libs-y) $(libs-m) $(virt-y)))
		#指明了 最终会链接的 built-in.o 文件所在的目录( 多个目录都有 built-in.o 文件)


967:  vmlinux-alldirs	:= $(sort $(vmlinux-dirs) $(patsubst %/,%,$(filter %/, \
		                     $(init-) $(core-) $(drivers-) $(net-) $(libs-) $(virt-))))
    #在所有指定文件内 寻找 built-in.o 文件


970: init-y		:= $(patsubst %/, %/built-in.o, $(init-y))   
#patsubst是Makefile内置函数, 判断init-y变量的内容 是否存在 '/' 符号, 如果存在就给init-y赋值 /built-in.o

971: core-y		:= $(patsubst %/, %/built-in.o, $(core-y))
972: drivers-y	:= $(patsubst %/, %/built-in.o, $(drivers-y))
973: net-y		:= $(patsubst %/, %/built-in.o, $(net-y))
974: libs-y1		:= $(patsubst %/, %/lib.a, $(libs-y))
975: libs-y2		:= $(patsubst %/, %/built-in.o, $(libs-y))
976: libs-y		:= $(libs-y1) $(libs-y2)
977: virt-y		:= $(patsubst %/, %/built-in.o, $(virt-y))

```



## drivers中tty下Makefile解读

```makefile
obj-$(CONFIG_TTY)		+= tty_io.o n_tty.o tty_ioctl.o tty_ldisc.o \  
				   tty_buffer.o tty_port.o tty_mutex.o tty_ldsem.o
     #$CONFIG_TTY 就是 Kconfig中的 TTY
obj-$(CONFIG_LEGACY_PTYS)	+= pty.o  #如果Kconfig中 LEGACY_PTYS配置defaule为y则将目标文件编译到内核
	       # 也就是说这个变量$(CONFIG_LEGACY_PTYS)  就等于 y,   obj-y += pty.o
obj-$(CONFIG_UNIX98_PTYS)	+= pty.o
obj-$(CONFIG_AUDIT)		+= tty_audit.o
obj-$(CONFIG_MAGIC_SYSRQ)	+= sysrq.o
obj-$(CONFIG_N_HDLC)		+= n_hdlc.o
obj-$(CONFIG_N_GSM)		+= n_gsm.o
obj-$(CONFIG_TRACE_ROUTER)	+= n_tracerouter.o
obj-$(CONFIG_TRACE_SINK)	+= n_tracesink.o
obj-$(CONFIG_R3964)		+= n_r3964.o

obj-y				+= vt/         # obj-y  代表编译近内核,  obj-m 代表编译成模块
obj-$(CONFIG_HVC_DRIVER)	+= hvc/  #通过递归的方式去调用这个目录下的 Makefile 文件
obj-y				+= serial/

# tty drivers
obj-$(CONFIG_AMIGA_BUILTIN_SERIAL) += amiserial.o
obj-$(CONFIG_BFIN_JTAG_COMM)	+= bfin_jtag_comm.o
obj-$(CONFIG_CYCLADES)		+= cyclades.o
obj-$(CONFIG_ISI)		+= isicom.o
obj-$(CONFIG_MOXA_INTELLIO)	+= moxa.o
obj-$(CONFIG_MOXA_SMARTIO)	+= mxser.o
obj-$(CONFIG_NOZOMI)		+= nozomi.o
obj-$(CONFIG_ROCKETPORT)	+= rocket.o
obj-$(CONFIG_SYNCLINK_GT)	+= synclink_gt.o
obj-$(CONFIG_SYNCLINKMP)	+= synclinkmp.o
obj-$(CONFIG_SYNCLINK)		+= synclink.o
obj-$(CONFIG_PPC_EPAPR_HV_BYTECHAN) += ehv_bytechan.o
obj-$(CONFIG_GOLDFISH_TTY)	+= goldfish.o
obj-$(CONFIG_DA_TTY)		+= metag_da.o
obj-$(CONFIG_MIPS_EJTAG_FDC_TTY) += mips_ejtag_fdc.o

obj-y += ipwireless/

#上面所有的 .o 文件的内容, 最后都会生成到一个 built-in.o 目标文件中,供内核链接使用
```







## Kconfig文件

```bash
#
# For a description of the syntax of this configuration file,
# see Documentation/kbuild/kconfig-language.txt.
#
# 这个文件就是命令  make menuconfig  出现的选项配置
# 如果要添加新的内容和选项, 那么就在这个 相应的目录中的 Kconfig 中进行添加, 而不是根目录的Kconfig文件
#    同时也要在 Makefile 文件中进行相应的修改和添加

config TTY         #默认定义,与等同目录下的 Makefile 关联,是变量  $(CONFIG_TTY)
	bool "Enable TTY" if EXPERT     #是否开启了 TTY 选项
	default y                       # y 则编译到内核, m 则编译成驱动, n 既不是内核也不是驱动
	---help---                      #出现的描述字段
	  Allows you to remove TTY support which can save space, and
	  blocks features that require TTY from inclusion in the kernel.
	  TTY is required for any text terminals or serial port
	  communication. Most users should leave this enabled.

if TTY    #如果TTY开启,就显示出下面的选项, 如果没开启就不显示

config VT
	bool "Virtual terminal" if EXPERT
	depends on !S390 && !UML
	select INPUT
	default y
	---help---
	  If you say Y here, you will get support for terminal devices with
	  display and keyboard devices. These are called "virtual" because you
	  can run several virtual terminals (also called virtual consoles) on
	  one physical terminal. This is rather useful, for example one
	  virtual terminal can collect system messages and warnings, another
	  one can be used for a text-mode user session, and a third could run
	  an X session, all in parallel. Switching between virtual terminals
	  is done with certain key combinations, usually Alt-<function key>.

endif # TTY   
```







## 将built-in文件编译成完整的内核镜像

```makefile
#源码根目录下 Makefile文件内容
982:  export KBUILD_LDS          := arch/$(SRCARCH)/kernel/vmlinux.lds
		#链接文件, 指导编译器 将这些 build-in.o 文件, 链接成一个最终的内核镜像文件  .img
		
#通过 ld 链接所有需要目录下的 build-in.o文件,来生成 vmlinux 这个内核镜像文件.

# 由 Makefile给出的, -o 最终镜像文件名, -T 使用的链接脚本, 
ld   \
   -m elf_x86_64 \
   -z max-page-size=0x200000 \
   --build-id -o vmlinux \
   -T .arch/x86/kernel/vmlinux.lds  \
   .arch/x86/kernel/head_64.o   # ... 等等很多的 .o  省略了
```

