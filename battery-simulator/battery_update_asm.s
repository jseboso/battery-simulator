## Mirror of batt_update.c, however made in assembly
.text
.global  set_batt_from_ports
        
set_batt_from_ports:

    # movX    SOME_GLOBAL_VAR(%rip), %reg

    # load global variable into register
    # Check the C type of the variable
    #    char / short / int / long
    # and use one of
    #    movb / movw / movl / movq 
    # and appropriately sized destination register   

    movw  BATT_VOLTAGE_PORT(%rip), %dx   # copy global var to reg dx  (16-bit word)
    movb  BATT_STATUS_PORT(%rip), %cl    # copy global var to reg cl  (8-bit byte)

    # check if batt voltage < 0, jump to error if true
    cmpw $0,%dx
    jl error
    # CORRECT ^^^

    # move battery voltage into r10
    movw %dx,%r10w
    # shift r10 right 1 bit
    sar $1,%r10w
    # move r10 into batt->mlvolts
    movw %r10w,0(%rdi)

    # subtract 3000 from r10
    sub $3000,%r10w
    # shift r10 right 3 bit
    sar $3,%r10w
    # move r10 into batt->percent
    movb %r10b,2(%rdi)


    # move battery status into r11
    movb %cl,%r11b
    # shift r11 right 4 bits
    shrb $4,%r11b
    # isolate least significant digit
    andb $0b00000001,%r11b
    # move r11 to batt->mode
    movb %r11b,3(%rdi)


    # check if volts < 3000
    cmpw $3000,0(%rdi)
    jl if1

    # check if volts > 3800
    cmpw $3800,0(%rdi)
    jg if2

    # continue to next block
    jmp set_batt_continued

error:
    # moves 1 into return value
    movl $1,%eax

    # return
    ret

if1:
    # moves 0 into batt->percent
    movb $0,2(%rdi)
    jmp set_batt_continued

if2:
    # moves 100 into batt->percent
    movb $100,2(%rdi)
    jmp set_batt_continued

if3:
    # moves 2 into batt->mode
    movb $2,3(%rdi)

    # jumps to final block
    jmp set_batt_final

set_batt_continued:
    # checks if batt->mode == 0
    cmpb $0,3(%rdi)
    # jumps to if3
    je if3

    # jumps to final block
    jmp set_batt_final

set_batt_final:
    # moves 0 into return value
    movl $0,%eax
    ret
    

.data

temp_display:                  # declare another int accessible via name 'temp_display'
    .int 0

bit_masks:                   # declare multiple ints sequentially starting at location
    .int 0b0111111 # pattern associated with 0
    .int 0b0000110
    .int 0b1011011
    .int 0b1001111
    .int 0b1100110
    .int 0b1101101
    .int 0b1111101
    .int 0b0000111
    .int 0b1111111
    .int 0b1101111 # pattern associated with 9


# WARNING: Don't forget to switch back to .text as below
# Otherwise you may get weird permission errors when executing 
.text
.global  set_display_from_batt

# ENTRY POINT FOR REQUIRED FUNCTION
set_display_from_batt:  
    ## assembly instructions here

	## two useful techniques for this problem
    movl    temp_display(%rip),%ecx    # moving temp_display into ecx
    leaq    bit_masks(%rip),%rbx  # load pointer to beginning of bit_masks into rbx

    # batt_t structure is in %rdi
    # integer pointer is in %rsi

    # moving and isolating batt.mlvolts into r8w
    # movl %edi,%r8d
    # andl $0b00000000000000001111111111111111,%r8d
    # use %r8w for batt.mlvolts

    # moving and isolating batt.percent into r8b
    # movl %edi,%r8d
    # shift r8 right 16 bits
    # shrl $16,%r8d
    # andl $0b00000000000000000000000011111111,%r8d
    # use %r8b for batt.percent

    # moving and isolating batt.mode into r8b
    # movl %edi,%r8d
    # shift r8 right 16 bits
    # shrl $24,%r8d
    # andl $0b00000000000000000000000011111111,%r9d
    # use %r8b for batt.mode

    # moving and isolating batt.percent into r8b
    movl %edi,%r8d
    # shift r8 right 16 bits
    shrl $16,%r8d
    andl $0b00000000000000000000000011111111,%r8d
    # use %r8b for batt.percent

    # setting left battery display
    # checking if batt.percent >= 5
    cmpb $5,%r8b
    jge batt_percent_5


    jmp set_disp_continued


