# 帮助命令 man 中的详细解读

```bash
帮助命令 man 中帮助信息的解读:
    NAME        :简短的指令, 数据名称说明.
    SYNOPSIS    :简短的指令下达语法(syntax) 简介.
    DESCRIPTION :较为完整地说明.
    OPTIONS     :针对 SYNOPSIS 部分中, 有列举的所有可用的选项说明.
    COMMANDS    :当这个程序(软件)在执行的时候,可以在此程序(软件) 中 下达的指令.
    FILES       :这个程序或数据所使用或参考或链接到某些文件.
    SEE ALSO    :可以参考的, 跟这个指令或数据有相关的其他说明.
    EXAMPLE     :一些可以参考的范例.
```

### man 命令错误 an: preconv: Bad system call 的解决方法

```
man: preconv: Bad system call
man: tbl: Bad system call
Manual page man(1) line ?/? (END) (press h for help or q to quit)man: nroff: Bad system call
```

```bash
可以设置一个环境变量 MAN_DISABLE_SECCOMP  到 .bashrc 和  .bash_profile 中

export MAN_DISABLE_SECCOMP=1
```

