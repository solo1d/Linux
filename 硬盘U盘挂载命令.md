```bash
#得到没有挂载的文件描述符
$lsblk

#也可以使用这样方式来得到, 但内容较多
$sudo fdisk -l




#设定编码和挂载
$sudo mount -o iocharset=utf8 /dev/sda2 video

$sudo umount  /dev/sda2
```

