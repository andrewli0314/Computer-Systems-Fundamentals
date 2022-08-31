########################################################################
# COMP1521 21T2 -- Assignment 1 -- Minesweeper!
#
#
# !!! IMPORTANT !!!
# Before starting work on the assignment, make sure you set your tab-width to 8!
# !!! IMPORTANT !!!
#
#
# This program was written by Jiayang Li (z53337892)
# on 31/10/21
#
# Version 1.5 (18-10-21): Team COMP1521 <cs1521@cse.unsw.edu.au>
#
########################################################################

# Constant definitions.

# DO NOT CHANGE THESE DEFINITIONS



VALUE_MASK      = 0x0F
IS_BOMB_MASK    = 0x10
IS_RVLD_MASK    = 0x20
IS_MRKD_MASK    = 0x40

EMPTY_CELL      = 0
MAX_NAME_LEN    = 20
MAX_SCORES      = 10

FALSE           = 0
TRUE            = 1

MARK            = 0
REVEAL          = 1

PLAYING         = 0
WIN             = 1
LOSE            = 2

NO              = 0
YES             = 1
SCORES          = 2

USER_SCORE_SIZE = 4 + MAX_NAME_LEN
N_INT_BYTES     = 4

########################################################################
# .DATA

# DO NOT CHANGE THE DATA SECTION

        .data

# int game_state;
game_state:
        .space          4

# int bomb_count;
bomb_count:
        .space          4

# int cells_left;
cells_left:
        .space          4

# int8_t grid[N_ROWS][N_COLS];
grid:
        .space          N_CELLS
        .align          2

# int nth_round = 0;
nth_round:
        .word           0

# char user_name[MAX_NAME_LEN + 1];
user_name:
        .space          MAX_NAME_LEN + 1
        .align          2

# UserScore high_score;
high_score:                                     # typedef struct UserScore {
        .byte           0:N_INT_BYTES           #       int  score;
        .byte           0:MAX_NAME_LEN + 1      #       char name[MAX_NAME_LEN + 1];
        .align          2                       # } UserScore;

# UserScore scores[MAX_SCORES];
scores:
        .space          USER_SCORE_SIZE * MAX_SCORES
        .align          2

mark_error:
        .asciiz         "Cannot mark a revealed cell.\n"

reveal_error:
        .asciiz         "Cannot reveal a marked cell.\n"

already_revealed:
        .asciiz         "Cell is already revealed.\n"

scores_msg:
        .asciiz         "-------------SCORES-----------\n\n"

scores_line_msg:
        .asciiz         "------------------------------\n"

scores_username_msg:
        .asciiz         "* USERNAME:\t"

scores_score_msg:
        .asciiz         "* SCORE:\t"
        .align          2

###########################################################################
####                                                                   ####
####   START HERE ... Your journey begins here, intrepid adventurer!   ####
####                                                                   ####
###########################################################################

########################################################################
#
# Implement the following 7 functions,
# and check these boxes as you finish implementing each function
#
#  - [ ] reveal_grid        - subset 0
#  - [ ] place_bombs        - subset 1
#  - [ ] mark_cell          - subset 2
#  - [ ] reveal_cell        - subset 3
#  - [ ] clear_surroundings - subset 3
#  - [ ] update_highscore   - subset 4
#  - [ ] print_scores       - subset 4
#
########################################################################

########################################################################
# .TEXT <reveal_grid>
        .text

reveal_grid:
        # Arguments: void
        # Returns: void
        #
		# $s0:  offset
		# $s1: grid[row][col]
		# $t8: row    
	    # $t9: col
reveal_grid__prologue:
        addiu   $sp, $sp, -4
        sw      $ra, 0($sp)
		addiu $sp, $sp, -4
		sw    $s0, ($sp)
		addiu $sp, $sp, -4
		sw    $s1, ($sp)
		addiu $sp, $sp, -4
		sw    $s2, ($sp)
		addiu $sp, $sp, -4
		sw    $s3, ($sp)
reveal_grid__body:
	
		li $t8,0	
L1:		
		bge $t8,N_ROWS,reveal_grid__epilogue
		
		li $t9,0
L2:
		blt   $t9,N_COLS,L3	
		b L4 
L3:

		mul  $s0, $t8, N_COLS
		add  $s0,$s0,$t9
		lb   $s1,grid($s0)
		ori  $s2,$s1,IS_RVLD_MASK
		sb   $s2,grid($s0)
		
		add $t9,$t9,1
		b L2 
L4:
		add $t8,$t8,1
		b L1 
   
reveal_grid__epilogue:
		lw    $s3, ($sp)
		addiu $sp, $sp, 4
		lw    $s2, ($sp)
		addiu $sp, $sp, 4
		lw    $s1, ($sp)
		addiu $sp, $sp, 4
		lw    $s0, ($sp)
		addiu $sp, $sp, 4
        lw      $ra, 0($sp)
        addiu   $sp, $sp, 4
		jr      $ra



########################################################################
# .TEXT <place_bombs>
        .text

place_bombs:
        # Args:
        #   - $a0: int bad_row
        #   - $a1: int bad_col
        # Returns: void 
		# $s2: bad_row
		# $s3: bad_col 
		# $s0: i
		# $s1: total_bombs 
place_bombs__prologue:
        addiu   $sp, $sp, -4
        sw      $ra, 0($sp)
		addiu $sp, $sp, -4
		sw    $s0, ($sp)
		addiu $sp, $sp, -4
		sw    $s1, ($sp)
		addiu $sp, $sp, -4
		sw    $s2, ($sp)
		addiu $sp, $sp, -4
		sw    $s3, ($sp)
		
		
		addiu $s2,$a0,0
		addiu $s3,$a1,0
		lw $s1,total_bombs
place_bombs__body:
		li $s0,0
		
L5:
		blt $s0,$s1,L6
		b place_bombs__epilogue
L6:       
		addiu $a0,$s2,0
		addiu $a1,$s3,0
		jal place_single_bomb
	    
	    addi $s0,$s0,1
		b L5
place_bombs__epilogue:
		lw    $s3, ($sp)
		addiu $sp, $sp, 4
		lw    $s2, ($sp)
		addiu $sp, $sp, 4
		lw    $s1, ($sp)
		addiu $sp, $sp, 4
		lw    $s0, ($sp)
		addiu $sp, $sp, 4
		lw      $ra, 0($sp)
        addiu   $sp, $sp, 4
		jr      $ra



########################################################################
# .TEXT <mark_cell>
        .text

		
mark_cell:
        # Arguments:
        #   $a0: int row
        #   $a1: int col
        # Returns: void
        # $s1: offset
		# $s2: grid[row][col]
		# $s0: debug_mode
		# $t5: IS_MRKD_MASK
		# $t6: bomb_count
mark_cell__prologue:
        addiu   $sp, $sp, -4
        sw      $ra, 0($sp)
		addiu $sp, $sp, -4
		sw    $s0, ($sp)
		addiu $sp, $sp, -4
		sw    $s1, ($sp)
		addiu $sp, $sp, -4
		sw    $s2, ($sp)
		addiu $sp, $sp, -4
		sw    $s3, ($sp)
		
		li $s1,0
		li $s2,0		
		mul $s1,$a0,N_COLS
		add $s1,$s1,$a1 
		lb $s2,grid($s1)
		lw $s0,debug_mode
		li $t5,IS_MRKD_MASK
		lw $t6,bomb_count
mark_cell__body:	
		li $t8,IS_RVLD_MASK
		and $t0, $s2, $t8
		beq  $t0,$0,L7
		
		beq  $s0,$0,L9
		b mark_cell__epilogue
L9:		
		la $a0,mark_error
		li $v0,4
		syscall
		b mark_cell__epilogue

