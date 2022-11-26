    ;;    game state memory location
    .equ CURR_STATE, 0x1000              ; current game state
    .equ GSA_ID, 0x1004                  ; gsa currently in use for drawing
    .equ PAUSE, 0x1008                   ; is the game paused or running
    .equ SPEED, 0x100C                   ; game speed
    .equ CURR_STEP,  0x1010              ; game current step
    .equ SEED, 0x1014                    ; game seed
    .equ GSA0, 0x1018                    ; GSA0 starting address
    .equ GSA1, 0x1038                    ; GSA1 starting address
    .equ SEVEN_SEGS, 0x1198              ; 7-segment display addresses
    .equ CUSTOM_VAR_START, 0x1200        ; Free range of addresses for custom variable definition
    .equ CUSTOM_VAR_END, 0x1300
    .equ LEDS, 0x2000                    ; LED address
    .equ RANDOM_NUM, 0x2010              ; Random number generator address
    .equ BUTTONS, 0x2030                 ; Buttons addresses

    ;; states
    .equ INIT, 0
    .equ RAND, 1
    .equ RUN, 2

    ;; constants
    .equ N_SEEDS, 4
    .equ N_GSA_LINES, 8
    .equ N_GSA_COLUMNS, 12
    .equ MAX_SPEED, 10
    .equ MIN_SPEED, 1
    .equ PAUSED, 0x00
    .equ RUNNING, 0x01

main:
    ;; TODO

font_data:
    .word 0xFC ; 0
    .word 0x60 ; 1
    .word 0xDA ; 2
    .word 0xF2 ; 3
    .word 0x66 ; 4
    .word 0xB6 ; 5
    .word 0xBE ; 6
    .word 0xE0 ; 7
    .word 0xFE ; 8
    .word 0xF6 ; 9
    .word 0xEE ; A
    .word 0x3E ; B
    .word 0x9C ; C
    .word 0x7A ; D
    .word 0x9E ; E
    .word 0x8E ; F

seed0:
    .word 0xC00
    .word 0xC00
    .word 0x000
    .word 0x060
    .word 0x0A0
    .word 0x0C6
    .word 0x006
    .word 0x000

seed1:
    .word 0x000
    .word 0x000
    .word 0x05C
    .word 0x040
    .word 0x240
    .word 0x200
    .word 0x20E
    .word 0x000

seed2:
    .word 0x000
    .word 0x010
    .word 0x020
    .word 0x038
    .word 0x000
    .word 0x000
    .word 0x000
    .word 0x000

seed3:
    .word 0x000
    .word 0x000
    .word 0x090
    .word 0x008
    .word 0x088
    .word 0x078
    .word 0x000
    .word 0x000

    ;; Predefined seeds
SEEDS:
    .word seed0
    .word seed1
    .word seed2
    .word seed3

mask0:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF

mask1:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x1FF
	.word 0x1FF
	.word 0x1FF

mask2:
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF

mask3:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000

mask4:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000

MASKS:
    .word mask0
    .word mask1
    .word mask2
    .word mask3
    .word mask4


; BEGIN:procedure_name
procedure_name:
    ; your implementation code
    ret
; END:procedure_name

; BEGIN:clear_leds
clear_leds:
    stw zero, LEDS(zero)
    stw zero, LEDS+4(zero)
    stw zero, LEDS+8(zero)
    ret
; END:clear_leds

; BEGIN:set_pixel
set_pixel:
    addi t0, a0, 0          ; t0 = x-pos
    addi t1, a1, 0          ; t1 = y-pos
    addi t2, zero, LEDS     ; t2 = led array address
    addi t3, zero, 4        ; t3 = number of columns in a led array
    jmpi loop1_cond
loop1:                      ; to choose the right led array, perform x mod 4 calculus
    sub t0, t0, t3          ; x -= 4
    add t2, t2, t3          ; (quotient of x/4) += 1, hence address t2 += 4
loop1_cond:
    bgeu t0, t3, loop1      ; check if x >= 4
    ldw t4, 0(t2)           ; t4 = load the led array at address t2
    slli t0, t0, 3          ; t0 = (x mod 4) * 8
    add t5, t0, t1          ; t5 = (x mod 4) * 8 + y
    addi t6, zero, 1        ; t6 = 1
    sll t6, t6, t5          ; t6 = shift the '1' at the right place
    or t7, t4, t6           ; t7 = turn on the led
    stw t7, 0(t2)           ; MEM(t2) = t7
    ret
