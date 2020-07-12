
org 100h ; il programma inizia dalla locazione di memoria indicata

mov ax,0 ; "pulisco" ax
mov bx,0 ; "pulisco" bx
mov cx,0 ; "pulisco" cx
mov dx,0 ; "pulisco" dx

input:      ; etichetta indicante l'inizio dell'input del numero
  mov dx,0  ; pulisco dx ogni volta
  mov ah,1h ; "setto" il servizio per l'input 
  int 21h   ; richiamo l'ISR tramite l'interrupt DOS. Il carattere acquisito verra' collocato in
            ;al
  cmp al,13 ; confronto il contenuto di al col codice ASCII 13 (corrispondente al tasto "ENTER")
  je fine   ; se e' uguale vuol dire che l'utente ha terminato l'immissione, per cui vai a
            ;"fine", in caso contrario, continua con l'esecuzione del codice
  
  inc keys  ; incremento il numero di caratteri presenti sullo schermo (contenuto nella variabile
            ;keys)
  
  ; controllo backspace
  back: ; etichetta indicante l'inizio del codice per gestire il cancellamento dei caratteri
        ;tramite la pressione del tasto "BACKSPACE"
  cmp al,8 ; comparo il contenuto di al con il codice ASCII 8 (corrispondente al carattere
           ;"BACKSPACE")
  jne caratteri ; se non e' uguale, vuol dire che e' stato premuto un altro carattere, per cui
                ;passo al controllo caratteri
  cmp digits,0  ; confronto il numero di cifre contenute nella variabile digits con 0
  jne continua2 ; se non e' uguale, quindi il numero delle cifre e' diverso (maggiore) di 0,
                ;passa a "continua2"
  cmp keys,1    ; se il numero di cifre e' 0, si passa al confronto tra il numero di caratteri
                ;presenti sullo schermo con 1
  jne segno     ; se non e' uguale ad uno, e le cifre (digits) al tempo stesso sono 0 vuol dire
                ;che sullo schermo si trova solo il simbolo del segno (keys e' due perche' viene
                ;incrementato alla pressione di backspace), per cui passa alla relativa gestione
                ;da "segno"
  dec keys      ; se keys e' 1 vol dire che non c'e' niente, e' stato solo premuto il backspace,
                ;per cui decrementa keys per farlo tornare a 0
  jmp input     ; salta incondizionatamente ad "input"
  ; se c'e' il segno, cancellalo
  segno:          ; etichetta indicante il codice per la gestione della cancellazione del segno
  cmp sign,1      ; confronto la variabile sign con 1
  jne continua2   ; se non e' uguale (ovvero non c'e' il segno) passa a "continua2"
  mov sign,0      ; se e' uguale, bisogna cancellarlo, per cui sposta 0 su sign
  push cx         ; dovendo utilizzare alcuni registri per la cancellazione del carattere, devo
                  ;conservarne i relativi valori nello stack. Inserisco nello stack il contenuto
                  ;di cx
  push bx         ; inserisco nello stack il valore di bx
  mov cx,1        ; sposto su cx 1 (ovvero il numero di volte che il carattere contenuto in al
                  ;dovra' essere stampato a schermo)
  mov bx,0        ; sposto su bx 0 (cioe' il numero della pagina su cui dovra' essere dato
                  ;l'output. 0 e' la pagina su cui mi trovo di default)
  mov ah,0ah      ; "setto" il servizio 0ah sul registro ah
  mov al,0        ; sposto su al il carattere che dovra' essere stampato, ovvero "null" indicato
                  ;dal codice ASCII 0
  int 10h         ; richiamo l'ISR tramite l'interrupt BIOS 10h
  pop bx          ; finito di stampare (e quindi di cancellare il carattere) riprendo i valori
                  ;dei registri usati. Estraggo l'ultimo valore inserito nello stack e lo metto
                  ;su bx
  pop cx          ; riestraggo l'ultimo valore e lo metto nel registro cx
  mov bx_lim,6553 ; non essendo piu' un numero con segno, riporto i limiti per controllare
                  ;l'overflow a quelli di default (per numeri senza segno). Quindi sposto sulla
                  ;variabile bx_lim 6553
  mov al_lim,53   ; sposto sulla variabile al_lim il valore 53 (codice ASCII corrispondente al
                  ;carattere '5')
  sub keys,2      ; sottraggo a keys 2 (uno per il backspace premuto e uno per il carettere del
                  ;segno '-' appena cancellato)
  jmp input       ; salto incondizionatamente ad "input"
  continua2:      ; etichetta indicante il caso in cui si debba cancellare un carattere indicante
                  ;una cifra
  sub keys,2      ; sottraggo a keys 2 (uno per backspace e uno per il carattere indicante la
                  ;cifra cancellata)
  dec digits      ; decremento di uno digits (dato che cancello una cifra)
  push cx         ; devo conservare i valori di alcuni registri che devo usare per l'output e la
                  ;relativa cancellazione del carattere. Inserisco il valore di cx nello stack
  push bx         ; inserisco il valore di bx nello stack
  mov cx,1        ; sposto su cx 1 (il numero di volte da stampare il contenuto di al)
  mov bx,0        ; sposto su bx 0 (corrispondente alla pagina su cui stampare)
  mov ah,0ah      ; "setto" su ah il servizio della modalita' testo (0ah)
  mov al,0        ; sposto su al il valore da stampare ("null" corrispondente ad ASCII 0)
  int 10h         ; richiamo l'ISR tramite l'interrupt BIOS 10h
  pop bx          ; estraggo l'ultimo valore dallo stack e lo metto in bx
  pop cx          ; estraggo l'ultimo valore dallo stack e lo metto in cx
  cmp ow,1        ; confronto il contenuto di ow (indicante se si era gia' andato in overflow o
                  ;meno) con 1
  jne ricalcola   ; se non e' uguale passa a "ricalcola"
  ; ricontrolla overflow
  mov cl,aus      ; se ow e' uguale ad 1 vuol dire che cancellando c'e' la possibilita' che
                  ;l'overflow non ci sia piu' (rispetto ovviamente ai caratteri digitati in
                  ;precedenza) per cui sposto il valore di aus (nel quale era stato memorizzato
                  ;il numero di cifre presenti quando si era andato in overflow) in cl
  cmp digits,cl   ; comparo digits con cl (aus)
  jnb input       ; se digits non e' minore vuol dire che si e' ancora in una situazione di
                  ;overflow, per cui salta ad input senza fare nient'altro
  mov ow,0        ; altrimenti vuol dire che non si e' piu' in overflow per cui sposta su ow 0
  push ax         ; si procede alla cancellazione del messaggio di avviso dell'overflow, per cui
                  ;salvo i valori dei registri che dovro' usare, nello stack. Inserisco ax nello
                  ;stack
  push bx         ; inserisco bx nello stack
  push cx         ; inserisco cx nello stack
  push dx         ; inserisco dx nello stack
  ; messaggio cancella avviso
  mov ah,02h      ; "setto" il servizio 02h per lo spostamento del cursore su ah
  mov dh,2        ; sposto su dh 2 (la riga su cui si dovra' stampare, corrispondente a quella in
                  ;cui e' l'avviso di overflow da cancellare)
  mov dl,0        ; sposto su dl 0 dato che devo iniziare dall'inizio della riga a stampare
  mov bx,0        ; sposto su bx 0 (corrispondente alla pagina su cui ci si trova di default)
  int 10h         ; richiamo l'ISR con l'interrupt BIOS 10h spostando quindi la posizione del
                  ;cursore dove indicato dai valori nei registri
  mov dx,offset cls ; sposto su dx l'offset del vettore di caratteri "cls" contenente la stringa
                    ;da stampare per cancellare il messaggio di overflow
  mov ah,9h       ; "setto" su ah il servizio 9h
  int 21h         ; richiamo l'ISR con l'interrupt DOS 21h
  mov ah,02h      ; devo rispostare il cursore dov'era prima, per cui "setto" il servizio 02h su
                  ;ah
  mov dh,0        ; sposto 0 su dh dato che la riga dove si immettono le cifre del numero e' 0
  mov dl,aus      ; sposto su dl il valore di aus (che indicando le cifre presenti al momento
                  ;dell'overflow, indirettamente e' anche il numero della colonna su cui si deve
                  ;posizionare il cursore, con delle condizioni dettate dalle istruzioni
                  ;successive)
  cmp sign,1      ; comparo sign con 1
  je  noDec       ; se e' uguale (e quindi e' un numero con segno) vai a "noDec"
  dec dl          ; altrimenti (se quindi non e' un numero con segno) decrementa dl di uno (per
                  ;posizionarsi sulla colonna corretta)
  noDec:          ; etichetta indicante il codice da eseguire immediatamente se il numero
                  ;considerato non e' col segno
  mov bx,0        ; sposta su bx 0 (corrispondente alla pagina schermo di output di default)
  int 10h         ; richimao l'ISR tramite l'interrupt BIOS 10h spostando quindi il cursore
  ; fine messaggio
  pop dx          ; riprendo i valori dei registri. Estraggo l'ultimo valore dello stack e lo
                  ;metto su dx
  pop cx          ; Estraggo l'ultimo valore dello stack e lo metto su cx
  pop bx          ; Estraggo l'ultimo valore dello stack e lo metto su bx
  pop ax          ; Estraggo l'ultimo valore dello stack e lo metto su ax
  jmp input       ; salto incondizionatamente ad input
  ricalcola:      ; etichetta indicante il ricalcolo del numero totale quando si cancella una
                  ;cifra
  mov ax,bx       ; sposto il valore di bx (quindi il numero totale immesso) in ax
  mov dx,0        ; "pulisco" dx dato che dovro' eseguire una divisione che comportera' anche
                  ;l'utilizzo implicito di dx
  div ten         ; divido (implicitamente) cio' che e' contenuto in ax (quindi il numero) per il
                  ;valore della variabile ten (10)
  mov bx,ax       ; sposto quindi il numero ricalcolato contenuto in ax nel registro bx
  
  mov cx,0        ; "pulisco" cx
  jmp input       ; salto incondizionatamente ad "input"
  
  ; controllo per i caratteri
  caratteri:      ; etichetta indicante il codice riguardante la gestione del codice nel caso in
                  ;cui l'utente immetta un carattere diverso da un numero
  cmp al,45       ; confronto cio' che e' contenuto in al (cio' che e' stato acquisito da
                  ;tastiera) con il valore 45 (codice ASCII corrispondente al segno meno '-')
  jne lettere     ; se non e' uguale (per cui e' stato digitao un altro carattere) passa a
                  ;"lettere"
  cmp keys,1      ; se invece il carattere acquisito e' proprio quello del segno, conpara il
                  ;numero di caratteri presenti sullo schermo (keys) con 1
  jne lettere     ; se non e' uguale (quindi sono di piu'), tratta il segno immesso come un
                  ;qualsiasi altro carattere non ammesso andando a "lettere"
  mov sign,1      ; altrimenti vuol dire che si sta immettendo un numero con segno, per cui
                  ;sposta su sign 1
  mov bx_lim,3276 ; modifica il valore di controllo per l'overflow dato che per i numeri con
                  ;segno sara' diverso. Sposta su bx_lim 3276
  mov al_lim,55   ; modificalo anche per al_lim spostando il valore 55 (ASCII corrispondente al
                  ;carattere '7')
  jmp input       ; salta incondizionatamente ad "input"
  lettere:        ; etichetta indicante il codice per gestire l'immissione dei caratteri e
                  ;compiere le opportune operazioni a seconda di cio' che si immette
  cmp al,48       ; confronta il carattere acquisito (in al) con 48 (corrispondente a '0')
  jb cancella     ; se e' minore vuol dire che non e' un numero per cui passa a "cancella"
  cmp al,58       ; altrimenti comparalo con 58 (corrispondente al carattere successivo a '9'
                  ;ovvero ':')
  jb controllo    ; se e' minore vuol dire che il carattere immesso e corrispondente ad una
                  ;cifra compresa fra 0 e 9, per cui passa a "controllo" per gestirlo
  cancella:       ; altrimenti vuol dire che e' un carattere non trattabile come numero, per cui
                  ;si passa alla cancellazione indicata dall'etichetta "cancella"
  push cx         ; avendo bisogno bisogno di alcuni registri per l'output, ne conservo il valore
                  ;nello stack. Inserisco cx nello stack
  push bx         ; inserisco bx nello stack
  
  mov bx,0        ; sposto 0 in bx in riferimento alla pagina di default
  mov ah,02h      ; "setto" su ah il servizio di spostamento del cursore 02h
  mov dh,0        ; sposto su dh (indicante la riga) 0, ovvero quella in cui si trovano i
                  ;caratteri immessi da tastiera
  mov dl,keys     ; sposto su dl (ovveor la colonna) il valore di keys corrispondente ai
                  ;caratteri immessi
  dec dl          ; poiche' il numero di caratteri immessi prende in considerazione anche il
                  ;carattere da cancellare, decremento dl dato che per dare l'output e cancellare
                  ;il carattere, mi devo posizionare alla sua posizione
  int 10h         ; richiamo l'ISR tramite l'interrupt BIOS 10h spostando quindi il cursore alla
                  ;posizione voluta
  
  mov cx,1        ; ora do l'output per cancellare il carattere per cui sposto su cx 1 (il numero
                  ;di volte da dare l'output)
  mov bx,0        ; sposto su bx 0 (la pagina di default su cui dare l'output)
  mov ah,0ah      ; "setto" su ah il servizio 0ah
  mov al,0        ; metto su al 0 (ASCII corrispondente a "null" per cancellare il carattere)
  int 10h         ; richiamo l'ISR tramite l'interrupt BIOS 10h cancellando quindi il carattere
  pop bx          ; ripristino i valori dei registri utilizzati. Estraggo l'ultimo valore dallo
                  ;stack e lo metto in bx
  pop cx          ; estraggo l'ultimo valore dallo stack e lo metto in cx
  dec keys        ; decremento keys (dato che era stato incrementato all'acquisizione del
                  ;carattere (successivamente cancellato)
  jmp input       ; salto incondizionatamente ad "input"
  
   
  controllo:        ; etichatta indicante il codice atto a gestire l'immissione di un carattere 
                    ;corrispondente ad un numero
  inc digits        ; incremento il numero di cifre presenti sul video (digits)
  cmp ow,1          ; comparo ow con 1
  je input          ; se e' uguale vuol dire che precedentemente si era gia' in una situazione di
                    ;overflow, per cui non modificare il valore di bx (il registro accumulatore
                    ;utilizzato per contenere il numero totale) e passa direttamente ad "input"
  cmp digits,5      ; altrimenti inizia a controllare se si sta andando in overflow. Confronta
                    ;quindi il numero di cifre (digits) con 5
  jna confronto     ; se non e' maggiore, passa a "confronto"
  cmp bx,11111      ; altrimenti confronta bx con 11111 (dato che le cifre potrebbero essere
                    ;anche solo 0 prima del numero effettivo, si esegue questo ulteriore
                    ;controllo)
  ja overflow       ; se e' maggiore vai ad "overflow"
  confronto:        ; etichetta indicante il codice per gestire l'overflow in base al valore del
                    ;registro accumulatore utilizzato
  cmp bx,bx_lim     ; confronto bx con bx_lim (indicante il limite entro cui può valere bx per
                    ;non andare in overflow alla pressione di un'altra cifra)
  ja overflow       ; se e' maggiore passa ad "overflow"
  jb noOverflow     ; se e' minore passa a "noOverflow"
  cmp al,al_lim     ; se e' uguale confronta la nuova cifra acquisita (su al) con al_lim (ovvero
                    ;la cifra maggiore aggiungibile affinche' non si vada in overflow)
  jna noOverflow    ; se non e' maggiore passa a "noOverflow"
  overflow:         ; etichetta indicante il codice per gestire il caso in cui ci sia un overflow
  mov ow,1          ; sposta su ow 1
  push ax           ; dovendo usare ax, lo conservo nello stack. Inserisco il valore di ax nello
                    ;stack
  mov al,digits     ; devo memorizzare il numero di cifre presenti quando vado in overflow. Per
                    ;cui sposto in al digits
  mov aus,al        ; sposto quindi in aus al, memorizzando quindi il numero di cifre presenti
  pop ax            ; estraggo l'ultimo valore inserito nello sack e lo metto in ax
  push ax           ; adesso do in output il messaggio di overflow, consero quindi i valori dei
                    ;registri che devo usare nello stack. Inserisco ax nello stack
  push bx           ; inserisco bx nello stack
  push cx           ; inserisco cx nello stack
  push dx           ; inserisco dx nello stack
  ; messaggio
  mov ah,02h        ; "setto" il servizio 02h (per lo spostamento del cursore) su ah
  mov dh,2          ; su dh imposto la riga 2 sulla quale verra' dato in output il messaggio
  mov dl,0          ; su dl imposto la colonna (0) dalla quale si dovra' iniziare a dare i output
                    ;il vettore di caratteri
  mov bx,0          ; su bx imposto la pagina di default (0), ovvero quella su cui mi trovo
  int 10h           ; richiamo l'ISR tramite l'interrupt BIOS 10h
  mov dx,offset msg ; adesso devo stampare il messaggio. Sposto su dx l'offset del vettore msg
  mov ah,9h         ; "setto" il servizio 9h su ah
  int 21h           ; richiamo l'ISR tramite l'interrupt DOS 21h, dando quindi in output la
                    ;stringa fino al simbolo del dollaro ('$')
  mov ah,02h        ; passo nuovamente allo spostamento del cursore per portarlo a dov'era prima.
                    ;"Setto" quindi il servizio 02h su ah
  mov dh,0          ; imposto la riga 0 su dh (dov'e' il numero)
  mov dl,keys       ; imposto la colonna su dl usando keys (contenente il numero di caratteri
                    ;presenti)
  mov bx,0          ; imposto la pagina di default (0) su bx
  int 10h           ; richiamo l'ISR tramite l'interrupt BIOS 10h spostando cosi' il cursore
  ; fine messaggio
  pop dx            ; finito di dare in output il messaggio riprendo i valori dei registri dallo
                    ;stack. Estraggo l'ultimo valore dallo stack e lo metto in dx
  pop cx            ; estraggo l'ultimo valore dallo stack e lo metto in cx
  pop bx            ; estraggo l'ultimo valore dallo stack e lo metto in bx
  pop ax            ; estraggo l'ultimo valore dallo stack e lo metto in ax
  jmp input         ; salto incondizionatamente ad input
  noOverflow:       ; etichetta indicante il codice per gestire la situazione in cui non c'e'
                    ;l'overflow
  mov ow,0          ; sposto su ow 0
  
  continua:         ; etichetta indicante il codice atto a gestire la corretta "registrazione"
                    ;del numero totale immesso, nel registro accumulatore
  mov cl,al         ; sposto la cifra che e' stata immessa (al) in cl
  mov ax,bx         ; sposto bx in ax
  mov dx,0          ; "pulisco" dx dato che anche lui dovra' essere usato implicitamente
  mul ten           ; moltiplico il valore in ax per il valore di ten (10)
  mov bx,ax         ; risposto quindi il valore moltiplicato di ax in bx
  sub cl,48         ; sottraggo 48 a cl per farlo diventare una cifra effettiva da usare come
                    ;numero e non come carattere
  add bx,cx         ; aggiungo cx a bx ottenendo nel registro accumulatore usato (bx) il numero
                    ;totale
  jmp input         ; salto incondizionatamente ad "input"

fine:        ; etichetta indicante il codice per memorizzare il numero totale immesso nella
             ;variabile apposita
cmp sign,1   ; compara sign con 1
jne positive ; se non e' uguale (e quindi non si e' immesso un numero negativo) passa a
             ;"positive"
mov dx,0     ; altrimenti eseguo il codice per convertire il numero da positivo in negativo
mov ax,bx    ; sposto il numero contenuto in bx in ax
mul minum    ; lo moltiplico per il contenuto di minum (-1)
mov bx,ax    ; sposto il numero convertito da ax a bx
positive:    ; etichetta indicante il codice da eseguire subito se il numero immesso non deve
             ;essere negativo
mov n,bx     ; sposto come operazione finale il numero totale da bx ad n

ret          ; ritorna il controllo al sistema operativo

; Dichiarazione delle variabili
bx_lim dw 6553 ; variabile contenente il limite entro il cui puo' valere il contenuto di bx per
               ;non andare in overflow quando si da' in input un'altra cifra. Variabile a seconda
               ;se si sta operando con un numero positivo o negativo
al_lim db 53   ; variabile contenente la cifra massima da poter dare in input (il relativo codice
               ;ASCII) senza andre in overflow se cio' che e' contenuto in bx e' uguale al
               ;contenuto di bx_lim. Variabile a seconda se si sta operando con un numero
               ;positivo o negativo
sign db 0      ; variabile indicante la presenza del segno meno (1-numero negativo ; 0-numero
               ;positivo)
keys db 0      ; variabile indicante il numero di caratteri presenti sullo schermo
aus db ?       ; variabile che memorizza il numero di cifre presenti sullo schermo quando si va
               ;in overflow
digits db 0    ; variabile contenente il numero di cifre numeriche presenti sullo schermo
ten dw 10      ; variabile contenente 10 con cui si possono eseguire le moltiplicazioni e le
               ;divisioni quando necessario
minum dw -1    ; variabile contenente -1 per poter convertire in fase finale il numero da
               ;positivo in negativo moltiplicandolo per il suo contenuto
n dw ?         ; variabile che conterra' il numero immesso quando si premera' il tasto "ENTER"
ow db 0        ; variabile indicante la presenza di overflow (1-overflow ; 0-no overflow)
cls db "                                           $" ; vettore di caratteri "spazio" utilizzata
                                                      ;per cancellare il messaggio indicante
                                                      ;l'overflow sullo schermo quando non si e'
                                                      ;piu' in una situazione di overflow
msg db "C'E' STATO UN OVERFLOW!! CANCELLA QUALCOSA!$" ; vettore di caratteri rappresentante la
                                                      ;frase da dare in output quando si va in
                                                      ;overflow
                                                     