L7:		
		li $t8,IS_MRKD_MASK
		and $t0,$s2,$t8
		beq $t0,$0,L8
		
		
		not $t5,$t5
		and $s3,$s2,$t5 
		sb $s3,grid($s1)
			
		addi $t6,$t6,1
		sw $t6,bomb_count
		
		b mark_cell__epilogue
L8:
		li $t8,IS_MRKD_MASK
		or $s3,$s2,$t8
		sb $s3,grid($s1)
		addi $t6,$t6,-1
		sw $t6,bomb_count
		
mark_cell__epilogue:
        lw    $s3, ($sp)
		addiu $sp, $sp, 4
		lw    $s2, ($sp)
		addiu $sp, $sp, 4
		lw    $s1, ($sp)
		addiu $sp, $sp, 4
		lw    $s0, ($sp)
		addiu $sp, $sp, 4
        lw      $ra, 0($sp)
        addiu   $sp, $sp, 4
		jr      $ra



########################################################################
# .TEXT <reveal_cell>
        .text

reveal_cell:
        # Arguments:
        #   $a0: int row
        #   $a1: int col
        # Returns: void
        # $s5: offset
		# $s6: grid[row][col] 
		# $s7: row  
		# $s4: col 
		# $s1: debug_mode
		# $s3: cells_left
		# $s2: game_state
reveal_cell__prologue:
        addiu   $sp, $sp, -4
        sw      $ra, 0($sp)
		addiu $sp, $sp, -4
		sw    $s0, ($sp)
		addiu $sp, $sp, -4
		sw    $s1, ($sp)
		addiu $sp, $sp, -4
		sw    $s2, ($sp)
		addiu $sp, $sp, -4
		sw    $s3, ($sp)
		addiu $sp, $sp, -4
		sw    $s4, ($sp)
		addiu $sp, $sp, -4
		sw    $s5, ($sp)
		addiu $sp, $sp, -4
		sw    $s6, ($sp)
		addiu $sp, $sp, -4
		sw    $s7, ($sp)
		
		addiu $s7,$a0,0
		addiu $s4,$a1,0
		mul $s5,$s7,N_COLS
		add $s5,$s5,$s4 
		
		lb $s6,grid($s5)
		lw $s1,debug_mode
		lw $s2,game_state
reveal_cell__body:
		li $t9,IS_MRKD_MASK
		and $t8,$s6,$t9
		beq  $t8,$0,L10
		
		beq  $s1,$0,L15
		b reveal_cell__epilogue
L15:		
		li $v0,4
		la $a0,reveal_error
		syscall 
		
		b reveal_cell__epilogue
		
L10:
		li $t9,IS_RVLD_MASK
        and $t8,$s6,$t9
		beq  $t8,$0,L11
		
		beq  $s1,$0,L16
		b reveal_cell__epilogue
L16:		
		li $v0,4
		la $a0,already_revealed
		syscall 
		
		b reveal_cell__epilogue
		
L11:
		li $t9,IS_BOMB_MASK
		and $t8,$s6,$t9
		bne $t8,$0,L17
		b L12 
L17:
		li $t9,LOSE
		sw $t9,game_state
		lw $s2,game_state
		
L12:
		li $t9,VALUE_MASK
		and $t8,$s6,$t9
		beq $t8,$0,L13
		
		li $t9,IS_RVLD_MASK
		or $s6,$s6,$t9
		sb $s6,grid($s5)
		
		li $t9,LOSE 
		beq   $s2,$t9,L14
		
		addi $s3,$s3,-1
		sw $s3,cells_left 
		b L14
		
L13:
		addiu $a0,$s7,0
		addiu $a1,$s4,0
		jal clear_surroundings
L14:		
		beq  $s3,$0,L18
		b reveal_cell__epilogue
L18:
		li $t8,WIN
		sw $t8,game_state
		lw $s2,game_state
reveal_cell__epilogue:
		lw    $s7, ($sp)
		addiu $sp, $sp, 4
		lw    $s6, ($sp)
		addiu $sp, $sp, 4
		lw    $s5, ($sp)
		addiu $sp, $sp, 4
		lw    $s4, ($sp)
		addiu $sp, $sp, 4
		lw    $s3, ($sp)
		addiu $sp, $sp, 4
		lw    $s2, ($sp)
		addiu $sp, $sp, 4
		lw    $s1, ($sp)
		addiu $sp, $sp, 4
		lw    $s0, ($sp)
		addiu $sp, $sp, 4
        lw      $ra, 0($sp)
        addiu   $sp, $sp, 4
		jr      $ra



########################################################################
# .TEXT <clear_surroundings>
        .text


clear_surroundings:
        # Arguments:
        #   $a0: int row
        #   $a1: int col
        # Returns: void
        #
		# $s0: offset
		# $s1: grid[row][col] 
        # $s2: row
		# $s3: col 
		# $s4: cells_left
clear_surroundings__prologue:
        addiu   $sp, $sp, -4
        sw      $ra, 0($sp)
		addiu $sp, $sp, -4
		sw    $s0, ($sp)
		addiu $sp, $sp, -4
		sw    $s1, ($sp)
		addiu $sp, $sp, -4
		sw    $s2, ($sp)
		addiu $sp, $sp, -4
		sw    $s3, ($sp)
		addiu $sp, $sp, -4
		sw    $s4, ($sp)
		
		
clear_surroundings__body:

		addiu $s2,$a0,0
		addiu $s3,$a1,0
		
		
		mul $s0,$s2,N_COLS
		add $s0,$s0,$s3 
		lb $s1,grid($s0)
		
		lw $s4,cells_left
		
		bge   $s2,N_ROWS,clear_surroundings__epilogue	
		bge   $s3,N_COLS,clear_surroundings__epilogue
		blt  $s2,$0, clear_surroundings__epilogue
		blt  $s3,$0 clear_surroundings__epilogue
		
		li $t8,IS_RVLD_MASK
		and $t7,$s1,$t8
		beq  $t7,$0,L19
		b clear_surroundings__epilogue
L19:		
		li $t8,IS_RVLD_MASK
		or $s1,$s1,$t8
        sb $s1,grid($s0)
		
		
		addi $s4,$s4,-1
		sw $s4,cells_left
		lw $s4,cells_left
		
		li $t8,IS_MRKD_MASK
		not $t8,$t8 
		li $t9,0
		and $s1,$s1,$t8 
		sb $s1,grid($s0)
		
		li $t8,VALUE_MASK
		and $t9,$s1,$t8
		beq  $t9,$0,L20
		b clear_surroundings__epilogue
L20:		
		li $t8,-1
		li $t9,0
		add $a0,$s2,$t8
		add $a1,$s3,$t9
		jal clear_surroundings
		
		li $t8,-1
		li $t9,-1
		add $a0,$s2,$t8
		add $a1,$s3,$t9
		jal clear_surroundings
		
		addi $a0,$s2,-1
		addi $a1,$s3,1
		jal clear_surroundings
		
		addi $a0,$s2,0
		addi $a1,$s3,-1
		jal clear_surroundings
		
		addi $a0,$s2,0
		addi $a1,$s3,1
		jal clear_surroundings
		
		addi $a0,$s2,1
		addi $a1,$s3,-1
		jal clear_surroundings
		
		addi $a0,$s2,1
		addi $a1,$s3,0
		jal clear_surroundings
		
		li $t8,1
		li $t9,1
		add $a0,$s2,$t8
		add $a1,$s3,$t9
		jal clear_surroundings
		
