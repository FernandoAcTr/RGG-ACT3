;Programa manejador de archivos que permite crear, leer, modificar
;o borrar archivos mediante un menu de opciones 

;=========== Macro print ============
;despliega una cadena por pantalla
;Parametros: 
;cadena: cadena en la memoria
;===================================
print macro cadena 
	push ax 	;salvamos cualquier dato del usuario 
	push dx 
	lea dx, cadena
	mov ah,09h
	int 21h        
	pop dx
	pop ax	;recuperamos los datos del usuario
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
       

;=========== Macro readStr ============
;lee una cadena de caracteres 
;y los deposita en un buffer
;se finaliza la cadena con la tecla ESC
;Parametros:
;buffer: dezplazamiento del buffer   
;Devuelve
;CX: numero de caraceres leidos
;===================================
readStr macro buffer  
    local esc, leer, back, noback, enter
	push bx
    push ax  
    push si
	
	xor cx, cx
	lea bx, buffer
   
	xor si,si        ;si = 0
	leer:    	    
        mov AH, 01h   ;servicio de lectura de caracter
        int 21h                     
        cmp al, 27   ;al == esc ? 
        je  esc
        cmp al, 08h ;al == tecla back ?
        je back
        cmp al, 0dh ;al == enter ?
        je enter
                           
        mov [bx+si], al ;se coloca el caracter leido en el buffer
        inc si          ;incrementamos la posicion del buffer  
        inc cx ;cx++
        jmp noback
        
        enter:
        mov [bx+si], 10 ;se coloca un enter en el buffer
        inc si
        mov [bx+si], 13 ;se coloca un retorno
        inc si  
        printChar 10  ;se imprime el enter para que se vea reflejado en pantalla
        jmp noback
       
        
        back:
        dec si
        
        noback:        
    jmp leer
    
    esc:
    mov [bx+si], "$"  ;se adiciona un simbolo de final de cadena
    dec cx ;la tecla esc no cuenta como caracter escrito
     
	pop si
	pop ax
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
    ;mov ax, 0h
    jmp fin ;si no hubo error ve al final de la macro 
  
    error: 
    ;mov ax, 1
    
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
    ;mov ax, 0h
    jmp fin ;si no hubo error ve al final de la macro 
  
    error: 
    ;mov ax, 1h
    
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

.model small
.stack
      
.data 
    ;definir encabezados
    cabeza1 db 10,13,'Lenguajes de Interfaces','$'
    cabeza2 db 10,13,'Manejo de archivos (A3)',10,'$'  
    cabeza3 db 10,13,'Equipo D', 09,'Fecha: 15/05/2020',10,'$' 
    cabeza4 db 10,13,'Integrantes:','$'
    int1 db 10,13,'Luis Fernando Acosta Tovar','$'    
    int2 db 10,13,'Leonardo Hernandez Ojeda','$'
    int3 db 10,13,'Juan Pablo Marcial Avila','$'
    int4 db 10,13,'Saul Garcia Hernandez',10,'$' 
    
    ;definir menu
    titulo db 10,13, 'Operaciones con Archivos: ',10,'$'
    opc1 db 10,13, '1.', 09, 'Crear un archivo','$'
    opc2 db 10,13, '2.', 09, 'Leer un archivo','$'
    opc3 db 10,13, '3.', 09, 'Modificar un archivo','$'
    opc4 db 10,13, '4.', 09, 'Eliminar un archivo','$'
    opc5 db 10,13, '5.', 09, 'Re-nombrar un archivo','$'
    opc6 db 10,13, '6.', 09, 'Terminar un archivo','$' 
    opc7 db 7,10,13, 'Opcion: ','$' 
    
    ;nombre del archivo
    opNombre db 7,10,13, 'Nombre del archivo: ','$'
    opNewNombre db 7,10,13, 'Nuevo nombre del archivo: ','$' 
    
    ;mensajes al usuario
    msgError db 7,10,10,13, 'El archivo no existe',10,'$'
    msgExito db 7,10,10,13, 'Archivo creado con exito',10,'$'  
    msgRenameExito db 7,10,10,13, 'Archivo renombrado con exito',10,'$'
    msgDelExito db 7,10,10,13, 'Archivo eliminado con exito',10,'$'
    msgEsc db 7,10,10,13, 'Confirme su edicion con ta tecla ESC',10,'$'
    msgFin db 10,13,'Programa Terminado','$'
    
    ;variables del archivo
    file db 20 dup(?),  ;nombre del archivo 
    newFile db 20 dup(?),  ;nombre del nuevo archivo usado para renombrar
    handler dw ?   
    buffer db 1000 dup('$'),'$' ;buffer con un amplio espacio para el texto leido

