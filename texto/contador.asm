;El programa cuenta el numero de palabras de un fichero de texto en el disco
;el fichero debe estar ubicado en C:

;============== Macro openFile ==========
;abre un fichero de texto
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
     
    mov ah,3dh ;interrupcion para abrir el archivo
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
;abre un fichero de texto
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
    
    mov ah,3eh
    mov bx,handler
    int 21h
    
    jc error: ;si hubo error al abrir CF = 1
    mov ax, 0h
    jmp fin ;si no hubo error ve al final de la macro 
  
    error: 
    mov ax, 1h
    
    fin: 
    pop bx
endm

;=========== Macro print ============
;despliega una cadena por pantalla
;Parametros: 
;cadena: cadena en la memoria
;===================================
print macro cadena 
	push ax ;salvamos cualquier dato del usuario 
	push dx 
	lea dx, cadena
	mov ah,09h ;int para imprimir cadenas
	int 21h        
	pop dx
	pop ax	;recuperamos los datos del usuario
endm 


      
.model small
.stack
.data
     file db 'c:\texto.txt',0 ;el nombre debe terminar con 0
     buffer db 600 dup(?),'$' ;buffer con un amplio espacio para el texto leido
     handler dw ? 
     palabras db 0 
     salida db 7,10,13,'Numero de palabras: ','$' 
.code
.startup
    
    openFile file,0h,handler  
    readFile 600,buffer,handler
    closeFile handler
    print buffer
    
    ;contar el numero de espacios en blanco recorriendo todo el buffer 
    lea si,buffer
    mov cx,568
   inicio:   
        lodsb   ;carga el byte apuntado por SI en AL e incrementa SI
        cmp al,' '
        je espacio
        jmp noespacio
        espacio:
         inc palabras 
     
        noespacio:
   loop inicio
   inc palabras; ;se ajusta a la ultima palabra que no se cuenta en el ciclo
   
   print salida
   mov al, palabras
   aam
   mov dl,ah
   call printDigit 
   mov dl,al
   call printDigit 
    
.exit   

;======== printDigit ===========
;despliega un numero del 0 al 9 en pantalla
;Parametros: 
;dl: numero a desplegar  
;==============================
printDigit proc NEAR
	push ax      	;salvamos cualquier dato del usuario
		
	mov ah, 02h		;seleccionamos el servicio 02h para escritura de un caracter
	add dl, 30H		;convertimos el numero a ASCII antes de mostrarlo 
	int 21h

	pop ax			;recuperamos los datos del usuario
	ret
printDigit endp 


end