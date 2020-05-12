
;========================================= IMPRESION DE CADENAS =======================

;=========== Macro print ============
;despliega una cadena por pantalla
;Parametros: 
;cadena: cadena en la memoria
;===================================
print macro cadena 
	push ax 						;salvamos cualquier dato del usuario 
	push dx 
	lea dx, cadena
	mov ah,09h
	int 21h        
	pop dx
	pop ax							;recuperamos los datos del usuario
endm

;======== printDigit ===========
;despliega un numero del 1 al 9 en pantalla
;Parametros: 
;num: numero a desplegar  
;==============================
printDigit macro num
	push ax      	;salvamos cualquier dato del usuario
	push dx

	mov dl, num
	mov ah, 02h		;seleccionamos el servicio 02h para escritura de un caracter
	add dl, 30H		;convertimos el numero a ASCII antes de mostrarlo 
	int 21h

	pop dx
	pop ax			;recuperamos los datos del usuario
endm

;======== printChar ===========
;despliega un caracter en pantalla
;Parametros: 
;char: caracter a desplegar  
;==============================
printChar macro char
	push ax      	;salvamos cualquier dato del usuario
	push dx

	mov dl, char
	mov ah, 02h		;seleccionamos el servicio 02h para escritura de un caracter
	int 21h

	pop dx
	pop ax			;recuperamos los datos del usuario
endm
       
; ========================================= LECTURA =========================================	   
;=========== Macro readNum ============
;lee un digito del teclado 
;Devuelve:
;BL: numero leido del teclado en decimal
;===================================
readDigit macro    
    push ax   
  
    mov AH, 01h     ;servicio de lectura de caracter
    int 21h  
    sub al, 30h  
    mov bl, al    
    
    pop ax 	
endm 

;=========== Macro readChar ============
;lee un caracter ASCII del teclado
;Devuelve:
;BL: caracter leido del teclado
;===================================
readChar macro    
    push ax   
  
    mov AH, 01h     ;servicio de lectura de caracter
    int 21h   
    mov bl, al    
    
    pop ax 	
endm 

;=========== Macro readStr ============
;lee una cadena de caracteres 
;y los deposita en un buffer
;Parametros:
;buffer: dezplazamiento del buffer
;numBytes: numero maximo de caracteres del buffer
;===================================
readStr macro numBytes, buffer  
    local enter, leer, back, noback
	push bx
    push cx
    push ax  
    push si
	
	mov cx, numBytes
	lea bx, buffer
   
	xor si,si        ;si = 0
	leer:    	    
        mov AH, 01h   ;servicio de lectura de caracter
        int 21h                     
        cmp al, 0dh   ;al == enter ? 
        je  enter
        cmp al, 08h ;al == tecla back
        je back
                           
        mov [bx+si], al ;se coloca el caracter leido en el buffer
        inc si          ;incrementamos la posicion del buffer
        jmp noback
        
        back:
        inc cx ;la tecla back no cuenta como caracter leido
		dec si
        
        noback:        
    loop leer
    
    enter:
    mov [bx+si], "$"  ;se adiciona un simbolo de final de cadena
     
	pop si
	pop ax
	pop cx
	pop bx

endm 

;======================== Macro flush ====================
;Limpia el contenido de un buffer de texto            
;Parametros: 
;buffer: buffer que se desea limpiar
;numBytes: numero de bytes a desechar
;=========================================================
flush macro numBytes, buffer 
    push cx
    push si
    push ax
     
    mov cx, numBytes ;se cargan el numero de bytes
    lea di, buffer ;se direcciona el buffer para STOSB
    mov al, '$' ;caracter con el que se limpiara el buffer
    rep stosb  ;almacena AL en [SI] e incrementa SI 
    
    pop ax
    pop si
    pop cx
endm

;========================================= CONVERSION DE NUMEROS ================================

; ================= Macro ITOA ===================== 
; Convierte un valor numerico a una cadena de caracteres
; y la almacena en un buffer
; Parametros
; valor: valor entero
; buffer: buffer donde guardar la cadena final
; Devuelve:
; BX: Offset de la cadena de caracteres
; ====================================================  
itoa macro valor, buffer
  local itoa_1, itoa_2, itoa_3, itoa_4 
  push cx	 ;salvamos los datos del usuario
  push ax
  
  xor cx,cx  ;CX = 0
   
  lea bx, buffer
  mov ax, valor
   
  ; El ciclo itoa_1 extrae los digitos del
  ; menos al mas significativo de AX y los
  ; guarda en el stack. Al finalizar el 
  ; ciclo el digito mas significativo esta
  ; arriba del stack.
  ; CX contiene el strNumero de digitos
  itoa_1:
  cmp ax,0   
  je itoa_2  	;Salta si AX == 0
             
  xor dx,dx  	;dx = 0
  push bx    	;salva la direccion de la cadena 
  mov bx,10  	
  div bx		; AX = AX-DX / BX el residuo lo deja en DX
  pop bx		; regresa la direccion de la cadena
  push dx		; Nos interesa meter al stack los residuos
  inc cx		; strNumDigitos++
  jmp itoa_1

  ; Esta seccion maneja el caso cuando
  ; el strNumero a convertir (AX) es 0.
  ; En este caso, el ciclo anterior
  ; no guarda valores en el stack y
  ; CX tiene el valor 0
  itoa_2:
  cmp cx,0    	; strNumDigitos == 0 
  ja itoa_3   	; Salta si CX > 0 significa que hay digitos en la pila
  mov ax,'0'  	
  mov [bx],ax 	; pone un '0' en la cadena
  inc bx      	; apunta al siguiente byte de la cadena
  jmp itoa_4	; salta a la seccion final

  ;Esta seccion se encarga de extraer los digitos
  ;de la pila y convertirlos a ASCII
  ;al llegar a este punto CX ya contiene el strNumero 
  ;de digitos
  itoa_3:
  pop ax      ; Extraemos los strNumero del stack
  add ax,30h  ; lo pasamos a su valor ascii
  mov [bx],ax ; lo guardamos en la cadena final
  inc bx
  loop itoa_3

  itoa_4:
  mov ax,'$'  ; terminar cadena con '$' para 
  mov [bx],ax ; imprimirla con 09H de la INT 21h
  pop ax
  pop cx	  ; restauramos los datos del usuario
  
