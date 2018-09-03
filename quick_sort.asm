.data
    dateName:    .align 5
    		 .asciiz "Joe"
    		 .align 5
    		 .asciiz "Jenny"
    		 .align 5
    		 .asciiz "Jill"
    		 .align 5
    		 .asciiz "John"
    		 .align 5
    		 .asciiz "Jeff"
    		 .align 5
    		 .asciiz "Joyce"
    		 .align 5
    		 .asciiz "Jerry"
    		 .align 5
    		 .asciiz "Janice"
    		 .align 5
    		 .asciiz "Jake"
    		 .align 5
    		 .asciiz "Jonna"
    		 .align 5
    		 .asciiz "Jack"
    		 .align 5
    		 .asciiz "Jocelyn"
    		 .align 5
    		 .asciiz "Jessie"
    		 .align 5
    		 .asciiz "Jess"
    		 .align 5
    		 .asciiz "Janet"
    		 .align 5
    		 .asciiz "Jane"
    dataAddr:    .align 2 #addresses should start on a word boundary
    		 .space 64 #16 pointers to strings: 16*4 = 64
    size:        .word   16  #size = 16
    blank:	 .asciiz " "
    left_bracket:.asciiz "["
    right_bracket:.asciiz " ]\n"
    string1:     .asciiz "Initial array:\n"
    string2:     .asciiz "Sorted array:\n"
    null:        .asciiz ""
    zero:        .word 0
    
.text
    main:
	la $s0, dateName
	la $s1, dataAddr
	lw $s2, size
	la $s3, null
	# $s4, $s5 are used later

    
    ##Initialize the array of dataName and dataAddr
    	# $t0 = dataName
    	add $t0, $zero, $s0 
    	# $t1 = dataAddr
    	add $t1, $zero, $s1
    	# $t2 = size = 16
	add $t2, $zero, $s2
	
    Initialize:  	
	sw $t0, ($t1)
	addi $t0, $t0, 32
	addi $t1, $t1, 4
	addi $t2, $t2, -1
	
	bgtz $t2, Initialize
	
    	##print the initial array
    	# printf("Initial array:\n");
        li $v0, 4
        la $a0, string1
        syscall
        
       
        add $a1, $zero, $s1 # starting address of array of data to be printed
	add $a2, $zero, $s2 # initialize loop counter to array size
	jal Print #Print the initialize array
	
	##do quick sort
	# $a1 = data, $a2 = size
	add $a1, $zero, $s1
	add $a2, $zero, $s2
	jal QuickSort
	
	##print  the sorted array
	li $v0, 4 
        la $a0, string2
        syscall
	
	add $a1, $zero, $s1 #starting address of array of data to be printed  
	add $a2, $zero, $s2 #initialize loop counter to array size
	jal Print
	
	li $v0, 10
	syscall

##Print function
Print:
	add $t1, $zero, $a1 #starting address of array of data to be printed
	add $t2, $zero, $a2 #initialize loop counter to array size
	
	# printf("[")
	li $v0, 4
	la $a0, left_bracket
	syscall
	

printloop:
	#Print out blank, " "
	li $v0, 4
	la $a0, blank
	syscall
	
	#Print out element
	li $v0, 4
	lw $a0, 0($t1)
	syscall
	
	# for (int i = 0; i < size; i++)
	addi $t1, $t1, 4 #increase address of data to be printed
	addi $t2, $t2, -1 #decrement loop counter
	bgtz $t2, printloop   #repeat while not finished

	#print out " ]"
	li $v0, 4
	la $a0, right_bracket
	syscall
	
	jr $ra #return

