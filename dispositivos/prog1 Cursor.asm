
;Programa que pide un caracter al usuario para imprimirlo en el centro de la pantalla
;la cual esta pintada de color azul
; se usa e modo de video de texto

.model small
.stack 100h
.data
    msg1 DB 7,10,13,"Ingrese un caracter para mostrar en el centro de la pantalla azul: ","$"
    msgU dw ?,"$"
.code
.startup
   
    mov ah,0h
    mov al,14h       ;selecciona el modo texto
    int 10h          ;llama a la funcion 10h para activar el modo texto
    
    mov ah,6         ;funcion 6 scroll window up
    mov cl,0         ;columna inicial
    mov dl,132       ;columna final
    mov ch,0         ;renglon inicial
    mov dh,25        ;renglon final
    mov bh,30        ;color azul
    int 10h          ;manda a la funcion y pinta la pantalla de azul con fuente amarilla
    
    
    mov ah,2h        ;funcion 2 que selecciona la posicion del cursor
    mov dl,0         ;columna del cursor
    mov dh,0         ;renglon del cursor
    mov bh,0         ;pagina mostrada
    int 10h          ;llamada a la funcion para posicionar el cursor en la posicion (0,0)
    
    lea dx,msg1        ;Parametro de la funcion para imprimir mensaje
    call displayString  ;llamada a la funcion para imprimir mensaje
          
        
    call readChar        ;leemos el primer valor
    mov ax, bx           ;AX = valor leido
    mov msgU,ax
    
    mov ah,2h        ;funcion 2 que selecciona la posicion del cursor
    mov dl,40         ;columna del cursor
    mov dh,13         ;renglon del cursor
    mov bh,0         ;pagina mostrada
    int 10h          ;llamada a la funcion para posicionar el cursor en la posicion (0,0)
    
    
    lea dx,msgU
    call displayString
    
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