endm  

; ========= Macro ATOI =============
; Parametros
; cadena: cadena en memoria    
; Devuelve: 
; Valor en BX                                 
; ==================================
atoi macro cadena 
  local atoi_1, noascii
  push ax 	  ;salvamos los datos del usuario   
  push cx        
  push si
  
  lea si, cadena
  CLD		  ;borramos la bandera de direccion (incremento)
  xor bx,bx   ;BX = 0

atoi_1:
  lodsb       ;carga byte apuntado por SI en AL e incrementa si
  
			  ;Comparamos si el caracter leído es <'0' o >'9' en ascii 
  cmp al,'0'  
  jb noascii  ;al < '0'
  cmp al,'9'
  ja noascii  ;al > '9'

  sub al,30h  ;restamos el valor del 0 en ascii para convertir a decimal
  cbw         ;extiende el byte en AL a un word para ocupar todo AX
  push ax     ;salvamos el digito temporal
  
  mov ax,bx   ;BX tendra el valor final
  mov cx,10
  mul cx      ;AX=AX*10
  
  mov bx,ax	  ;ponemos en bx el valor calculado hasta el momento
  pop ax	  ;recuperamos el digito temporal
  add bx,ax   ;sumamos al valor final el digito temporal
  jmp atoi_1  ;seguir mientras SI apunte a un strNumero ascii
  
  noascii:
  pop si         
  pop cx
  pop ax	  ;recuperamos los datos del usuario
           
endm 


;=========================================================== MANEJO DE ARCHIVOS =====================================

;=========== Macro readFileName ============
;lee una cadena de caracteres (nombre del fichero)
;y los deposita en un buffer
;Parametros:
;buffer: dezplazamiento del buffer
;numBytes: numero maximo de caracteres del buffer
;===================================
readFileName macro numBytes, buffer  
    local enter, leer, back, noback
	push bx
    push cx
    push ax  
    push si
	
	mov cx, numBytes
	lea bx, buffer
   
	xor si,si        ;si = 0
	leer:    	    
        mov AH, 01h   ;servicio de lectura de caracter
        int 21h                     
        cmp al, 0dh   ;al == enter ? 
        je  enter
        cmp al, 08h ;al == tecla back
        je back
                           
        mov [bx+si], al ;se coloca el caracter leido en el buffer
        inc si          ;incrementamos la posicion del buffer
        jmp noback
        
        back:
        inc cx ;la tecla back no cuenta como caracter leido
        dec si
        
        noback:        
    loop leer
    
    enter:
    mov [bx+si], 0h  ;se adiciona un 0 al final del nombre del archivo
     
	pop si
	pop ax
	pop cx
	pop bx

endm    
 
;============== Macro createFile ==========
;Si el fichero indicado mediante la cadena ASCII ya existia, entonces se vacia su contenido.
;Si el fichero no existia, entonces se crea
;Parametros            
;filename: nombre en memoria del fichero     
;handler: word en memoria en donde depositar el handle
;Devuelve 
;handler: manejador numerico del fichero 
;ax: 1 si hubo error, 0 si no hubo error 
;===============================
createFile macro fileName, handler  
    local error, fin ;etiquetas locales
    push cx
    push dx
    
    mov ah,3ch ;funcion para la creacion de ficheros
    mov cx,0 ;0H Fichero Normal. 01H Fichero de Sólo Lectura. 02H Fichero Oculto. 03H Fichero de Sistema.
    lea dx, fileName
    int 21h    
    jc error ;si no se pudo crear  
    
    mov handler,ax 
    mov ax, 0
    jmp fin ;si no hubo error ve al final de la macro 
    
    error: 
    mov ax, 1 
    
    fin:
    pop dx
    pop cx
endm

