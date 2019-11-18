# 开机流程,模块管理与Loader
grub2 是Linux 下优秀的开机管理程序 (boot loader).

## Linux开机流程 (重要)
- **载入BOIS 的硬件信息与进行自我检测, 并依据设置取得第一个可开机的设备(硬盘或网络,保存操作系统的硬件)**
- **读取并执行第一个开机设备内的 MBR或GPT 分区中的 **开机启动程序 `boot loader`** (就是grub2,spfdisk等程序)**
- **依据 boot loader 的设置载入 Kernel(内核), kernel会开始侦测硬件与载入驱动程序.**
- **在硬件驱动成功后,Kernel会主动调用systemd 程序,并以 default.target(操作环境)准备操作系统.**
  - **systemd 执行 sysinit.target 初始化系统及basic.target 准备操作系统**
  - **systemd 启动 multi-user.target 下的本机与服务器服务**
  - **systemd 执行 multi-user.target 下的 /etc/rc.d/rc.local 文件**
  - **systemd 执行 multi-user.target 下的 getty.target 及登陆服务**
  - **systemd 执行 graphical(图形化) 需要的服务**
