batt_percent_5:
    # updates bit 24
    orl $0b00000001000000000000000000000000,%ecx

    # checking if batt.percent >= 30
    cmpb $30,%r8b
    jge batt_percent_30

    jmp set_disp_continued

batt_percent_30:
    # updates bit 24-25
    orl $0b00000011000000000000000000000000,%ecx

    # checking if batt.percent >= 50
    cmpb $50,%r8b
    jge batt_percent_50

    jmp set_disp_continued

batt_percent_50:
    # updates bit 24-26
    orl $0b00000111000000000000000000000000,%ecx

    # checking if batt.percent >= 70
    cmpb $70,%r8b
    jge batt_percent_70

    jmp set_disp_continued

batt_percent_70:
    # updates bit 24-27
    orl $0b00001111000000000000000000000000,%ecx

    # checking if batt.percent >= 90
    cmpb $90,%r8b
    jge batt_percent_90

    jmp set_disp_continued

batt_percent_90:
    # updates bit 24-28
    orl $0b00011111000000000000000000000000,%ecx

    jmp set_disp_continued

set_disp_continued:

    # moving and isolating batt.mode into r8b
    movl %edi,%r8d
    # shift r8 right 16 bits
    shrl $24,%r8d
    andl $0b00000000000000000000000011111111,%r9d
    # use %r8b for batt.mode

    # check if batt.mode is 1 (percent)
    cmpb $1,%r8b
    je batt_mode_1

    # check if batt.mode is 2 (volts)
    cmpb $2,%r8b
    je batt_mode_2

    jmp error2

error2:
    # moving 1 into return value
    movl $1,%eax
    ret

batt_mode_1:

    # set percent bits on *display (ecx)
    orl $0b001,%ecx

    # RIGHT DIGIT
    
    # moving and isolating batt.percent into r8b
    movl %edi,%r8d
    # shift r8 right 16 bits
    shrl $16,%r8d
    andl $0b00000000000000000000000011111111,%r8d
    # use %r8b for batt.
    
    # move batt.percent into rdx and rax
    movq %r8,%rdx
    movq %r8,%rax

    cwtl           # sign extend ax to long word
    cltq           # sign extend eax to quad word
    cqto           # sign extend ax to dx

    movq $10,%r9
    idivq %r9

    movq (%rbx,%rdx,4),%r10
    shll $3,%r10d
    
    orl %r10d,%ecx

    # END RIGHT DIGIT

    # middle digit if statement

    cmpb $100,%r8b
    jge if_above_100

    cmpb $10,%r8b
    jge if_above_10

    jmp set_disp_final

if_above_100:
    # moving and isolating batt.percent into r8b
    movl %edi,%r8d
    # shift r8 right 16 bits
    shrl $16,%r8d
    andl $0b00000000000000000000000011111111,%r8d
    # use %r8b for batt.
    
    # move batt.percent into rdx and rax
    movq %r8,%rdx
    movq %r8,%rax

    cwtl           # sign extend ax to long word
    cltq           # sign extend eax to quad word
    cqto           # sign extend ax to dx

    movq $100,%r9

    idivq %r9

    movq (%rbx,%rax,4),%r10
    shll $17,%r10d

    orl %r10d,%ecx

    cmpb $10,%r8b
    jge if_above_10

    jmp set_disp_final


if_above_10:

    # MIDDLE DIGIT
    # moving and isolating batt.percent into r8b
    movl %edi,%r8d
    # shift r8 right 16 bits
    shrl $16,%r8d
    andl $0b00000000000000000000000011111111,%r8d
    # use %r8b for batt.
    
    # move batt.percent into rdx and rax
    movq %r8,%rdx
    movq %r8,%rax

    cwtl           # sign extend ax to long word
    cltq           # sign extend eax to quad word
    cqto           # sign extend ax to dx

    movq $10,%r9

    idivq %r9

    movq %rax,%rdx

    cwtl           # sign extend ax to long word
    cltq           # sign extend eax to quad word
    cqto           # sign extend ax to dx

    idivq %r9

    movq (%rbx,%rdx,4),%r10
    shll $10,%r10d
    
    orl %r10d,%ecx

    jmp set_disp_final