clear_surroundings__epilogue:
		lw    $s4, ($sp)
		addiu $sp, $sp, 4
		lw    $s3, ($sp)
		addiu $sp, $sp, 4
		lw    $s2, ($sp)
		addiu $sp, $sp, 4
		lw    $s1, ($sp)
		addiu $sp, $sp, 4
		lw    $s0, ($sp)
		addiu $sp, $sp, 4
        lw      $ra, 0($sp)
        addiu   $sp, $sp, 4
		jr      $ra



########################################################################
# .TEXT <update_highscore>
        .text


update_highscore:
        # Arguments:
        #   $a0: int score
        # Returns: $v0 int  
        # $s1: hign_score.score
		# $s2: hign_socre.name offset 
		# $s3: user_name offset
		# $s4: user_name[i]
update_highscore__prologue:
        addiu   $sp, $sp, -4
        sw      $ra, 0($sp)	
		addiu $sp, $sp, -4
		sw    $s1, ($sp)
		addiu $sp, $sp, -4
		sw    $s2, ($sp)
		addiu $sp, $sp, -4
		sw    $s3, ($sp)
		addiu $sp, $sp, -4
		sw    $s4, ($sp)
		
		li $t0,FALSE 
		move $v0,$t0  
		move $t6,$a0
update_highscore__body:
			
		lw $s1,high_score
		
		blt   $s1,$t6,L22
		b update_highscore__epilogue
L22:		
		sw $t6,high_score
		
		li $s2,0
		li $s3,0
L21:		
		lb $s4,user_name($s3)
		beq   $s4,$0,L23
		sb $s4,high_score+4($s2)
		
		addi $s2,$s2,1
		addi $s3,$s3,1
		b L21
L23:
		li $t8,0
		sb $t8,high_score+4($s2)
		
		li $t0,TRUE
		move $v0,$t0
update_highscore__epilogue:
		lw    $s4, ($sp)
		addiu $sp, $sp, 4
		lw    $s3, ($sp)
		addiu $sp, $sp, 4
		lw    $s2, ($sp)
		addiu $sp, $sp, 4
		lw    $s1, ($sp)
		addiu $sp, $sp, 4
        lw      $ra, 0($sp)
        addiu   $sp, $sp, 4

        jr      $ra	



########################################################################
# .TEXT <print_scores>
        .text

print_scores:
        # Arguments: void
        # Returns: void
        # $s1: i 
		# $s2: curr.score
        # $s3: offset 
print_scores__prologue:
        addiu   $sp, $sp, -4
        sw      $ra, 0($sp)
		addiu $sp, $sp, -4
		sw    $s1, ($sp)
		addiu $sp, $sp, -4
		sw    $s2, ($sp)
		addiu $sp, $sp, -4
		sw    $s3, ($sp)
		
		la $a0,scores_msg
		li $v0,4
		syscall 
		
		li $t6,MAX_SCORES
		li $t7,USER_SCORE_SIZE
print_scores__body:
		li $s1,0
L27:
		blt     $s1, $t6, L24
		b L25
L24:	
		mul $s3,$s1,$t7  
		lw $s2,scores($s3)
		bne   $s2, -1, L26
		b L25 
L26:		
		la $a0,scores_line_msg
		li $v0,4
		syscall 
		
		la $a0,scores_username_msg
		li $v0,4
		syscall 
		
		la $a0,scores
		add $a0,$a0,$s3
		addi $a0,$a0,4
		li $v0,4
		syscall 
		
		li $a0,'\n'
		li $v0,11
		syscall 
		
		la $a0,scores_score_msg
		li $v0,4
		syscall 
		
		lw $a0,scores($s3)
		li $v0,1
		syscall 
		
		li $a0,'\n'
		li $v0,11
		syscall 
		
		addi $s1,$s1,1
		j L27
L25:
		la $a0,scores_line_msg
		li $v0,4
		syscall
print_scores__epilogue:
		lw    $s3, ($sp)
		addiu $sp, $sp, 4
		lw    $s2, ($sp)
		addiu $sp, $sp, 4
		lw    $s1, ($sp)
		addiu $sp, $sp, 4 
        
		lw      $ra, 0($sp)
        addiu   $sp, $sp, 4

        jr      $ra	




########################################################################
####                                                                ####
####        STOP HERE ... YOU HAVE COMPLETED THE ASSIGNMENT!        ####
####                                                                ####
########################################################################

# DO NOT CHANGE THE CODE BELOW HERE

##
## The following is various utility functions provided for you.
##
## You don't need to modify any of the following.  But you may find it
## useful to read through.
##

########################################################################
# .DATA

# DO NOT CHANGE THE DATA SECTION

        .data

# int debug_mode = FALSE;
debug_mode:
        .word           FALSE

# int seed = 0;
seed:
        .word           0

# int total_bombs;
total_bombs:
        .space          4

# int rand_master_seed = 0;
rand_master_seed:
        .word           0

# int rand_sub_seeds[3] = {123, 456, 789}
rand_sub_seeds:
        .word           123, 456, 789

### Strings used ###
bombs_prompt:
        .asciiz         "How many bombs on the grid? "

seed_prompt:
        .asciiz         "Seed: "

debug_mode_prompt:
        .asciiz         "Debug Mode: "

bombs_error_pt1:
        .asciiz         "Bombs must be in the range 1 to "
        
bombs_error_pt2:
        .asciiz         " inclusive.\n"

debug_mode_error:
        .asciiz         "Debug mode must be either 0 or 1.\n"

bad_user_input_error:
        .asciiz         "Bad user input, try again.\n"

user_name_prompt:
        .asciiz         "Enter your user name: "

reveal_prompt:
        .asciiz         "Reveal Any Cell to Begin...:\n"

first_move_prompt:
        .asciiz         "What's your first move? (action row col)\n"

next_move_prompt:
        .asciiz         "What's your next move? (action row col)\n"

win_msg:
        .asciiz         "Congratulations, you won!\n"

lose_msg:
        .asciiz         "Boom! you lost :(\n"

new_game_prompt:
        .asciiz         "New Game? (no: 0, yes: 1, scores: 2)\n"

total_bomb_count:
        .asciiz         "Total Bomb Count: "

marked_cell:
        .asciiz         "X "

bomb_cell:
        .asciiz         "* "

covered_cell:
        .asciiz         "- "

score_msg_pt1:
        .asciiz         "Your score was: "

score_msg_pt2:
        .asciiz         " cells remaining)\n"

update_highscore_msg_pt1:
        .asciiz         "The highscore is now: "

update_highscore_msg_pt2:
        .asciiz         " by you "

highscore_msg_pt1:
        .asciiz         "The highscore is: "

highscore_msg_pt2:
        .asciiz         " by "
        .align          2

########################################################################
# .TEXT <main>
        .text

# DO NOT CHANGE THIS FUNCTION

main:
        # Args:
        #   - $a0: int argc
        #   - $a1: char **argv
        # Returns:
        #   - $v0: int
        #
        # Frame:    $ra
        # Uses:     $a0, $v0
        # Clobbers: None
        #
        # Locals:
        #   - `int row` in $s0
        #   - `int col` in $s1
        #
        # Structure:
        #   main
        #   -> [prologue]
        #   -> body
        #   -> [epilogue]

main__prologue:
        addiu   $sp, $sp, -4
        sw      $ra, 0($sp)

main__body:
        jal     get_args        # get_args(argc, argv);
        lw      $a0, seed       #
        jal     seed_rng        # seed_rng();
        jal     init_scores     # init_scores();
        jal     control_play    # control_play();
                                #
        li      $v0, 0          # return 0;

main__epilogue:
        lw      $ra, 0($sp)
        addiu   $sp, $sp, 4

        jr      $ra



########################################################################
# .TEXT <control_play>
        .text

# DO NOT CHANGE THIS FUNCTION