;============== Macro openFile ==========
;abre un fichero de texto y obtiene un handler
;Parametros 
;modo: 0h solo lectura, 1h solo escritura, 2h lectura y escritura            
;filename: nombre en memoria del fichero     
;handler: word en memoria en donde depositar el handle
;Devuelve 
;handler: manejador numerico del fichero 
;ax: 1 si hubo error, 0 si no hubo error 
;===============================
openFile macro filename,modo,handler 
    local error, fin ;se definen etiquetas locales a la macro 
    push dx ;se salvan datos anteriores
     
    mov ah,3dh ;funcion para abrir archivos
    mov al,modo  ;0h solo lectura, 1h solo escritura, 2h lectura y escritura
    lea dx, filename ;cargamos el nombre del archivo
    int 21h
    jc error: ;si hubo error al abrir CF = 1
     
    mov handler,ax 
    mov ax, 0
    jmp fin ;si no hubo error ve al final de la macro 
  
    error: 
    mov ax, 1
    
    fin:
    pop dx
endm

;============== Macro readFile ==========
;lee el contenido de un fichero de texto
;Parametros 
;numbytes: numero de bytes a leer del fichero           
;buffer: buffer en se depositaran los caracteres leidos   
;handler: word en memoria en donde existe un handle
;Devuelve 
;buffer: buffer lleno con los caracteres leidos
;ax: 1 si hubo error, 0 si no hubo error 
;===============================
readFile macro numbytes,buffer,handler    
    local error, fin ;se definen etiquetas locales a la macro  
    push bx  ;se salvan datos anteriores  
    push cx
    push dx
    
    mov ah,3fh   ;interrupcion de lectura de fichero
    mov bx,handler ;se carga el manejador
    mov cx,numbytes ;se carga el numero de bytes a leer
    lea dx,buffer ;se carga el buffer 
    int 21h
    jc error: ;si hubo error al abrir CF = 1  
    mov ax, 0h
    jmp fin ;si no hubo error ve al final de la macro 
  
    error: 
    mov ax, 1
    
    fin: 
    pop dx
    pop cx
    pop bx

endm    

;================= Macro closeFile ==============
;Cierra un fichero abierto y libera el handler para
;otro fichero
;Parametros
;handler: el handler en memoria del fichero abierto
;Devuelve: 
;ax: 1 si hubo error, 0 si no hubo error 
;================================================
closeFile macro handler
    local error, fin ;etiquetas locales
    push bx ;salvar datos anteriores
    
    mov ah,3eh ;funcion 3h para cerrar archivos 
    mov bx,handler ;se carga el manejador del archivo
    int 21h
    
    jc error: ;si hubo error al abrir CF = 1
    mov ax, 0h
    jmp fin ;si no hubo error ve al final de la macro 
  
    error: 
    mov ax, 1h
    
    fin: 
    pop bx
endm    

;================= Macro deleteFile ==============
;Elimina un fichero de texto
;Parametros
;nombre: nombre en memoria del fichero a borrar.
;Devuelve: 
;ax: 1 si hubo error, 0 si no hubo error 
;================================================
deleteFile macro nombre
    local error, fin ;etiquetas locales
    push dx ;salvar datos anteriores
    
    mov ah,41h  ;funcion 41h para borrar archivos
    lea dx,nombre ;se carga el nombre del archivo a borrar
    int 21h
    
    jc error: ;si hubo error al borrar CF = 1
    mov ax, 0h
    jmp fin ;si no hubo error ve al final de la macro 
  
    error: 
    mov ax, 1h
    
    fin: 
    pop dx
endm   

;================= Macro writeFile ==============
;Escribe una cadena de texto sobre un archivo
;Parametros
;numbytes: numero de bytes a escribir
;handler: manejador del fichero
;buffer: buffer en memoria con el texto a escribir
;Devuelve: 
;ax: 1 si hubo error, 0 si no hubo error 
;================================================
writeFile macro numbytes,buffer,handler
    local error, fin ;etiquetas locales
    push bx ;salvar datos anteriores 
    push cx
    push dx
    
    mov ah,40h  ;funcion 40h para escribir ficheros
    mov bx,handler ;se carga el manejador del fichero
    mov cx, numbytes ;se cargan el numero de bytes a escribir
    lea dx, buffer ;se carga la direccion del buffer
    int 21h
    
    jc error: ;si hubo error al borrar CF = 1
    mov ax, 0h
    jmp fin ;si no hubo error ve al final de la macro 
  
    error: 
    mov ax, 1h
    
    fin: 
    pop dx
    pop cx
    pop bx
endm  

;================= Macro renameFile ==============
;Renombra un fichero
;Parametros
;oldName: El nombre actual del archivo
;newName: El nuevo nombre del archivo
;Devuelve: 
;ax: 1 si hubo error, 0 si no hubo error 
;================================================
renameFile macro oldName, newName  
    local error, fin ;etiquetas locales
    push ax
    push dx
    push di
    
    lea dx, oldName ;se cargan los nombres      
    lea di, newName
    mov ah, 56h ;funcion para renombrar ficheros
    int 21h 
    jc error: ;si hubo error al borrar CF = 1
    mov ax, 0h
    jmp fin ;si no hubo error ve al final de la macro 
  
    error: 
    mov ax, 1h
    
    fin: 
    pop di
    pop dx
    pop ax    
endm  

