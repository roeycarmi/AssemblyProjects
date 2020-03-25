org 100h
jmp start
INCLUDE painter.asm
;basic colors: Brown, Gray, Deep Gray, White, Black
basic_colors dw 6, 31, 7, 8, 0
size dw 3
color dw 31 ;default is white
welcome_msg db 10,10,9,9,9,9,"Painter ", 1, 13, 10
            db 9,9,9,9,"---------", 13, 10, 10
            db 9,9,9,"By: Roey Carmi",9,"January 2020.",13, 10, 10, 10
            db 9,"Instructoins: Press the left key to draw, and right click to exit.", 13, 10
            db 9,"Press a color of your choice from the palette on the left in order",13, 10
            db 9,"to change your current one.", 13, 10, 10    
            db 9,"Press any key to start the program!", 13, 10, 10, 10
            db 9,9,9,9,"Enjoy!!!$", 13, 10 

; A macro that when called, calls an int that cleans the screen
macro clear_screen
mov ax, 0600h    ;06 TO SCROLL & 00 FOR FULLJ SCREEN
mov bh, 00h    ;BLACK
mov cx, 0000h    ;STARTING COORDINATES
mov dx, 184fh    ;ENDING COORDINATES
int 10h
endm

start:

;Welcome screen:
;---------------

;set text mode
mov ax, 2
int 10h 

;print the welcome message
mov ah, 9
lea dx, welcome_msg 
int 21h
;wait for any key input
mov ah, 0
int 16h


;The actual program:
;-------------------

;enter graphic mode
mov ax, 13h
int 10h

;In this part the color palette at the left side of the screen is printed. Prints colors coded 32 - 48
; dx is changing and resembles the color
mov dx, 32d
xor cx, cx
draw_rectangles: ; In a variety of colors
draw_rectangle 0 cx 9 9 dx
add cx, 9d
inc dx
cmp dx, 48d
jle draw_rectangles

;In this part another more specific colors are added to the color palette at the left side of the screen.  
xor si, si
draw_more_rectangles: ; Brown and white -> black
draw_rectangle 0 cx 9 9 basic_colors[si]
add cx, 9d
add si, 2
cmp si, 10
jl draw_more_rectangles

;initiate cursor
xor ax, ax
int 33h
;show cursor
mov ax, 1h
int 33h

MouseLoop:
ClickLoop:
mov ah, 1
int 16h
jz continue
cmp al, '+'
je inc_size
cmp al, '-'
je dec_size
continue:
mov ax,3h ; read mouse status and position
int 33h
cmp bx, 02h ; check right mouse click (right click exit the program)
je exit     
cmp bx, 01h ; check left mouse click
jne MouseLoop
shr cx, 1 ; the x position needs to be divided by 2
sub cx, 3 ; prints the square slightly to the left of the mouse
cmp cx, 8 ; checks if the mouse is on the left side of the screen (where the color palette is at)
jle set_color ; go to change color
draw_rectangle cx dx size size color ; else: draw a rectangle (square at the current position)
jmp MouseLoop

set_color:
;get the color of the current pixel:
mov ah, 0dh ; function code
mov bh, 0
;cx and dx are already set to the x,y cordinates
int 10h
mov ah, 0 ; color is returned to al but color is a word type so ah should be 0
mov color, ax
;draw_rectangle 80 80 40 40 color
jmp MouseLoop


inc_size:
cmp size, 15
je MouseLoop
inc size
jmp MouseLoop

dec_size:
cmp size, 1
je MouseLoop
dec size
jmp MouseLoop

exit:
;Clean screen:
clear_screen

;End program
mov ax, 4c00h
int 21h

ret




