
org 100h

; set graphics mode
mov al,13h
mov ah,0
int 10h
; end settings

mov cx,0  ; set column
mov dx,0  ; set row
mov al,36 ; set color
mov bh,9  ; set number of pixel same color

rows:
mov cx,0  

columns:
mov ah,0ch ; set service
int 10h    ; print pixel

inc cx
cmp cx,251 ;set number of pixel-per-row to print
jne columns

; control: print the same color 7 times
dec bh
cmp bh,0
jne continue
mov bh,9
dec al

; change color
cmp al,36
ja continue
cmp al,32
jne continue ; if !al<36 and al!=32 change color to 57
mov al,55 

continue:
inc dx
cmp dx,181
jne rows

ret
