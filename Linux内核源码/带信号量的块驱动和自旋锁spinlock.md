- [信号量驱动源码](#信号量驱动源码)
- [内核原子变量驱动源码](#内核原子变量驱动源码)
- [自旋锁](#自旋锁)
- 





> **信号量用于进程之间的同步, 进程在信号量保护的临界区代码里是可以睡眠的, 这是和自旋锁的最大区别**



## 信号量驱动源码

**保护一段代码**

> - 信号量 semaphore 的特点:
>   - 允许进程和进程之间的同步
>   - 允许有多个进程进入临界区代码执行
>   - 进程获取不到信号量锁会陷入休眠, 并让出CPU
>   - **被信号量锁保护的临界区代码允许睡眠**
>   - 本质是基于进程调度器, UP(单核CPU) 和 SMP(多核CPU)下的实现无差异
>   - **不支持进程和中断之间的同步,  中断上下文是不会发生睡眠的**



**第二个进程会休眠**

```c
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/cdev.h>
#include <linux/fs.h>
#include <linux/wait.h>
#include <linux/poll.h>
#include <linux/sched.h>
#include <linux/slab.h>
#include <linux/semaphore.h>

#define BUFFER_MAX   (64)
#define OK           (0)
#define ERROR        (-1)

struct cdev* gDev;
struct file_operations* gFile;
dev_t devNum;
unsigned int subDevNum = 1;
int reg_major = 232;  //主设备号
int reg_minor = 0;    //次设备号
char buffer[BUFFER_MAX];
struct semaphore  sema;   //信号锁
int open_count = 0;    // 当前驱动只允许一个进程open


int hello_open(struct inode* p, struct file* f){
    down(&sema);    // 上锁  ,保护的是 open_count 变量
    if(open_count >= 1){
      up(&sema);
      printk(KERN_INFO "device is busy, hello_open fail" );
      return -EBUSY;
    }
    open_count++;
    up(&sema); // 释放锁
    printk(KERN_EMERG "hello_open ok\r\n"); // 会输出到 Linux的模块日志中, 使用 dmesg 命令查看
    return 0;
}

int hello_close(struct inode* inode, struct file* filp){
  if(open_count != 1){
    printk(KERN_INFO "something wrong, hello_close fail");
    return -EFAULT;
  }
  open_count--;
  printk(KERN_INFO "hello_clsoe ok\r\n");
  return 0;
}


ssize_t  hello_write(struct file*f, const char __user* u,  size_t s, loff_t* l){
    printk(KERN_EMERG "hello_write\r\n");
    int writelen = 0;
    writelen = BUFFER_MAX > s ? s : BUFFER_MAX;
    if(copy_from_user(buffer, u, writelen)){  // 从用户空间读取数据并拷贝到内核空间
      return -EFAULT;
    }
    return writelen;
}


ssize_t hello_read(struct file*f, char __user* u, size_t s, loff_t * l){
    printk(KERN_EMERG "hello_read\r\n");
    int readlen;
    readlen = BUFFER_MAX > s ? s : BUFFER_MAX;
    if(copy_to_user(u, buffer, readlen)){ // 从内核空间读取数据并拷贝到用户空间
       return -EFAULT;
    }
    return readlen;
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
    
   sema_init (&sema, 1);  // 初始化信号量锁, 共享资源设置为1
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



## 内核原子变量驱动源码

**就是一个共享值**

==**原子操作: 执行的时候,要么全部执行,要么都不执行, 不会被别的CPU打断, 不会被调度程序打断**==

**第二个进程不会陷入睡眠**

```c
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/cdev.h>
#include <linux/fs.h>
#include <linux/wait.h>
#include <linux/poll.h>
#include <linux/sched.h>
#include <linux/slab.h>
#include <linux/types.h>
#include <asm/atomic.h>
#include <asm/cmpxchg.h>


#define BUFFER_MAX   (64)
#define OK           (0)
#define ERROR        (-1)

struct cdev* gDev;
struct file_operations* gFile;
dev_t devNum;
unsigned int subDevNum = 1;
int reg_major = 232;  //主设备号
int reg_minor = 0;    //次设备号
char buffer[BUFFER_MAX];
static atomic_t can_open = ATOMIC_INIT(1);  // 原子变量 , 会等于1


int hello_open(struct inode* p, struct file* f){
    if( ! atomic_dec_and_test(&can_open)){   // 将can_open减1 等于0,无论是否得到了锁 ,原子操作
       // 下面是没有得到锁的线程所执行的代码
      printk(KERN_INFO "device is busy, hello_open fail"); 
      atomic_inc(&can_open);    // 将can_open +1, 恢复为0的状态  , 原子操作
      return -EBUSY;
    }
    printk(KERN_EMERG "hello_open ok\r\n"); // 会输出到 Linux的模块日志中, 使用 dmesg 命令查看
    return 0;
}

int hello_close(struct inode* inode, struct file* filp){
  atomic_inc(&can_open); 
  printk(KERN_INFO "hello_clsoe ok\r\n");
  return 0;
}


ssize_t  hello_write(struct file*f, const char __user* u,  size_t s, loff_t* l){
    printk(KERN_EMERG "hello_write\r\n");
    int writelen = 0;
    writelen = BUFFER_MAX > s ? s : BUFFER_MAX;
    if(copy_from_user(buffer, u, writelen)){  // 从用户空间读取数据并拷贝到内核空间
      return -EFAULT;
    }
    return writelen;
}


ssize_t hello_read(struct file*f, char __user* u, size_t s, loff_t * l){
    printk(KERN_EMERG "hello_read\r\n");
    int readlen;
    readlen = BUFFER_MAX > s ? s : BUFFER_MAX;
    if(copy_to_user(u, buffer, readlen)){ // 从内核空间读取数据并拷贝到用户空间
       return -EFAULT;
    }
    return readlen;
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
   
   spin_lock_init(&count_lock);  // 初始化
   
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





# 自旋锁

> - 自旋锁 spinlock 的特点:
>   - spinlock 是一种死等的锁机制
>   - semaphore 可以允许多个执行单元进入, 但 spinlock不行 , 一次只能有一个执行单元获取锁并进入临界区, 其他执行单元都是在门口不断的死等
>   - 执行时间短, 由于spinlock **死等** 这种特性, 如果临界区执行时间太长, 那么不断在临界区门口死等的 那些执行单元是多么浪费 CPU 啊
>   - 可以在中断上下文中执行. 由于不睡眠, 因此spinlock 可以在中断上下文中使用.

==**绝对不可以在 自旋锁的临界区内 调用睡眠函数 (sleep() 之类的)**==

**保证临界区代码 简短 高效**

```c
// spinlock系列函数
void spin_lock(spinlock_t* lock);  // 进程和进程之间的同步
void spin_lock_bh(spinlock_t* lcok);  // 涉及到和本地软中断之间的同步
void spin_lock_irq(spinlock_t* lock); // 涉及到和本地硬件中断之间的同步
void spin_lock_irqsave(lock, flags);  // 涉及到和本地硬件中断之间的同步并保存本地中断状态
int  spin_trylock(spinlock_t* lock);  // 尝试获取锁, 如果成功返回非0值, 否则返回零值
```



```c
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/cdev.h>
#include <linux/fs.h>
#include <linux/wait.h>
#include <linux/poll.h>
#include <linux/sched.h>
#include <linux/slab.h>
#include <linux/types.h>
#include <linux/spinlock_types.h>


#define BUFFER_MAX   (64)
#define OK           (0)
#define ERROR        (-1)

struct cdev* gDev;
struct file_operations* gFile;
dev_t devNum;
unsigned int subDevNum = 1;
int reg_major = 232;  //主设备号
int reg_minor = 0;    //次设备号
char buffer[BUFFER_MAX];

spinlock_t  count_lock;  // 自旋锁
int open_count = 0;


int hello_open(struct inode* p, struct file* f){
	spin_lock(&count_lock);
  if(open_count >= 1){
    spin_unlock(&count_lock);
    printk(KERN_INFO "device is busy, hello_open fail"); 
    return -EBUSY;
    }
  open_count++;
  spin_unlock(&count_lock);
    printk(KERN_EMERG "hello_open ok\r\n"); // 会输出到 Linux的模块日志中, 使用 dmesg 命令查看
    return 0;
}

int hello_close(struct inode* inode, struct file* filp){
	if(open_count != 1){
    printk(KERN_INFO "something wrong , hello_close fail");
    return -EFAULT;
  }
  open_count--;
  printk(KERN_INFO "hello_clsoe ok\r\n");
  return 0;
}


ssize_t  hello_write(struct file*f, const char __user* u,  size_t s, loff_t* l){
    printk(KERN_EMERG "hello_write\r\n");
    int writelen = 0;
    writelen = BUFFER_MAX > s ? s : BUFFER_MAX;
    if(copy_from_user(buffer, u, writelen)){  // 从用户空间读取数据并拷贝到内核空间
      return -EFAULT;
    }
    return writelen;
}


ssize_t hello_read(struct file*f, char __user* u, size_t s, loff_t * l){
    printk(KERN_EMERG "hello_read\r\n");
    int readlen;
    readlen = BUFFER_MAX > s ? s : BUFFER_MAX;
    if(copy_to_user(u, buffer, readlen)){ // 从内核空间读取数据并拷贝到用户空间
       return -EFAULT;
    }
    return readlen;
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
   
   spin_lock_init(&count_lock);  // 初始化
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



