# 文件查阅命令 和 观察文件类型命令\(压缩文件也行\)

## 普通文本查阅命令 \(cat,tac,nl,less,head,tail,od,last\)

```bash
文本 文件内容查阅 命令:
    $cat  filename     #从第一行显示文件内容
        # -A 显示特殊字符和tab,  -n 带行号(空行也算一行), -d 带行号(空行不算)
    $tac  filename     #从最后一行开始显示, 进行倒序显示.
    $nl   filename     #从第一行开始显示,并且输出行号.
    $less filename     #一页一页的显示文件内容,并且可以翻页.
        #快捷键: 空格->下一页 , b->上一页, 回车->下一行, /串 搜索 , :f -> 当前文件名和行号, q退出
    $head filename     #只显示头几行
        # -n 数字  表示要显示几行.(也可以写负值,会将后面的行屏蔽. -10 ,不显示文件末尾的10行)
    $tail filename     #只看尾巴几行
        # 也适用于 -n 数字 选项, -f 表示持续侦测这个文件,一旦有新的写入信息就立即显示出来.
    $od   filename     #以二进制方式读取文件内容.
    $last filename     #读取 数据格式文件.
```

## 可执行文件 内容查阅命令\(od\)

```bash
可执行文件 内容查阅命令:
    $od   [-t TYPE]  文件
        #-t 后面还会跟着参数 : c        使用 ASCII字符来输出. ($od -t c /bin/passwd )
        #                   d[size]   利用十进制来输出数据,每个整数占 size 字节.
        #                   f[size]   浮点数数值输出. 
        #                   o[size]   八进制为输出.   ($od -t cCc /etc/issue )
        #                   x[size]   十六进制输出.   
        # 详解: https://blog.csdn.net/qq_31246691/article/details/77282461
```

## 观察文件类型 命令\(file\)

```bash
观察文件类型 命令 $file  文件名
    可以用来查看文件的类型:
        有可能是 ASCII
        有可能是 二进制可执行文件
        有可能是 data文件
        还可以查看 压缩包tar文件 使用的是哪种压缩功能.(非常有用)
```



