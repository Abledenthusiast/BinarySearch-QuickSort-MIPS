        # Program sorts an unordered array of integers using quickSort then searches for a value using binary search
        #	the first index is returned as 0 
        #	the last index is the size of the list - 1
        # Version: 11/29  
        # 
        #      by Aaron P
            
            .data
            .align  2
values:     .word  4, 6, 7, 9, 16, 2, 5, 8, 9, 19, 1, 7, 8, 13, 18, 1, 9, 14, 16, 20, 1, 2, 9, 11, 18, 11, 14, 15, 16, 100,
	   .word  4, 6, 7, 9, 16, 2, 5, 50, 9, 19, 29, 13, 21, 9, 16, 2, 5, 8, 9, 19
	   .word 
	   
valCount:  .word   50
space: 	.asciiz ", "
theList:	.asciiz "The list: "
strFound:	.asciiz "Target was found at index: "
targetprmpt:	.asciiz "Enter your target value: "
Line: .asciiz "\n"

#-------------------------------------------------------------------------------------------------------------------------------

        .text
        .globl  main
      

main:     
        lw      $s1, valCount  # s2: number of values to sum (n)
        la  	$s2, values     # get array address
        # print list:
        li	$v0, 4
	la	$a0, theList
	syscall
	# print out entire unorted array	
        move	$a0, $s2
        move	$a1, $s1
        jal	printList
 # call sort routine       
       	la	$a0, values
       	li	$a1, 0
       	lw	$a2, valCount
       	# length - 1
       	addi	$a2, $a2, -1
        jal 	quickSort
   	# print sorted list
	li	$v0, 4
	la	$a0, theList
	syscall
	
	move	$a0, $s2
        move	$a1, $s1
        jal	printList
#-----------------------------
#	Main target search loop 
mainLoop:
       #------ Get integer input from the user
        li      $v0, 51              
        la      $a0, targetprmpt
        syscall       
        # keep searching while input not 0
 	beq	$a0, $zero, done
 	
        move	$a2, $a0	# Move the target input into function parameter
      
        la	$a0, values
        lw	$a1, valCount
        jal	binarySearch
        #--------NOTE----------
        # this part extracts the actual index from the address
        # if return value != -1 print the index
        bne	$v0, -1, targetTrue
        li	$v0, 1
	li	$a0, -1
	syscall
	j	continue
targetTrue:
        la	$s0, values
        move 	$s1, $v0
        #Print where list was found         
        li	$v0, 4
	la	$a0, strFound
	syscall        
        # extract index from base address offset
        sub	$a0, $s1, $s0
        srl	$a0, $a0, 2   
        li	$v0, 1
        syscall
continue:  
	# print new line and continue with prompt
	li	$v0, 4
	la	$a0, Line
	syscall    
        j	mainLoop
done:      	
	# end the program 
	
	li	$v0, 10		
        syscall   
                                                                                                                                                                                        
# void quickSort
# a0 address of array
# a1 first element	(i)
# a2 last element    (j)  

# t0 = i
# t1 = j
# t3 = pivot

# s0 = left
# s1 = right	      		      	
quickSort:
	addi    $sp, $sp, -12        # allocate stack space for 3 values
        sw      $ra, 0($sp)         # store off the return addr, etc 
        sw      $s0, 4($sp)
        sw	$s1, 8($sp)
#------------------------------------------------------
	# i = left
	# j = right
	move 	$t0, $a1
	move 	$t1, $a2
	# save left and right values
	move 	$s0, $a1
	move 	$s1, $a2
	# index offset for middle
	add	$t3, $t0, $t1	
	div	$t3, $t3, 2
	mul	$t3, $t3, 4
	# array[left+right/2] -- pivot
	add	$t3, $t3, $a0	# add pivot index (with offset) to array's base address
	lw	$t3, 0($t3) # pivot value at array[left+right/2]
partition:	
	# while ( i <= j )
	bgt	$t0, $t1, endPartition
	
	
whileI:
	# get array[i]
	mul	$t5, $t0, 4
	add	$t5, $t5, $a0		
		
	lw	$t5, 0($t5)
	# while ( array[i] <= pivot )
	bge	$t5, $t3, whileJ
	addi	$t0, $t0, 1
	j	whileI

whileJ:	
	# get array[j]
	mul 	$t2, $t1, 4
	add	$t2, $a0, $t2
	lw	$t2, 0($t2)
	# while ( array[j] <= pivot )
	ble	$t2, $t3, contB
	addi	$t1, $t1, -1
	j	whileJ
