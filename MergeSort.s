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