control_play:
        # Args: void
        # Returns: void
        #
        # Frame:    $ra, $s0, $s1, $s2, $s3, $s4
        # Uses:     $a0, $a1, $v0, $t0, $t1, $t2, $t3, $s0, $s1, $s2, $s3, $s4
        # Clobbers: $a0, $a1, $v0, $t0, $t1, $t2, $t3
        #
        # Locals:
        #   - `int action` in $s0
        #   - `int row`    in $s1
        #   - `int col`    in $s2
        #   - `int valid`  in $s3
        #   - `int play_again` in $s4
        #
        # Structure:
        #   control_play
        #   -> [prologue]
        #   -> control_do
        #       -> user_name_prompt
        #       -> remove_newline_loop
        #       -> remove_newline_loop_end
        #       -> reveal_end
        #       -> play_do
        #            -> play_do_mark
        #       -> play_do_while
        #   -> control_do_while
        #   -> [epilogue]

control_play__prologue:
        addiu   $sp, $sp, -24
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        sw      $s3, 16($sp)
        sw      $s4, 20($sp)

        li      $s4, NO                 # int play_again = NO;
control_play__control_do:
        bne     $s4, SCORES, control_play__user_name_prompt             # if (play_again == SCORES) {
                                        #
        jal     print_scores            # print_scores();
                                        #
        jal     prompt_new_game         # play_again = prompt_new_game();
        move    $s4, $v0                #
                                        #
        j       control_play__control_do_while                          # continue;
                                        # }
control_play__user_name_prompt:
        la      $a0, user_name_prompt   #
        li      $v0, 4                  #
        syscall                         # printf(user_name_prompt);
                                        #
        la      $a0, user_name          #
        li      $a1, MAX_NAME_LEN       #
        li      $v0, 8                  #
        syscall                         # scanf("%s", user_name);

### Parsing the scanned string to remove the newline character.
        li      $t0, 0

control_play__remove_newline_loop:
        lb      $t1, user_name($t0)     #
        li      $t2, '\n'               #
        beq     $t1, $t2, control_play__remove_newline_loop_end         # if (user_name[i] == '\n')
                                        #
        addi    $t0, $t0, 1             # i++;
        j       control_play__remove_newline_loop

control_play__remove_newline_loop_end:
        li      $t1, 0                  #
        sb      $t1, user_name($t0)     # user_name[i] = '\0'
                                        #
        la      $a0, reveal_prompt      #
        li      $v0, 4                  #
        syscall                         # printf(reveal_prompt);
                                        #
        jal     clear_grid              # clear_grid();
                                        #
        lw      $t0, debug_mode         #
        beqz    $t0, control_play__reveal_end           # if (debug mode)
        jal     reveal_grid             # reveal_grid();

control_play__reveal_end:
        li      $t0, PLAYING            #
        sw      $t0, game_state         # game_state = PLAYING;
                                        #
        lw      $t0, total_bombs        #
        sw      $t0, bomb_count         # bomb_count = total_bombs;
                                        #
        li      $t1, N_CELLS            #
        sub     $t1, $t1, $t0           #
        sw      $t1, cells_left         # cells_left = N_CELLS - total_bombs
                                        #
        jal     print_grid              # print_grid()

control_play__play_do:
        la      $a0, first_move_prompt  #
        li      $v0, 4                  #
        syscall                         # printf(first_move_prompt);
                                        #
        li      $v0, 5                  #
        syscall                         #
        move    $s0, $v0                # scanf("%d", &action);
                                        #
        beq     $s0, -1, control_play__epilogue         # if (action == -1) return;
                                        #
        li      $v0, 5                  #
        syscall                         #
        move    $s1, $v0                # scanf("%d", &row);
                                        #
        li      $v0, 5                  #
        syscall                         #
        move    $s2, $v0                # scanf("%d", &col);
                                        #
        move    $a0, $s0                #
        move    $a1, $s1                #
        move    $a2, $s2                #
        jal     check_valid_input       #
        move    $s3, $v0                # valid = check_valid_input(action, row, col);
                                        #
        bnez    $s3, control_play__play_do_mark         # if (!valid)
        la      $a0, bad_user_input_error
        li      $v0, 4                  #
        syscall                         # printf(bad_user_input_error);
        j       control_play__play_do_while

control_play__play_do_mark:
        bne     $s0, MARK, control_play__play_do_while  # if (action == MARK)
                                        #
        move    $a0, $s1                #
        move    $a1, $s2                #
        jal     mark_cell               # mark_cell(row, col);
        jal     print_grid              # print_grid();

control_play__play_do_while:
        beqz    $s3, control_play__play_do              # if (!valid
        bne     $s0, REVEAL, control_play__play_do      # || (action != REVEAL))
                                        #
        move    $a0, $s1                #
        move    $a1, $s2                #
        jal     fill_grid               # fill_grid(row, col);
                                        #
        move    $a0, $s1                #
        move    $a1, $s2                #
        jal     reveal_cell             # reveal_cell(row, col);
                                        #
        jal     print_grid              # print_grid();
        jal     play                    #
        move    $s4, $v0                # play_again = play();

control_play__control_do_while:
        bnez    $s4, control_play__control_do     # while (play_again)

control_play__epilogue:
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        lw      $s3, 16($sp)
        lw      $s4, 20($sp)
        addiu   $sp, $sp, 24

        jr      $ra



########################################################################
# .TEXT <play>
        .text

# DO NOT CHANGE THIS FUNCTION

play:
        # Args: void
        # Returns:
        #   - $v0: int
        #
        # Frame:    $ra, $s0, $s1, $s2
        # Uses:     $a0, $a1, $a2, $v0, $t0, $s0, $s1, $s2, $s3
        # Clobbers: $a0, $a1, $a2, $v0, $t0
        #
        # Locals:
        #   - `int action` in $s0
        #   - `int row`    in $s1
        #   - `int col`    in $s2
        #
        # Structure:
        #   play
        #   -> [prologue]
        #   -> while_playing
        #       -> action_mark
        #       -> action_reveal
        #       -> print_grid
        #   -> while_end
        #   -> [epilogue]

play__prologue:
        addiu   $sp, $sp, -16
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)

play__while_playing:
        lw      $t0, game_state         #
        bne     $t0, PLAYING, play__while_end   # while (game_state == PLAYING)
                                        #
        la      $a0, next_move_prompt   #
        li      $v0, 4                  #
        syscall                         # printf(next_move_prompt);
                                        #
        li      $v0, 5                  #
        syscall                         #
        move    $s0, $v0                # scanf("%d", &action);
                                        #
        li      $v0, FALSE              #
        beq     $s0, -1, play__epilogue # if (action == -1) return FALSE;
                                        #
        li      $v0, 5                  #
        syscall                         #
        move    $s1, $v0                # scanf("%d", &row);
                                        #
        li      $v0, 5                  #
        syscall                         #
        move    $s2, $v0                # scanf("%d", &col);
                                        #
        move    $a0, $s0                #
        move    $a1, $s1                #
        move    $a2, $s2                #
        jal     check_valid_input       # check_valid_input(action, row, col);
        move    $t0, $v0                #
                                        #
        beq     $t0, TRUE, play__action_mark    # if (!check_valid_input(...))
                                        #
        la      $a0, bad_user_input_error
        li      $v0, 4                  #
        syscall                         # printf(bad_user_input_error);
        j       play__while_playing     # continue;

play__action_mark:
        bne     $s0, MARK, play__action_reveal  # if (action == MARK)
                                        #
        move    $a0, $s1                #
        move    $a1, $s2                #
        jal     mark_cell               # mark_cell(row, col);
        j       play__print_grid        #

play__action_reveal:
        bne     $s0, REVEAL, play__print_grid   # else if (action == REVEAL)
                                        #
        move    $a0, $s1                #
        move    $a1, $s2                #
        jal     reveal_cell             # reveal_cell(row, col);

