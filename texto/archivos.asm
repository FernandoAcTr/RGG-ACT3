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

;=========== Macro readFileName ============
;lee una cadena de caracteres 
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
    int3 db 10,13,'Juan Pablo Marcial','$'
    int4 db 10,13,'Saul Arriaga',10,'$' 
    
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
    
    ;mensajes al usuario
    msgError db 7,10,10,13, 'El archivo no existe',10,'$'
    msgExito db 7,10,10,13, 'Archivo creado con exito',10,'$'
    msgFin db 10,13,'Programa Terminado','$'
    
    ;variables del archivo
    file db 20 dup(?),  ;nombre del archivo
    buffer db 1000 dup(?),'$' ;buffer con un amplio espacio para el texto leido
    handler dw ?

.code 
.startup  
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
        print opNombre 
        readFileName 20,file 
        createFile file,handler
        closeFile handler
        print msgExito        
        jmp menu
        
    leer: 
        call pedir
        cmp ax, 1 ; si hubo error         
        je error
        
        readFile 1000,buffer,handler 
        print buffer
        closeFile handler         
        jmp menu
        
    modificar:
        mov ax, 3
        jmp menu
        
    eliminar:
        mov ax, 4
        jmp menu
        
    renombrar:
        mov ax, 5
        jmp menu
        
    jmp menu
    
    error:
    print msgError
    jmp menu
    
    fin: 
    print msgFin
    mov ax,4c00h
    int 21h     
    
.exit

;======== pedir ===========
;pide el nombre del archivo y lo 
;intenta abrir
;Devuelve: 
;ax: 1 si error 0 si no hubo error  
;============================== 
pedir proc near   
    print opNombre 
    readFileName 20,file
    openFile file,0h,handler    
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

end


