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
	move  $a0, $s2
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

	move  $a0, $s3
	jal   sort
	move  $s3, $v0

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
	move  $t8, $a0
	move  $t9, $a1
	li    $v0, 9
	li    $a0, 8
	syscall			   #新建一个虚拟结点head
	sw    $t8, 4($v0)  #next指针初始为l_head
	move  $t0, $v0     #t0作为p_left
	move  $t1, $t9     #t1作为p_right
	move  $t2, $v0     #t2作为head
mergeLoop1:
mergeLoop2:
	lw    $t9, 4($t0)  #t9=p_left->next
	beqz  $t9, endMergeLoop2
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
mergeLoop3:
	lw    $t9, 4($t3)  #t9=p_right_temp->next
	beqz   $t9, endMergeLoop3
	lw    $t9, 0($t9)  #t9=t9->val
	lw    $t8, 4($t0)  #t8=p_left->next
	lw    $t8, 0($t8)  #t8=t8->val
	bgt   $t9, $t8, endMergeLoop3
	lw    $t3, 4($t3)  #p_right_temp=p_right_temp->next
	b     mergeLoop3
endMergeLoop3:
	lw    $t4, 4($t3)  #t4作为temp_right_pointer_next
	lw    $t9, 4($t0)  #t9=p_left->next
	sw    $t9, 4($t3)  #p_right_temp->next=p_left->next
	sw    $t1, 4($t0)  #p_left->next=p_right
	move  $t0, $t3     #p_left=p_right_temp
	move  $t1, $t4     #p_right=temp_right_pointer_next
	beqz  $t1, endMergeLoop1  # if(p_right==NULL) break;
	b     mergeLoop1
endMergeLoop1:
	lw    $v0, 4($t2)  #return head->next
	jr    $ra


sort: #传入a0表示首指针head，传回v0表示排序后的首指针
	move  $t0, $a0     #t0作为head
	lw    $t9, 4($t0)  #t9=head->next
	bnez  $t9, endSortIf1
	move  $v0, $a0
	jr    $ra		   #return head;
endSortIf1:
	move  $t1, $t0     #t1作为stride_1_pointer
	move  $t2, $t0     #t2作为stride_2_pointer
sortLoop1:
	lw    $t9, 4($t2)  #t9=stride_2_pointer->next
	beqz  $t9, endSortLoop1
	move  $t2, $t9     #stride_2_pointer=t9
	lw    $t9, 4($t2)  #t9=stride_2_pointer->next
	beqz  $t9, endSortLoop1
	move  $t2, $t9     #stride_2_pointer=t9
	lw    $t1, 4($t1)  #stride_1_pointer=stride_1_pointer->next
	b     sortLoop1
endSortLoop1:
	lw    $t2, 4($t1)  #stride_2_pointer=stride_1_pointer->next
	sw    $0,  4($t1)  #stride_1_pointer->next=NULL

	move  $a0, $t0
	subi  $sp, $sp, 16
	sw    $t0, 0($sp)
	sw    $t1, 4($sp)
	sw    $t2, 8($sp)
	sw    $ra, 12($sp)
	jal   sort
	lw    $ra, 12($sp)
	lw    $t2, 8($sp)
	lw    $t1, 4($sp)
	lw    $t0, 0($sp)
	addiu $sp, $sp, 16
	move  $t3, $v0     #t3作为l_head=msort(head);

	move  $a0, $t2
	subi  $sp, $sp, 20
	sw    $t0, 0($sp)
	sw    $t1, 4($sp)
	sw    $t2, 8($sp)
	sw    $t3, 12($sp)
	sw    $ra, 16($sp)
	jal   sort
	lw    $ra, 16($sp)
	lw    $t3, 12($sp)
	lw    $t2, 8($sp)
	lw    $t1, 4($sp)
	lw    $t0, 0($sp)
	addiu $sp, $sp, 20
	move  $t4, $v0     #t4作为r_head=msort(stride_2_pointer);

	move  $a0, $t3
	move  $a1, $t4
	subi  $sp, $sp, 4
	sw    $ra, 0($sp)
	jal   merge
	lw    $ra, 0($sp)
	addiu $sp, $sp, 4
	jr    $ra          #return merge(l_head,r_head);


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
