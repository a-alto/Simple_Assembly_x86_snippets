
; temperature rises fast, this emulator should be set to run at the maximum speed.

; if closed, the thermometer window can be re-opened from emulator's "virtual devices" menu.

#make_bin# ; Direttiva dell'emu8086 per creare un file .bin al salvataggio

name "thermo"

#start=thermometer.exe# ; direttiva dell'emu8086 per aprire il programma "thermometer.exe" per
                        ;simulare un termometro 
#start=Led_display.exe# ; direttiva dell'emu8086 per aprire il programma "Led_display.exe" per
                        ;simulare un display LED numerico

; set data segment to code segment:
mov ax, cs ; sposto l'indirizzo contenuto in cs in ax
mov ds, ax ; sposto il vaolore di ax nel registro ds

mov ax,0 ; "pulisco" il registro ax spostandovi 0
mov bx,0 ; "pulisco" il registro bx spostandovi 0
mov cx,0 ; "pulisco" il registro cx spostandovi 0
mov dx,0 ; "pulisco" il registro dx spostandovi 0

mov ah,9h          ; "setto" il servizio per la scrittura di una stringa di testo (9h) sul
                   ;registro ah
mov dx,offset msg1 ; metto su dx l'offset della variabile msg1 (per impostare la stringa da
                   ;stampare)
int 21h            ; richiamo l'ISR tramite l'interrupt DOS 21h

input:     ; input temperatura minima
mov dx,0   ; "pulisco" ogni volta il registro dx per non farlo interferire con le operazioni
           ;implicite di moltiplicazione
mov ah,1h  ; "setto" su ah il servizio per l'input 1h
int 21h    ; richiamo l'ISR tramite l'interrupt DOS 21h (il valore acquisito andra' nel registro
           ;al)
cmp al,13  ; comparo il valore di al con 13 (ASCII corrispondente al tasto "ENTER")
je fine    ; se e' uguale vuol dire che l'utente ha terminato l'immissione, per cui salta a
           ;"fine"
mov cl,al  ; sposto il valore di al su cl
mov al,bl  ; sposto il numero totale (contenuto nel registro bl, usato come accumulatore) su al
mul ten    ; moltiplico (implicitamente) il contenuto di al per il valore della variabile ten
           ;(10)
mov bl,al  ; risposto al in bl
sub cl,48  ; sottraggo a cl 48 per convertirlo da carattere ASCII a cifra utilizzabile
add bl,cl  ; aggiungo a bl il valore di cl ottenendo cosi' il nuovo numero totale
jmp input  ; salto incondizionatamente ad "input"
fine:      ; fine dell'input del numero
mov min,bl ; sposto il numero totale immesso (in bl) nella variabile min (contenente il valore
           ;della temperatura minima)

mov ah,02h ; "setto" il servizio per la gestione del cursore 02h sul registro ah
mov dl,0   ; imposto su dl la prima colonna (a posizione 0)
mov dh,1   ; vado a riga successiva impostando in dh la seconda riga (a posizione 1)
int 10h    ; richiamo l'ISR tramite l'interrupt BIOS 10h spostando quindi il cursore nella
           ;posizione impostata

mov ah,9h          ; "setto" il servizio per la scrittura di una stringa di testo (9h) sul
                   ;registro ah
mov dx,offset msg2 ; metto su dx l'offset della variabile msg2 (per impostare la stringa da
                   ;stampare)
int 21h            ; richiamo l'ISR tramite l'interrupt DOS 21h

mov ax,0 ; "pulisco" il registro ax spostandovi 0
mov bx,0 ; "pulisco" il registro bx spostandovi 0
mov cx,0 ; "pulisco" il registro cx spostandovi 0
mov dx,0 ; "pulisco" il registro dx spostandovi 0

input2:    ; input temperatura massima
mov dx,0   ; "pulisco" ogni volta il registro dx per non farlo interferire con le operazioni
           ;implicite di moltiplicazione
mov ah,1h  ; "setto" su ah il servizio per l'input 1h            
int 21h    ; richiamo l'ISR tramite l'interrupt DOS 21h (il valore acquisito andra' nel registro
           ;al)
cmp al,13  ; comparo il valore di al con 13 (ASCII corrispondente al tasto "ENTER")
je fine2   ; se e' uguale vuol dire che l'utente ha terminato l'immissione, per cui salta a
           ;"fine2"
mov cl,al  ; sposto il valore di al su cl
mov al,bl  ; sposto il numero totale (contenuto nel registro bl, usato come accumulatore) su al
mul ten    ; moltiplico (implicitamente) il contenuto di al per il valore della variabile ten
           ;(10)
mov bl,al  ; risposto al in bl
sub cl,48  ; sottraggo a cl 48 per convertirlo da carattere ASCII a cifra utilizzabile
add bl,cl  ; aggiungo a bl il valore di cl ottenendo cosi' il nuovo numero totale
jmp input2 ; salto incondizionatamente ad "input2"
fine2:     ; fine dell'input del numero
mov max,bl ; sposto il numero totale immesso (in bl) nella variabile max (contenente il valore
           ;della temperatura massima)

