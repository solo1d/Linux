内核版本 3.9

**查看内核的日志信息命令 `$dmesg` 可以用来查看日志**

- [Linux网络栈](#Linux网络栈)
- [网络设备](#网络设备)
- 



# Linux网络栈

- Linux网络栈
  - 开放系统互联OSI  模型定义的7个逻辑网络层:
    - 物理层,  提供电信号
    - **数据链路层,  处理端点间的数据传输, 常见标准是以太网, Linux以太网 网络设备驱动程序就在这一层**
    - 网络层 , 负责 数据包转换和主机编址
    - 传输层/ 协议层, 完成节点间的数据发送
    - 会话层,  处理端点间的会话
    - 表示层 , 处理数据传输的格式设置
    - 应用层,  向最终用户应用程序提供网络服务
  - **网络内核栈所涉及的3层:  L2, L3, L4**
    - L2 对应数据链路层,(网络设备驱动程序) 收到数据包会传递给L3
    - L3 对应网络层, 检查数据包是否为当前设备后, 内核网络栈就将其传递给L4
    - L4 对应传输层, TCP和UDP 协议 的监听套接字
      - **内核并不涉及 L4 之上的各层, 这些层由用户空间应用程序来实现, 也不涉及L1物理层**
  - **发生的行为如下:**
    - 根据协议规则(如 NAT, IPsec 规则),  可能需要对数据包进行修改
    - 数据包可能被丢弃
    - 数据包可能导致设备发送错误消息
    - 可能需要重组数据包
    - 需要计算数据包的校验和

==**GSO: 通用分段延后处理功能.  是内核网络栈的一项网络功能, 在传输路径中将大型数据包划分成小型数据包,  也会在网络设备中实现**==



# 网络设备



L2层 , 网络设备驱动程序,  数据链路层

- **网络设备的结构体 `net_device`**
  - 包含设备参数如下:
    - 设备的IRQ号
    - 设备的MTU
    - 设备的MAC地址
    - 设备的名称，如etho或eth1。
    - 设备的标志，如状态为up还是down。
    - 与设备相关联的组播地址清单。
    - promiscuity计数器, 大于0时,网络栈就不会丢弃那些目的地并非本地主机的数据包
    - 设备支持的功能，如GSO或GRO。
    - 网络设备回调两数的对象（net device ops)，这个对象由两数指针组成，如用于打开和停止设备、开始传输、修改网络设备MTU等的函数
    - ethtoo1回调函数对象，它支持通过运行命令行实用程序ethtoo1来获取有关设备的信息。
    - 发送队列和接收队列数（如果设备支持多个队列)。
    - 设备最后一次发送数据包的时间戳。
    - 设备最后一次接收数据包的时问戳。

