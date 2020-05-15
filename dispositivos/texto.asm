
;Programa que pinta la pantalla de azul y despliega opciones
;para cambiar el modo actual de texto, esto cambia la resolucion de la consola en modo de video de texto
;se usan funciones de la interrupcion 10h para pintar la pantalla, cambiar la ubicacion del cursor y cambiar el modo 
; de video de texto
.model small
.stack 100h
.data
    msg1 DB 7,10,13,"Ingrese una opcion para cambiar modo de texto:","$"
    msg2 DB 7,10,13,"1)40x25","$"
    msg3 DB 7,10,13,"2)80x25","$"
    msg4 DB 7,10,13,"3)132x25","$"
    msg5 DB 7,10,13,"Opcion no valida","$"  
    msg6 DB 7,10,13,"LI EQUIPO 2","$"  
    msg7 DB 7,10,13,"Actualmente esta en el modo: ","$"

.code
.startup   
    mov ah,0h
    mov al,94h         ;selecciona el modo texto
    int 10h          ;llama a la funcion 10h para activar el modo texto
    
    mov ah,6         ;funcion 6 scroll window up
    mov cl,0         ;columna inicial
    mov dl,132       ;columna final
    mov ch,0         ;renglon inicial
    mov dh,25        ;renglon final
    mov bh,30        ;color cyan
    int 10h          ;manda a la funcion y pinta la pantalla de azul con fuente amarilla
    
    mov ah,2h        ;funcion 2 que selecciona la posicion del cursor
    mov dh,0         ;renglon del cursor
    mov dl,0         ;columna del cursor
    mov bh,0         ;pagina mostrada
    int 10h          ;llamada a la funcion para posicionar el cursor en la posicion (0,0)
     
    
    lea dx, msg1        ;Parametro de la funcion para imprimir mensaje
    call displayString  ;llamada a la funcion para imprimir mensaje
    lea dx, msg2        ;Parametro de la funcion para imprimir mensaje
    call displayString  ;llamada a la funcion para imprimir mensaje
    lea dx, msg3        ;Parametro de la funcion para imprimir mensaje
    call displayString  ;llamada a la funcion para imprimir mensaje
    lea dx, msg4        ;Parametro de la funcion para imprimir mensaje
    call displayString  ;llamada a la funcion para imprimir mensaje
    
    
    call readChar        ;leemos el primer valor
    mov ax, bx           ;AX = valor leido
    cmp ax,'1'           ;compara si el valor leido es 1
    jz modo1             ;si es 1 salta a la etiqueta modo1
    cmp ax,'2'           ;compara si el valor leido es 2
    jz modo2             ;si es 2 salta a la etiqueta modo2
    cmp ax,'3'           ;compara si el valor leido es 3
    jz modo3             ;si es 3 salta a la etiqueta modo3
    
    jmp novalido         ;si no es una opcion valida salta a la etiqueta novalido
    
modo1:    
     mov ah,0h           ;funcion para seleccionar el modo de video de texto
     mov al,0h           ;sleecciona el modo 0h 40x25 1 color
     int 10h
     
     lea dx,msg7         ;imprime al modo en que esta 
     call displayString
     lea dx,msg2
     call displayString
     lea dx,msg6
     call displayString  ;imprime el numero de equipo 
     
.exit                    ;termina el programa 

modo2:  
     mov ah,0h           ;funcion para seleccionar el modo de video de texto
     mov al,3h           ;sleecciona el modo 3h 80x25 16 colores
     int 10h             ;llama la interrupcion para cambiar el modo de video
     
     lea dx,msg7         ;imprime al modo en que esta
     call displayString
     lea dx,msg3
     call displayString
     lea dx,msg6
     call displayString  ;imprime el numero de equipo 
     
     .exit               ;termina el programa
     
modo3:  
     mov ah,0h           ;funcion para seleccionar el modo de video de texto
     mov al,14h          ;sleecciona el modo 14h 132x25 16 colores
     int 10h             ;llama la interrupcion para cambiar el modo de video
     
     lea dx,msg7         ;imprime al modo en que esta
     call displayString
     lea dx,msg4
     call displayString
     lea dx,msg6
     call displayString  ;imprime el numero de equipo 
     
     .exit               ;termina el programa
             
novalido:
     lea dx, msg5        ;Parametro de la funcion
    call displayString   ;despliega un mensaje de opcion no valida
                    ;acaba el programa
.exit  


displayString PROC NEAR
    push ax
    
    mov ah,09h ;se elije la funcion 09h para desplegar cadenas
	int 21h
	 
	pop ax
          
    ret  ;instruccion de retorno
displayString ENDP  


;======== readChar ===========
;lee un caracter ASCII del teclado
;Devuelve: 
;bx: caracter leido  
;============================== 
readChar PROC NEAR 
     push ax   
     
     mov ah, 01h ;funcion 01h para leer caracteres del teclado
     int 21h 
     cbw  ;se extiende el caractere leido en AL a todo el byte AX (AH=0)
     mov bx, ax     
     
     pop ax  
     ret
readChar ENDP  