mov ax,0 ; "pulisco" il registro ax spostandovi 0
mov bx,0 ; "pulisco" il registro bx spostandovi 0
mov cx,0 ; "pulisco" il registro cx spostandovi 0
mov dx,0 ; "pulisco" il registro dx spostandovi 0

mov cl,min ; sposto nel registro cl il valore della variabile min (la temperatura minima)
mov dl,max ; sposto nel registro dl il valore della variabile max (la temperatura massima)

start:      ; inizio del codice per la gestione del bruciatore tramite la trasmissione di dati

in al,125   ; leggo il dato dalla porta 125 (corrispondente a quella della temperatura segnalata
            ;dal termometro virtuale) e lo metto nel registro al
out 199,al  ; invio alla porta 199 (corrispondente a quella del display LED virtuale) la
            ;temperatura (contenuta in al)
mov temp,al ; sposto il valore appena acquisito (in al) nella variabile temp
push dx     ; inserisco nello stack il valore di dx
push cx     ; inserisco nello stack il valore di cx
push bx     ; inserisco nello stack il valore di bx
push ax     ; inserisco nello stack il valore di ax

; stampa del carattere '*' per la composizione del grafico della temperatura
mov ah,02h  ; "setto" su ah il servizio per la gestione del cursore 02h
mov dh,24   ; imposto in dh la riga 24 (ovvero l'ultima possibile nello schermo virtuale in
            ;emulazione)
sub dh,temp ; sottraggo a dh il valore di temp (ovvero la temperatura del termometro) per
            ;gestire il grafico con l'equazione y=24-y (altrimenti il grafico risulterebbe
            ;capovolto)
inc cols    ; incremento la variabile cols (contenente il numero della colonna a cui si e'
            ;arrivati)
mov dl,cols ; imposto la colonna spostano su dl il valore di cols
int 10h     ; richiamo l'ISR tramite l'interrupt 10h spostando quindi il cursore sulla posizione
            ;impostata

mov ah,0eh  ; "setto" su ah il servizio 0eh (modalita' teletype)
mov al,'*'  ; sposto su al il carattere da stampare ('*')
int 10h     ; richiamo l'ISR tramite l'interrupt 10h stampando il carattere

pop ax      ; estraggo l'ultimo valore dallo stack e lo metto in ax (ripristinando il valore
            ;precedente)
pop bx      ; estraggo l'ultimo valore dallo stack e lo metto in bx (ripristinando il valore
            ;precedente)
pop cx      ; estraggo l'ultimo valore dallo stack e lo metto in cx (ripristinando il valore
            ;precedente)
pop dx      ; estraggo l'ultimo valore dallo stack e lo metto in dx (ripristinando il valore
            ;precedente)
cmp al,cl   ; comparo il valore di al con quello di cl (la temperatura del termometro con quella
            ;minima)
jl  low     ; se e' minore, salta a "low"

cmp al,dl   ; altrimenti confronto al con dl (la temperatura del termometro con quella massima) 
jle  ok     ; se e' minore o uguale, salta ad "ok"
jg   high   ; se e' maggiore, salta ad "high"

low:        ; codice atto a gestire il caso in cui la temperatura del termometro sia minore di
            ;quella minima immessa
mov al, 1   ; sposto su al 1
out 127, al ; invio il dato contenuto in al (1) alla porta 127 (corrispondente a quella per il
            ;controllo del bruciatore: 1- acceso; 0- spento). Accendo quindi il bruciatore
jmp ok      ; salto incondizionatamente a "ok"

high:       ; codice atto a gestire il caso in cui la temperatura del termometro sia maggiore di
            ;quella massima immessa
mov al, 0   ; sposto su al 0
out 127, al ; invio il dato contenuto in al (0) alla porta 127 (corrispondente a quella per il
            ;controllo del bruciatore: 1- acceso; 0- spento). Spengo quindi il bruciatore. 

ok:         ; codice da eseguire quando e' tutto a posto o le dovute operazioni sul bruciatore si
            ;sono verificate
jmp start   ; salto incondizionatamente a "start" senza fine

; Dichiarazione variabili
msg1 db "Inserisci la temperatura minima: $"  ; vettore di caratteri contenente il messaggio da
                                              ;stampare prima dell'immissione della temperatura
                                              ;minima
msg2 db "Inserisci la temperatura massima: $" ; vettore di caratteri contenente il messaggio da
                                              ;stampare prima dell'immissione della temperatura
                                              ;massima
min db ?                                      ; variabile contenente la temperatura minima
                                              ;immessa
max db ?                                      ; variabile contenente la temperatura massima
                                              ;immessa
ten db 10                                     ; variabile contenente il valore 10 che verra'
                                              ;utilizzato nelle moltiplicazioni quando si
                                              ;immetteranno dei numeri
cols db -1                                    ; variabile contenente la colonna alla quale si e'
                                              ;arrivati a stampare il carattere '*'
                                              ;(inizializzata a -1 poiche' la prima volta che
                                              ;verra' incrementata dovra' partire da 0)
temp db ?                                     ; variabile contenente la temperatura del
                                              ;termometro (utilizzata come variabile d'appoggio)