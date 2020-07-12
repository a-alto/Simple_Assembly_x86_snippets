
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h ; il programma inizia da questa locazione di memoria in poi

mov ax,0 ; "pulisco" ax
mov bx,0 ; "pulisco" bx
mov cx,0 ; "pulisco" cx
mov dx,0 ; "pulisco" dx

call legginum ; chiamo la procedura "legginum"
sub sp,8      ; sottraggo 8 ad sp spostandomi quindi di quattro posizioni nello stack (una
              ;posizione vale 16 bit, per cui 2 byte) per le quattro cifre massime esadecimali
call ToHex    ; chiamo la procedura "ToHex"

;sposto il cursore (dato che la stampa del numero convertito andra' eseguito, per chiarezza
;dell'utente, due righe dopo)
mov ah,02h    ; "setto" il servizio di sopostamento del cursore (02h) su ah
mov dh,2      ; imposto la terza riga (2) su dh
mov dl,0      ; imposto la prima colonna (0) su dl
int 10h       ; richiamo l'ISR tramite l'interrupt BIOS 10h muovendo quindi il cursore alla
              ;posizione impostata

;stampa del numero 
mov sp,0xFFF6 ; sposto sullo Stack Pointer (sp) l'indirizzo dello stack 0xFFF6 (o FFF6h) dove
              ;sara' l'ultima cifra convertita in esadecimale e quindi la prima a dover essere
              ;stampata
stampa:       ; etichetta indicante il codice per la stampa del numero convertito 
mov ah,0eh    ; "setto" su ah il servizio per la modalita' telescrivente (0eh)
mov bx,0      ; "pulisco" bx
pop bx        ; estraggo l'ultimo valore dallo stack e lo metto in bx
mov al,bl     ; sposto il contenuto di bl in al (dato che solo la parte "bassa" del registro bx
              ;conterra' effettivamente la cifra esadecimale da stampare)
mov bx,0      ; sposto su bx 0 (ovvero impoosto la prima pagina, quella su cui ho immesso il
              ;numero)
cmp al,0      ; comparo al con 0
jz stampa     ; se e' uguale salto a "stampa" (dato che al vale 0 solo se nessuna cifra e' stata
              ;convertita)
int 10h       ; richiamo l'ISR tramite l'interrupt BIOS 10h e stampo la cifra
loop stampa   ; eseguo il ciclo tornando a "stampa" finche' cx non e' 0 (cx dopo la procedura di
              ;conversione assumera' un valore corrispondente al numero di cifre convertite e
              ;quindi da stampare)

ret           ; il controllo ritorna al sistema operativo

; Procedura per leggere in input il numero da convertire                                                   
legginum proc ; nome della procedura ("legginum") e parola chiave che la identifica ("proc")
    input:    ; etichetta indicante l'inizio del codice per gestire l'input
    mov dx,0  ; "pulisco" ogni volta dx perche' altrimenti potrebbe interferire con la
              ;moltiplicazione di ax successivamente
    mov ah,1h ; "setto" su ah il servizio 1h per l'input
    int 21h   ; richiamo l'ISR tramite l'interrupt DOS 21h
    cmp al,13 ; comparo il carattere acquisito (su al) con il codice ASCII 13 (corrispondente al
              ;tasto "ENTER")
    je fine   ; se e' uguale vuol dire che l'utente ha terminato l'immissione, per cui salto a
              ;"fine"
    mov cl,al ; altrimenti vuol dire che l'utente ha immesso un numero da tastiera, per cui si
              ;procede spostando il contenuto di al in cl
    mov ax,bx ; sposto il contenuto di bx (tutto il numero totale acquisito fino a quel momento)
              ;in ax (bx e' il registro usato come accumulatore)
    push cx   ; per eseguire la moltiplicazione ho bisogno di un registro libero, per cui sposto
              ;cx nello stack
    mov cx,10 ; sposto 10 su cx
    mul cx    ; moltiplico (implicitamente) il contenuto di ax (tutto il numero accumulato fino
              ;a quel momento) per quello di cx (10)
    pop cx    ; estraggo l'ultimo valore dallo stack e lo metto su cx (cosi' da ripristinarne il
              ;valore precedente
    mov bx,ax ; il risultato della moltiplicazione e' in ax, per cui lo sposto nuovamente nel
              ;registro accumulatore bx
    sub cl,48 ; sottraggo a cl (contenente il carattere numerico acquisito) 48 per trasformarlo
              ;da carattere a numero effettivo
    add bx,cx ; sommo a bx cx per cui ora il numero totale comprende anche l'ultimo numero
              ;acquisito da tastiera
    jmp input ; salto incondizionatamente ad "input"
    fine:     ; etichetta indicante il codice da eseguire una volta concluso l'input del numero
    mov ax,bx ; sposto au ax il contenuto di bx (per cui tutto il numero acquisito viene
              ;memorizzato in ax)
    ret       ; il controllo ritorna al programma chiamante
legginum endp ; nome della procedura ("legginum") e parola chiave che ne indica la fine ("endp")

; Procedura per convertire il numero acquisito
ToHex proc ; nome della procedura ("ToHex") e parola chiave che la identifica ("proc") 
    mov [0xFFFC],0 ; "pulisco" la locazione di memoria (nello stack) 0xFFFC spostandoci 0 
    mov [0xFFFA],0 ; "pulisco" la locazione di memoria (nello stack) 0xFFFA spostandoci 0
    mov [0xFFF8],0 ; "pulisco" la locazione di memoria (nello stack) 0xFFF8 spostandoci 0
    mov [0xFFF6],0 ; "pulisco" la locazione di memoria (nello stack) 0xFFF6 spostandoci 0
    mov bp,sp      ; "conservo" il valore del registro sp in bp (per "ricordare" a quale
                   ;indirizzo dello stack puntava prima di modificarne il valore)
    mov sp,0xFFFE  ; sposto su sp il valore esadecimale FFFE corrispondente al primo indirizzo
                   ;utilizzabile dello stack
    mov cx,0       ; sposto su cx 0 dato che verrà usato come contatore delle cifre esadecimali
                   ;ottenute dalla conversione del numero decimale
    converti:      ; etichetta indicante il codice adibito alla conversione del numero immesso
                   ;da decimale ad esadecimale
    mov dx,0       ; "pulisco" ogni volta dx per non compromettere la moltiplicazione di ax
    mov bx,16      ; sposto 16 su bx per poter eseguire la moltiplicazione
    div bx         ; divido (implicitamente) il contenuto di ax per quello di bx ottenendo come
                   ;resto (ubicato in dx) la cifra esadecimale ottenuta
    cmp dx,9       ; comparo il valore ottenuto come resto (in dx) con 9
    jna num        ; se non e' maggiore allora la cifra esadecimale e' un carattere numerico
                   ;compreso fra 0 e 9, per cui la gestisco passando a "num"
    add dx,55      ; altrimenti vuol dire che la cifra esadecimale e' una lettera, per cui vi
                   ;aggiungo 55 per trasformare il valore numerico in un carattere ASCII
                   ;corrispondente a una lettera (tra A ed F)
    jmp salva      ; salto incondizionatamente a "salva"
    num:           ; etichetta indicante il codice adibito a convertire il valore numerico della
                   ;cifra esadecimale in un carattere ASCII numerico
    add dx,48      ; sommo a dx 48 convertendolo cosi' da valore numerico a carattere numerico
    salva:         ; etichetta indicante il codice adibito a salvare la cifra esadecimale
                   ;ottenuta dalla divisione (salvataggio nello stack) ed altre operazioni per
                   ;procedere con la conversione del numero totale
    push dx        ; sposto nello stack il valore di dx (salvando quindi la cifra esadecimale)
    inc cx         ; incremento cx che in questo caso funge da contatore delle cifre esadecimali 
    cmp ax,0       ; comparo ax con 0
    jne converti   ; se non e' uguale vuol dire che non si e' ancora finito di convertire il
                   ;numero, per cui salto a "converti"
    mov sp,bp      ; "ripristino" il precedente valore dell Stack Pointer spostando il valore di
                   ;bp (dove era stato salvato) in sp
    ret            ; il controllo ritorna al programma chiamante
ToHex endp ; nome della procedura ("ToHex") e parola chiave che ne indica la fine ("endp")
