**volatile ——定义类型为易变**

```c
unsigned long low, high;
asm volatile ( "rdtsc" : "=a" (low), "=d" (high) );

```

***const volatile 对象***——类型为 const-volatile-限定的 对象，const volatile 对象的非 mutable 子对象，volatile 对象的 const 子对象，或 const 对象的非 mutable volatile 子对象。同时表现为 const 对象与 volatile 对象。





```cpp
#include <iostream>
 
extern "C" int func();
// func 的定义以汇编语言书写
// 原始字符串字面量可以很有用
asm(R"(
.globl func
    .type func, @function
    func:
    .cfi_startproc
    movl $7, %eax
    ret
    .cfi_endproc
)");
 
int main()
{
    int n = func();
    // 扩展内联汇编
    asm ("leal (%0,%0,4),%0"
         : "=r" (n)
         : "0" (n));
    std::cout << "7*5 = " << n << std::endl; // 冲刷缓冲区是有意的
 
    // 标准内联汇编
    asm ("movq $60, %rax\n\t" // Linux 上的“退出”的系统调用序号
         "movq $2,  %rdi\n\t" // 此程序返回 2
         "syscall");
}
输出：

7*5 = 35

```





```assembly
+------------------------------+------------------------------------+
|       Intel Code             |      AT&T Code                     |
+------------------------------+------------------------------------+
| mov     eax,1                |  movl    $1,%eax                   |   
| mov     ebx,0ffh             |  movl    $0xff,%ebx                |   
| int     80h                  |  int     $0x80                     |   
| mov     ebx, eax             |  movl    %eax, %ebx                |
| mov     eax,[ecx]            |  movl    (%ecx),%eax               |
| mov     eax,[ebx+3]          |  movl    3(%ebx),%eax              | 
| mov     eax,[ebx+20h]        |  movl    0x20(%ebx),%eax           |
| add     eax,[ebx+ecx*2h]     |  addl    (%ebx,%ecx,0x2),%eax      |
| lea     eax,[ebx+ecx]        |  leal    (%ebx,%ecx),%eax          |
| sub     eax,[ebx+ecx*4h-20h] |  subl    -0x20(%ebx,%ecx,0x4),%eax |
+------------------------------+------------------------------------+


+---+--------------------+
| r |    Register(s)     |
+---+--------------------+
| a |   %eax, %ax, %al   |
| b |   %ebx, %bx, %bl   |
| c |   %ecx, %cx, %cl   |
| d |   %edx, %dx, %dl   |
| S |   %esi, %si        |
| D |   %edi, %di        |
+---+--------------------+


Some other constraints used are:

"m" : A memory operand is allowed, with any kind of address that the machine supports in general.
"o" : A memory operand is allowed, but only if the address is offsettable. ie, adding a small offset to the address gives a valid address.
"V" : A memory operand that is not offsettable. In other words, anything that would fit the `m’ constraint but not the `o’constraint.
"i" : An immediate integer operand (one with constant value) is allowed. This includes symbolic constants whose values will be known only at assembly time.
"n" : An immediate integer operand with a known numeric value is allowed. Many systems cannot support assembly-time constants for operands less than a word wide. Constraints for these operands should use ’n’ rather than ’i’.
"g" : Any register, memory or immediate integer operand is allowed, except for registers that are not general registers.
Following constraints are x86 specific.

"r" : Register operand constraint, look table given above.
"q" : Registers a, b, c or d.
"I" : Constant in range 0 to 31 (for 32-bit shifts).
"J" : Constant in range 0 to 63 (for 64-bit shifts).
"K" : 0xff.
"L" : 0xffff.
"M" : 0, 1, 2, or 3 (shifts for lea instruction).
"N" : Constant in range 0 to 255 (for out instruction).
"f" : Floating point register
"t" : First (top of stack) floating point register
"u" : Second floating point register
"A" : Specifies the `a’ or `d’ registers. This is primarily useful for 64-bit integer values intended to be returned with the `d’ register holding the most significant bits and the `a’ register holding the least significant bits.

```







```c
asm("movl %ecx %eax"); /* moves the contents of ecx to eax */
__asm__("movb %bh (%eax)"); /*moves the byte from bh to the memory pointed by eax */


 __asm__ ("movl %eax, %ebx\n\t"
          "movl $56, %esi\n\t"
          "movl %ecx, $label(%edx,%ebx,$4)\n\t"
          "movb %ah, (%ebx)");

asm ( assembler template 
     : output operands                  /* optional */
     : input operands                   /* optional */
     : list of clobbered registers      /* optional */
    );

int a=10, b;
asm ("movl %1, %%eax; 
     movl %%eax, %0;"
     :"=r"(b)        /* output */
     :"r"(a)         /* input */
     :"%eax"         /* clobbered register */
    );       





int main(void)
{
        int foo = 10, bar = 15;
        __asm__ __volatile__("addl  %%ebx,%%eax"
                             :"=a"(foo)
                             :"a"(foo), "b"(bar)
                             );
        printf("foo+bar=%d\n", foo);
        return 0;
}


```