; END:set_pixel

; BEGIN:wait
wait: 
    addi t0, zero, 1            ; initial counter of 2e19: set to 1 then ssli 19 
    slli t0, t0, 19             ; times since 2e19 can't be represent with 16 bits
loop2:
    ldw t1, SPEED(zero)         ; decrement of the counter depends on the game speed
    sub t0, t0, t1
    bne t0, zero, loop2
    ret
; END:wait

; --------------------------------------------- JEREMY

; BEGIN:get_gsa
get_gsa:
    ldw t0, GSA_ID(zero)
    sll t1, a0, 2                     ; t1 = a0 * 4 
    ldw v0, GSA0(t1)                  ; v0 = MEM(a0 * 4 + GSA0)
    beq t0, zero, end_get_gsa         ; end if GSA_ID = 0
    ldw v0, GSA1(t1)                  ; v0 = MEM(a0 * 4 + GSA1)
end_get_gsa: 
    ret
; END:get_gsa

; BEGIN:set_gsa
set_gsa:
    ldw t0, GSA_ID(zero)
    bne t0, zero, set_id1         ; jump to set_id1 if GSA_ID = 1
set_id0:
    sll t0, a0, 2                 ; t0 = a0 * 4 
    stw a1, GSA0(t0)              ; MEM(a0 * 4 + GSA0) = a1 
    jmpi end_set_gsa
set_id1:
    sll t0, a0, 2                 ; t0 = a0 * 4 
    stw a1, GSA1(t0)              ; MEM(a0 * 4 + GSA1) = a1
end_set_gsa: 
    ret
; END:set_gsa

; BEGIN:random_gsa
random_gsa:
    addi sp, sp, -4                 ; make space for the return address
    stw ra, 0(sp)                   ; put on the stack the return value
    ldw t0, GSA_ID(zero)            ; t0 = current GSA in use. Note: unused since choice of GSA delegated to set_gsa
    addi t1, zero, 0                ; t1 = current array number
    addi t2, zero, 0                ; t2 = current pixel number
    addi t3, zero, 0                ; t3 = the generated array 
    addi t4, zero, N_GSA_LINES      ; t4 = number of lines in a gsa
    addi t5, zero, N_GSA_COLUMNS    ; t5 = number of columns in a gsa  
    
    jmpi generate_pixel
next_pixel:
    addi t2, t2, 1            ; t2 += 1 : next pixel
    beq t2, t5, next_array    ; evaluate if next array, i.e. if t2 == N_GSA_COLUMNS
generate_pixel:
    ldw t0, RANDOM_NUM(zero)  ; t0 = draw a random number
    andi t0, t0, 1            ; t0 = t0 % 2
    slli t3, t3, 1            ; shift left logical by 1 the generated array t3
    or t3, t3, t0             ; copy the generated pixel in the array
    jmpi next_pixel
next_array:
    addi a0, t1, 0               ; a0 = t1 : put the array number in reg a0
    addi a1, t3, 0               ; a1 = t3 : put the generated array in reg a1
    call set_gsa
    addi t2, zero, 0             ; t2 = 0 : reset pixel counter
    addi t3, zero, 0             ; t3 = 0 : reset the generated array
    addi t1, t1, 1               ; t1 += 1 : next array
    bne t1, t4, generate_pixel   ; evaluate if generate pixel, i.e. if t1 != N_GSA_LINES

    ldw ra, 0(sp)           ; load the previous return address
    addi sp, sp, 4          ; update the stack pointer
    ret
; END:random_gsa

; BEGIN:change_speed
change_speed:
    ldw t0, SPEED(zero)         ; t0 = load game speed from memory
    addi t1, zero, MIN_SPEED    ; t1 = min speed
    addi t2, zero, MAX_SPEED    ; t2 = max speed
    bne a0, zero, decrease      ; branch depending on whether increasing or decreasing
increase:
    beq t0, t1, end_change_speed   ; branch if already max speed
    addi t0, t0, 1                 ; t0 += 1 
    jmpi end_change_speed
decrease:
    beq t0, t2, end_change_speed   ; branch if already min speed
    addi t0, t0, -1                ; t0 += -1       
