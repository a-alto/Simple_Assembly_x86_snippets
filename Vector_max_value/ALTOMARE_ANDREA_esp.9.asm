
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h ; il programma parte dalla locazione di memoria indicata in poi, la parte prima e'
         ;riservata

mov di,0      ; dovendo partire dalla posizione 0 del vettore, metto il valore 0 nel registro di
              ;indice di
mov cx,10     ; il vettore ha 10 elementi, per cui, usando il loop il registro cx come contatore
              ;(implicitamente), memorizzo in cx il valore 10

inizio:       ; etichetta che indica l'inizio del ciclo, l'esecuzione ripartira' da qui ad ogni
              ;ciclo
 mov al,max   ; dovendo confrontare il valore alla posizione [di] del vettore v con il valore
              ;massimo memorizzato nella variabile max, sposto il valore di max in al
 cmp v[di],al ; confronto (in realta' cmp compie una sottrazione) il valore di v[di] con il valore
              ;di al (ovvero max)
 jb continua  ; compio un salto condizionato con jb ('jump below') ovvero se il primo operando e'
              ;minore del secondo (e quindi v[di] NON e' il valore massimo): se la condizione e'
              ;verificata, salto all'istruzione successiva all'etichetta continua 
 mov bl,v[di] ; sposto il valore di v[di] in bl dato che non lo posso memorizzare direttamente in
              ;max
 mov max,bl   ; sposto il valore di bl nella variabile max (la quale conterra' il valore massimo
              ;fino al punto in cui si e' arrivati a controllare)
 continua:    ; etichetta utilizzata per saltare alle istruzioni successive nel caso il valore
              ;v[di] confrontato con max non sia il valore massimo, per cui si saltano le
              ;operazioni di memorizzazione del valore massimo
 add di,1     ; incremento il valore del registro di di 1 potendo quindi navigare nel vettore v
              ;(che e' byte, richiede quindi solo un'incremento di un'unita')
 loop inizio  ; loop decrementa implicitamente cx di 1 e ritorna ad eseguire le istruzioni
              ;successive all'etichetta inizio, tutto questo finche' cx non diventa 0

ret           ; il controllo ritorna al sistema operativo

; dichiarazione delle variabili
v db 10 , 5 , 31 , 40 , 18 , 22 , 27 , 3 , 9 , 15 ; dichiarazione del vettore
max db 0 ; dichiarazione della variabile in cui verra' memorizzato il valore massimo
