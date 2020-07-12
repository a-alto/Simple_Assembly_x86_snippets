
org 100h

mov ax,0
mov bx,0
mov cx,0
mov dx,0

ix1:
mov dx,0
mov ah,1h
int 21h
cmp al,13
je fine1
mov cl,al
mov ax,bx
mul ten
mov bx,ax
sub cl,48
add bx,cx
jmp ix1

fine1:
mov x1,bl

mov ah,02h
mov dh,0
mov dl,4
int 10h
mov ax,0
mov bx,0

iy1:
mov dx,0
mov ah,1h
int 21h
cmp al,13
je fine2
mov cl,al
mov ax,bx
mul ten
mov bx,ax
sub cl,48
add bx,cx
jmp iy1

fine2:
mov y1,bl

mov ah,02h
mov dh,1
mov dl,0
int 10h
mov ax,0
mov bx,0

ix2:
mov dx,0
mov ah,1h
int 21h
cmp al,13
je fine3
mov cl,al
mov ax,bx
mul ten
mov bx,ax
sub cl,48
add bx,cx
jmp ix2

fine3:
mov x2,bl

mov ah,02h
mov dh,1
mov dl,4
int 10h
mov ax,0
mov bx,0

iy2:
mov dx,0
mov ah,1h
int 21h
cmp al,13
je fine4
mov cl,al
mov ax,bx
mul ten
mov bx,ax
sub cl,48
add bx,cx
jmp iy2

fine4:
mov y2,bl

call draw

ret

draw proc
    ;stampa riga1
    mov ah,02h
    mov dh,y1
    mov dl,x1
    int 10h
    
    mov cl,x2
    sub cl,x1
    inc cx
    mov ah,0ah
    mov al,'*'
    int 10h
    
    ;stampa colonna1
    mov ah,02h
    mov dh,y1
    mov dl,x2
    int 10h
    
    mov cl,y2
    sub cl,y1
    
    colonna1:
    push cx
    mov ah,02h
    inc dh
    mov dl,x2
    int 10h
    
    mov ah,0ah
    mov cx,1
    mov al,'*'
    int 10h
    pop cx
    loop colonna1
    
    ;stampa riga2
    mov ah,02h
    mov dh,y2
    mov dl,x1
    int 10h
    
    mov cl,x2
    sub cl,x1
    mov ah,0ah
    mov al,'*'
    int 10h 
    
    ;stampa colonna2
    mov ah,02h
    mov dh,y2
    mov dl,x1
    int 10h
    
    mov cl,y2
    sub cl,y1
    dec cl
    
    colonna2:
    push cx
    mov ah,02h
    dec dh
    mov dl,x1
    int 10h
    
    mov ah,0ah
    mov cx,1
    mov al,'*'
    int 10h
    pop cx
    loop colonna2
    
    
    
    ret
draw endp

x1 db ?
y1 db ?
x2 db ?
y2 db ?
ten db 10
