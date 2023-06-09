- 查看服务运行状态

```bash
[root@room4pc09 桌面]# systemctl status crond       #查看服务运行状态
● crond.service - Command Scheduler
   Loaded: loaded (/usr/lib/systemd/system/crond.service; enabled; vendor preset: enabled)
   Active: active (running) since 二 2019-01-29 21:52:22 CST; 1 day 12h ago
 Main PID: 1403 (crond)
   CGroup: /system.slice/crond.service
           └─1403 /usr/sbin/crond -n

1月 29 21:52:22 room4pc09.tedu.cn systemd[1]: Started Command Scheduler.
```

- 查看服务是否开启

```bash
[root@room4pc09 桌面]# systemctl is-enabled crond.service #查看服务是否开启 
enabled
```

- 查看服务是否活跃

```bash
[root@room4pc09 桌面]# systemctl is-active crond
active
```

- 字符模式：multi-user.target
- 图形模式：graphical.target

```bash
[root@room4pc09 桌面]# systemctl get-default   #查看默认模式
multi-user.target
```

- **设置默认的运行模式**

```bash
[root@room4pc09 桌面]# systemctl set-default graphical.target  #设置为图形模式 
Removed symlink /etc/systemd/system/default.target.
Created symlink from /etc/systemd/system/default.target to /usr/lib/systemd/system/graphical.target.

[root@room4pc09 桌面]# systemctl get-default  #查看默认模式
graphical.target

[root@room4pc09 桌面]# reboot               #重启
```



```bash
[root@room4pc09 桌面]# systemctl isolate multi-user.target   #当前立即进入字符模式
[root@room4pc09 桌面]# systemctl isolate graphical.target  #当前立即进入图形模式
```

