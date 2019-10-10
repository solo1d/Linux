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

