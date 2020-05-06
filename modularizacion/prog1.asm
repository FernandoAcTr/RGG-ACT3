;Programa que ilustra el uso de procedimientos. 
;Suma dos numeros y entrega el valor en un registro

.MODEL SMALL			 						;se selecciona el modelo SMALL
.STACK 				 							;se define el segmento de pila
.DATA 					 						;comienza el segmento de datos
	msgPedir1 DB 7,10,13,"Ingresa el valor #1 ","$" 		;se definen los mensajes al usuario 
	msgPedir2 DB 7,10,13,"Ingresa el valor #2 ","$"
	msgSalida DB 7,10,13,"El resultado es: ","$"
.CODE					 						;inicia segmento de codigo
.STARTUP				 						;se inicializa el registro de datos
	lea dx, msgPedir1                           ;Parametro de la funcion
    call desplegar  
    
    call leer                                   ;leemos el primer valor
    mov ax, bx                                  ;AX = valor leido
    
    lea dx, msgPedir2                           ;Parametro de la funcion desplegar
    call desplegar
    
    call leer                                   ;se lee el segundo valor
    add ax, bx                                  ;AX = AX+ valor leido   
    
    AAA						                    ;Ajuste despues de la suma
    
    lea dx, msgSalida                           ;Parametro de la funcion desplegar
    call desplegar
    
    mov dl, ah				                    ;mostramos el primer digito     
	call displayNumero	
	mov dl, al 				                    ;mostramos el segundo digito
	call displayNumero                            
    
    
     
.EXIT											;salida del DOS  


;======== desplegar ===========
;despliega una cadena de texto en pantalla
;Parametros 
;dx: dezplazamiento de la cadena a desplegar  
;==============================
desplegar PROC NEAR
    push ax
    
    mov ah,09h									;se elije la funcion 09h para desplegar cadenas
	int 21h
	 
	pop ax
          
    ret                                         ;instruccion de retorno
desplegar ENDP 
 
;======== leer ===========
;lee un caracter del teclado
;Devuelve: 
;bx: caracter leido  
;============================== 
leer PROC NEAR 
     push ax   
     
     mov ah, 01h 
     int 21h 
     cbw 
     mov bx, ax 
     
     pop ax  
     ret
leer ENDP   
            
;======== displayNumero ===========
;despliega un caracter ASCCI como su valor numerico
;Parametros: 
;dl: numero a desplegar  
;==============================
displayNumero proc NEAR
		push ax 									;salvamos cualquier dato del usuario
		mov ah, 02h									;seleccionamos el servicio 02h para escritura de un caracter
		add dl, 30H									;convertimos el numero a ASCII antes de mostrarlo 
		int 21h
		pop ax										;recuperamos los datos del usuario
		ret
displayNumero endp


END											    ;fin del programa


	