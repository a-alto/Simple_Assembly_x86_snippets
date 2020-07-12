
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h ; il programma parte dalla locazione di memoria indicata in poi

mov di,0 ; sposto il valore 0 su di che servira' come indice del primo vettore
mov bx,0 ; sposto il valore 0 su bx che servira' come indice del terzo vettore
mov cx,7 ; sposto il valore 7 su cx che servira' come contatore per il ciclo esterno

for1:         ; etichetta per il ciclo principale
mov al,v1[di] ; sposto il valore di v1[di] su al
mov dx,8      ; sposto 8 su dx che fungera' da contatore per il ciclo secondario (lo faccio ogni
              ;volta dato che ad ogni ciclo, quello secondario deve essere eseguito quel numero di
              ;volte
mov si,0      ; sposto (ogni volta dato che devo cominciare sempre dall'inizio del vettore) il
              ;valore 0 su si
for2:         ; etichetta per il ciclo secondario
cmp al,v2[si] ; compara il valore di al (v1[di]) con il valore di v2[si]
jne continua  ; se non sono uguali, salta il blocco di istruzioni passando direttamente a quelle
              ;successive a continua
mov v3[bx],al ; sposta il valore di al in v3[bx]
inc bx        ; incrementa bx (dato che e' usato come indice del vettore v3)
mov dx,1      ; sposta il valore 1 su dx
continua:     ; etichetta per l'esecuzione del restante codice del ciclo secondario senza aver
              ;effettuato il blocco di istruzioni nel caso v1[di] e v2[si] non corrispondano
inc si        ; incrementa si per spostarsi in v2
dec dx        ; decrementa dx per il ciclo secondario (analogamente al cx per quello principale)
cmp dx,0      ; compara dx con 0 (per capire se si e' arrivati alla fine del ciclo)
jne for2      ; se il valore di dx non e' 0, il ciclo non e' finito per cui salta a for2
inc di        ; incrementa di per spostarsi in v1
loop for1     ; salta a for1 finche' cx non e' 0

ret ; il controllo ritorna al sistema operativo

; Dichiarazione delle variabili
v1 db 3 , 57 , 32 , 18 , 25 , 50 , 21      ; primo vettore
v2 db 4 , 15 , 20 , 30 , 25 , 32 , 60 , 50 ; secondo vettore
v3 db 8 dup(0)                             ; terzo vettore
