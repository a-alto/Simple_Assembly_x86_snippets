
org 100h

mov cx,3  ; sposto 3 nel registro cx (che fungera' da contatore per il ciclo di stampa)
mov al,x  ; sposto il numero a piu' cifre da stampare (contenuto in x) nel registro al
mov bl,10 ; sposto 10 in bl dato che dovro' dividere il numero da stampare ogni volta per 10 per
          ;ottenerne le singole cifre
mov di,3  ; sposto 3 in di per spostarmi nel vettore s 

inizio:        ; etichetta indicante l'inizio del ciclo per la conversione delle cifre nel
               ;rispettivo codice ASCII per la stampa corretta del numero    
  mov ah,0     ; sposto su ah 0 dato che tutto il registro ax dev'essere diviso per 10, quindi lo
               ;pulisco
  dec di       ; decremento di per spostarmi nel vettore (parto dall'ultima posizione nel metter
               ;le cifre del numero)
  div bl       ; divido tutto il valore del registro ax (quindi il numero) per il valore di bl
               ;(10)
  add ah,48    ; aggiungo 48 al valore contenuto in ah (il resto della divisione) per
               ;"convertirlo" nel corrispondente carattere ASCII (lo 0 ha codice 48)
  mov s[di],ah ; sposto quindi la cifra convertita contenuta in ah nel vettore s in posizione di
cmp al,0       ; comparo al con 0
jne inizio     ; se al e' 0 vuol dire che ho finito di convertire tutte le cifre del numero,
               ;quindi passo oltre. In caso contrario, continuo la conversione saltando ad
               ;"inizio"

mov ah,0Eh     ; devo stampare le cifre del numero in sequenza, quindi imposto la modalita'
               ;"Teletype" (Telescrivente) nel registro ah

stampa:        ; etichetta indicante l'inizio del ciclo di stampa
  mov al,s[di] ; sposto la prima cifra da stampare (contenuta nel vettore s in posizione di) nel
               ;registro al (adibito a contenere cio' che bisogna stampare)
  int 10h      ; richiamo l'interrupt, quindi stampo il valore
  inc di       ; incremento di per spostarmi nel vettore e quindi alla stampa della cifra
               ;successiva
loop stampa    ; ripeto il ciclo tornando a "stampa" fin quando cx non e' 0, stampando quindi
               ;tutte le cifre

ret            ; il controllo ritorna al sistema operativo

; Dichiarazione delle variabili
x db 125        ; variabile di tipo Byte contenente il numero a piu' cifre da stampare
                ;correttamente sullo schermo
s db 3 dup(" ") ; vettore contenente i valori ASCII per ogni cifra del numero da stampare
                ;(inizialmente contenente tre spazi vuoti)
