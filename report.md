# 汇编程序设计实验

## 实验简介

### 学生信息

杨雅儒，无73，2017011071 。

### 实验目的

* 了解MIPS处理器的硬件结构，学会用底层思维实现指令需求
* 学会如何调试汇编程序

### 实验任务

实现三个汇编程序——冒泡排序、快速排序以及归并排序。

### 实验环境及注意事项

在本机Linux上进行测试，使用vim编写，MARS运行。**另外麻烦助教注意一下，由于本机Linux上的mips不支持相对路径，于是使用了一个绝对路径`\home\yyr\Work\asm\a.in`。提交的代码以本地能够正常执行为准，故希望助教测试时首先更改代码首部的文件名字符串。**

## 测试

### 程序内部的调试代码

首先是在三个程序内部写了调试代码，会在命令行输出排序前和排序后的数组。

### view.cpp

view.cpp，用于显示二进制文件（while不停读取4bytes直到文件结尾），用法为：

```
./view a.in
```

### check.cpp

**对拍程序，用C++实现，可以自动地不停测试数据**，用法：

```
./check QuickSort.s
```

## 实验流程及算法思路

### 冒泡排序

总体即按照课件上的C代码实现，使用`Arr: .space 4050`创建了足够大的数组，书写了主函数、sort函数、chswap函数以及调试用的printArrToScreen函数。

#### 主函数

主函数做的工作就是从文件中读入数组，然后调用sort函数进行排序，再将数组写入到文件，最后结束程序（需要注意文件读写后需要关闭文件）。

#### sort函数

参数：$a0传入数组基址，$a1传入n。

内容：sort函数做的工作就是利用冒泡排序的算法，对整个Arr数组进行从小到大排序。冒泡一共进行n轮，每轮从右向左冒泡，其中利用chswap函数进行判断并确定是否交换数组的两相邻位置。

#### ckswap函数

参数：$a0传入表示可能交换$a0和$a0+4地址的值 (不满足顺序时交换)。

内容：判断内存中$a0地址的值是否大于$a0+4地址的值，若是则进行交换。

#### printArrToScreen函数

参数：$a0传入数组基址，$a1传入n表示数组长度。

内容：将整个数组以空格间隔的形式输出到屏幕，并且最后输出换行符。


### 快速排序




### 归并排序

## 问题总结

* **调试时回转到上一步可能会出问题**，例如文件打开时，回转到syscall之前再向下运行则会出现打开失败的情况。
* 在Linux系统下，文件打开时 "./a.in" 似乎不行，改成绝对路径即可运行；而在Windows系统下，测试中使用"a.in"可以。
* 开数组的时候，在.data下使用类似 `Arr:     .space  4050`，但要注意**数组要开在其它东西前面否则会出错**，具体原因暂不清楚。

## 附：代码

### 冒泡排序

