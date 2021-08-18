```c
## 被称为连接符，用来将两个宏参数连接为一个宏参数。
而单个#的功能是将其后面的宏参数进行字符串化操作，简单地说就是在对它所引用的宏变量通过替换后在其左右各加上一个双引号，使其成为字符串。

#@是使参数用单引号包住


 另外还有：
 #define A(x) T_##x
 #define B（x） #@x
 #define C（x） #x
 我们假设：x=1，则有：
 A(1)------）T_1
 B(1)------）'1'
 C(1)------）"1"
```

```c
表示L与x连接。
#define Conn(x,y) x##y
#define ToChar(x) #@x
#define ToString(x) #x
 
x##y表示什么？表示x连接y，举例说：
int  n = Conn(123,456);  结果就是n=123456;     // 这里是int
char* str = Conn("asdf", "adf")结果就是 str = "asdfadf";   // 这里是char*
怎么样，很神奇吧
 
再来看#@x，其实就是给x加上单引号，结果返回是一个const char。举例说：
char a = ToChar(1);结果就是a='1';
做个越界试验char a = ToChar(123);结果是a='3';
但是如果你的参数超过四个字符，编译器就给给你报错了！error C2015: too many characters in constant   ：P
 
最后看看#x,估计你也明白了，他是给x加双引号
char* str = ToString(123132);就成了str="123132";
```

```c
void kthread_create(char *data, ...){
    va_list args;
    va_start(args, data);
    char* pd = va_arg(args, char*);
    printf("%s |  %s\n", data, pd);  // va_list  type is  char*
    va_end(args);
}



#define kthread_run(T, ... )\
({                        \
    kthread_create( T , ## __VA_ARGS__); \
})

int main(void){
    char T[] = "asd";
    char P[] = "PASD";
    kthread_run(T, P);
}
```