```c
#include <include/linux/netdevice.h>

// 网络设备的结构体 net_device
struct net_device {
	char			name[IFNAMSIZ];  // 网络设备的名称 eth0, 命令 ip link set eth0 name newName 
	struct hlist_node	name_hlist; // 包含网络设备的散列表，索引为网络设备名

/* snmp 别名,记录在 /sys/class/new/eth0/ifalias 文件中 , 命令 ip link set eth0 alias newAlias */
  char 			*ifalias;  	

	/*
	 *	I/O specific fields
	 *	FIXME: Merge these and struct ifmap into one
	 */
	unsigned long		mem_end;	/* shared mem end	*/
	unsigned long		mem_start;	/* shared mem start	*/
	unsigned long		base_addr;	/* device I/O address	*/
	unsigned int		irq;	 			/* 设备的 IRQ中断请求号 */

	/*
	 *	Some hardware also needs these fields, but they are not
	 *	part of the usual set specified in Space.c.
	 */

	unsigned long		state;  // 一个标志, 设备的状态, 在 include/linux/netdevice.h 中定义

	struct list_head	dev_list;   /* 全局的网络设备链表 */
	struct list_head	napi_list;  /* napi表示新的New API,指的是在流量过高时切换成轮询模式 而不是中断*/
	struct list_head	unreg_list; /* 已注销的网络设备列表 */

	/* 当前活动的(已启用的) 设备功能集 */
	netdev_features_t	features;
	/* 当前活动的设备功能集 */
	netdev_features_t	hw_features;
	/* 用户要求的功能, 可以供用户进行修改,  命令 ethtool -K eth1 rx on */
	netdev_features_t	wanted_features;
 	/* VLAN 设备可继承的特性掩码, 也就是 子设备继承的功能集 */
	netdev_features_t	vlan_features;

  /* 封装设备继承的特性掩码 此字段指示硬件能够执行哪些封装卸载，并且驱动程序需要适当地设置它们 */
	netdev_features_t	hw_enc_features;
  
	int			ifindex; 	/* 接口索引。唯一设备标识符, 在文件 /sys/class/net/eth0/ifindex 中*/
	int			iflink;

  /* 统计信息结构, 命令  ethtool -S eth0 输出, 记录在目录 /sys/class/net/eth0/statistics/ 中 */
	struct net_device_stats	stats; 
	atomic_long_t		rx_dropped; /* 核心网络丢弃的数据包数量 不要在驱动程序中使用它。 */

#ifdef CONFIG_WIRELESS_EXT
	/* List of functions to handle Wireless Extensions (instead of ioctl).
	 * See <net/iw_handler.h> for details. Jean II */
	const struct iw_handler_def *	wireless_handlers;
	/* Instance data managed by the core of Wireless Extensions. */
	struct iw_public_data *	wireless_data;
#endif
	const struct net_device_ops *netdev_ops;	/* 包含多个回调函数指针的结构体 */
  /* 包含多个指针, 指向回调函数用于处理减负,获取和设置各种网络设置, 获取统计信息 等信息 */
	const struct ethtool_ops *ethtool_ops; 

	/* 包含回调函数 用于创建,分析, 重建  第二层报头 (帧) */
	const struct header_ops *header_ops;

	unsigned int		flags;	/* 网络状态的接口标志, 混杂模式 ,环回 等 , 用户空间可见 */
	unsigned int		priv_flags; /* 类似于“标志”，但对用户空间不可见。有关定义，请参见 if.h。 */
	unsigned short		gflags;  /* 全剧标志, 遗留成员 */
	unsigned short		padded;	/* alloc_netdev() 添加了多少填充内容 */

	unsigned char		operstate; /* RFC2863 操作状态 */
	unsigned char		link_mode; /* 将策略映射到操作状态  */

	unsigned char		if_port;	/* Selectable AUI, TP,..*/
	unsigned char		dma;		/* DMA channel		*/

	unsigned int		mtu;	/* 网络接口的 MTU最大传输单元, 设备能够处理的最长帧 */
	unsigned short		type;	/* 网络接口的硬件类型, 以太网,PPP 等	*/
	unsigned short		hard_header_len;	/* 硬件报头的长度, 帧报头, MAC地址那部分 */

	/* extra head- and tailroom the hardware may need, but not in all cases
	 * can this be guaranteed, especially tailroom. Some cases also use
	 * LL_MAX_HEADER instead to allocate the skb.
	 */
	unsigned short		needed_headroom;
	unsigned short		needed_tailroom;

	/* Interface address info. */
	unsigned char		perm_addr[MAX_ADDR_LEN]; /* 永久硬件地址 MAC */
	unsigned char		addr_assign_type; /* 分配的硬件地址类型 */
	unsigned char		addr_len;	/* 硬件地址长度 ,就是MAC长度  为6	*/
	unsigned char		neigh_priv_len;   /* 只在ATM 代码中初始化它  atm/clip.c*/
	unsigned short          dev_id;		/* for shared network cards */

	spinlock_t		addr_list_lock;
	struct netdev_hw_addr_list	uc;	/* 单播mac地址列表 */
	struct netdev_hw_addr_list	mc;	/* 多播mac地址列表 */
	bool			uc_promisc;

  /* 计数器, 表示网络接口卡 被命令在混杂模式下工作的 计数, 会增减, 为0时 退出混杂模式 */
	unsigned int		promiscuity; 
	unsigned int		allmulti;  /* 计数器, 启用或禁用 所有组播模式, (接受或不接受 组播数据包) */


	/* Protocol specific pointers */

#if IS_ENABLED(CONFIG_VLAN_8021Q)
	struct vlan_info __rcu	*vlan_info;	/* VLAN info */
#endif
#if IS_ENABLED(CONFIG_NET_DSA)
	struct dsa_switch_tree	*dsa_ptr;	/* dsa specific data */
#endif
	void 			*atalk_ptr;	/* AppleTalk link 	*/
	struct in_device __rcu	*ip_ptr;	/* IPv4 特有数据 */
	struct dn_dev __rcu     *dn_ptr;        /* DECnet specific data */
	struct inet6_dev __rcu	*ip6_ptr;       /* IPv6 特有数据 */
	void			*ax25_ptr;	/* AX.25 specific data */
	struct wireless_dev	*ieee80211_ptr;	/* IEEE 802.11 无线设备的特定数据指针，注册前分配 */

/*
 * 缓存行主要用于接收路径（包括 eth_type_trans()）
 */
	unsigned long		last_rx;	/*最后一次接收的时间不应在驱动程序中设置，除非确实需要，因为网络堆栈（绑定）在必要时使用它，以避免弄脏此缓存线。*/

	struct list_head	upper_dev_list; /* List of upper devices */


	unsigned char		*dev_addr;	/* 硬件地址，（在 bcast 之前，因为大多数数据包是单播的） */
   /* eth_type_trans()中使用的接口地址信息 ,修改MAC命令 ifconfig wlan0 hw ether MAC地址 */

	struct netdev_hw_addr_list	dev_addrs; /* 设备硬件地址列表 */

	unsigned char		broadcast[MAX_ADDR_LEN];	/* 硬件广播地址	*/

#ifdef CONFIG_SYSFS
	struct kset		*queues_kset; /* 一组特定类型的 kobject ,属于特定的子系统 */
#endif

#ifdef CONFIG_RPS
	struct netdev_rx_queue	*_rx; /* RX接受队列数组 */
	unsigned int		num_rx_queues;	/* 在 register_netdev() 时分配的 RX接受 队列数 */
	unsigned int		real_num_rx_queues;	/* 设备中当前活动的 RX 队列数 */

#ifdef CONFIG_RFS_ACCEL
	/* CPU reverse-mapping for RX completion interrupts, indexed
	 * by RX queue number.  Assigned by driver.  This must only be
	 * set if the ndo_rx_flow_steer operation is defined. */
	struct cpu_rmap		*rx_cpu_rmap;
#endif
#endif

	rx_handler_func_t __rcu	*rx_handler;  
	void __rcu		*rx_handler_data;

	struct netdev_queue __rcu *ingress_queue;

/*
 * 缓存线主要用于传输路径
 */
	struct netdev_queue	*_tx ;  /* 一个发送队列数组 */
	unsigned int		num_tx_queues; 	/* 在 alloc_netdev_mq() 时间分配的 发送 TX 队列数 */
	unsigned int		real_num_tx_queues; 	/* 设备中当前活动的 TX 队列数 */

  /* qdisc 层 (排队原则)  实现了对Linux 内核流量的管理, 使用 命令 ip addr show eht0 查看*/
	struct Qdisc		*qdisc; /* 每个设备都将维护一个 名为qdisc队列, 其中包含要发送的数据包 */

	/* 设置命令为 ip link set  txqueuelen 1000 dev eth0 */
  unsigned long		tx_queue_len;	/* 每个队列允许的最大数据包数(帧数), 默认1000, FDDI设备则为100 */
  
	spinlock_t		tx_global_lock;

#ifdef CONFIG_XPS
	struct xps_dev_maps __rcu *xps_maps;
#endif

	/* These may be needed for future network-power-down code. */

	/*
	 * trans_start here is expensive for high speed devices on SMP,
	 * please use netdev_queue->trans_start instead.
	 */
	unsigned long		trans_start;	/* 最后一次传输的时间（以 jiffies 为单位）*/

  /* 看门狗是一个定时器,它在网络接口在指定时间内一直处于空闲状态而未传输数据时,就调用一个回调函数 */
	int			watchdog_timeo; 
  
	struct timer_list	watchdog_timer;

	/* 每个CPU的网络设备应用计数, 也可以是当前设备被引用的次数*/
	int __percpu		*pcpu_refcnt;

	/* delayed register/unregister */
	struct list_head	todo_list;

	struct hlist_node	index_hlist;	/* 包含网络设备的索引哈希链,索引为网络设备索引 (字段 ifindexx) */

	struct list_head	link_watch_list;

	/* 网络设备各种注册状态的枚举*/
	enum { NETREG_UNINITIALIZED=0,
	       NETREG_REGISTERED,	/* completed register_netdevice */
	       NETREG_UNREGISTERING,	/* called unregister_netdevice */
	       NETREG_UNREGISTERED,	/* completed unregister todo */
	       NETREG_RELEASED,		/* called free_netdev */
	       NETREG_DUMMY,		/* dummy device for NAPI poll */
	} reg_state:8;

	bool dismantle; /* 为true时, 代表设备处于拆卸状态 即将被释放 */

	enum { // 新链路的创建的两个状态
		RTNL_LINK_INITIALIZED,   // 进行状态, 链路创建未完成
		RTNL_LINK_INITIALIZING,  // 最终状态, 链路已创建好
	} rtnl_link_state:16;  

	/* 在注销网络设备时调用, 会执行注销所需的额外任务 */
	void (*destructor)(struct net_device *dev);

#ifdef CONFIG_NETPOLL
	struct netpoll_info __rcu	*npinfo;
#endif

#ifdef CONFIG_NET_NS
	/* 网络设备所属的命名空间, 命名空间提供了虚拟化 */
	struct net		*nd_net;
#endif

	/* mid-layer private */
	union {
		void				*ml_priv;
		struct pcpu_lstats __percpu	*lstats; /* 环回网络的统计信息 */
		struct pcpu_tstats __percpu	*tstats; /* 隧道的统计信息 */
		struct pcpu_dstats __percpu	*dstats; /* 哑网设备的统计信息 */
		struct pcpu_vstats __percpu	*vstats; /* veth(虚拟以太网设备)的统计信息 */
	};
	/* GARP */
	struct garp_port __rcu	*garp_port;
	/* MRP */
	struct mrp_port __rcu	*mrp_port;


	struct device		dev;  	/* 与网络设备相关联的 device 对象, 内核中 每个设备都与一个设备对象 */
	
  /* 可选设备、统计和无线 sysfs 组的空间, 供网络 sysfs 使用 */
	const struct attribute_group *sysfs_groups[4];
  
	const struct rtnl_link_ops *rtnl_link_ops;/* rtnetlink 链接操作对象,包含处理网络设备的回调函数*/

	/* for setting kernel sock attribute on TCP connection setup */
#define GSO_MAX_SIZE		65536
	unsigned int		gso_max_size; /* 用于将指定网络设备的 gso_max_size 设备为指定的值 */
#define GSO_MAX_SEGS		65535
	u16			gso_max_segs;

#ifdef CONFIG_DCB
	/* Data Center Bridging netlink ops */
	const struct dcbnl_rtnl_ops *dcbnl_ops;
#endif
	u8 num_tc;  /* 网络设备中的流量 类别数 */

  /* cgroup 网络优先级模块提供了设备网络流量优先级接口 */
  struct netdev_tc_txq tc_to_txq[TC_MAX_QUEUE];
	u8 prio_tc_map[TC_BITMASK + 1];

#if IS_ENABLED(CONFIG_FCOE)
	/* max exchange id for FCoE LRO by ddp */
	unsigned int		fcoe_ddp_xid;
#endif
#if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
	struct netprio_map __rcu *priomap;
#endif

  /* 关联的物理设备, phy 设备可能会附加自身用于硬件时间戳 */
	struct phy_device *phydev;

	struct lock_class_key *qdisc_tx_busylock;

	/* 网络设备所属的组 */
	int group;

	struct pm_qos_request	pm_qos_req; /* 电源管理服务质量(PM Qos) 请求对象 */
};

```