```
.data
	Arr:     .space 4050
	space:   .asciiz " "
	line:    .asciiz "\n"
	infile:  .asciiz "/home/yyr/Work/asm/a.in"
	outfile: .asciiz "/home/yyr/Work/asm/a.out"

.text
.global main

main:   
	li    $v0, 13
	la    $a0, infile
	li	  $a1, 0       #读取
	li	  $a2, 0       #模式，设定为0即可
	syscall
	addu  $a0, $0, $v0
	li    $v0, 14
	la	  $a1, Arr
	li    $a2, 4       #读取四个字节，为n
	syscall
	la    $a1, Arr
	lw    $s1, 0($a1)  #s1=n
	li    $v0, 14
	la	  $a1, Arr
	sll   $a2, $s1, 2
	syscall			   #读取数组
	li    $v0, 16  
	syscall			   #关闭文件

	la	  $a0, Arr
	move  $a1, $s1
	jal   printArrToScreen  #调试

	la    $a0, Arr
	move  $a1, $s1
	jal   sort         #排序

	la	  $a0, Arr
	move  $a1, $s1
	jal   printArrToScreen  #调试

	li    $v0, 13
	la    $a0, outfile
	li	  $a1, 1       #写入
	li	  $a2, 0       #模式，设定为0即可
	syscall
	addu  $a0, $0, $v0
	li    $v0, 15
	la	  $a1, Arr
	sll   $a2, $s1, 2
	syscall
	li    $v0, 16  
	syscall			   #关闭文件

	li    $v0, 10
	syscall		       # exit


sort: # a0传入数组基址，a1传入n
	addu  $t0, $0, $a0 # t0为基址
	addu  $t1, $0, $a1 # t1=n
	li    $t2, 0	   # t2=0 作为i
loopi:
	sll   $t3, $t1, 2  # t3 初始赋为倒数第二个位置的地址
	addu  $t3, $t3, $t0
	subi  $t3, $t3, 8
loopj:
	addu  $a0, $0, $t3 # a0=t3 (当前地址)
	addu  $s0, $0, $ra # 暂存ra
	jal   ckswap	   # 调用ckswap进行判断
	addu  $ra, $0, $s0 # 还原ra
	subiu $t3, $t3, 4
	bleu  $t0, $t3, loopj # t0(基址)<=t3(当前地址)时跳转到loopj

	addiu $t2, $t2, 1  # t2=t2+1
	blt	  $t2, $t1, loopi     # t2(i)<t1(n) 时跳转到loopi
	jr    $ra


ckswap: # a0传入表示可能交换a0和a0+4地址的值 (不满足顺序时交换)
	lw    $t8, 0($a0)
	lw    $t9, 4($a0)
	ble   $t8, $t9, exitSwap  #t8<=t9时跳转到exitSwap(即不交换)
	sw    $t8, 4($a0)
	sw    $t9, 0($a0)
exitSwap:
	jr    $ra

printArrToScreen:         # a0传入数组基址，a1传入n
	addu  $t6, $0, $a0     # t6存基址
	addu  $t7, $0, $a1     # t7存n
	li    $t8, 0          # t8(i)=0
loop:
	sll   $t9, $t8, 2
	addu  $t9, $t9, $t6   # t9赋值为目标地址
	li    $v0, 1
	lw    $a0, 0($t9) 
	syscall				  # 打印数字
	li	  $v0, 4
	la	  $a0, space
	syscall				  # 打印空格
	addiu $t8, $t8, 1     # i=i+1
	blt   $t8, $a1, loop  # t8(i)<a1(n)时跳转到loop
	li	  $v0, 4
	la	  $a0, line		  # 打印换行
	syscall
	jr    $ra
```

### 快速排序

