# Lab 1 实验报告

#### 姓名:崔晨昊      学号:19307130084



## Part A

### Task 1 & Task 2

按要求进行即可

### Task 3

gdb模式下完成该任务需要三步：

- 找到ret指令执行时的栈顶位置
- 利用strcpy，将内存中某段修改为Task2中的指令
- 利用strcpy，将ret时栈顶的值修改为目标指令的起始地址

在非gdb模式下，栈缩小了一部分，统一向高地址处移动了一段。此时，ret时**栈顶的相对位置不变**，所以并不影响，目标指令的确切地址实际上略大于gdb所得地址。通过在目标指令之前**插入大量nop**，使得只要跳转到目标指令之前的任意位置(中间全是nop)，就一定会执行目标指令。

```python
start  = 304
ret    = 0xffffcb3c
offset = 112
```

### Task 4

该任务下，栈的长度变为100-200之间不定。这导致ret时的栈顶位置在文件中是不确定的，但是**一定在原本位置之后100以内**。所以将112-212之间全部填入return address即可，由于gdb在栈中有一定大小，重复Task 3中参数发现出现illegal instruction错误，可知是返回地址过低，应该高一些。所以我将`start`和`ret`两个参数的值增加了0x80（即128，由多增加了100个Byte的空间填return address推导而来）

```python
start  = 432
ret    = 0xffffcbbc
offset = 112
```

新增代码：

```python
while offset <= 112+100:
	content[offset:offset + L] = (ret).to_bytes(L,byteorder='little')
    offset = offset + L
```

### Task 5

该任务要求在64位模式下运行，由于8个Byte的地址是小端法存储，所以要保证在return address之前无0x00，以及return address除高位之外无0x00。

通过gdb调试可以拿到return address的地址(相对于文件头的位置)。另外，`fread()`在内存中保留了一份完整的文件内容，将return address设为目标及其指令或之前nop的地址即可。

```python
start  = 432
ret    = 0x7fffffffde80
offset = 216
```

### Task 6

由于之前的Task就一直将start设的比较大，所以本题的思路和Task 5大致相同。用gdb调试得知`offset`的值应该设为18，并且由于return address高位有0x0的原因，strcpy终止。但是幸运的是在那之后的栈为0，刚好补齐了return address的高位，使得地址能够被正确读出。

```python
start  = 432
ret    = 0x7fffffffde86
offset = 18
```

## Part B

### Task 1&2

按要求进行即可。Task 2中发现必须文件名长度一致时，环境变量的位置才会一样。

在shell中加入环境变量后，实验知`/bin/sh`的位置在`0xffffd3fc`，`system`的位置在`0xf7e12420`，`exit`的位置在`0xf7e04f80`。

### Task 3

本题有两种做法将/bin/sh放入内存，一种是利用环境变量，也可以利用badfile。

在程序执行过程中，栈帧如下![img](https://img-blog.csdn.net/20131124171848671?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2FuZ3llemkxOTkzMDkyOA==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

也就是说，我们可以**修改bof的return address**，使其返回到`system`函数中，此时的**栈环境应该是进入system的样子**。即我们还需要保证原本栈上return address之后有：

1. system的返回地址
2. 参数1

|                    栈结构                    |
| :------------------------------------------: |
|        address of /bin/s (paramemter)        |
| address of exit() (return address of system) |
| address of system() (return address of bof)  |
|                 ebp of bof()                 |
|                     ...                      |
|                    buffer                    |

```python
X = 90
sh_addr = 0xffffd3fc
Y = 82
system_addr = 0xf7e12420
Z = 86
exit_addr = 0xf7e04f80
```

#### Attack variation 1

修改`exit()`地址为其余可执行函数地址时，例如改为`main()`会无限循环(当然最终结果是爆栈)，可以正常进入下一个函数。

#### Attack variation 2

攻击失败了，文件名不一样导致其被装载入内存后目标值(环境变量)的开始地址发生变化

### Task 4

本题需要利用`execv()`函数以及`main()`中buffer进行。需要：

- 构造argv数组，并将数组地址填入栈对应execv第二个参数的位置

构造数组并不难，同时为了体现设计字符串的多样性，我**将`-p`也放在`badfile`中**，但必须放在栈覆盖位置的后面，防止"-p"的'\\0'导致`strcpy()`提前终止拷贝

|             栈结构              |
| :-----------------------------: |
|      "/bin/bash"  环境变量      |
|               ...               |
|          argv[2]：NULL          |
|    argv[1]：address of “-p”     |
| argv[0]：address of "/bin/bash" |
|               ...               |
|         address of argv         |
|     address of "/bin/bash"      |
|        address of exit()        |
|       address of execv()        |
|           ebp of bof            |

### Task 5

### Task 5

本题需要将`setuid()`和`system()`串联起来，由于setuid的参数是0，所以strcpy无法拷贝完整，一定**需要将esp设为`main()`内buffer的位置**

利用objdump，在retlib的汇编代码中找到以下两个代码段：

```python
<__libc_csu_init + 99>: # garget1
    1413:	5d                   	pop    %ebp
    1414:	c3                   	ret
```

```python
<bof + 97>: # garget2
	12ae:	c9                   	leave  
    12af:	c3                   	ret
```

`gadget1`使`ebp`可以是任意值

`gadget2`使`esp`可以是任意值(借助`ebp`)

由此设计出ROP方案如下：

1. 利用g1、g2，将`esp`设为存储`setuid()`地址的栈帧顶A，`ebp`设为栈帧底A
2. 利用g1，pop掉作为`setuid()`的参数0
3. 利用g1、g2，将`esp`设为存储`system()`地址的栈帧顶B，`ebp`设为0

|栈结构 |
| :--------: |
| shell address |
| exit()     |
| system()（此处作为栈帧顶B） |
| 栈帧底B=0（此处作为栈帧底A） |
| g2   |
| 栈帧顶B |
|  g1  |
|0（setuid的第一个参数） |
|  g1   |
| setuid（此处作为栈帧顶A） |
| 栈帧底A |
|g2|
|栈帧顶A|
| g1 |
| ebp of bof |
