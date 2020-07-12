
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

; PROGRAMMA CHE ESEGUE L'ESPRESSIONE y=(a+b^2)*c/d DATI DEI VALORI PREDEFINITI

org 100h ; il programma partira' da questa posizione di memoria (la parte prima e' riservata al
         ;sistema)

mov al,b ; sposto il valore della variabile b in al (la meta' di registro ax) per poi utilizzarlo
         ;nella moltiplicazione
mul b    ; moltiplico il valore della variabile b con il valore contenuto in al (il mul considera
         ;al come fattore implicito), e tutto il risultato verra' memorizzato in tutto ax
mov bl,a ; sposto il valore della variabile a nel "mezzo registro" bl (di bx)
         ;per usarlo nell'addizione
add ax,bx; eseguo l'addizione tra il contenuto di ax e quello di bx,
         ;il risultato verra'memorizzato in ax
mov bl,c ; sposto il valore della variabile c nel mezzo registro bl per usarlo nella
         ;moltiplicazione
mul bx   ; eseguo la moltiplicazione tra il valore contenuto in bx
         ;(ovvero c dato che l'avevo spostato in bl) e (implicitamente) il valore di ax,
         ;essendo i fattori che moltiplico (ax e bx) a 16 bit (word) allora il risultato sara'
         ;memorizzato totalmente in dx e ax (sebbene il risultato non sia in questo caso cosi'
         ;grande per cui sara' contenuto completamente in ax ([dx:ax]=ax*bx)
mov bl,d ; sposto il valore della variabile d nel mezzo registro bl per usarlo nella divisione
div bx   ; eseguo la divisione tra il valore di bx (ovvero d dato che l'avevo spostato in bl)
         ;e (implicitamente, come per il mul dato che le due istruzioni hanno un funzionamento
         ;simile) ax, tutto il risultato verra' poi memorizzato (dato che ax e bx sono a 16 bit
         ;ovvero word) nel modo ax=risultato dx=resto
mov y,ax ; sposto il risultato della divisione (ovvero il risultato dell'operazione finale
         ;memorizzato in ax) nella variabile y


ret      ; comando che interrompe l'esecuzione del programma ritornando al sistema operativo

; dichiarazione delle variabili (non si puo' fare prima, altrimenti l'assemblatore lo considerera'
;come codice eseguibile, ed e' sbagliato)
a db 100 ; dichiarazione di a di tipo byte (ad 8 bit) con un valore iniziale di 100
b db 15  ; dichiarazione di b di tipo byte (ad 8 bit) con un valore iniziale di 15
c db 10  ; dichiarazione di c di tipo byte (ad 8 bit) con un valore iniziale di 10
d db 5   ; dichiarazione di d di tipo byte (ad 8 bit) con un valore iniziale di 5

y dw 0   ; dichiarazione di y di tipo word (a 16 bit) con un valore iniziale di 0