end_change_speed:
    stw t0, SPEED(zero)    ; save speed in memory
    ret
; END:change_speed

; BEGIN:pause_game
pause_game:
    ldw t0, PAUSE(zero)     ; t0 = load game pause from memory
    addi t1, zero, 1        ; t1 = 1
    xor t2, t0, t1          ; t2 = t0 xor 1 to invert the bits
    and t0, t2, t1          ; t0 = only the first bit xored
    stw t0, PAUSE(zero)     ; save game pause in memory
    ret
; END:pause_game

; BEGIN:change_steps
change_steps:
    addi t0, a0, 0              ; t0 = the units
    addi t1, a1, 0              ; t1 = the tens         
    addi t2, a2, 0              ; t2 = the hundreds
    addi t3, zero, 0xF          ; t3 = max and mask
    addi t4, zero, 0            ; t4 = the carry
    addi t5, zero, 1            ; t5 = the mask to extract the carry
    slli t5, t5, 4   
    ldw t6, CURR_STEP(zero)     ; t6 = the current step

    ; filter the digits of the current step
    and t0, t6, t3              ; t0 = the units
    slli t3, t3, 4              ; shift the mask by 4 positions
    and t1, t6, t3              ; t1 = the tens
    srli t1, t1, 4
    slli t3, t3, 4              ; shift the mask by 4 positions         
    and t2, t6, t3              ; t2 = the hundreds
    srli t2, t2, 8
    addi t3, zero, 0xF          ; reset the mask

add_units:
    add t0, t0, a0              ; perform the addition if the corresponding button is pressed 
    and t4, t0, t5              ; t4 = extract the carry for the tens if any
    srli t4, t4, 4  
    and t0, t0, t3              ; t0 = the 4 LSB of the addition, that is the new units digit
add_tens:
    add t1, t1, a1              ; perform the addition if the corresponding button is pressed 
    add t1, t1, t4              ; perform the addition with the carry if any
    and t4, t1, t5              ; t4 = extract the carry for the hundreds if any
    srli t4, t4, 4  
    and t1, t1, t3              ; t4 = the 4 LSB of the addition, that is the new tens digit
