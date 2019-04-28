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
	bgt   $s5, $s1, endInputLoop  #s5(i)>s1(n)时退出循环
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
	li    $v0, 15
	move  $a0, $s2
	move  $a1, $s4
	li    $a2, 4
	syscall            #输出当前结点数据
	lw    $s4, 4($s4)  #s4=s4->next
	bnez   $s4, outputLoop

	li    $v0, 16  
	syscall			   #关闭文件

	li    $v0, 10
	syscall		       # exit


merge: # a0传入左链表首地址l_head，a1传入右链表首地址r_head，v0传出合并后链表首地址
	li    $v0, 9
	li    $a0, 8
	syscall			   #新建一个虚拟结点head
	sw    $a0, 4($v0)  #next指针初始为l_head
	move  $t0, $v0     #t0作为p_left
	move  $t1, $a1     #t1作为p_right
	move  $t2, $v0     #t2作为head
mergeLoop1:
mergeLoop2:
	lw    $t9, 4($t0)  #t9=p_left->next
	bez   $t9, endMergeLoop2
	lw    $t9, 0($t9)  #t9=t9->val
	lw    $t8, 0($t1)  #t8=p_right->val
	bgt   $t9, $t8, endMergeLoop2
	lw    $t0, 4($t0)  #p_left=p_left->next
	b     mergeLoop2
endMergeLoop2:
	lw    $t9, 4($t0)  #t9=p_left->next
	bnez  $t9, endMergeIf1
	sw    $t1, 4($t0)  #p_left->next=p_right
	b     endMergeLoop1 #break
endMergeIf1:
	move  $t3, $t1     #t3作为p_right_temp
endMergeLoop1:
	
	


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
	bnez   $t6, printLoop  # 下一个非空的时候继续循环
	li	  $v0, 4
	la	  $a0, line		  # 打印换行
	syscall
	jr    $ra