play__print_grid:
        jal     print_grid              # print_grid();
        j       play__while_playing     #

play__while_end:
        jal     check_end_play          # return check_end_play();

play__epilogue:
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        addiu   $sp, $sp, 16

        jr      $ra



########################################################################
# .TEXT <check_end_play>
        .text

# DO NOT CHANGE THIS FUNCTION

check_end_play:
        # Args: void
        # Returns:
        #   - $v0: int
        #
        # Frame:    $ra, $s0
        # Uses:     $a0, $v0, $t0, $t1, $s0
        # Clobbers: $a0, $v0, $t0, $t1
        #
        # Locals:
        #   - `int score`    in $s0
        #   - `int response` in $t0
        #
        # Structure:
        #   check_end_play
        #   -> [prologue]
        #       -> lose
        #   -> high_score
        #       -> update_highscore
        #       -> print_highscore
        #   -> new_game
        #   -> [epilogue]

check_end_play__prologue:
        addiu   $sp, $sp, -8
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)

        lw      $t0, game_state         #
        bne     $t0, WIN, check_end_play__lose          # if (game_state == WIN)
                                        #
        la      $a0, win_msg            #
        li      $v0, 4                  #
        syscall                         # printf(win_msg);
                                        #
        j       check_end_play__high_score

check_end_play__lose:
        la      $a0, lose_msg           #
        li      $v0, 4                  #
        syscall                         # printf(lose_msg);

check_end_play__high_score:
        li      $t0, N_CELLS            #
        lw      $t1, cells_left         #
        sub     $s0, $t0, $t1           # score = N_CELLS - cells_left;
                                        #
        move    $a0, $s0                #
        jal     add_user_score          # add_user_score(score);
                                        #
        la      $a0, score_msg_pt1      #
        li      $v0, 4                  #
        syscall                         # printf(score_msg_pt1);
                                        #
        move    $a0, $s0                #
        li      $v0, 1                  #
        syscall                         # printf("%d", score);
                                        #
        li      $a0, ' '                #
        li      $v0, 11                 #
        syscall                         # printf(" ");
                                        #
        li      $a0, '('                #
        li      $v0, 11                 #
        syscall                         # printf("(");
                                        #
        lw      $a0, cells_left         #
        li      $v0, 1                  #
        syscall                         # printf("%d", cells_left);
                                        #
        la      $a0, score_msg_pt2      #
        li      $v0, 4                  #
        syscall                         # printf(score_msg_pt2);
                                        #
        move    $a0, $s0                #
        jal     update_highscore        #
        beqz    $v0, check_end_play__print_highscore    # if (update_highscore(score))

check_end_play__update_highscore:
        la      $a0, update_highscore_msg_pt1
        li      $v0, 4                  #
        syscall                         # printf(update_highscore_msg_pt1);
                                        #
        lw      $a0, high_score         #
        li      $v0, 1                  #
        syscall                         # printf("%d", high_score.score);
                                        #
        la      $a0, update_highscore_msg_pt2
        li      $v0, 4                  #
        syscall                         # printf(update_highscore_msg_pt2);
                                        #
        li      $a0, '('                #
        li      $v0, 11                 #
        syscall                         # printf("(");
                                        #
        la      $a0, high_score         #
        add     $a0, $a0, 4             #
        li      $v0, 4                  #
        syscall                         # printf("%s", high_score.name);
                                        #
        li      $a0, ')'                #
        li      $v0, 11                 #
        syscall                         # printf(")");
                                        #
        li      $a0, '\n'               #
        li      $v0, 11                 #
        syscall                         # printf("\n");
                                        #
        j       check_end_play__new_game

check_end_play__print_highscore:
        la      $a0, highscore_msg_pt1  #
        li      $v0, 4                  #
        syscall                         # printf(highscore_msg_pt1);
                                        #
        lw      $a0, high_score         #
        li      $v0, 1                  #
        syscall                         # printf("%d", high_score.score);
                                        #
        la      $a0, highscore_msg_pt2  #
        li      $v0, 4                  #
        syscall                         # printf(highscore_msg_pt2);
                                        #
        la      $a0, high_score         #
        add     $a0, $a0, 4             #
        li      $v0, 4                  #
        syscall                         # printf("%s", high_score.name);
                                        #
        li      $a0, '\n'               #
        li      $v0, 11                 #
        syscall                         # printf('\n');
                                        #
check_end_play__new_game:
        jal     prompt_new_game         # return prompt_new_game()
                                        #
check_end_play__epilogue:
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        addiu   $sp, $sp, 8

        jr      $ra



########################################################################
# .TEXT <add_user_score>
        .text

# DO NOT CHANGE THIS FUNCTION

add_user_score:
        # Args:
        #   - $a0: int score
        # Returns: void
        #
        # Frame:    None
        # Uses:     $t0, $t1, $t2, $t3, $t4
        # Clobbers: $t4
        #
        # Locals:
        #   - `int nth_round` in $t0
        #   - `int i` in $t2
        #   - current character in $t3
        #   - index within `scores` in $t1
        #
        # Structure:
        #   add_user_score
        #   -> while
        #   -> endwhile
        #   -> [epilogue]

        lw      $t0, nth_round                  #
        rem     $t1, $t0, MAX_SCORES            # nth_round % MAX_SCORES
        mul     $t1, $t1, USER_SCORE_SIZE       # (nth_round % MAX_SCORES) * USER_SCORE_SIZE
                                                #
        sw      $a0, scores($t1)                # user_score.score = score;
                                                #
        li      $t2, 0                          # int i = 0;
add_user_score__while:
        lb      $t3, user_name($t2)             #
        beqz    $t3, add_user_score__endwhile   # while (user_name[i] != '\0') {
                                                #
        add     $t4, $t1, 4                     #
        add     $t4, $t4, $t2                   #
        sb      $t3, scores($t4)                #       user_score.name[i] = user_name[i];
                                                #
        addi    $t2, $t2, 1                     #       ++i;
        j       add_user_score__while           # }
                                                #
add_user_score__endwhile:
        add     $t4, $t1, 4                     #
        add     $t4, $t4, $t2                   #
        sb      $zero, scores($t4)              # user_score.name[i] = '\0';
                                                #
        addi    $t0, $t0, 1                     #
        sw      $t0, nth_round                  # nth_round++;
                                                #
add_user_score__epilogue:
        jr      $ra



########################################################################
# .TEXT <add_user_score>
        .text

# DO NOT CHANGE THIS FUNCTION

prompt_new_game:
        # Args: void
        # Returns: void
        #
        # Frame:    None
        # Uses:     $a0, $v0, $t0
        # Clobbers: $a0, $v0
        #
        # Locals:
        # `int response` in $t0
        #
        # Structure:
        #   prompt_new_game
        #   -> prompt
        #   -> [epilogue]
prompt_new_game__prompt:
        la      $a0, new_game_prompt    #
        li      $v0, 4                  #
        syscall                         # printf(new_game_prompt)
                                        #
        li      $t0, 0                  # int response = 0;
                                        #
        li      $v0, 5                  #
        syscall                         #
        move    $t0, $v0                # scanf("%d", &response);
                                        #
        beq     $t0, YES, prompt_new_game__epilogue     # if (response != 1
        beq     $t0, SCORES, prompt_new_game__epilogue  #     && response != 2)
                                        #
        li      $t0, NO                 # response = NO;
                                        #
prompt_new_game__epilogue:
        move    $v0, $t0                # return response;
        jr      $ra                     #



########################################################################
# .TEXT <check_valid_input>
        .text

# DO NOT CHANGE THIS FUNCTION

