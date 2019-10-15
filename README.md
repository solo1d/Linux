---
description: CentOS7.7
---

# Linux

## 主要是 Linux 系统结构和命令.

### 终端乱码解决方案

```bash
终端乱码:   (下面两个解决方案)
    临时生效
        $export LANG=en_US.UTF-8
        $export LC_ALL=en_US.UTF-8

    永久生效->  修改 /etc/locale.conf  文件, 将下面的内容写入文件(会将系统变成英文)
        LC_ALL=en_US.UTF-8
```

## 关机和重启以及内存数据写会到磁盘

```bash
$sync     将内存数据写会到硬盘命令

关机前 应该使用 $sync 命令来将在内存的数据写会到硬盘中.
    关机脚本:  sudo sync && sudo sync && sudo shutdown -h now
```

## 查看当前 Linux所支持的文件系统

```bash
 $ sudo ls -l /lib/modules/$(uname -r)/kernel/fs
 
 #系统目前已载入到内存中支持的文件系统则有:
$cat /proc/filesystems
```

## 挂载点的设备文件名

```bash
$df -T /boot         #后面的/boot  可以换成挂载点(目录)
```

## 挂载硬盘命令

```bash
$mount  -t  文件系统  UUID=''    挂载点目录        #也可以不需要-t和文件系统
$blkid     #会列出所有设备的 UUID和文件系统类型
```

## 获得CPU核心数量

```bash
$grep 'processor' /proc/cpuinfo
 processor : 0
 processor : 1
# 这是表示有两颗 cpu核心的意思, (一颗CPU,两颗CPU核心  / 或者一颗CPU,一颗核心<超线程>)
```





















