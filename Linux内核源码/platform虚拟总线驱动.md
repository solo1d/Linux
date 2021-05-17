- [platform虚拟总线驱动的好处](#platform虚拟总线驱动的好处)
- [源码和配套的Makefile](#源码和配套的Makefile)
- 





## platform虚拟总线驱动的好处

1. 把设备都挂接在一个 pseudo 总线上, 便于管理, 同时也符合Linux 的设备模型机制. 
   1. 其结果是,  配套的 sysfs 节点, 设备电源管理都成为可能.
2. 隔离设备和驱动.  
   1. 在BSP中定义platform 设备和它使用的资源, 设备的具体配置信息; 而在驱动中, 只需要通过 通用的API去获取资源和数据, 做到了BSP相关代码和驱动代码的分离, 使得驱动具有更好的可拓展性和跨平台性.



# 源码和配套的Makefile

```c
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/cdev.h>
#include <linux/fs.h>
#include <linux/wait.h>
#include <linux/poll.h>
#include <linux/sched.h>
#include <linux/slab.h>
#include <linux/platform_device.h>


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

#define LEDBASE 0x56000010
#define LEDLEN  0x0c

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
 
// 初始化
static  int hellodev_probe(struct platform_device* pdev){
  	 printk(KERN_INFO "hellodev_probe\n");
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


static int  hellodev_remove(struct platform_device* pdev){
	  printk(KERN_INFO "hellodev_remove \n");
    cdev_del (gDev);
  	kfree(gFile);
    kfree(gDev);
    unregister_chrdev_region(devNum, subDevNum);
    return 0;
}

static void hello_plat_release(struct device* dev){
  return ;
}

static struct resource hello_dev_resource[] = {
	[0] = {
		.start = LEDBASE,
		.end   = LEDBASE + LEDLEN - 1,
		.flags = IORESOURCE_MEM,
	}
};

// 平台设备的结构体
struct platform_device hello_device = {
	.name		  = "hello-device",
	.id		  = -1,
	.num_resources	  = ARRAY_SIZE(hello_dev_resource),
	.resource	  = hello_dev_resource,
	.dev = {
		.release = hello_plat_release,
    }
};

// 平台驱动的结构体
static struct platform_driver hellodev_driver = {
  .probe    = hellodev_probe,
  .remove   = hellodev_remove,    // 卸载平台时会执行这个函数
  .driver   = {
    .owner  = THIS_MODULE,
    .name   = "hello-device",
  },
};


int  charDrvInit(void){
  platform_device_register(&hello_device);   // 注册平台 设备的结构体
  return platform_driver_register(&hellodev_driver);  // 注册平台 驱动的结构体
}

void __exit charDrvExit(void){
  platform_device_unregister(&hello_device); // 先卸载设备
  platform_driver_unregister(&hellodev_driver);  // 再卸载驱动
  return ;
}

 module_init(charDrvInit);   // 声明了驱动的入口函数, 挂载
 module_exit(charDrvExit);   // 声明了驱动的出口函数, 卸载
 MODULE_LICENSE("GPL");     // 该源码的声明许可
```



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