check_valid_input:
        # Args:
        #   - $a0: action
        #   - $a1: row
        #   - $a2: col
        # Returns:
        #   - $v0: int
        #
        # Frame:    None
        # Uses:     $a0, $a1, $a2, $v0, $t0
        # Clobbers: $t0
        #
        # Locals:   None
        #
        # Structure:
        #   check_valid_input
        #   -> action
        #   -> row
        #   -> col
        #   -> true
        #   -> false
        #   -> [epilogue]

check_valid_input__action:
        beq     $a0, MARK, check_valid_input__row       # if (action != MARK
        beq     $a0, REVEAL, check_valid_input__row     #     && action != REVEAL)
        j       check_valid_input__false                # return FALSE;

check_valid_input__row:
        blt     $a1, 0, check_valid_input__false        # if (row < 0
        li      $t0, N_ROWS                             #     || row > N_ROW - 1)
        sub     $t0, $t0, 1                             #
        bgt     $a1, $t0, check_valid_input__false      # return FALSE;

check_valid_input__col:
        blt     $a2, 0, check_valid_input__false        # if (col < 0
        li      $t0, N_COLS                             #     || row > N_COLS - 1)
        sub     $t0, $t0, 1                             #
        bgt     $a2, $t0, check_valid_input__false      # return FALSE;

check_valid_input__true:
        li      $v0, TRUE                               #
        j       check_valid_input__epilogue             # return TRUE;

check_valid_input__false:
        li      $v0, FALSE                              # return FALSE;

check_valid_input__epilogue:
        jr      $ra



########################################################################
# .TEXT <print_grid>
        .text

# DO NOT CHANGE THIS FUNCTION

print_grid:
        # Args: void
        # Returns: void
        #
        # Frame:    None
        # Uses:     $a0, $v0, $t0, $t1, $t2, $t3
        # Clobbers: $a0, $v0, $t3
        #
        # Locals:
        #   - `int i`      in $t0
        #   - `int j`      in $t1
        #   - `grid[i][j]` in $t2
        #
        # Structure:
        #   print_grid
        #   -> print_total_bombs
        #   -> row_loop
        #       -> col_loop
        #            -> if_marked
        #            -> if_revealed
        #               -> if_bombs
        #               -> if_value
        #            -> if_covered
        #            -> end_if
        #       -> col_loop_end
        #   -> row_loop_end

print_grid__print_total_bombs:
        la      $a0, total_bomb_count   #
        li      $v0, 4                  #
        syscall                         # printf(total_bomb_count);
                                        #
        lw      $a0, bomb_count         #
        li      $v0, 1                  #
        syscall                         # printf("%d", bomb_count);
                                        #
        li      $a0, '\n'               #
        li      $v0, 11                 #
        syscall                         # printf("\n");
                                        #
        li      $t0, 0                  # int i = 0;
print_grid__row_loop:
        bge     $t0, N_ROWS, print_grid__row_loop_end           # while (i < N_ROWS)
                                        #
        li      $t1, 0                  # int j = 0;
print_grid__col_loop:
        bge     $t1, N_COLS, print_grid__col_loop_end           # while (j < N_ROWS)
                                        #
        mul     $t2, $t0, N_COLS        #
        add     $t2, $t2, $t1           #
        lb      $t2, grid($t2)          # $t2 = grid[i][j]

print_grid__if_marked:
        and     $t3, $t2, IS_MRKD_MASK  #
        beqz    $t3, print_grid__if_revealed                    # if (grid[i][j] & IS_MRKD_MASK)
                                        #
        la      $a0, marked_cell        #
        li      $v0, 4                  #
        syscall                         # printf("X ");
                                        #
        j       print_grid__end_if      #

print_grid__if_revealed:
        and     $t3, $t2, IS_RVLD_MASK  #
        beqz    $t3, print_grid__if_covered                     # else if (grid[i][j] & IS_RVLD_MASK)

print_grid__if_bomb:
        and     $t3, $t2, IS_BOMB_MASK  #
        beqz    $t3, print_grid__if_value                       # if (grid[i][j] & IS_BOMB_MASK)
                                        #
        la      $a0, bomb_cell          #
        li      $v0, 4                  #
        syscall                         # printf("* ");
                                        #
        j       print_grid__end_if      #

print_grid__if_value:                   # else
        and     $a0, $t2, VALUE_MASK    #
        li      $v0, 1                  #
        syscall                         # printf("%d", grid[i][j] & VALUE_MASK);
                                        #
        li      $a0, ' '                #
        li      $v0, 11                 #
        syscall                         # printf(" ");
                                        #
        j       print_grid__end_if      #

print_grid__if_covered:                 # else
        la      $a0, covered_cell       #
        li      $v0, 4                  #
        syscall                         # printf("- ");

print_grid__end_if:
        addi    $t1, $t1, 1             # j++;
        j       print_grid__col_loop    #

print_grid__col_loop_end:
        li      $a0, '\n'               #
        li      $v0, 11                 #
        syscall                         # printf("\n");
                                        #
        addi    $t0, $t0, 1             # i++;
        j       print_grid__row_loop    #

print_grid__row_loop_end:
        jr      $ra



########################################################################
# .TEXT <fill_grid>
        .text

# DO NOT CHANGE THIS FUNCTION

fill_grid:
        # Args:
        #   - $a0: bad_row
        #   - $a1: bad_col
        # Returns: void
        #
        # Frame:    $ra
        # Uses:     None
        # Clobbers: None
        #
        # Locals:   None
        #
        # Structure:
        #   check_valid_input
        #   -> [prologue]
        #   -> body
        #   -> [epilogue]

fill_grid__prologue:
        addiu   $sp, $sp, -4
        sw      $ra, ($sp)

fill_grid__body:
        jal     place_bombs             # place_bombs(bad_row, bad_col);
        jal     count_adj_bombs         # count_adj_bombs();

fill_grid__epilogue:
        lw      $ra, ($sp)
        addiu   $sp, $sp, 4

        jr      $ra



########################################################################
# .TEXT <place_single_bomb>
        .text

# DO NOT CHANGE THIS FUNCTION

place_single_bomb:
        # Args:
        #   - $a0: bad_row
        #   - $a1: bad_col
        # Returns: void
        #
        # Frame:    $ra, $s0, $s1, $s2, $s3
        # Uses:     $a0, $t0, $t1, $s0, $s1, $s2, $s3
        # Clobbers: $a0, $t0, $t1
        #
        # Locals:
        #   - `int row` in $s0
        #   - `int col` in $s1
        #   - `int bad_row` in $s2
        #   - `int bad_col` in $s3
        #
        # Structure:
        #   check_valid_input
        #   -> [prologue]
        #   -> do
        #   -> while
        #   -> place_bomb
        #   -> [epilogue]

place_single_bomb__prologue:
        addiu   $sp, $sp, -20
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        sw      $s3, 16($sp)

        move    $s2, $a0                # store bad_row
        move    $s3, $a1                # store bad_col
                                        #
place_single_bomb__do:
        li      $a0, N_ROWS             #
        jal     rand_value              #
        move    $s0, $v0                # row = rand_value(N_ROWS);
                                        #
        li      $a0, N_COLS             #
        jal     rand_value              #
        move    $s1, $v0                # col = rand_value(N_COLS);
                                        #
place_single_bomb__while:               # is_bad_cell(
        move    $a0, $s0                #       row,
        move    $a1, $s1                #       col,
        move    $a2, $s2                #       bad_row,
        move    $a3, $s3                #       bad_col
        jal     is_bad_cell             # );
                                        #
        beq     $v0, TRUE, place_single_bomb__do        # while(is_bad_cell(...));
                                        #
