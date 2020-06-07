 
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

.model small

.stack 
.data    

    msg1 DB 10,13,'Selecciona el producto de la maquina','$'
    msg2 DB 10,13,'1. Panditas','$'
    msg3 DB 10,13,'2. Gansito','$'   
    msg4 DB 10,13,'3. Chocoroles','$'
    msg5 DB 10,13,'4. Barritas','$'
    msgOp DB 10,13,7,'Opcion: ', '$' 
    msgInv DB 10,13,7,'Solo una de las 4 opciones ', '$'

.code 
.startup
     
    bucle:
        
    print msg1
    print msg2
    print msg3
    print msg4
    print msg5 
    print msgOp
       
    call readDigit  ;lee un digito y el resultado queda en bl
    call convertir  ;hacemos la equivalencia entre la opcion y el pin que se quiere encender
    
    cmp bh, 0h
    je invalida
        
    mov al, bh
    call girar ;giramos el motor un determinado tiempo 
    jmp valida  
    
    invalida:
    print msgInv 
    
    valida:    
   loop bucle    
    
.exit

;======== girar ===============
;procedimiento que escribe el valor de AL en el puerto paralelo 
;Parametros: 
;al: Valor a escribir en el puerto 
;============================== 
girar proc near
    push dx
    push cx 
    push bp
    push si
    
    mov dx, 278H ;direccionamos el puerto 
    out dx, al   ;mandamos al puerto el valor de AL
   
    ;CD-DX numeros de microsegundos del delay (1500000 - 1.5 seg) 
    ;mov cx, 3dH
    ;mov dx, 0900H       
    ;mov ah, 86H ;servicio 86H de la int 15 que funciona como un delay de microsegundos
    ;int 15H    
    
    ;start delay
     mov bp, 21845 ;(5555H)     
     mov si, 21845 ;(5555H) 
     delay:
        dec bp
        nop
        jnz delay
        dec si
        jnz delay        
    ;end delay
     
    mov al, 0h
    out dx, al  ;apagamos el puerto 
    
    pop si
    pop bp
    pop cx
    pop dx 
    ret
girar endp    

;======== readNum ===========
;lee un numero ASCII del teclado y lo regresa como decimal
;Devuelve: 
;bl: numero leido  
;============================== 
readDigit PROC NEAR 
     push ax   
     
     mov ah, 01h 	;funcion 01h para leer caracteres del teclado
     int 21h 
     sub al, 30h	;convertir a decimal
     mov bx, ax     
     
     pop ax  
     ret
readDigit ENDP 

;======== convertir ===========
;convierte la opcion tecleada por el usuario 
;a un numero para mandar al puerto    
;Paramtros
;bl: Opcion tecleada
;Devuelve: 
;bh: numero convertido  
;============================== 
convertir proc near
    mov bh, 0
    
    cmp bl, 1
    je uno
    cmp bl, 2
    je dos
    cmp bl, 3
    je tres
    cmp bl, 4
    je cuatro
    jmp fin
     
    uno: 
    mov bh, 1   
    jmp fin
    
    dos:
    mov bh, 2
    jmp fin
    
    tres:
    mov bh, 4
    jmp fin
     
    cuatro: 
    mov bh, 8 
    jmp fin
    
    fin:   
     ret
convertir endp    
    
END
