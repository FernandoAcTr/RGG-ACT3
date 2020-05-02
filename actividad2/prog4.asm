;Programa que muestra la funcionalidad de las operaciones aritmeticas basicas
;Pide dos numeros al usuario del 0 al 9 y los suma, resta, divide y multiplica
dosseg 													
.model small 
.stack 100h
.data
	num1 	 db ?
	num2 	 db ?
	msgEnt1  db 10,13,7,'Ingresa el operando #1 [0-9]: ', '$'
	msgEnt2  db 10,13,7,'Ingresa el operando #2 [0-9]: ', '$'
	msgSuma  db 10,13,7,'Suma: ', '$'
	msgRest  db 10,13,7,'Resta: ', '$'
	msgMult  db 10,13,7,'Multiplicacion: ', '$'
	msgDiv   db 10,13,7,'Division: ', '$'
	msgRes   db 10,13,7,'Residuo: ', '$'
	strMayor db ' Es mayor que $'
	strMenor db ' Es menor que $'
	strIgual db ' Es igual que $'
	salto	 db 10,13,7,'$'
.code 
.startup
	
	;pedimos dos operandos al usuario
	lea dx, msgEnt1
	call displayCadena	
	mov si, offset num1		;direccion donde leer dejara el num1
	call leer
	
	lea dx, msgEnt2
	call displayCadena	
	mov si, offset num2		;direccion donde leer dejara el num2
	call leer
	
	;Sumamos los operandos 
	mov al, num1			;AL = num1
	add al, num2			;AL = AL + num2
	lea dx, msgSuma			;cargamos el mensaje de suma
	call displayCadena
	
	AAM						;ajusta el numero de 2 digitos a 4 digitos hexadecimales
	mov dl, ah				;mostramos el primer digito
	call displayNumero	
	mov dl, al 				;mostramos el segundo digito
	call displayNumero	
	
	;Restamos los operandos 
	mov al, num1			;AL = num1
	sub al, num2			;AL = AL - num2
	lea dx, msgRest			;cargamos el mensaje de resta
	call displayCadena
	
	AAM						;ajusta el numero de 2 digitos a 4 digitos hexadecimales
	mov dl, ah				;mostramos el primer digito
	call displayNumero	
	mov dl, al 				;mostramos el segundo digito
	call displayNumero	
	
	;Multiplicamos los operandos 
	mov al, num1			;AL = num1
	mul num2				;AL = AL * num2
	lea dx, msgMult			;cargamos el mensaje de resta
	call displayCadena
	
	AAM						;ajusta el numero de 2 digitos a 4 digitos hexadecimales
	mov dl, ah				;mostramos el primer digito
	call displayNumero	
	mov dl, al 				;mostramos el segundo digito
	call displayNumero	
	
	;Dividimos los operandos 
	xor ax,ax				;AX = 0
	mov al, num1			;AL = num1
	div num2				;AL = AL / num2 ; AH = residuo 
	lea dx, msgDiv			;cargamos el mensaje de resta
	call displayCadena
	
	AAM						;ajusta el numero de 2 digitos a 4 digitos hexadecimales
	mov dl, ah				;mostramos el primer digito
	call displayNumero	
	mov dl, al 				;mostramos el segundo digito
	call displayNumero		
	
	;se depliega el pimer numero
	lea dx, salto
	call displayCadena 		;se despliega un salto de linea
	mov dl, num1			
	call displayNumero
	
	;Comparamos los numeros
	mov al, num1
	cmp al, num2
	
	;saltamos a la etiqueta correspondiente dependiendo el resultado de CMP
	ja mayor
	jb menor
	je igual 
	
	mayor:
		lea dx, strMayor		;cargamos el mensaje mayor que
		jmp fin 				;salto incondicional a la etiqueta de fin
		
	menor:
		lea dx, strMenor		;cargamos el mensaje menor que
		jmp fin 				;salto incondicional a la etiqueta de fin
		
	igual:
		lea dx, strIgual		;cargamos el mensaje igual que
		jmp fin					;salto incondicional a la etiqueta de fin
		
	fin: 
		call displayCadena		;desplegamos el mensaje de igualdad o desigualdad que se cargo el alguna etiqueta 
								;se depliega el segundo numero
		mov dl, num2			
		call displayNumero
		
		;se finaliza el programa con la funcion 4CH de la interrupcion 21h
		mov ax, 4c00h
		int 21h	
	
.exit

;========== leer un numero del teclado =================
;parametros: SI --> posicion para almacenar el numero
	leer proc NEAR
		push ax 									;salvamos cualquier dato del usuario
		mov ah, 01h									;seleccionamos el servicio 01h para lectura de un caracter, lo devuelve un byte en AL
		int 21h
		sub al, 30h									;convertimos el numero a decimal
		mov [si], al							    ;almacenamos el numero en el vector
		pop ax										;recuperamos los datos del usuario
		ret
	leer endp
	
;========== desplegar una cadena en pantalla =============
; parametros: DX --> desplazamiento del mensaje a desplegar
	displayCadena proc NEAR 
		push ax 									;salvamos cualquier dato del usuario
		mov ah,09h
		int 21h
		pop ax										;recuperamos los datos del usuario
		ret
	displayCadena endp
	
;========== desplegar un numero en pantalla =================
;parametros: DL --> numero a desplegar
	displayNumero proc NEAR
		push ax 									;salvamos cualquier dato del usuario
		mov ah, 02h									;seleccionamos el servicio 02h para escritura de un caracter
		add dl, 30H									;convertimos el numero a ASCII antes de mostrarlo 
		int 21h
		pop ax										;recuperamos los datos del usuario
		ret
	displayNumero endp
	
end
	