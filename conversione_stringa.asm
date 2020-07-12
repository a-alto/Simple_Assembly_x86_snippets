
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

mov di,0

mov ah,0Eh

stampa:
  mov al,s[di]
  cmp al,36
  je conversione
  int 10h
  inc di
  jmp stampa

conversione:
mov al,13
int 10h

mov di,0

inizio:
  mov al,s[di]
  cmp al,96
  jna continue
  cmp al,123
  jnb continue
  sub al,32
  mov s[di],al
continue:
  cmp al,36
  je stop
  int 10h
  inc di
jmp inizio

stop:


ret

s db "oggi interroghiamo di sistemi$"