add_hundreds:
    add t2, t2, a2              ; perform the addition if the corresponding button is pressed 
    add t2, t2, t4              ; perform the addition with the carry if any
    and t2, t2, t3              ; t4 = the 4 LSB of the addition, that is the new hundreds digit (don't care about the carry)

end_change_steps:
    slli t2, t2, 8
    slli t1, t1, 4
    or t2, t2, t1
    or t2, t2, t0
    stw t2, CURR_STEP(zero)     ; save the changed steps
    ret
; END:change_steps

; BEGIN:increment_seed
increment_seed:
    addi sp, sp, -4         ; make space for the return address
    stw ra, 0(sp)           ; put on the stack the return value
    ldw t0, SEED(zero)          ; t0 = retrieve the current game seed from memory
    addi t1, zero, INIT         ; t1 = tag for init state
    addi t2, zero, RAND         ; t2 = tag for random state
    addi t3, zero, N_GSA_LINES  ; t3 = number of lines in the GSA
    addi t4, zero, 0            ; t4 = counter for the GSA lines when copy the seed in state_init
    addi t5, zero, SEEDS        ; t5 = the seed address
    ldw t6, CURR_STATE(zero)    ; t6 = retrieve the current game state from memory
    addi t7, zero, N_SEEDS      ; t7 = the number of seeds

    beq t6, t2, state_rand      ; decide where to branch according to the state

state_init:
    beq t0, t7, set_random_gsa
    addi t0, t0, 1          
    stw t0, SEED(zero)      ; MEM(SEED) += 1
    beq t0, t7, set_random_gsa
    sll t0, t0, 2           ; t0 *= 4 : shift left logical by 2 of the seed number to have a valid address
    add t5, t5, t0          ; t5 = get the address of the particular seed in use
    jmpi copy_seed
next_seed:
    addi t4, t4, 1          ; t4 += 1 : next line in the GSA
    beq t4, t3, end_increment_seed
copy_seed:
    addi a0, t4, 0          ; a0 = t4 : put the array number in reg a0
    sll t7, t4, 2           ; t7 = t4 * 4 : sll by 2 of t4 to have a valid address
    add t7, t7, t5          ; t7 = t7 + t5 : address of the t4-th seed
    addi a1, t7, 0          ; a1 = t7 : put the retrieved seed in reg a1
    call save_stack
    call set_gsa
    call retrieve_stack
    jmpi next_seed
set_random_gsa:
    call random_gsa
end_increment_seed:
    ldw ra, 0(sp)           ; load the previous return address
    addi sp, sp, 4          ; update the stack pointer
    ret
save_stack:
    addi sp, sp, -32       ; sp -= 32 : prepare for pushing eight words
    stw t0, 28(sp) 
    stw t1, 24(sp)   
    stw t2, 20(sp) 
    stw t3, 16(sp)   
    stw t4, 12(sp)  
    stw t5, 8(sp) 
    stw t6, 4(sp)  
    stw t7, 0(sp)
    ret
retrieve_stack:
    ldw t7, 0(sp)
    ldw t6, 4(sp)
    ldw t5, 8(sp)
    ldw t4, 12(sp)
    ldw t3, 16(sp)
    ldw t2, 20(sp)
    ldw t1, 24(sp)
    ldw t0, 28(sp)
    addi sp, sp, 32      ; sp == 32 : eight words were popped
    ret
; END:increment_seed

; BEGIN:update_state
update_state:
    ;a0 has a 32-bit word s.t. the 5 LSB's are the bits decribing if the button is pressed or not
    ;and t0, a0, 0x1F           ;takes the 5 LSB's from a0
    ldw t1, CURR_STATE(zero)    ;get the current state
    addi t2, zero, 0            ;iter to compare game state
    bne t1, t2, notInit
    addi t2, zero, N_SEEDS      ;to check if b0=N
    ldw t3, SEED(zero)          ;get the seed number
    and t0, a0, 1               ;check if b0 is pressed
    beq t0, zero, notPressed_US
    addi t3, t3, 1              ;incremented seed by 1 since b0 was pressed
    bne t3, t2, exit_US
    addi t1, t1, 1              ;b0=N, state INIT=0 goes to state RAND=1
    stw t1, CURR_STATE(zero)    ;store the new current state
    jmpi exit_US
    notPressed_US:
        and t0, a0, 2           ;check if b1 is pressed
        beq t0, zero, exit_US   ;if not pressed, then do nothimg
        addi t1, t1, 2          ;b1 is pressed, state INIT=0 goes to state RUN=2
        jmpi exit_US
    notInit_US:
        addi, t2, t2, 1         ;iter to compare game state    
        bne t1, t2, runState_US
        and t0, a0, 2           ;check if b1 is pressed
        beq t0, zero, exit_US
        addi t1, t1, 1          ;b1 is pressed, state RAND=1 goes to state RUN=2
        stw t1, CURR_STATE(zero);store the new current state
        jmpi exit_US
    runState_US:
        ldw t2, CURR_STEP(zero) ;load the current step
        beq t2, zero, endSteps_US
        and t0, a0, 8           ;check if b3 is pressed
        beq t0, zero, exit_US
        addi t1, zero, 0        ;b3 is pressed, state RUN=2 goes to state INIT=0
        addi sp, sp, -4         ;make space for the return address
        stw ra, 0(sp)           ;put on the stack the return value
        call reset_game
        ldw ra, 0(sp)           ;load the previous return address
        addi sp, sp, 4          ;update the stack pointer
        jmpi exit_US
        endSteps_US:
            addi t1, zero, 0    ;no more steps, state RUN=2 goes to state INIT=0
            addi sp, sp, -4         ;make space for the return address
            stw ra, 0(sp)           ;put on the stack the return value
            call reset_game
            ldw ra, 0(sp)           ;load the previous return address
            addi sp, sp, 4          ;update the stack pointer
            jmpi exit_US

    exit_US:

    ret
;END:update_state

; BEGIN:select_action
select_action:
    addi sp, sp, -4         ; make space for the return address
    stw ra, 0(sp)           ; put on the stack the return value
    ldw t0, CURR_STATE(zero)    ; t0 = current game state
    addi t1, zero, INIT         ; t1 = tag for init state
    addi t2, zero, RAND         ; t2 = tag for random state
    addi t3, zero, RUN          ; t3 = tag for random state
    addi t5, zero, 1            ; t5 = 1 for the reference and masking
    
    beq t0, t1, select_init_rand
    beq t0, t2, select_init_rand
    beq t0, t3, select_run
    jmpi end_select_action
retrieve_buttons:
    slli t5, t5, 4
    and t0, a0, t5
    srli t5, t5, 1
    and t1, a0, t5
    srli t5, t5, 1
    and t2, a0, t5
    srli t5, t5, 1
    and t3, a0, t5
    srli t5, t5, 1
    and t4, a0, t5
    ret
select_init_rand:               ; if current state is init state or random state
    call retrieve_buttons
    bne t0, t5, but234_init_rand
    call save_stack
    call increment_seed         ; call increment_seed if button 0 is pressed
    call retrieve_stack
but234_init_rand:
    add a0, zero, t4
    add a1, zero, t3
    add a2, zero, t2
    call change_steps           ; call change_steps with which button is pressed
    jmpi end_select_action    
select_run:                     ; if current state is run state
    call retrieve_buttons
    bne t0, t5, but12_run
    call pause_game
but1_run:
    bne t1, t5, but2_run
    addi a0, zero, 0
    call change_speed
but2_run:
    bne t2, t5, but4_run
    addi a0, zero, 1
    call change_speed
but4_run:
    bne t4, t5, but4_run
    call increment_seed 

save_stack:
    addi sp, sp, -32       ; sp -= 32 : prepare for pushing eight words
    stw t0, 28(sp) 
    stw t1, 24(sp)   
    stw t2, 20(sp) 
    stw t3, 16(sp)   
    stw t4, 12(sp)  
    stw t5, 8(sp) 
    stw t6, 4(sp)  
    stw t7, 0(sp)
    ret
retrieve_stack:
    ldw t7, 0(sp)
    ldw t6, 4(sp)
    ldw t5, 8(sp)
    ldw t4, 12(sp)
    ldw t3, 16(sp)
    ldw t2, 20(sp)
    ldw t1, 24(sp)
    ldw t0, 28(sp)
    addi sp, sp, 32      ; sp == 32 : eight words were popped
    ret
end_select_action:
    ldw ra, 0(sp)           ; load the previous return address
    addi sp, sp, 4          ; update the stack pointer
    ret
; END:select_action

; BEGIN:cell_fate
cell_fate:
    bne a1, zero, isAlive_CF        ;the cell is alive
    addi t0, zero, 3                ;put 3 in register t0
    addi t1, zero, 2                ;put 2 in register t1
    bne a0, t0, exit_CF             ;check if population is equal to 3
    addi v0, zero, 1                ;cell was dead and has exactly 3 live neighbors, so becomes alive
    jmpi exit_CF
    isAlive_CF:
        blt a0, t1, cellDies_CF     ;alive cell has underpopulation around it
        blt t0, a0, cellDies_CF     ;alive cell has overpopulation around it
        addi v0, zero, 1            ;alive cell has 2 or 3 alive neighbors, so stays alive
        jmpi exit_CF
        cellDies_CF:
            addi v0, zero, 0
            jmpi exit_CF
    exit_CF:

    ret
;END:cell_fate

; BEGIN:find_neighbors
find_neighbors:
    addi sp, sp, -8                 ;make space on the stack
    stw a0, 4(sp)                   ;store the x-coord
    stw a1, 0(sp)                   ;store the y-coord
    ;add a0, zero, a1                ;put the y-coord in a0
    addi t0, zero, 1                ;iter over 3 lines
    add t1, zero, a1                ;put y-coord in register t1
    addi t2, zero, -2               ;for the break
    loop_FN:
        addi sp, sp, -16
        stw t0, 12(sp)               ;put iter in stack
        stw t1, 8(sp)               ;put y-coord in stack
        stw t2, 4(sp)               ;put break point in stack
        stw ra, 0(sp)               ;store the return address
        add a0, t1, t0              ;line: y + t0
        call get_gsa
        ldw ra, 0(sp)
        ldw t2, 4(sp)
        ldw t1, 8(sp)
        ldw t0, 12(sp)
        addi sp, sp, 16
        addi sp, sp, -4             
        stw v0, 0(sp)               ;store the GSA of line y + t0
        addi t0, t0, -1             ;decrease iter by 1
        bne t0, t2, loop_FN         ;if iter != -2 then loop
    ldw t0, 0(sp)                   ;GSA line: y-1
    ldw t1, 4(sp)                   ;GSA line: y
    ldw t2, 8(sp)                   ;GSA line: y+1
    ldw a1, 12(sp)                  ;y-coord
    ldw a0, 16(sp)                  ;x-coord
    addi sp, sp, 20                 ;reset stack pointer

    addi a0, a0, -1                 ;bring the x to minus one position

    srl t0, t0, a0                  ;have the three coordinates at the 3 LSBs
    andi t0, t0, 7                  ;mask the rest 
    srl t1, t1, a0
    andi t1, t1, 7
    srl t2, t2, a0
    andi t2, t2, 7

    addi t3, zero, 3                ;iterator
    addi t4, zero, 0                ;iterator for shifts
    addi t5, zero, 0                ;to store the bit we are looking at
    addi v0, zero, 0                ;counter for neighbors

    iterX_FN:
        srl t5, t0, t4
        andi t5, t5, 1
        bne t5, zero, incrNeigh1_FN
        addi v0, v0, 1
        incrNeigh1_FN:
        srl t5, t1, t4
        andi t5, t5, 1
        bne t5, zero, incrNeigh2_FN
        addi, v0, v0, 1
        incrNeigh2_FN:
        srl t5, t2, t4
        andi t5, t5, 1
        bne t5, zero, incrNeigh3_FN
        addi v0, v0, 1
        incrNeigh3_FN:
        addi t3, t3, -1
        addi t4, t4, 1
        bne t3, zero, iterX_FN

    srli t5, t1, 1              ;get the value of the cell (x, y) to the LSB
    and t5, t5, 1               ;mask the rest
    add v1, zero, t5            ;store if the cell is alive or not
    addi t5, t5, 1              ;to compare if the cell is alive or not
    bne v1, t5, exit_FN
    addi, v0, v0, -1            ;if the the cell is alive, must deduce by 1 to not count the target cell as a neighbor
    exit_FN:
    ret
;END:find_neighbors

; BEGIN:update_gsa
update_gsa:
    ldw t1, PAUSE(zero)                 ; t1 = load the word containing if the game is paused
    beq t1, zero, end_update_gsa        ; the procedure should not do anything if the game is paused  

    addi sp, sp, -4                     ; make space for the return address
    stw ra, 0(sp)                       ; put on the stack the return value
    ldw t0, GSA_ID(zero)                ; t0 = load the current gsa_id
    
    addi t2, zero, N_GSA_LINES          ; t2 = number of lines in a gsa
    addi t3, zero, N_GSA_COLUMNS        ; t3 = number of columns in a gsa
    addi t4, zero, N_GSA_COLUMNS - 1    ; t4 = x-pos (we run the array backwards)
    addi t5, zero, 0                    ; t5 = y-pos
    addi t6, zero, 0                    ; t6 = the new array

next_pixel:
    addi t4, t4, -1             ; t4 += 1 : next pixel
    blt t4, zero, next_array    ; evaluate if next array, i.e. if t4 < 0
generate_pixel:
    addi a0, t4, 0          ; put in the right registers the coordinates
    addi a1, t5, 0
    call save_stack
    call find_neighbours
    addi a0, v0, 0
    addi a1, v1, 0
    call cell_fate              ; retrieve the fate of cell at pos (t4, t5)
    call retrieve_stack
    slli t6, t6, 1
    or t6, t6, v0               ; add the fate to the array
    jmpi next_pixel
next_array:
    addi a0, t5, 0                      ; a0 = t5 = y-pos : put the array number in reg a0
    addi a1, t6, 0                      ; a1 = t6 : put the generated array in reg a1
    call set_gsa_inversed
    addi t4, zero, N_GSA_COLUMNS - 1    ; t4 = 11 : reset pixel counter
    addi t6, zero, 0                    ; t6 = 0 : reset the generated array
    addi t5, t5, 1                      ; t5 += 1 : next array
    bne t5, t2, generate_pixel          ; evaluate if generate pixel, i.e. if t5 != N_GSA_LINES
    jmpi invert_gsa_id

set_gsa_inversed:
    ldw t0, GSA_ID(zero)            ; t0 = load the current gsa_id
    beq t0, zero, set_inversed_id1  ; jump to set_inversed_id1 if GSA_ID = 0
set_inversed_id0:
    sll t0, a0, 2                   ; t0 = a0 * 4 
    stw a1, GSA0(t0)                ; MEM(a0 * 4 + GSA0) = a1 
    jmpi end_set_gsa_inversed
set_inversed_id1:
    sll t0, a0, 2                   ; t0 = a0 * 4 
    stw a1, GSA1(t0)                ; MEM(a0 * 4 + GSA1) = a1
end_set_gsa_inversed: 
    ret

; inverting the gsa_id once the update is done
invert_gsa_id:
    ldw t0, GSA_ID(zero)    ; t0 = load the current gsa_id
    addi t7, zero, 1        ; t7 = 1 for the reference
    xor t7, t0, t7          ; invert the gsa_id
    stw t0, GSA_ID(zero)
    jmpi retrieve_address

save_stack:
    addi sp, sp, -32       ; sp -= 32 : prepare for pushing eight words
    stw t0, 28(sp) 
    stw t1, 24(sp)   
    stw t2, 20(sp) 
    stw t3, 16(sp)   
    stw t4, 12(sp)  
    stw t5, 8(sp) 
    stw t6, 4(sp)  
    stw t7, 0(sp)
    ret
retrieve_stack:
    ldw t7, 0(sp)
    ldw t6, 4(sp)
    ldw t5, 8(sp)
    ldw t4, 12(sp)
    ldw t3, 16(sp)
    ldw t2, 20(sp)
    ldw t1, 24(sp)
    ldw t0, 28(sp)
    addi sp, sp, 32      ; sp == 32 : eight words were popped
    ret

retrieve_address:
    ldw ra, 0(sp)           ; load the previous return address
    addi sp, sp, 4          ; update the stack pointer
end_update_gsa:
    ret
; END:update_gsa

; --------------------------------------------- SEB
;; BEGIN:wait
;wait: 
;    addi t0, zero, 0x80000
;    loop:
;        addi t0, t0, -1
;        bne t0, zero, loop
;    ret
;; END:wait

; BEGIN:get_gsa
get_gsa:
    ldw t0, GSA_ID(zero)
    andi a0, a0, 7              ;does a modulo 8
    bne t0, zero, gamesa1_1
    slli a0, a0, 2              ;do y*4 to get a valid address
    ldw v0, GSA0(a0)
    jmpi end
    gamesa1_1:
        ldw v0, GSA1(a0)
    end:
    ret
; END:get_gsa

; BEGIN:set_gsa
set_gsa:
    ldw t0, GSA_ID(zero)
    bne t0, zero, gamesa1_2
    slli a1, a1, 2              ;do y*4 to get a valid address
    stw a0, GSA0(a1)
    jmpi end
    gamesa1_2:
        stw a0, GSA1(a1)
    end:
    
    ret
; END:set_gsa

; BEGIN:set_pixel
set_pixel:
    ;GSA[y][x] = LEDS[checkmod][y + 8*(xmod4)]
    addi t5, zero, 0
    
    ret
; END:set_pixel

; BEGIN:draw_gsa
draw_gsa:

    call clear_leds
    addi t2, zero, N_GSA_LINES-1        ;max for y axis
    addi a0, zero, 0                    ;argument for x
    addi a1, zero, 0                    ;argument for y
    addi t7, zero, 1                    ;mask
    
    loop_draw_gsa1:                     ;iter lines
        addi t1, zero, N_GSA_COLUMNS-1  ;max for x axis
        add a0, t1, zero                ;put the value of the line in a0
        blt t2, zero, exit
        call get_gsa                    ;gsa of line y in v0
        loop_draw_gsa2:                 ;iter columns
            srl t3, v0, t1              ;shift right to get the bit in LSB
            and t3, t3, t7              ;apply mask to get only LSB
            add a0, t1, zero            ;put the column value in a0
            add a1, t2, zero            ;put the line value in a1
            bne t3, zero, set_pixel     ;set pixel if the LSB is 1
            addi t1, t1, -1             ;decrement by 1
            blt t1, zero, loop_draw_gsa1;check if not out of bounds
            jmpi loop_draw_gsa2         ;jump if not yet complet

    exit:

    ret
; END:draw_gsa
