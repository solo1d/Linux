- [页框](#页框)
- [伙伴算法](#伙伴算法)
- [slab](#slab)
  - [linux下slab内存管理和分配](#linux下slab内存管理和分配)
  - [linux内存分配函数比较](#linux内存分配函数比较)
  - 



**slab是小内存管理机制**



## 页框

**内核使用 `struct page`结构体 描述每个物理页,  也叫页框**

- Linux会把系统的所有内存管理起来, 也就是使用伙伴算法来进行管理和分配
  - 会将所有内存 按照4K (4096) 一个块分开
    - **每个4K 块都使用 `struct page`结构体来管理,  有多少个4K 块, 就有多少个结构体来描述物理块**



## 伙伴算法

==**内核在很多情况下,需要申请连续的页框, 而且数量不定. 伙伴算法可以解决 多个物理页的分配和管理**==

- Linux把所有的空闲页框分为11个链表,
  - 每个链表上的页框块都是固定的.
    - **在第 n 条链表中 每个 页框块 都包含  2的n次方  个连续页, 最大是11个链表. 2^10=1024个页框**
      - 也就是 第一条链表是 2^0 ,  里面保存的都是非连续的 单个页框 链表
      - 第5个链表是 2^4 , 里面保存的都是 连续的16个页框的  链表
        - **系统中每个 页框块  的第一个页框的 物理地址 是该块大小的整数倍.**
          - **例如: 大小为16个页框的块, 其 起始地址是 16*2^12 的倍数,  2^12= 4096=4K**

```c
static inline struct page*  aloc_pages (gfp_t gfp_mask, unsigned int order);
// 分配 2^order 个连续的物理页, 并返回一个指针, 指向第一个页的 page 结构体

void*  page_address(const struct page* page);
// 返回 page页面所映射的 虚拟地址
```



## slab

==**slab实现了小块内存分配和管理**==

- slab层 把不同的对象划分为所谓的  **高速缓存(cache)组,** 其中每个高速缓存都存放不同类型的对象;
  - **每种对象类型对应 一个高速缓存(cache)**
    - 例如: 一个高速缓存 存放task_struct结构体, 而另一个高速缓存 存放 struct inode 结构体
  - **slab由一个或者多个物理上连续的页组成,  也就是借助伙伴算法**

> **slab解决的问题**
>
> 1. 减少伙伴算法在分配小块连续内存时所产生的内部碎片;
> 2. 将频繁使用的对象缓存起来, 减少分配, 初始化和释放对象的时间开销
> 3. 通过着色技术跳这个对象 以更好的使用硬件高速缓存

![slab.png](./jpg/slab.png)







## linux下slab内存管理和分配

**可以使用命令 `cat /proc/slabinfo` 来查看系统所有的高速缓存**

```c
// 使用该函数建立一个的高速缓存,  但是需要另外的函数来进行使用这块高速缓存
struct kmem_cache*  kmem_cache_create(const char* name, size_t size, size_t align,
                                      unsigned long flags, void (*ctor)(void*) );
/*  参数:
		   name:  高速缓存的名字
		   size:  高速缓存大小
		   align: 对齐大小 ,  1024,4096
		   flags: 
		   ctor: 
			返回值:  申请到的一个高速缓存 
*/

void kmem_cache_destriy(struct kmem_cache* s);
/*  释放从 kmem_cache_create() 函数申请的高速缓存内存
  参数: s: kmem_cache_create() 函数返回值
*/


```

```c
// 从高速缓存中 去获取申请所需要的内存
void* kmem_cache_alloc(struct kmem_cache* cachep, gfp_t flags)l
  /*  参数:
         cachep: 由kmem_cache_create()返回的高速缓存结构体
         flags:  内核中不同 内存申请的场景, 中断上下文不允许睡眠, 进程上下文允许睡眠,普通内存还是高速缓存
      返回值: 返回申请到的 内存的地址指针
  */
// 实际 kmem_cache_alloc() 函数内部就是调用的 slab_alloc() 函数来实现的.
static __always_inline void*  slab_alloc(struct keme_cache* cache, gfp_t flags,
                                         unsigned long caller);
```





```c
// 下面的函数, 申请的内存空间只会比 size 要去的大, 不会小
// 设备驱动 所需要的内存 在物理上应该是连续的

static __always_inline void* kmalloc(size_t size, fgp_t flags);
static inline void*  kzalloc(size_t szie, gfp_t flags); // 申请到的空间置0
/* 在内核或驱动里面 申请内存的常用函数
   返回一个指向内存块的指针, 其内存块大小 至少是size大小, 所分配的内存 在物理上 是连续的.
   
*/
void kfree(void* kmem);


void* vmalloc(unsigned long size);
void* vzalloc(unsigned long size);  // 申请到的空间置0
/* 返回一个指向内存块的指针, 其内存块大小 至少是size大小, 所分配的内存在物理上 无需连续.
  不可用于中断上下文
*/
void vfree(void* vmem);

```





## linux内存分配函数比较

| 内核空间 |          | vmalloc / vfree                    | 虚拟  连续  物理  不定 | vmalloc区大小限制    | 页      VMALLOC区域          | 可能睡眠, 不能从中断上下文中调用, 或其他不允许阻塞情况下调用.   VMALLOC区域vmalloc_start 至 vmalloc_end 之间, vmalloc 比 kmlloc慢, 适用于分配大内存. |
| :------- | -------- | ---------------------------------- | ---------------------- | -------------------- | ---------------------------- | ------------------------------------------------------------ |
|          | slab     | kmalloc/kcalloc/krealloc/kfree     | 物理连续               | 64B ~4MB(随slab而变) | 2^order 字节Normal区域       | 大小有限, 不如vmalloc/malloc大. 最 大/小 值由 `KMALLOC_MIN_SIZE / KMALLOC_SHIFT_MAX`, 对应 64B/4MB.  从 `/proc/slabinfo` 中的 malloc-xxxx 中分配, 建立在 `kmem_cache_create` 基础之上 |
|          |          | kmem_cache_create                  | 物理连续               | 64B ~ 4MB            | 字节大小,需对齐.  Normal区域 | 便于固定大小数据的频繁分配和释放, 分配时从缓存池中获取地址, 释放时页不一定真正释放内存. 通过 slab进行管理 |
|          | 伙伴系统 | __get_free_page/ __get_free_pages  | 物理连续               | 4MB(1024页)          | 页   Normal区域              | __get_free_pages基于alloc_pages, 但是限定不能使用 HIGHMEM    |
|          |          | alloc_page/alloc_pages/ free_pages | 物理连续               | 4MB                  | 页   Normal/Vmalloc 都可     | CONFIG_FORCE_MAX_ZONEORDER 定义了最大页数11, 从0开始到10,   2^10 , 一次能分配到的最大的页数是 1024 |



