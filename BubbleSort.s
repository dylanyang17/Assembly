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
