
org 100h

mov ax,0
mov bx,0
mov cx,0
mov dx,0

base:
mov dx,0
mov ah,1h
int 21h
cmp al,13
je fine_B
mov cl,al
mov ax,bx
mul ten
mov bx,ax
sub cl,48
add bx,cx
jmp base

fine_B:
mov b,bx

mov ah,02h
mov dh,0
mov dl,4
int 10h
mov ax,0
mov bx,0

esponente:
mov dx,0
mov ah,1h
int 21h
cmp al,13
je fine_E
mov cl,al
mov ax,bx
mul ten
mov bx,ax
sub cl,48
add bx,cx
jmp esponente

fine_E:
mov e,bx

mov bx,offset b
mov dx,offset e
mov ax,0
mov cx,0
call pow

ret

pow proc
    mov cx,[dx]
    dec cx
    mov ax,[bx]
    pot:
    mul [bx]
    loop pot
    ret
pow endp

b dw ?
e dw ?
ten dw 10


