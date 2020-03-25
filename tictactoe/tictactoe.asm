org 100h

jmp start

THREE_X equ 264
THREE_O equ 237
LEFT_KEY equ 04Bh
RIGHT_KEY equ 04Dh
UP_KEY equ 048h
DOWN_KEY equ 050h
X_O_SUM equ 167 
RED_BLUE_SUM equ 21

x_position dw 35
y_position dw 8

relative_x db 0
relative_y db 0

turns db 0
shape db 'X'
won_shape db ?
color db 9
board_frame db 10,10,10,9, 9, 9, 9, "    | | ", 10, 13          
            db 9, 9, 9, 9, "   -----", 10, 13          
            db 9, 9, 9, 9, "    | | ", 10, 13 ; boards 0, 1, 2          
            db 9, 9, 9, 9, "   -----", 10, 13          
            db 9, 9, 9, 9, "    | | $", 10, 13          
num_board db 9 dup(0)            

game_title db "TIC TAC TOE$"
game_over_msg db "GAME OVER! $"
won_msg db " Won.$"
draw_msg db "It's a draw!$"
intro db "-Hello Orna! Welcome to Tic Tac Toe-", 10, 13
      db "By (Only) Yonatan Kadman.", 10, 10, 10, 13
      db "You know the rules - row/column/diaganol to win.", 10, 13
      db "Use the arrows to move arround,", 10, 13                     
      db "Hit Space to place a shape.", 10, 10, 13
      db 9,9,9,"Enjoy!!!", 10, 10, 13
      db 9,9,"Press anything to continue...$"

macro set_cursor x y
push x
push y
call set_cursor        
endm

start:                                                                                      
mov ah, 0
mov al, 3
int 10h ; Set the screen to 80X25 16 colored

;print intro
mov ah, 9
mov dx, offset intro
int 21h

mov ah, 0
int 16h ; get char

mov ah, 0
mov al, 3
int 10h ; Set the screen to 80X25 16 colored
      
set_cursor 32 3

mov ah, 9
lea dx, game_title
int 21h

set_cursor 0, 5
lea dx, board_frame
mov ah, 9
int 21h

set_cursor 35, 8

main:
    mov ah, 0
    int 16h ;get char
    cmp al, 20h ;space
    je call_draw_shape
    cmp al, 'q'         
    je exit
    cmp ah, LEFT_KEY
    je go_left
    cmp ah, RIGHT_KEY
    je go_right
    cmp ah, DOWN_KEY
    je go_down
    cmp ah, UP_KEY
    je go_up
jmp main                                                                                    


call_draw_shape:
    ;Get the char at the current position
    mov ah, 8
    mov bh, 0
    int 10h
    cmp al, 20h ;space
    jne main
    ;Update the numbers board
    mov ax, 0
    mov al, relative_y
    mov bl, 3
    mul bl
    add al, relative_x
    mov si, ax ;2D to 1D
    mov al, shape
    mov num_board[si], al        
    mov al, shape
    mov won_shape, al
    call draw_shape
    call check_board
    jmp main
   
go_left:
    cmp relative_x, 0
    je main
    dec  relative_x
    sub x_position, 2
    set_cursor x_position y_position
    jmp main

go_right:
    cmp relative_x, 2
    je main
    inc  relative_x
    add x_position, 2
    set_cursor x_position y_position
    jmp main

go_up:
    cmp relative_y, 0
    je main
    dec  relative_y
    sub y_position, 2
    set_cursor x_position y_position  
    jmp main        
       
go_down:
    cmp relative_y, 2
    je main
    inc  relative_y
    add y_position, 2
    set_cursor x_position y_position
    jmp main   

game_over:

;Prints the winner with a message
set_cursor 31 20
mov ah, 9
lea dx, game_over_msg
int 21h

mov ah, 2
mov dl, won_shape
int 21h

mov ah, 9
lea dx, won_msg
int 21h

mov ah, 0             
int 16h
jmp exit


draw:
;Print the draw message
set_cursor 32 20
mov ah, 9
lea dx, draw_msg
int 21h

mov ah, 0             
int 16h
jmp exit


exit:   
	mov ah, 04ch
	int 21h
ret

PROC check_board
;Runs in a loop on the rows, cols and check the 2 diaganols
;It sums every row/col/diaganol and check if its like the sum of three Xs or three Os.

;Check rows
mov bx, 0
mov si, 0
check_rows:
mov bl, num_board[si + 0] 
mov ax, bx
mov bl, num_board[si + 1] 
add ax, bx
mov bl, num_board[si + 2] 
add ax, bx
cmp ax, THREE_X
je game_over 
cmp ax, THREE_O
je game_over
add si, 3
cmp si, 6
jle check_rows

;Check columns
mov bx, 0
mov si, 0
check_cols:          
mov bl, num_board[si + 0] 
mov ax, bx
mov bl, num_board[si + 3] 
add ax, bx
mov bl, num_board[si + 6] 
add ax, bx
cmp ax, THREE_X
je game_over 
cmp ax, THREE_O
je game_over
inc si
cmp si, 2
jle check_cols

;Check diagonals
mov bx, 0
mov bl, num_board[0]
mov ax, bx
mov bl, num_board[4]
add ax, bx
mov bl, num_board[8]
add ax, bx
cmp ax, THREE_X
je game_over 
cmp ax, THREE_O
je game_over

mov bx, 0
mov bl, num_board[2]
mov ax, bx
mov bl, num_board[4]
add ax, bx
mov bl, num_board[6]
add ax, bx
cmp ax, THREE_X
je game_over 
cmp ax, THREE_O
je game_over


inc turns
cmp turns, 9
je draw
ret
ENDP check_board


PROC set_cursor
push bp
mov bp, sp
pusha
mov ah, 2
mov dh, [bp + 4] ; row (y)
mov dl, [bp + 6] ; column (x)
mov bh, 0 ;page number
int 10h
popa
mov sp, bp
pop bp
retn 4
ENDP set_cursor

     

PROC draw_shape                                                                 
pusha
mov al, shape   ;smiley character
mov bh, 0       ;page
mov bl, color   ;Blue or Red
mov cx, 1       ;Number of prints
mov ah, 9       ;put the char in cursor position
int 10h
mov al, X_O_SUM
sub al, shape
mov shape, al
mov al, RED_BLUE_SUM
sub al, color
mov color, al 
popa
ret
ENDP draw_shape
