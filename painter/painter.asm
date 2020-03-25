PROC draw_pixel ; param: (x, y, color)
    push bp
    mov bp, sp
    pusha
    mov bh, 0
    mov ax, [bp + 4] ; color
    mov dx, [bp + 6] ; Y coord
    mov cx, [bp + 8] ; X coord    
    mov ah, 0ch
    int 10h
    popa
    mov sp, bp
    pop bp
    retn 6    
ENDP draw_pixel

macro draw_pixel x y color
    push x
    push y
    push color
    call draw_pixel
endm

PROC draw_rectangle ; param: (x, y, height, width, color)  
push bp
    mov bp, sp
    pusha
    mov cx, [bp + 6] ; height
    outer_loop:
    mov bx, [bp + 8] ; width
    dec cx
    cmp cx, 0
    jl draw_rectangle_end          
    
    inner_loop:
    ;-----
    dec bx
    mov ax, [bp + 12] ; x
    add ax, bx 
    push ax
    mov ax, [bp + 10] ; y  
    add ax, cx
    push ax 
    push [bp + 4] ; color
    call draw_pixel
    ;-----
    cmp bx, 0
    je outer_loop
    jmp inner_loop 
        
    draw_rectangle_end:
    popa
    mov sp, bp
    pop bp
    
    retn 10   
ENDP draw_rectangle

macro draw_rectangle x y height width color
push x
push y
push height
push width
push color
call draw_rectangle    
endm