place_single_bomb__place_bomb:
        mul     $t0, $s0, N_COLS        #
        add     $t0, $t0, $s1           #
        lb      $t1, grid($t0)          # $t1 = grid[row][col]
                                        #
        ori     $t1, $t1, IS_BOMB_MASK  #
        sb      $t1, grid($t0)          # grid[row][col] |= IS_BOMB_MASK;
                                        #
place_single_bomb__epilogue:
        lw      $s3, 16($sp)
        lw      $s2, 12($sp)
        lw      $s1, 8($sp)
        lw      $s0, 4($sp)
        lw      $ra, 0($sp)
        addiu   $sp, $sp, 20

        jr      $ra



########################################################################
# .TEXT <clear_grid>
        .text

# DO NOT CHANGE THIS FUNCTION

clear_grid:
        # Args: void
        # Returns: void
        #
        # Frame:    None
        # Uses:     $t0, $t1, $t2, $t3
        # Clobbers: $t2, $t3
        #
        # Locals:
        #   - `int row` in $t0
        #   - `int col` in $t1
        #
        # Structure:
        #   clear_grid
        #   -> row_loop
        #       -> col_loop
        #       -> col_loop_end
        #   -> row_loop_end

        li      $t0, 0                  # int row = 0;
clear_grid__row_loop:
        bge     $t0, N_ROWS, clear_grid__row_loop_end           # while (row < N_ROWS)
        li      $t1, 0                  # int col = 0;
clear_grid__col_loop:
        bge     $t1, N_COLS, clear_grid__col_loop_end           # while (col < N_COLS)
                                        #
        mul     $t2, $t0, N_COLS        #
        add     $t2, $t2, $t1           # $t2 = &grid[row][col]
        li      $t3, EMPTY_CELL         #
        sb      $t3, grid($t2)          # grid[row][col] = EMPTY_CELL;
                                        #
        addi    $t1, $t1, 1             # col++;
        j       clear_grid__col_loop    #

clear_grid__col_loop_end:
        addi    $t0, $t0, 1             # row++;
        j       clear_grid__row_loop    #

clear_grid__row_loop_end:
        jr      $ra



########################################################################
# .TEXT <count_adj_bombs>
        .text

# DO NOT CHANGE THIS FUNCTION

count_adj_bombs:
        # Args: void
        # Returns: void
        #
        # Frame:    None
        # Uses:     $t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7
        # Clobbers: $t5, $t6, $t7
        #
        # Locals:
        #   - `int i` in $t0
        #   - `int j` in $t1
        #   - `int count` in $t2
        #   - `int n` in $t3
        #   - `int m` in $t4
        #
        # Structure:
        #   count_adj_bombs
        #   -> row_loop
        #       -> col_loop
        #            -> adj_loop1
        #               -> adj_loop2
        #                    -> valid_check
        #                       -> check_bomb
        #                    -> check_end
        #               -> adj_loop2_end
        #            -> adj_loop1_end
        #       -> col_loop_end
        #   -> row_loop_end

        li      $t0, 0                  # int i = 0;
count_adj_bombs__row_loop:
        bge     $t0, N_ROWS, count_adj_bombs__row_loop_end      # while (i < N_ROWS)
        li      $t1, 0                  # int j = 0;
count_adj_bombs__col_loop:
        bge     $t1, N_COLS, count_adj_bombs__col_loop_end      # while (j < N_COLS)
        li      $t2, 0                  # int count = 0;
                                        #
        li      $t3, -1                 # int n = -1;
count_adj_bombs__adj_loop1:
        bgt     $t3, 1, count_adj_bombs__adj_loop1_end          # while (n <= 1)

        li      $t4, -1                 # int m = -1;
count_adj_bombs__adj_loop2:
        bgt     $t4, 1, count_adj_bombs__adj_loop2_end          # while (m <= 1)

count_adj_bombs__valid_check:
        add     $t5, $t0, $t3           # i + n;
        blt     $t5, 0, count_adj_bombs__check_end              # if (i + n >= 0
        bge     $t5, N_ROWS, count_adj_bombs__check_end         #     && i + n < N_ROWS
                                        #
        add     $t6, $t1, $t4           # j + m;
        blt     $t6, 0, count_adj_bombs__check_end              #     && j + m >= 0
        bge     $t6, N_COLS, count_adj_bombs__check_end         #     && j + m < N_COLS)

count_adj_bombs__check_bomb:
        mul     $t7, $t5, N_COLS        #
        add     $t7, $t7, $t6           #
        lb      $t7, grid($t7)          # $t7 = grid[i+n][j+m];
                                        #
        and     $t7, $t7, IS_BOMB_MASK  #
        beqz    $t7, count_adj_bombs__check_end                 # if (grid[i+n][j+m] & IS_BOMB_MASK)
                                        #
        addi    $t2, $t2, 1             # count++;

count_adj_bombs__check_end:
        addi    $t4, $t4, 1             # m++;
        j       count_adj_bombs__adj_loop2

count_adj_bombs__adj_loop2_end:
        addi    $t3, $t3, 1             # n++;
        j       count_adj_bombs__adj_loop1

count_adj_bombs__adj_loop1_end:
        mul     $t5, $t0, N_COLS        #
        add     $t5, $t5, $t1           #
        lb      $t6, grid($t5)          # $t6 = grid[i][j]
                                        #
        or      $t6, $t6, $t2           #
        sb      $t6, grid($t5)          # grid[i][j] |= count
                                        #
        addi    $t1, $t1, 1             # j++;
        j       count_adj_bombs__col_loop

count_adj_bombs__col_loop_end:
        addi    $t0, $t0, 1             # i++;
        j       count_adj_bombs__row_loop

count_adj_bombs__row_loop_end:
        jr      $ra



########################################################################
# .TEXT <is_bad_cell>
        .text

# DO NOT CHANGE THIS FUNCTION

is_bad_cell:
        # Args:
        #   - $a0: int row
        #   - $a1: int col
        #   - $a2: int bad_row
        #   - $a3: int bad_col
        # Returns:
        #   - $v0: int
        #
        # Frame:    None
        # Uses:     $a0, $a1, $a2, $a3, $v0, $t0, $t1, $t2, $t3
        # Clobbers: $v0, $t2, $t3
        #
        # Locals:
        #   - `int i` in $t0
        #   - `int j` in $t1
        #
        # # Structure:
        #   is_bad_cell
        #   -> if_bomb
        #   -> endif_bomb
        #   -> out_loop
        #       -> in_loop
        #            -> if_bad
        #            -> if_bad_end
        #       -> in_loop_end
        #   -> out_loop_end
        #   -> [epilogue]

is_bad_cell__if_bomb:
        mul     $t0, $a0, N_COLS        # if ((grid[row][col] & IS_BOMB_MASK))
        add     $t0, $t0, $a1           #
        lb      $t0, grid($t0)          #
        andi    $t0, $t0, IS_BOMB_MASK  #
        beqz    $t0, is_bad_cell__endif_bomb
                                        #
        li      $v0, TRUE               #
        j       is_bad_cell__epilogue   # return TRUE;
is_bad_cell__endif_bomb:
                                        #
        li      $t0, -1                 # i = -1;
is_bad_cell__out_loop:
        bgt     $t0, 1, is_bad_cell__out_loop_end       # while (i <= 1)
        li      $t1, -1                 # j = -1;
is_bad_cell__in_loop:
        bgt     $t1, 1, is_bad_cell__in_loop_end        # while (j <= 1)

is_bad_cell__if_bad:
        add     $t2, $a0, $t0                           # if (
        bne     $t2, $a2, is_bad_cell__if_bad_end       #   (row + i) == bad_row
        add     $t3, $a1, $t1                           #   &&
        bne     $t3, $a3, is_bad_cell__if_bad_end       #   (col + j) == bad_col
                                                        # )
        li      $v0, TRUE                               #
        j       is_bad_cell__epilogue                   # return TRUE;