.code 
.startup  
    mov ax, @data
	mov es, ax ;es = ds lo requiere la instruccion STOSB de flush
	
    ;Encabezado
    print cabeza1 
    print cabeza2
    print cabeza3
    print cabeza4
    print int1 
    print int2
    print int3
    print int4 
    
    menu:
    ;mostrar el menu
    print titulo
    print opc1 
    print opc2
    print opc3
    print opc4
    print opc5
    print opc6   
    print opc7   
      
    ;leer la opc del usuario
    call readChar  
    cmp bx,31h
    je crear 
    
    cmp bx,32h
    je leer 
    
    cmp bx,33h
    je modificar 
    
    cmp bx,34h
    je eliminar 
    
    cmp bx,35h
    je renombrar 
    
    cmp bx,36h
    je fin 
    
    jmp fin ;si no tecleo alguna opcion valida se va al fin
    
    crear: 
        call pedir   ;pedir el nombre del fichero 
        createFile file,handler  ;crear el fichero
        closeFile handler  ;cerrar el fichero
        print msgExito  ;imprimir un mensaje      
        jmp menu
        
    leer:
        ;limpiamos el buffer
        lea si, buffer
        call size
        flush cx, buffer    
     
        call pedir   ;pedir el nombre del fichero
        openFile file,0h,handler  ;abrir el fichero en solo lectura
        cmp ax, 1 ; si hubo error         
        je error        
        
        readFile $-buffer,buffer,handler   ;leer el fichero     
        printChar 10   ;se imprime un salto de linea 
        printChar 10  
      
        print buffer    ;imprimir el buffer
        printChar 10   ;se imprime un salto de linea 
        printChar 10     
        
        closeFile handler ;cerrar el fichero 
        lea si, buffer ;linea de depuracion no util al programa      
        jmp menu
        
    modificar:   
        ;limpiamos el buffer
        lea si, buffer
        call size
        flush cx, buffer    
    
        call pedir  ;pedir el nombre del fichero
        openFile file,2h,handler  ;abrir el fichero en lectura y escritura
        cmp ax, 1 ; si hubo error         
        je error 
        
        ;se imprime el contenido anterior
        readFile $-buffer,buffer,handler   ;leer el fichero
         
        printChar 10   ;se imprime un salto de linea
        printChar 10
               
        print buffer    ;imprimir el buffer
        print msgEsc    ;indicacion al usuario
        
        printChar 10   ;se imprime un salto de linea 
                
        readStr buffer ;se pide al usuario el nuevo texto
                        
        writeFile cx,buffer,handler  ;cx contiene el numero de caracteres leidos que seran escritos  
        closeFile handler
        jmp menu
        
    eliminar:
        call pedir   ;pedir el nombre del fichero 
        deleteFile file  ;eliminar el fichero
        cmp ax, 1 ; si hubo error         
        je error
        
        print msgDelExito 
        
        jmp menu
        
    renombrar:
        call pedir   ;pedir el nombre del fichero
        print opNewNombre
        readFileName 20,newFile  ;pedir el nuevo nombre del fichero    
        
        renameFile file, newFile    
        cmp ax, 1 ; si hubo error         
        je error  
        
        print msgRenameExito ;mensaje al usuario
        
        jmp menu
        
    jmp menu
    
    error:
    print msgError
    jmp menu
    
    fin: 
    print msgFin
    mov ax,4c00h ;funcion 4c para terminar el programa
    int 21h     
    
.exit

;======== pedir ===========
;pide el nombre del archivo y lo 
;guarda en memoria
;Devuelve: 
;ax: 1 si error 0 si no hubo error  
;============================== 
pedir proc near   
    print opNombre 
    readFileName 20,file        
    ret    
endp

;======== readChar ===========
;lee un caracter ASCII del teclado
;Devuelve: 
;bx: caracter leido  
;============================== 
readChar PROC NEAR 
     push ax   
     
     mov ah, 01h 	;funcion 01h para leer caracteres del teclado
     int 21h 
     cbw 	;se extiende el caractere leido en AL a todo el byte AX (AH=0)
     mov bx, ax     
     
     pop ax  
     ret
readChar ENDP 

;======== size ===========
;obtiene la longitud efectiva de un buffer de texto
;Parametros      
;SI: offset del buffer
;Devuelve: 
;cx: longitud del buffer  
;==============================
size proc near
   push ax
   
   xor cx,cx 
   init:
    lodsb  ;lee el primer byte e incrementa si
    cmp al, '$' ; al == $ 
    je final 
    inc cx      ; incrementa cx
   jmp init
   
   final:
   ;dec cx ;descuenta el ultimo caracter
   pop ax
   ret 
size endp

end