```
.data
	Arr:     .space 4050
	space:   .asciiz " "
	line:    .asciiz "\n"
	infile:  .asciiz "/home/yyr/Work/asm/a.in"
	outfile: .asciiz "/home/yyr/Work/asm/a.out"

.text
.global main

main:   
	li    $v0, 13
	la    $a0, infile
	li	  $a1, 0       #读取
	li	  $a2, 0       #模式，设定为0即可
	syscall
	addu  $a0, $0, $v0
	li    $v0, 14
	la	  $a1, Arr
	li    $a2, 4       #读取四个字节，为n
	syscall
	la    $a1, Arr
	lw    $s1, 0($a1)  #s1=n
	li    $v0, 14
	la	  $a1, Arr
	sll   $a2, $s1, 2
	syscall			   #读取数组
	li    $v0, 16  
	syscall			   #关闭文件

	la	  $a0, Arr
	move  $a1, $s1
	jal   printArrToScreen  #调试

	la    $a0, Arr
	li    $a1, 0
	subi  $a2, $s1, 1
	jal   sort         #排序

	la	  $a0, Arr
	move  $a1, $s1
	jal   printArrToScreen  #调试

	li    $v0, 13
	la    $a0, outfile
	li	  $a1, 1       #写入
	li	  $a2, 0       #模式，设定为0即可
	syscall
	addu  $a0, $0, $v0
	li    $v0, 15
	la	  $a1, Arr
	sll   $a2, $s1, 2
	syscall
	li    $v0, 16  
	syscall			   #关闭文件

	li    $v0, 10
	syscall		       # exit


sort: # a0传入数组基址，a1传入left, a2传入right
	move  $t0, $a0		#t0存数组基址
	move  $t1, $a1		#t1存left
	move  $t2, $a2		#t2存right
	move  $t3, $t1      #t3(i)=t1(left)
	move  $t4, $t2      #t4(j)=t2(right)
	add   $t5, $t3, $t4
	srl   $t5, $t5, 1    
	sll   $t5, $t5, 2
	add   $t5, $t5, $t0
	lw    $t5, 0($t5)   #t5(mid)=Arr[(i+j)/2]
sortLoop:				#while(i<=j)
startLoopi:
	sll   $t6, $t3, 2
	add   $t6, $t6, $t0
	lw    $t6, 0($t6)   #t6=Arr[i]
	bge   $t6, $t5, endLoopi
	addiu $t3, $t3, 1   #t3(i)=t3(i)+1
	b     startLoopi
endLoopi:				#while(arr[i]<mid)
startLoopj:	
	sll   $t6, $t4, 2
	add   $t6, $t6, $t0
	lw    $t6, 0($t6)   #t6=Arr[j]
	ble   $t6, $t5, endLoopj
	subi  $t4, $t4, 1   #t4(j)=t4(j)-1
	b     startLoopj
endLoopj:				#while(arr[j]>mid)
	bgt   $t3, $t4, endIf1  #t3(i)>t4(j)时跳出
	sll   $t6, $t3, 2
	add   $t6, $t6, $t0
	lw    $t8, 0($t6)   #t8=Arr[i]
	sll   $t7, $t4, 2
	add   $t7, $t7, $t0
	lw    $t9, 0($t7)   #t9=Arr[j]
	sw    $t8, 0($t7)   #Arr[j]=t8
	sw    $t9, 0($t6)   #Arr[i]=t9
	addiu $t3, $t3, 1   #t3(i)=t3(i)+1
	subi  $t4, $t4, 1   #t4(j)=t4(j)-1
endIf1:
	bge   $t1, $t4, endIf2  #t1(left)>=t4(j)时跳出
	subi  $sp, $sp, 28
	sw	  $t0, 0($sp)
	sw	  $t1, 4($sp)
	sw	  $t2, 8($sp)
	sw	  $t3, 12($sp)
	sw	  $t4, 16($sp)
	sw	  $t5, 20($sp)
	sw	  $ra, 24($sp)
	move  $a0, $t0
	move  $a1, $t1
	move  $a2, $t4
	jal   sort          #sort(Arr,left,j)
	lw	  $ra, 24($sp)
	lw	  $t5, 20($sp)
	lw	  $t4, 16($sp)
	lw	  $t3, 12($sp)
	lw	  $t2, 8($sp)
	lw	  $t1, 4($sp)
	lw	  $t0, 0($sp)
	addi  $sp, $sp, 28
endIf2:
	bge   $t3, $t2, endIf3  #t3(i)>=t2(right)时跳出
	subi  $sp, $sp, 28
	sw	  $t0, 0($sp)
	sw	  $t1, 4($sp)
	sw	  $t2, 8($sp)
	sw	  $t3, 12($sp)
	sw	  $t4, 16($sp)
	sw	  $t5, 20($sp)
	sw	  $ra, 24($sp)
	move  $a0, $t0
	move  $a1, $t3
	move  $a2, $t2
	jal   sort          #sort(Arr,i,right)
	lw	  $ra, 24($sp)
	lw	  $t5, 20($sp)
	lw	  $t4, 16($sp)
	lw	  $t3, 12($sp)
	lw	  $t2, 8($sp)
	lw	  $t1, 4($sp)
	lw	  $t0, 0($sp)
	addi  $sp, $sp, 28
endIf3:
	jr    $ra

printArrToScreen:         # a0传入数组基址，a1传入n
	addu  $t6, $0, $a0     # t6存基址
	addu  $t7, $0, $a1     # t7存n
	li    $t8, 0          # t8(i)=0
printLoop:
	sll   $t9, $t8, 2
	addu  $t9, $t9, $t6   # t9赋值为目标地址
	li    $v0, 1
	lw    $a0, 0($t9) 
	syscall				  # 打印数字
	li	  $v0, 4
	la	  $a0, space
	syscall				  # 打印空格
	addiu $t8, $t8, 1     # i=i+1
	blt   $t8, $a1, printLoop  # t8(i)<a1(n)时跳转到printLoop
	li	  $v0, 4
	la	  $a0, line		  # 打印换行
	syscall
	jr    $ra
```