is_bad_cell__if_bad_end:
        addi    $t1, $t1, 1             # j++;
        j       is_bad_cell__in_loop    #
                                        #
is_bad_cell__in_loop_end:
        addi    $t0, $t0, 1             # i++;
        j       is_bad_cell__out_loop   #
                                        #
is_bad_cell__out_loop_end:
        li      $v0, FALSE              # return FALSE;

is_bad_cell__epilogue:
        jr      $ra



########################################################################
# .TEXT <init_scores>
        .text

# DO NOT CHANGE THIS FUNCTION

init_scores:
        # Args: void
        # Returns: void
        #
        # Frame:    None
        # Uses:     $t0, $t1, $t2
        # Clobbers: $t0
        #
        # Locals:
        #   - `int i` in $t1
        #   - `scores[i] offset` in $t2
        #
        # Structure:
        #   init_scores
        #   -> for_score
        #   -> for_score_end
        #   -> [epilogue]
        li      $t1, 0                                          # int i = 0;
init_scores__for_score:
        bge     $t1, MAX_SCORES, init_scores__for_score_end     # for (; i < MAX_SCORES;) {
                                                                #
        mul     $t2, $t1, USER_SCORE_SIZE                       #
        li      $t0, -1                                         #
        sw      $t0, scores($t2)                                # scores[i].score = -1;
                                                                #
        addi    $t2, $t2, 4                                     #
        sb      $zero, scores($t2)                              # scores[i].name[0] = '\0';
                                                                #
        addi    $t1, $t1, 1                                     #       i++;
        j       init_scores__for_score                          # }
init_scores__for_score_end:
init_scores__epilogue:
        jr      $ra


########################################################################
# .TEXT <get_args>
        .text

# DO NOT CHANGE THIS FUNCTION

get_args:
        # Args: void
        # Returns: void
        #
        # Frame:    None
        # Uses:     $a0, $v0, $t0
        # Clobbers: $a0, $v0
        #
        # Locals:
        #   - `int tmp` in $t0
        #
        # Structure:
        #   get_args
        #   -> get_bombs
        #   -> get_bombs_error
        #   -> get_seed
        #   -> get_debug_mode
        #   -> get_debug_mode_error
        #   -> get_debug_mode_end_error
        #   -> get_args_exit
        #   -> [epilogue]

get_args__get_bombs:
        la      $a0, bombs_prompt       #
        li      $v0, 4                  #
        syscall                         # printf(bombs_prompt);
                                        #
        li      $v0, 5                  #
        syscall                         #
        move    $t0, $v0                # scanf("%d", &tmp);
                                        #
        ble     $t0, 0, get_args__get_bombs_error               # if (tmp <= 0
        bgt     $t0, MAX_BOMBS, get_args__get_bombs_error       #     || tmp > MAX_BOMBS)
        j       get_args__get_bombs_end_error                   #

get_args__get_bombs_error:
        la      $a0, bombs_error_pt1    #
        li      $v0, 4                  #
        syscall                         # printf(bombs_error_pt1);
        li      $a0, MAX_BOMBS          #
        li      $v0, 1                  #
        syscall                         # printf("%d", MAX_BOMBS);
        la      $a0, bombs_error_pt2    #
        li      $v0, 4                  #
        syscall                         # printf(bombs_error_pt2);
                                        #
        j       get_args__exit          # exit();

get_args__get_bombs_end_error:
        sw      $t0, total_bombs        # total_bombs = tmp;

get_args__get_seed:
        la      $a0, seed_prompt        #
        li      $v0, 4                  #
        syscall                         # printf(seed_prompt);
                                        #
        li      $v0, 5                  #
        syscall                         #
        move    $t0, $v0                # scanf("%d", &tmp);
                                        #
        sw      $t0, seed               # seed = tmp;

get_args__get_debug_mode:
        la      $a0, debug_mode_prompt  #
        li      $v0, 4                  #
        syscall                         # printf(debug_mode_prompt);
                                        #
        li      $v0, 5                  #
        syscall                         #
        move    $t0, $v0                # scanf("%d", &tmp);
                                        #
        beq     $t0, FALSE, get_args__get_debug_mode_end_error  # if (tmp != FALSE
        beq     $t0, TRUE, get_args__get_debug_mode_end_error   #     && tmp != TRUE)

get_args__get_debug_mode_error:
        la      $a0, debug_mode_error   #
        li      $v0, 4                  #
        syscall                         # printf(debug_mode_error);
                                        #
        j       get_args__exit          # exit();

get_args__get_debug_mode_end_error:
        sw      $t0, debug_mode         # debug_mode = tmp;
                                        #
        j       get_args__epilogue      #

get_args__exit:
        li      $a0, 1                  #
        li      $v0, 17                 #
        syscall                         # exit(1);

get_args__epilogue:
        jr      $ra



########################################################################
# .TEXT <seed_rng>
        .text

# DO NOT CHANGE THIS FUNCTION

seed_rng:
        # Args:
        #   - $a0: unsigned int input_seed
        # Returns: void
        #
        # Frame:    None
        # Uses:     $a0
        # Clobbers: None
        #
        # Locals: None
        #
        # Structure:
        #   seed_rng

        sw      $a0, rand_master_seed   # rand_master_seed = input_seed
        jr      $ra                     #



########################################################################
# .TEXT <rand_value>
        .text

# DO NOT CHANGE THIS FUNCTION

rand_value:
        # Args:
        #   - $a0: uint32_t n
        # Returns:
        #   - $v0: uint32_t
        #
        # Frame:    None
        # Uses:     $a0, $v0, $t0, $t1
        # Clobbers: $v0
        #
        # Locals:
        #   - `rand_sub_seeds` in $t1
        #
        # Structure:
        #   seed_rng

        lw      $t0, rand_master_seed   # (rand_master_seed
        mul     $t0, $t0, 1103515245    #       * 1103515245
        addiu   $t0, $t0, 12345         #       + 12345)
        and     $t0, $t0, 0x7FFFFFFF    #       & 0x7FFFFFFF;
        sw      $t0, rand_master_seed   # store rand_master_seed
                                        #
        la      $t1, rand_sub_seeds     #
                                        #
        lw      $t0, 0($t1)             # (rand_sub_seeds[0]
        mul     $t0, $t0, 1103515245    #       * 1103515245
        addiu   $t0, $t0, 12345         #       + 12345)
        and     $t0, $t0, 0x7FFFFFFF    #       & 0x7FFFFFFF;
        sw      $t0, 0($t1)             # store rand_sub_seeds[0]
                                        #
        lw      $t0, 4($t1)             # (rand_sub_seeds[1]
        mul     $t0, $t0, 1103515245    #       * 1103515245
        addiu   $t0, $t0, 12345         #       + 12345)
        and     $t0, $t0, 0x7FFFFFFF    #       & 0x7FFFFFFF
        sw      $t0, 4($t1)             # store rand_sub_seeds[1]
                                        #
        lw      $t0, 8($t1)             # (rand_sub_seeds[2]
        mul     $t0, $t0, 1103515245    #       * 1103515245
        addiu   $t0, $t0, 12345         #       + 12345)
        and     $t0, $t0, 0x7FFFFFFF    #       & 0x7FFFFFFF
        sw      $t0, 8($t1)             # store rand_sub_seeds[2]
                                        #
        lw      $t0, rand_master_seed   #
        rem     $t0, $t0, 3             # rand_master_seed % 3
                                        #
        mul     $t0, $t0, 4             #
        lw      $t0, rand_sub_seeds($t0)#
                                        #
        rem     $v0, $t0, $a0           # return rand_sub_seeds[$t0] % n
        jr      $ra                     #