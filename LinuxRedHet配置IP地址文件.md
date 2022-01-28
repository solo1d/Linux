需要修改的文件为 `/etc/sysconfig/network-scrips/ifcfg-eth0`

```ini
DEVICE="eth0"
NM_CONTROLLED="yes"
ONBOOT=yes
TYPE=Ethernet
BOOTPROTO=none
IPADDR=192.168.230.129				#这里修改
PREFIX=24
GATEWAY=192.168.230.1
DNS1=192.168.230.1
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth0"
UUID=5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03
HWADDR=00:0C:29:71:B1:1C
```





