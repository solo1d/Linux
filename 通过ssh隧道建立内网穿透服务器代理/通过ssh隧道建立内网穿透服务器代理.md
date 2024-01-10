## 环境配置

> - 内网环境： 
>   - Linux   **服务器**
>     - 本机IP并不重要，不需要固定。
>     - 需要映射的服务端口：
>       - http: 80 端口服务
> - 外网环境
>   - Linux   **跳板机**  登录用户为 ois
>     - 需要有固定的IP地址。 例如 12.12.12.10
>       - 会映射内网的服务和端口



## 修改服务器和跳板机的sshd配置

```bash
$ sudo vim  /etc/ssh/sshd_config
	将 #GatewayPorts no  字段修改为下面的样式即可
		GatewayPorts clientspecified
```



## 服务器和跳板机建立自动登录密钥

```bash
# 只建立 服务器登录跳板机的密钥

# 进入 .ssh 目录。 如果该目录没有，那么就使用 ssh 链接到跳板机进行自动创建即可。
服务器 $ cd  ~/.ssh  

# 建立密钥 , 后面的 ois 名称随意，一般都是取用户名
服务器 $ ssh-keygen -t rsa -f ois
		# 命令执行期间会有多次要求输出密码， 直接给几次回车即可. 
		#   完成后会生成两个文件  ois 和 ois.pub

# 拷贝生成公钥的  ois.pub 内容到跳板机的  ~/.ssh/authorized_keys 中 
# 如果没有就进行建立
跳板机 $ cd ～/.ssh ; touch authorized_keys
# 更新文件权限
跳板机 $ chmod 644 authorized_keys
# 写入 ois.pub  内容到 authorized_keys 文件
跳板机 $ vim ～/.ssh/authorized_keys

# 服务器创建 ~/.ssh/config 配置文件，写入服务器的配置
服务器 $ cd  ~/.ssh ; touch config
服务器 $ vim ~/.ssh/config
	#将如下内容写入文件保存即可
Host  ois
    User ois
    Port 12345
    HostName  12.12.12.10
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/ois
```



## 服务器和跳板机ssh服务重启

```bash
服务器 $ sudo systemctl restart ssh
跳板机 $ sudo systemctl restart ssh
```



## 服务器建立远程转发

```bash
# 远程服务器是 12.12.12.10， ssh服务监听端口是 12345 , 登录用户是 ois , 8080是映射出去的端口
# 本地服务器是 localhost,   本地需要转发的服务端口是 80
# 通过访问 12.12.12.10 的8080 端口，就可以间接的访问到 内网服务器的 80 端口。
	# 8080 前面的 : 这个代表全ip网段都可以访问，如果不配置，那么只能本地访问

$ ssh -o ServerAliveInterval=5 -o ServerAliveCountMax=1 -R *:8080:localhost:80  -T  -N  ois@12.12.12.10 -p 12345

# 参数说明
# -R  代表远程转发
# -T 禁用伪终端分配。
# -N 不发送任何命令，只用来建立连接。没有这个参数，会在 SSH 服务器打开一个 Shell。
# -p ssh服务端口
# -o ServerAliveInterval=5  -o ServerAliveCountMax=1  持久化配置，该命令每 5 秒发送一次 ssh keepalive 消息，但是发送另一个 keepalive 消息，没有收到对上一个keepalive消息的响应数据包，ssh客户端会默认中断该连接。
```



## 服务器建立远程转发启动脚本

脚本名称 sshServer.sh

