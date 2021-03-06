- [内核的5大作用](#内核的5大作用)
- [驱动模块简介](#驱动模块简介)
  - [设备分类](#设备分类)
- [驱动模块编写](#驱动模块编写)
  - [驱动模块编写过程](#驱动模块编写过程)
  - [驱动模块使用命令](#驱动模块使用命令)
  - [字符设备驱动结构体描述](#字符设备驱动结构体描述)
    - [编写字符设备驱动所用到的函数](#编写字符设备驱动所用到的函数)
    - [一个简单字符设备驱动模版](#一个简单字符设备驱动模版)
      - [配套的Makefile模版](#配套的Makefile模版)
- [简单的字符设备驱动](#简单的字符设备驱动)
  - [配套的Makefile](#配套的Makefile)
  - [创建匹配的设备文件](#创建匹配的设备文件)
  - [C函数调用简单的字符设备驱动中的函数](#C函数调用简单的字符设备驱动中的函数)
  - [使用dmesg命令查看模块输出和日志](#使用dmesg命令查看模块输出和日志)
  - 







## 内核的5大作用

**内存管理,  进程的调度, 网络协议栈的支持, 文件系统的管理, 设备(驱动)管理.**

# 驱动模块简介

驱动是连接内核与设备的桥梁.

**设备驱动是由内核设备管理来控制的.由内核统一管理.**

驱动编写的规范也要符合内核提供的框架来写.

**模块是 linux内核进行组件管理的一种方式, 驱动是基于模块进行加载和删除的.**

**应用程序要通过`系统调用`操作硬件,  系统调用通过内核的`驱动管理`  找到对应的驱动, 然后调用驱动里面的方法去操作具体的硬件**

**需要一个通用的结构体来描述是三种设备所有的通信与信息.**

## 设备分类

- **字符设备**
  - 字符设备驱动   ---> 字符设备文件
  - I/O传输过程中 **以字符为单位** 进行传输
  - 用户对字符设备发出读/写请求时,实际的硬件 读/写操作 一般也紧跟着发生,**同步**的
  - **字符设备是最基本,最常用的设备. 它将千差万别的各种硬件设备采用一个统一的接口封装起来, 屏蔽硬件差异,简化了应用层的操作.**
  - eg(例如): LCD显示器, 鼠标, 键盘, 触摸屏....
  
- **块设备**
  
  - 块设备驱动   --->  块设备文件
  - 与字符设备相反, 数据传输以块(内存缓冲) 为单位传输,一般为 4K.
  - 用户对块设备读/写时, 硬件上的读/写操作不会紧接着发生,即用户请求和硬盘操作是**异步**的.
  - 磁盘类,闪存类 等设备封装成块设备.
  - eg(例如):  磁盘, usb闪存...
  
- **网络设备**
  
  - 网络设备驱动         (没有设备文件的)
  - 网络设备时一类特殊的设备, 不像字符设备或块设备那样通过对应的设备文件访问,也不能直接通过 read 或 write 进行数据请求,  而是通过 socket 接口函数进行访问.
  - eg(例如); 网卡..
  
  **设备文件: 字符设备和块设备有设备文件, 网络设备没有设备文件(使用socket通信).**

# 驱动模块编写

## 驱动模块编写过程

- **模块编写**

  - **需要添加 <linux/init.h> 和 <linux/module.h> 头文件,(在 内核源码/include/linux  目录下)**

  - 入口 (加载)

    - **宏**`module_init( 入口函数名 );`
      - **入口函数:**  ` int  __init  函数名(void);`
        - **`__init 的作用是; 将函数名统一的放到一个__init段里面,统一去加载`**

  - 出口 (卸载)

    - **宏**`module_exit( 出口函数名 );`
      - **出口函数:**`void  __exit  函数名(void);`

  - GPL协议申明

    - **宏**`MODULE_LICENSE("GPL");`

  - **一个范例模版**

    - ```c
      /* 文件名是 hello.c */
      #include <linux/init.h>
      #include <linux/module.h>
      
      int __init  demo_init(void){
              printk("init--%s--%s---%d---\n",__FILE__,__func__,__LINE__);
              return 0;
      }
      
      void __exit demo_exit(void){
              printk("exit--%s--%s---%d---\n",__FILE__,__func__,__LINE__);
      }
      
      module_init(demo_init);
      module_exit(demo_exit);
      MODULE_LICENSE("GPL");
      ```

- **驱动模块编译**

  - 使用 gcc 编译器,make ,内核源代码.

  - 使用内核的构建方法来构建内核模块

    - 编写 **编译内核模块的Makefile**
      - **内核模块编译的几种方法:**
        - `内部编译`  .将内核模块的源文件 放在内核源码中进行编译.(需要修改 Kconfig, Makefile, make menuconfig 这三个文件).
        - `外部编译`  .将内核模块的源文件 放在内核源码外进行编译
        - `动态编译`  .编译生成动态模块  xxx.ko 文件
        - `静态编译` . 将内核模块编译进 zbImage 或 uImage  内核镜像里面.

  - **编译过程**

    - **首先查看 `内核源码/Documentation/kbuild/modules.rst` 这个文档(有时也叫 modules.txt).**

      - 根据这个文档去写一个makefile文件, 来编译和构建一个内核模块. 里面还有一个范例. 	

    - **随后建立一个Makefile ,然后添加如下内容: **

      - ```bash
        KERDIR="/lib/modules/5.4.0ass/build/"     #内核源代码目录
        PWD:=$(shell pwd)							        #当前所在的目录,也是编写新驱动所在的目录
          
        obj-m:=hello.o	        	#.ko驱动是依赖于那些.o文件生成的.
        
        #编译工作. 会生成 .ko 驱动
        all:			
                   make -C ${KERDIR} M=$(PWD) modules
        
        #清理工作   
        clean:		
      						make -C ${KERDIR} M=$(PWD) clean                                                    
        ```
    
    - **完成Makefile文件之后,就可以执行 `$make` 进行编译, 这样就会生成 .ko 文件了.**

  

  

  ## 驱动模块使用命令

  - **查看内核模块信息 `$modinfo  模块.ko`**

    - ```bash
      # modinfo hello.ko 
      filename:       /root/test/hello.ko	    #文件名
      license:        GPL											#协议
      srcversion:     3380159E1CB4352256AAA4D  #版本说明
      depends:        												 #依赖
      retpoline:      Y
      name:           hello										 #作者
      vermagic:       5.4.0ass SMP mod_unload modversions 
      ```

  - **查看当前系统已经加载的内核模块 `$lsmod`**

    - ```bash
      #  lsmod
      模块名称							  	大小  被几个程序或驱动所使用以及依赖
      Module                  Size  Used by
      ip6t_rpfilter          16384  1 
      ip6t_REJECT            16384  2 
      nf_reject_ipv6         20480  1 ip6t_REJECT
      ```

  - **将模块加载到内核中,并予以运行 `$insmod`**

    - ```bash
      # insmod hello.ko          调用的是 demo_init 函数(hello.c 文件中的),只会执行一次
      ```

  - **查看内核的日志信息命令 `$dmesg` 可以用来查看内核模块加载是否正常**

    - ```bash
      # dmesg | grep -i 'hello'      #打印信息多,使用管道查看.
      # dmesg  -c                    #这个 -c 选项会清除内核的所有日志信息.
      输出:
      [ 7805.721165] init--/root/test/hello.c--demo_init---5---
      											文件名              函数名       行号
      说明, hello.c 这个文件的 demo_init函数的第5行执行了一次(这是写在hello.c中的).
      ```

  - **将内核模块卸载命令, `$rmmod hello`**  . 这个hello是模块名,不需要加后缀

    - ```bash
      # rmmod  hello             调用的是 demo_exit 函数(hello.c 文件中的),只会执行一次
      
      # dmesg | grep -i 'hello'       再查看一次
      [ 8372.945348] exit--/root/test/hello.c--demo_exit---9---
       这个输出内容也定义在 hello.c 中.
      ```



## 字符设备驱动结构体描述

**要遵循内核提供的 字符设备驱动框架**

- **描述所有字符设备驱动的结构体 `cdev` :**

  - ```c
    #include <linux/cdev.h>
    /* cdev 结构体原型, 在 内核源码/include/linux/cdev.h 文件中       */
    struct cdev {
    	struct kobject kobj;		/* 设备模型相关的内容 */
    	struct module *owner;   /* 设备驱动是属于哪个模块的,一般给 THIS_MODULE 当前模块*/
    	const struct file_operations *ops;   /* 这个结构体很重要, 下面给出原型--- */
    	struct list_head list;    /*  列表头,内核通过列表的形式来管理 cdev 和设备 */
    	dev_t dev;			/* 设备号,内核用来管理字符设备的唯一的标识符,很重要,下面给详解 */
    	unsigned int count;		/* 设备个数 */
    } __randomize_layout;
    
    
    
    /*-----------       dev_t dev;       -----------------*/
    /* dev是 内核用来管理字符设备的唯一的标识符,用来唯一标识设备的,数据类型是 32位无符号整型  */
    /* 定义在 内核源码/include/linux/types.h 文件中 */
    /* 设备号是内核的资源,在使用的时候必须进行注册或者分配一个设备号. */
    /* 组成是:  主设备号+ 次设备号  ,主设备号由高12位组成,次设备号由低20位组成 .
    			通过两个宏来分别提取设备号:   MAJOR( dev );   #从设备号 dev 中提取主设备号
    													      MINOR( dev );   #从设备号 dev 中提取次设备号
    			通过一个宏来生成主+次设备号:  MKDEV( int ma, int mi);
    			  这三个宏都定义在 内核源码/include/linux/kdev_t.h 文件中.
    */
    
    
    /*-----------       struct file_operations *ops       -----------------*/
    #include <linux/fs.h>
    /* const struct file_operations *ops; 的原型在 内核源码/include/linux/fs.h 文件中 */
    /* 这个结构体是操作方法集,驱动管理调用这些函数指针来操作硬件 */
    /* 这个操作方法集是提供给 应用层的 */
    struct file_operations {
    	struct module *owner;   /* 设备驱动是属于哪个模块的,一般给 THIS_MODULE 当前模块*/
    	loff_t (*llseek) (struct file *, loff_t, int);
    	ssize_t (*read) (struct file *, char __user *, size_t, loff_t *);
    	ssize_t (*write) (struct file *, const char __user *, size_t, loff_t *);
    	__poll_t (*poll) (struct file *, struct poll_table_struct *);
    	long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
    	int (*mmap) (struct file *, struct vm_area_struct *);
    	int (*open) (struct inode *, struct file *);
    	int (*release) (struct inode *, struct file *);
    	int (*fasync) (int, struct file *, int);
    } __randomize_layout;
    	/* 省略很多内容, 全都是函数指针, 上面都是一些常用的内容 */ 
    ```



## 编写字符设备驱动所用到的函数

0. **分配设备号, 注册设备号,注销设备号, 有以下两种方法任选其一即可:**

   1. **自动分配设备号**

      1. ```c
         #include <linux/cdev.h>
         /***************************************
          *功能:  自动分配设备号
          *参数:  @dev        传递 dev_t 类型定义的变量, 取地址传入.(不可以传递空指针)
          *	    @baseminor  次设备号起始,自己指定,一般给0就好
          *			@count      次设备的个数.一个驱动对应多个同类型的驱动.
          *			@name       设备号的名字.
          *返回值: 成功返回0. 失败返回 负值错误码
          ***************************************/
         int alloc_chrdev_region(dev_t *dev, unsigned baseminor, unsigned count, 
                                 const char *name)
         ```

   2. **指定设备号注册**

      1. ```c
         /***************************************
          *功能:  指定设备号注册
          *参数:  @from       设备号,使 MKDEV(major,minor) 宏去生成一个设备号,再传递进去.
          *			@count      次设备的个数.
          *			@name       设备号的名字.
          *返回值: 成功返回0. 失败返回 负值错误码
          ***************************************/
         int register_chrdev_region(dev_t from, unsigned count, const char *name)
         ```

   3. **注销设备号**

      1. ```c
         /***************************************
          *功能:  注销设备号, 无论是制定设备号还是自动分配设备号.
          *参数:  @from       已注册的设备号
          *			@count      注销多少个.
          *返回值: 无
          ***************************************/
         void unregister_chrdev_region(dev_t from, unsigned count)
         ```

      2. 

1. **cdev 结构体分配内存空间,使用函数 `cdev_alloc`,**

   1. ```c
      /****************************************
       *功能: 为 cdev 结构体分配空间,
       *返回值: 成功返回分配到的结构体地址,   
       *		   失败返回 NULL
       ******************************************/
      struct cdev* cdev_alloc(void);      
      
      ```

2. **初始化 cdev 结构体,使用函数 `cdev_init`**

   1. ```c
      /***************************************
       *功能: 初始化 cdev 结构体
       *参数:    @cdev    已分配空间的 cdev 结构体指针,
       *        @faps    操作方法集的指针.
       *返回值: 无
       ***************************************/
      void cdev_init(struct cdev* cdev, const struct file_operations* fops);
      ```

3. **添加(注册) 字符设备到内核中,由内核统一管理.**

   1. ```c
      /***************************************
       *功能: 添加(注册) 字符设备到内核中
       *参数:    @p      已分配空间并初始化完成的 cdev 结构体指针,
       *        @dev     已注册或分配的设备号.
       *	      @count   同时驱动 同类型的设备的个数
       *返回值:  成功返回0,  失败返回 负值错误码. 
       ***************************************/
      int cdev_add(struct cdev *p, dev_t dev, unsigned count);
      ```

4. **删除(注销) 字符设备**

   1. ```c
      /***************************************
       *功能: 添加(注册) 字符设备到内核中
       *参数:    @p      已分配空间并初始化完成的 cdev 结构体指针,
       *        @dev     设备号.
       *	      @count   同时驱动 同类型的设备的个数
       *返回值: 无
       ***************************************/
      void  cdev_del(struct cdev * p);
      ```

5. **初始化操作方法集**

   1. ```c
      #include <linux/fs.h>
      
      首先自定义提供给应用层调用的接口函数.( open , release,之类的),都是在全局下.
      int demo_open(struct inode* inode, struct file* filp){ 内容省略, 无所谓; };
      int demo_release(struct inode* inode, struct file* filp){ 内容省略,无所谓; };
      
      struct file_operations fops = { 
        	.owner = THIS_MODULE,        /* 前面的. 是结构体局部初始化 ,参数代表当前模块 */
          .open  = demo_open,
          .release = demo_release,
      };    /* 只初始化了一部分 */
      ```



## 一个简单字符设备驱动模版

```c
#include <linux/init.h>
#include <linux/module.h>
#include <linux/cdev.h>
#include <linux/fs.h>


#define  BASEMINOR 0        /*次设备号起始 */
#define  COUNT     3
#define  NAME      "chrdev_demo"

dev_t devno;                    /* 设备号*/
struct cdev* cdevp = NULL;       /* 描述字符设备驱动的结构体 */


int demo_open(struct inode* inode, struct file* filp){
	printk(KERN_INFO "---%s---%s---%d---\n",__FILE__,__func__,__LINE__);
	return 0;
}

int demo_release(struct inode* inode , struct file* filp){
	printk(KERN_INFO "---%s---%s---%d---\n",__FILE__,__func__,__LINE__);
	return 0;
}


struct file_operations fops = {  /* 初始化操作方法集, 这是提供供应用层的调用接口*/
	.owner	 = THIS_MODULE,
	.open    = demo_open,
	.release = demo_release,
};




static int __init  demo_init(void){
	int ret ;   /* 接收返回值的变量 */
	
	/* 0. 首先申请到设备号 */
	ret = alloc_chrdev_region(&devno, BASEMINOR,COUNT, NAME);
	if(ret < 0){
		printk(KERN_ERR "alloc_chrdev_region failed....\n");
		goto err1;
	}
	printk(KERN_INFO "major = %d \n",MAJOR(devno)); /*查看分配到的主设备号*/
	

	/* 1. cdev 结构体分配内存空间*/
	cdevp = cdev_alloc();
	if( cdevp == NULL ){	
		printk(KERN_ERR "cdev_alloc  failed..., mem\n");
		ret = -ENOMEM;
		goto err2;
	}
		
	/* 2. 初始化 cdev 结构体 */
	cdev_init(cdevp, &fops );

	/* 3. 添加字符设备到内核中,由内核统一管理*/
	ret = cdev_add(cdevp, devno, COUNT);
	if(ret < 0){
		printk(KERN_ERR "cdev_alloc  failed..., mem\n");
		goto err2;
	}

	printk("init--%s--%s---%d---\n",__FILE__,__func__,__LINE__);	
		return 0;
	
err2:	
	unregister_chrdev_region( devno, COUNT);
err1:
	return ret;

}
static void __exit demo_exit(void){
	cdev_del(cdevp);
	unregister_chrdev_region( devno, COUNT);

	printk("exit--%s--%s---%d---\n",__FILE__,__func__,__LINE__);	
}


module_init(demo_init);
module_exit(demo_exit);
MODULE_LICENSE("GPL");
```



## 配套的Makefile模版

```makefile
KERDIR="/lib/modules/5.4.0ass/build/"     #内核源代码目录

PWD:=$(shell pwd)	   #当前所在的目录,也是编写新驱动所在的目录
  
obj-m:=hello.o	        	#.ko驱动是依赖于那些.o文件生成的.
   
all:		
	make -C ${KERDIR} M=$(PWD) modules
	
clean:
	make -C ${KERDIR} M=$(PWD) clean 
```





## 简单的字符设备驱动

```c
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/cdev.h>
#include <linux/fs.h>
#include <linux/wait.h>
#include <linux/poll.h>
#include <linux/sched.h>
#include <linux/slab.h>

#define BUFFER_MAX   (10)
#define OK           (0)
#define ERROR        (-1)

struct cdev* gDev;
struct file_operations* gFile;
dev_t devNum;
unsigned int subDevNum = 1;
int reg_major = 232;  //主设备号
int reg_minor = 0;    //次设备号
char* buffer;
int flag = 0;

int hello_open(struct inode* p, struct file* f){
    printk(KERN_EMERG "hello_open\r\n"); // 会输出到 Linux的模块日志中, 使用 dmesg 命令查看
    return 0;
}

ssize_t  hello_write(struct file*f, const char __user* u,  size_t s, loff_t* l){
    printk(KERN_EMERG "hello_write\r\n");
    return 0;
}

ssize_t hello_read(struct file*f, char __user* u, size_t s, loff_t * l){
    printk(KERN_EMERG "hello_read\r\n");
    return 0;
}
 
 int hello_init(void){
     devNum = MKDEV(reg_major, reg_minor);   //通过一个宏来生成主+次设备号
     if(OK == register_chrdev_region(devNum, subDevNum, "helloworld")){ // 指定设备号注册
         printk(KERN_EMERG "register_chrdev_region ok\n");
     }
     else{
         printk(KERN_EMERG "register_chrdev_region error \n"); 
         return ERROR;
     }
     printk(KERN_EMERG "hello driver init \n");
     gDev = kzalloc(sizeof(struct cdev), GFP_KERNEL);
     gFile = kzalloc(sizeof(struct file_operations), GFP_KERNEL);
    gFile->open = hello_open;
    gFile->read = hello_read;
    gFile->write = hello_write;
    gFile ->owner = THIS_MODULE;
    cdev_init(gDev, gFile);
    cdev_add (gDev, devNum,1);
    return 0;
 }

void __exit hello_exit(void){
    cdev_del (gDev);
    unregister_chrdev_region(devNum, subDevNum);
    return ;
}

 module_init(hello_init);   // 声明了驱动的入口函数, 挂载
 module_exit(hello_exit);   // 声明了驱动的出口函数, 卸载
 MODULE_LICENSE("GPL");     // 该源码的声明许可
```

## 配套的Makefile

```makefile
ifneq ($(KERNELRELEASE),)
obj-m := helloDev.o
else
PWD := $(shell pwd)
#KDIR := /home/jinxin/linux-4.9.229
#KDIR := /lib/modules/4.4.0.31-generic/build
KDIR := /lib/modules/`uname -r`/build
all:
	make -C $(KDIR) M=$(PWD)
clean:
	rm -rf *.o *.ko *.mkd.c *.symvers *.c~ *~
endif
```



## 加载字符设备驱动模块到内核

```bash
make #编译出 .ko 内核驱动模块文件

sudo insmod hello.ko  #加载 hello.ko 模块到内核
sudo lsmod  | grep 'hello'    #检查模块是否被加载成功
sudo rmmod  hello      #卸载 hello 模块
```





## 创建匹配的设备文件

```bash
#使用命令  mknod 来创建 字符设备文件
mknod  /dev/hello  c 232 0
			# /dev/hello 设备名  
			# c 是字符设备  , b 是块设备
			# 232 是主设备号
			# 0 是次设备号
```



## C函数调用简单的字符设备驱动中的函数

```c
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/select.h>
#include <unistd.h>

#define DATA_NUM  (64)

int main(int argc, char* argv[]){
        int fd, i;
        int r_len, w_len;
        fd_set fdset;
        char buf[DATA_NUM] = "hello world";
        memset(buf, 0, DATA_NUM);
        fd = open("/dev/hello", O_RDWR);
        printf( " %d\r\n", fd);
        if(-1 == fd){
                perror("open file error\r\n");
                return -1;
        }
        else{
                printf("open successe\r\n");
        }

        w_len = write(fd, buf, DATA_NUM);  //最终会调用 设备驱动的 write函数
        r_len =  read(fd, buf, DATA_NUM);
        printf("%d   %d\r\n", w_len, r_len);
        printf("%s\r\n", buf);

        return 0;
}
```



## 使用dmesg命令查看模块输出和日志

```bash
dmesg     #查看模块输出和日志
dmesg -c  #清空所有 模块输出和日志
```