contB:
	# if (i <= j)
	bgt	$t0, $t1, partition
	# swap section
	mul 	$t2, $t0, 4	# array [i]
	mul 	$t6, $t1, 4	# array [j]
	
	add	$t2, $t2, $a0
	add	$t6, $t6, $a0
	
	lw	$t7, 0($t2)	# array[i]
	lw	$t4, 0($t6)	# array[j]
	
	sw	$t7, 0($t6)	# array[j] = array[i]
	sw	$t4, 0($t2)	# array[i] = array[j]
	
	addi	$t0, $t0, 1
	addi	$t1, $t1, -1
		
	j 	partition	
endPartition:	
	# recursively sort the rest of the list

	bge	$s0, $t1, ifRight	# if left  < j
	la	$a0, values
	move	$a1, $s0
	move	$a2, $t1
	# quicksort(array, left, j)
	jal	quickSort	

ifRight:	
	bge	$t0, $s1, endQS	# if i < right
	la	$a0, values
	move	$a1, $t0
	move	$a2, $s1
	# quicksort(array, i, right)
	jal	quickSort
endQS:		 
#-------- END ------------	
        lw      $ra, 0($sp)         # load the return addr, etc 
        lw      $s0, 4($sp)
        lw	$s1, 8($sp)
	addi    $sp, $sp, 12 
	jr 	$ra
	
#-------- void printList ------------		
#a0: theList
#a1: length of list	
printList: 

	addi    $sp, $sp, -4        # allocate stack space for 1 value
        sw      $ra, 0($sp)         # store off the return addr, etc 
#---------------------------------------------        
	li	$t1, 0
	move	$t3, $a0
	move	$t2,$a1
		
prntLoop:
	bge	$t1,$t2 prntEnd	# i < valCount; i++
	
	
	#print list[i]
	lw	$a0, 0($t3)	
	li	$v0, 1		
	syscall 
#-------------------------------------------------	
	addi	$t1, $t1, 1	#i++
	addi	$t3, $t3, 4	#update pointer
	beq $t1, $t2 prntEnd	#print ", " while not the last index
	li	$v0, 4
	la	$a0, space
	syscall 

	
	j	prntLoop
prntEnd: 
	li	$v0, 4
	la	$a0, Line
	syscall 
 # load return addr and reset stack 
 #--------------------------------- 	
	lw      $ra, 0($sp) 
	addi    $sp, $sp, 4       
 
	jr $ra
	
#----------- Binary Search -------------------------------        
     #	move $t0, $a0		# a0  address of array
     #	move $t1, $a1		# a1  size of array
     #	move $t2, $a2		# a2  target
binarySearch:
	addi    $sp, $sp, -4        # allocate stack space for 1 value
        sw      $ra, 0($sp)         # store off the return addr, etc 
        #------------------
     # t3 = middle address
     # t5 = middle index
     #----------------------    	
     	move     $t0, $a0                # bottom
        move     $t1, $a1	         #  n
        

       
        
        div	$t3, $t1, 2	#t3 = middle
        move	$t5, $t3 	# save middle for later
        
        mul	$t3, $t3, 4 	# get address of middle value
        add	$t3, $t3, $a0	# t3 = base address + middle address
        lw	$t4, 0($t3)	# load actual value of middle index into t4
        
      	beq	$t1, 1, baseCase # only 1 index left
        
        #-----------------------
     	bne	$a2, $t4,notFound
     		j found
    notFound:
    	bgt	$a2, $t4,largerThanMid
    	
    	move	$a0, $t0 # bottom address   
    #	addi	$t5, $t5, -1 # top = mid - 1	
    	move	$a1, $t5
    #	move	$a2, $a2
    	#recusive call: binarySearch(middle of array, size/2, 
    	jal	binarySearch
    	move 	$t3, $v0
    	j endBS
    largerThanMid:
    	addi	$t3, $t3, 4 # mid = mid + 1... but in address mode
    	move	$a0, $t3  # bottom address is middle + 1
    	move	$a1, $t5	
    	#recusive call: binarySearch(middle of array, size/2, 
    	jal	binarySearch
    	move 	$t3, $v0
    	j endBS
    
     found:
     	move $v0, $t3
     	j endBS
     	
     baseCase:
     	bne	$a2, $t4, sadEnding
     	 move $v0, $t3
     	 j endBS
    sadEnding:
    	li $v0, -1
     endBS:
	#--------------------------
	lw      $ra, 0($sp)         # restore the return address, etc    
        addi    $sp, $sp, 4
	
	jr $ra
