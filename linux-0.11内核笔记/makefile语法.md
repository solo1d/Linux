

make
    gcc  - 编译器   (作用是 按照某种规则来编译代码)
    make - linux自带的构建器   (规则)
          构建的规则在 makefile 文件中.他指定了make 如何工作.

**makefile 文件 :  可以理解为脚本文件或配置文件,里面就是定义了一系列的规则.**



makefile 文件的命名方式 : (两种命名方式)
    makefile
    Makefile

makefile 中的规则:  (包含三部分 目标, 依赖, 命令)
    gcc a.c b.c c.c -o app;     
      // 目标是 生成 app
      // 依赖是 a.c b.c c.c 这些源文件 动态库 静态库之类的内容
      // 命令是 完整的shell 命令.  gcc a.c b.c c.c -o app  

 工作原理:
        1. 检查依赖文件是否存在:
           向下搜索下边的子规则,如果有子规则是用来生成查找的依赖的,就执行规则中的命令.
            2. 依赖存在, 判断是否需要更新:
           原则 : 目标时间(app) > 依赖的时间     不更新,反之   则更新.


makefile 排列关系和书写格式: (拥有一条或多条)
        
        目标:依赖  (换行)   
        (tab缩进)命令         //必须是一个tab, 不可以使用空格代替

第一版本: 

```makefile
app:a.c b.c c.c
	gcc a.c b.c c.c -o app
# 第一个版本的缺点 : 效率过低, 修改一个文件,所有文件会被全部重新编译.
```

第二版本:

```makefile
app:a.o b.o c.o
	gcc a.o b.o c.o -o app 
a.o:a.c
	gcc a.c -c -o a.o
b.o:b.c
	gcc b.c -c -o b.o
c.o:c.c
	gcc c.c -c -o c.o
# make由第二个命令开始执行, 第一条命令是最终目标,下面全是准备工作. 当第一个命令需要哪个参数的时候
# 就会向下寻找能够生成这个参数的命令,然后再继续查找. 
#      优点:当其中一个文件被修改的时候, 只有这个文件会被重新编译成.o, 其他的不用动, 非常有效率和节约时间.
#      缺点:代码冗余, 重复内容太多.
```


第三个版本:  

```makefile
obj = a.o b.o c.o
target = app
$(target):$(obj)
	gcc $(obj) -o $(target)
%.o:%.c
	gcc -c $< -o $@

# 详解: 最后这两行会被替换成(a.o, b.o c.o 挨个替换,当成公式看)
	# a.o:a.c
	#		gcc -c a.c -o a.o
# %号 就是通配符. 但是不可以出现在命令中.
# obj是脚本对象字符串,里面存储了 a.o b.o c.o         (makefile自带的变量是大写的,小心冲突)
# $(target)    表示取出 target 中的内容,当成*pt 指针.


# 自动变量:   下面的三个符号都只能在命令中使用 (gcc -c $< -o $%)
#		$@  规则中的目标 (上面就是a.o)
#		$<  规则中的第一个依赖(a.c)
#   $^  规则中的所有依赖 (a.c  ,因为只有这一个)
```



 第四个版本: (需要熟练的运用第三版)

```makefile
src = $(wildcard ./*.c)               # wildcard函数 会搜索后面参数目录下的所有.c文件,来返回
obj = $(patsubst %.c, %.o, $(src))    # patsubst函数 将src中的.c字符串,转换为.o 来返回  
target = app

$(target):$(obj)                      # 可移植性.
	gcc $^ -o $@
%.o:%.c
	gcc -c $< -o $@

# 缺点: 不能清理项目,  .o 文件很多 ,目录复杂, 无法清理.
```

​    

 第五个版本:  比版本四多编写一个清理项目的规则

```makefile
src = $(wildcard ./*.c)               # wildcard函数 会搜索后面参数目录下的所有.c文件,来返回
obj = $(patsubst %.c, %.o, $(src))    # patsubst函数 将src中的.c字符串,转换为.o 来返回  
target = app
$(target):$(obj)                      # 可移植性.
	gcc $^ -o $@
%.o:%.c
	gcc -c $< -o $@

.PHONY:clean           #声明 clean目标 为伪目标,  .PHONY是伪目标关键字语法.
clean:                 #清理项目规则,前面的 - 表示忽略执行失败的命令,继续向下执行其余命令.
	-rm $(obj) -f
```



 第六个版本: (多目录下的设置)

```makefile
path_in  = ./include
path_src = ./src
path_obj = ./obj
path_bin = ./bin

include arch/Makefile        # 包含另一个Makefile文件

temp_src = $(wildcard ${path_src}/*.c)
src = $(patsubst %.c, ${path_obj}/%.o,$(notdir ${temp_src}))

retget = app
main = ${path_bin}/${retget}

${main}:${src}
	gcc -g -o $@ ${src} -I${path_in} 

${path_obj}/%.o:${path_src}/%.c
	gcc -g -c $< -o $@  -I${path_in}

.PHONY:clean
clean:
	-rm -fr ${path_obj}/* ${path_bin}/*
```

