```makefile
#
# 这个文件就是命令  make menuconfig  出现的选项配置
# 如果要添加新的内容和选项, 那么就在这个 相应的目录进行添加, 而不是根目录的Kconfig文件


config HELLO                   #默认定义,与等同目录下的 Makefile 关联,是变量  $(CONFIG_TTY)
    tristate "hello device"   #是否开启了HELLO选项,有 M,Y,N 三种选择,tristate变成bool就是2种选择Y,N
    default y 	  						# y 则编译到内核, m 则编译成驱动, n 既不是内核也不是驱动, 默认选择y *
    ---help---								 #出现的描述字段
        hello device
if HELLO    #如果HELLO开启,就显示出下面的选项, 如果没开启就不显示

config VT
	bool "Virtual terminal" if EXPERT
	depends on !S390 && !UML
	select INPUT
	default y
	---help---
		  If you say Y here, you will get support for terminal devices with
endif      #HELLO
```

