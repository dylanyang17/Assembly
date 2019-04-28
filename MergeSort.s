.data
	num:     .space 4
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
	move  $s2, $v0     #s2=fd
	move  $a0, $s2
	li    $v0, 14
	la	  $a1, num 
	li    $a2, 4       #读取四个字节，为n
	syscall
	lw    $s1, 0($a1)  #s1=n

	li    $v0, 9
	li    $a0, 8
	syscall			   #新建一个结点
	sw    $0, 4($v0)   #next指针初始为0
	move  $s3, $v0     #s3存放首指针
	move  $s4, $s3     #s4存放当前指针
	
	li    $v0, 14
	la    $a1, num
	li    $a2, 4
	syscall
	lw    $s7, 0($a1)  #s7临时存储读入的一个数
	sw    $s7, 0($s3)  #放入首指针的数据中
	li    $s5, 2	   #s5存放循环变量i

inputLoop:
	bgl   $s5, $s1, endInputLoop  #s5(i)>s1(n)时退出循环
	li    $v0, 9
	li    $a0, 8
	syscall			   #新建一个结点
	sw    $0,  4($v0)  #next指针初始为0
	sw    $v0, 4($s4)  #上一个位置的next指向当前结点地址
	move  $s4, $v0     #s4=v0，指向当前位置
	
	li    $v0, 14
	move  $a0, $s2
	la    $a1, num
	li    $a2, 4
	syscall
	lw    $s7, 0($a1)  #s7临时存储读入的一个数
	sw    $s7, 0($s4)  #放入当前结点的数据中

	addiu $s5, $s5, 1
	b     inputLoop
endInputLoop:
	move  $a0, $s2     #a0=s2(fd)
	li    $v0, 16  
	syscall			   #关闭文件


	move  $a0, $s3
	jal   printListToScreen  #调试

# TODO:调用排序函数

	move  $a0, $s3
	jal   printListToScreen  #调试

	li    $v0, 13
	la    $a0, outfile
	li	  $a1, 1       #写入
	li	  $a2, 0       #模式，设定为0即可
	syscall
	move  $s2, $v0     #s2=fd
	move  $s4, $s3     #s4指向当前位置
outputLoop:
	
	


	move  $a0, $v0
	li    $v0, 15
	la	  $a1, Arr
	sll   $a2, $s1, 2
	syscall
	li    $v0, 16  
	syscall			   #关闭文件

	li    $v0, 10
	syscall		       # exit

printListToScreen:         # a0传入链表首地址
	addu  $t6, $0, $a0     # t6存当前地址
printLoop:
	li    $v0, 1
	lw    $a0, 0($t6) 
	syscall				  # 打印数字
	li	  $v0, 4
	la	  $a0, space
	syscall				  # 打印空格
	lw    $t6, 4($t6)
	bnz   $t6, printLoop  # 下一个非空的时候继续循环
	li	  $v0, 4
	la	  $a0, line		  # 打印换行
	syscall
	jr    $ra
