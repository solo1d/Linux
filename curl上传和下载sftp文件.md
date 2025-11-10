### 使用curl命令去上传和下载sftp服务器的文件

```bash
# 文件上传
# 用户名是 sftpuser 、密码是 password
# -P 端口使用 22
# -T 后面跟本地文件
# -k 跳过服务器密钥验证
curl -k -u sftpuser:password -P 22  -T /home/user/本地文件   sftp://目标服务器IP/远程路径


# 文件下载
# -o 后面是下载到本地的文件
curl -k -u sftpuser:password -P 22 -o  /home/user/本地文件   sftp://目标服务器IP/远程路径 

# 如果是上传文件夹的话，需要保持远程目录，添加参数 --create-dirs
# -sS  静默模式（仅显示错误）
curl -k -u sftpuser:password -P 22   \
		-T /home/user/本地文件 --create-dirs -sS   sftp://目标服务器IP/远程路径/需要构建的目录/

```