batt_mode_2:
    # set volts bits on *display (ecx)
    orl $0b110,%ecx

    # moving and isolating batt.mlvolts into r8w
    movl %edi,%r8d
    andl $0b00000000000000001111111111111111,%r8d
    # use %r8w for batt.mlvolts

    # CALCULATING RIGHTDIGIT

    # move r8 into rdx and rax
    movq %r8,%rdx

    addl $5,%edx
    

    movq %rdx,%rax

    cwtl           # sign extend ax to long word
    cltq           # sign extend eax to quad word
    cqto           # sign extend ax to dx

    # move 10 into r9
    movq $10,%r9

    # divide by 10
    idivq %r9

    movq %rax,%rdx

    cwtl           # sign extend ax to long word
    cltq           # sign extend eax to quad word
    cqto           # sign extend ax to dx

    # move 10 into r9
    # movq $10,%r9

    # divide by 10
    idivq %r9
    # rdx holds remainder, eax has int division result
    # rdx now has rightDigit!

    movq (%rbx,%rdx,4),%r10
    shll $3,%r10d
    
    orl %r10d,%ecx

    # RIGHT DIGIT END

    # MIDDLE DIGIT BEGIN
    
    # move r8 into rdx and rax
    movq %r8,%rdx
    

    movq %rdx,%rax

    cwtl           # sign extend ax to long word
    cltq           # sign extend eax to quad word
    cqto           # sign extend ax to dx

    # move 100 into r9
    movq $100,%r9

    # divide by 100
    idivq %r9

    movq %rax,%rdx

    cwtl           # sign extend ax to long word
    cltq           # sign extend eax to quad word
    cqto           # sign extend ax to dx

    # move 10 into r9
    movq $10,%r9

    # divide by 10
    idivq %r9
    # rdx holds remainder, eax has int division result
    # rdx now has rightDigit!

    movq (%rbx,%rdx,4),%r10
    shll $10,%r10d
    
    orl %r10d,%ecx

    # MIDDLE DIGIT END
    
    # LEFT DIGIT BEGIN

    # move r8 into rdx and rax
    movq %r8,%rdx
    movq %r8,%rax
    
    cwtl           # sign extend ax to long word
    cltq           # sign extend eax to quad word
    cqto           # sign extend ax to dx

    movq $1000,%r9

    idivq %r9

    movq (%rbx,%rax,4),%r10

    shll $17,%r10d

    orl %r10d,%ecx

    # END LEFT DIGIT
    

    jmp set_disp_final

set_disp_final:

    # moving temp_display into display pointer
    movl %ecx,0(%rsi)
    # movl %ecx,0(%esi)

    # moving 0 into return value
    movl $0,%eax
    ret


.text
.global batt_update
   
# ENTRY POINT FOR REQUIRED FUNCTION
batt_update:
	# assembly instructions here
    
    # pushing empty batt_t struct onto stack
    pushq $0

    movq %rsp,%rdi

    call    set_batt_from_ports   # stack aligned, call function
    # return val from func in rax or eax

    # check if set_batt's return value isnt 0
    cmpl $0,%eax
    jne error3
    # jump to error if value != 0

    # GOOD UNTIL HERE

    movq 0(%rsp),%rdi
    # deferencing batt_t

    # pushing batt_display into the stack
    pushq  BATT_DISPLAY_PORT(%rip)

    # movl %esp,%esi
    movq %rsp,%rsi

    call    set_display_from_batt

    # dereferencing batt_t struct into r10
    movl 0(%rsi),%r10d
    # setting batt_display_port equal to r10
    movl %r10d,BATT_DISPLAY_PORT(%rip)

    addq    $16,%rsp     # shrink the stack to restore it to its original position

    movq $0,%rax
    ret

error3:
    addq    $8,%rsp
    # return output of 1
    movl $1,%eax
    ret