```bash
#!/bin/bash
#nohup 进入后台,当前用户推出登录后 也会执行

#工作目录
cur_path=$(cd "$(dirname "$0")"; pwd)
cd $cur_path

SERVER_USER="ois"

# 服务器工作位置
SERVER_WORK_PATH="/home/${SERVER_USER}/sshRemote"

APP_NAME="ServerAliveInterval"

# 配置服务启动的本地端口
LocalPortList=("22" "80" "3306")
# 配置服务启动的远程映射端口
RemotePortList=("50022" "8080" "53306")

# 获取数组长度
ListLen=${#LocalPortList[@]}

#检查程序是否在运行
is_exist(){
   serviecPort=$1
   pid=`ps -ef|grep ${APP_NAME} | grep ${serviecPort} |grep -v grep|awk '{print $2}'`
   #如果不存在返回0，存在返回1
   if [ -z "${pid}" ]; then
    return 0
   else
    return 1
   fi   
}

# ssh 服务启动
set_service(){
  localProt=$1
  remotePort=$2
  
  is_exist ${remotePort}


  if [  $? -eq  0 ] ; then
      #启动
      nohup ssh   -o ServerAliveInterval=5 -o ServerAliveCountMax=1  -R *:${remotePort}:localhost:${localProt}  -T  -N  ${SERVER_USER} >/dev/null  2>&1 &
  fi
}

# 强制停止某个服务
killService(){
   serviecPort=$1
   pid=`ps -ef|grep ${APP_NAME} | grep ${serviecPort} |grep -v grep|awk '{print $2}'`
   # pid 不为空的话 就进入
   if [ -n "${pid}" ]; then
        kill -9 ${pid}
   fi
}


# 循环启动服务
startService(){
  for ((i=0; i<ListLen; i++)); do
    set_service ${LocalPortList[i]} ${RemotePortList[i]}
  done
}

# 重启某个服务
restartService(){
  localPort=$1
  remotePort=$2

  # 先停止
  killService $remotePort
  
  # 单独启动
  set_service ${localPort} ${remotePort}
}

# 全部停止
stopService(){
  for ((i=0; i<ListLen; i++)); do
    killService ${RemotePortList[i]}
  done
}

# 遍历所有传入的参数
for arg in "$@"; do
  # 判断参数是否为"start"
  if [ "$arg" = "start" ]; then
      startService
  fi
  
  # 判断参数是否为"stop"
  if [ "$arg" = "stop" ]; then
      stopService
  fi


  # 判断参数是否为"restart"
  if [ "$arg" = "restart" ]; then
     # $2传入的是 本地端口 .$3 传入的是远程端口
     restartService  $2 $3
  fi
done




#进行服务注册通知
# 通知文件 sshRemotePortList.txt
ServerPortFile="sshRemotePortList.txt"
ssh ${SERVER_USER}  "echo "${RemotePortList[@]}" > ${SERVER_WORK_PATH}/${ServerPortFile}"




# 检测跳板机的端口服务状态，并进行重启
#  跳板机 服务开启失败的端口列表文件
ServerPortFailFile="sshRemotePortFailList.txt"
FailPort=`ssh ${SERVER_USER}  "cat ${SERVER_WORK_PATH}/${ServerPortFailFile}"`

#如果不存在返回0，存在返回1
if [ -z "${FailPort}" ]; then
  aaaatemp=0  # 无用的内容,只是占位置
else
  # 获得每个服务的端口
  IFS=' ' read -r -a FailPortList <<< "$FailPort"
  # 获取数组长度
  FailPortLen=${#FailPortList[@]}
  # 进行循环重启服务
  for ((i=0; i<FailPortLen; i++)); do
      for ((p=0; p<ListLen; p++)); do
        if [ ${RemotePortList[p]} ==  ${FailPortList[i]} ]; then
             restartService  ${LocalPortList[p]} ${RemotePortList[p]}
        fi
    done
  done
fi 
```

### 跳板机服务脚本

脚本名称 sshTbServer.sh

该脚本需要放到  sshRemote 目录下

```bash
#!/bin/bash

#工作目录 sshRemote
cur_path=$(cd "$(dirname "$0")"; pwd)
cd $cur_path

# 服务开启失败的端口列表文件
ServerPortFailFile="sshRemotePortFailList.txt"

# 和服务器同步的名称
ServerPortFile="sshRemotePortList.txt"

# 检测文件
if [ ! -f "${ServerPortFile}" ]; then
	exit 0;   # 文件不存在，就直接推出
fi

ServerPortFileMem=`cat  ./${ServerPortFile}`

# 获得每个服务的端口
IFS=' ' read -r -a RemotePortList <<< "$ServerPortFileMem"

# 获取数组长度
ListLen=${#RemotePortList[@]}

# 文件检测并截断, 不存在就创建， 存在就截断
if [ -f "${ServerPortFailFile}" ]; then
	truncate -s 0 ${ServerPortFailFile}
else
	touch ${ServerPortFailFile}
fi


# 检测该端口是否还在监听中
for (( i = 0; i < ListLen; i++ )); do
	result=$(netstat -ptln4 2>/dev/null | grep ":${RemotePortList[i]}")
	if [ -z "$result" ]; then
		# 端口并没有在监听，进行服务重启记录
  		echo  "${RemotePortList[i]} " >> ${ServerPortFailFile}
	fi
done
```