##str_lt Function
str_lt:
	move $t4, $a1 #pass argument pointer s4
	move $t5, $a2 #pass argument pointer s5
	lb $t1, 0($t4) #transfer pointer into value: $t1 = *x
	lb $t2, 0($t5) #transfer pointer into value: $t2 = *y
	move $t3, $zero#store '\0'
    str_lt_loop:
    	beq $t1, $t3, done
    	beq $t2, $t3, done
    	# if ( *x < *y ) return 1;
	blt $t1, $t2, return1
	# if ( *y < *x ) return 0;
	bgt $t1, $t2, return0
	addi $t4, $t4, 1
	addi $t5, $t5, 1
	lb $t1, 0($t4) #transfer pointer into value
	lb $t2, 0($t5) #transfer pointer into value
	j str_lt_loop
	
    done: 
    	beq $t2, $t3, return0
    	bne $t2, $t3, return1
    	
    return1:
        addi $v1, $zero, 1
        jr $ra
    return0:
        addi $v1, $zero, 0
        jr $ra

##swap_str_ptrs function
swap_str_ptrs:
	move $t1, $a0 #pass argument pointer a0(s1)
	move $t2, $a3 #pass argument pointer a3(s2)
	lw $t3, 0($t1) #store *s1
	lw $t4, 0($t2) #store *s2
	sw $t3, 0($t2) # exchange
	sw $t4, 0($t1) # exchange
	jr $ra

##Quick Sort Function
QuickSort:
	# adjust stack for 2 items
	subu $sp, $sp, 4
	# save the return address
	sw $ra, 0($sp)
	
	# $t4 = the address of dataAddr
	add $s4, $zero, $a1
	# $t2 = the size, len
	add $s5, $zero, $a2
	#Base Case
	ble $s5, 1, quicksortdone # return if len <= 1
	
	# set $s0 = len - 1
	sub $s0, $s5, 1
	# set $s6 = pivot = 0
	move $s6, $zero
	# set $s7 = i = 0
	move $s7, $zero 
	
    loop:
    	# for (int i = 0; i < len - 1; i++)
    	bge $s7, $s0, loopdone
    	
    	mul $t6, $s7, 4
    	add $t6, $s4, $t6
    	#$a1 = a[i]
    	lw $a1, 0($t6)
    	
    	mul $t6, $s0, 4
    	add $t6, $s4, $t6
    	#$a2 = a[len-1]
    	lw $a2, 0($t6)

    	jal str_lt

    	
    	beq $v1, 1, continue
    	# i++
    	addi $s7, $s7, 1
    	j loop
    	
    continue:
    	mul $t6, $s7, 4
    	add $t6, $s4, $t6 # change $a0 into &a[i]
    	move $a0, $t6
    	
    	mul $t6, $s6, 4
    	add $t6, $s4, $t6
    	move $a3, $t6 #change $a3 into &a[pivot]
    	
    	jal swap_str_ptrs
    	addi $s6, $s6, 1
    	addi $s7, $s7, 1
    	j loop
    	
    loopdone:
    	mul $t6, $s6, 4
    	add $t6, $s4, $t6
    	move $a0, $t6 #change $a0 into &a[pivot]
    	
    	mul $t6, $s0, 4
    	add $t6, $s4, $t6
    	move $a3, $t6 #change $a3 into &a[len - 1]

    	jal swap_str_ptrs
    	
    	#Recursion
    	
    	addi $sp, $sp, -12
	sw $s4, 0($sp)
    	sw $s5, 4($sp)
    	sw $s6, 8($sp)

	# quick_sort(a, pivot)
    	move $a1, $s4
    	move $a2, $s6
    	jal QuickSort

	lw $s4, 0($sp)
    	lw $s5, 4($sp)
    	lw $s6, 8($sp)
    	addi $sp, $sp, 12
    	
    	#quick_sort(a + pivot + 1, len - pivot - 1)
    	# set a + pivot + 1
    	addi $t6, $s6, 1
    	mul $t6, $t6, 4
	add $a1, $s4, $t6
	# set len - pivot - 1
	sub $t6, $s5, $s6
	subi $a2, $t6, 1
    	
    	jal QuickSort 
    	
   	
    quicksortdone:
    	lw $ra, 0($sp)

     	addi $sp, $sp, 4
     	# return address
     	jr $ra
