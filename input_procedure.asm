
org 100h

mov ax,0
mov bx,0
mov cx,0
mov dx,0

input:
mov bx,offset n
call scanf
jmp input

fine:

ret

scanf proc
    mov dx,0
    mov ah,1h
    int 21h
    cmp al,13
    je fine
    mov cl,al
    mov ax,[bx]
    mul ten
    mov [bx],ax
    sub cl,48
    add [bx],cx
    ret
scanf endp
    

n dw 0
ten dw 10



