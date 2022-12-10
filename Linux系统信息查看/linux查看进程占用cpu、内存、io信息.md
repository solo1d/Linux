# linux查看进程占用cpu、内存、io信息

- [top](#top)
- [/proc/pid目录](#/proc/pid目录)
- [内存](#内存)
- [CPU](#CPU)
- [IO](#IO)







### top

**top**命令是**Linux**下常用的性能分析工具，能够实时显示系统中各个进程的资源占用状况，类似于**Windows**的任务管理器

**内容解释：**

- PID：进程的ID
- USER：进程所有者
- PR：进程的优先级别，越小越优先被执行
- NInice：值
- VIRT：进程占用的虚拟内存
- RES：进程占用的物理内存
- SHR：进程使用的共享内存
- S：进程的状态。S表示休眠，R表示正在运行，Z表示僵死状态，N表示该进程优先值为负数
- %CPU：进程占用CPU的使用率
- %MEM：进程使用的物理内存和总内存的百分比
- TIME+：该进程启动后占用的总的CPU时间，即占用CPU使用时间的累加值。
- COMMAND：进程启动命令名称



**常用的命令：**

- P：按%CPU使用率排行
- T：按TIME+排行
- M：按%MEM排行



### /proc/pid目录

获取程序pid

```bash
lsof -i:3306
```



假如获取的`mysql`的`pid`为`3779` 

那么获取内存使用情况

```bash
cat /proc/3779/status | grep VmRSS
```



可以进入这个目录查看可用信息

```bash
cd /proc/3779/
ls -l
```



**常用（N为进程的pid）**

文本(可用cat查看)

- **/proc/N/cmdline** 进程启动命令
- **/proc/N/environ** 进程环境变量列表
- **/proc/N/stat** 进程的状态
- **/proc/N/statm** 进程使用的内存的状态
- **/proc/N/status** 进程状态信息,比**stat/statm**更具可读性

链接(所在目录中用`ls -l`查看)

- **/proc/N/cwd** 链接到进程当前工作目录
- **/proc/N/exe** 链接到进程的执行命令文件
- **/proc/N/root** 链接到进程的根目录



## 内存

1) 消耗内存前10排序的进程

```bash
ps aux | sort -k4nr |head -n 10
```



2) 查看内存占用 排序

```bash
top
# 然后按 M
```



3) 查看swap

```bash
free -h
# 或者
cat /proc/swaps
```



3) 查看某个程序的内存占用

获取程序pid

```bash
lsof -i:3306
# 或者
ps -aux | grep mysqld

```

```bash
#假如我获取的`mysql`的`pid`为`3779` 
#那么获取内存使用情况
cat /proc/3779/status | grep VmRSS
#或者
top -p 3779
```





## CPU

消耗CPU前10排序的进程

```bash
ps aux | sort -k3nr |head -n 10
```



查看CPU占用 排序

```bash
top
# 然后按 `P`
```





## IO

每隔1s查询一次 共查询10次

```bash
iostat 1 10
```



## 路由信息

查看主机路由信息

```bash
netstat -rn
```

