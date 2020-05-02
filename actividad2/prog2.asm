;programa que pide al usuario que digite 5 numeros y el programa los invierte usando la pila
;Temas puntuales: Procedimientos y manejo de pila
dosseg 													;especifica que los segmentos deben ordenarse según la convención de DOS
.model small 
.stack 100h
.data
	msg db 'Ingresa un numero del 1 al 9: ','$'		;definimos un mensaje 
	numeros dw 5 dup(?)								;definimos un bloque para almacenar los 5 numeros
.code
.startup 
	lea dx, msg										;cargamos la direccion del mensaje a desplegar
	mov si,0										;direccionamos el espacio 0 del vector de numeros
	call llenar										;llamada a la funcion de llenado de los numeros y la pila
	
.exit												;salida del DOS
	
;========== desplegar una cadena en pantalla =============
; parametros: DX --> mensaje a displayCadena
	displayCadena proc NEAR 
		push ax 									;salvamos cualquier dato del usuario
		mov ah,09h
		int 21h
		pop ax										;recuperamos los datos del usuario
		ret
	displayCadena endp

;========== leer un caracter del teclado =================
;parametros: SI --> posicion del vector para almacenar el numero
	leer proc NEAR
		push ax 									;salvamos cualquier dato del usuario
		mov ah, 01h									;seleccionamos el servicio 01h para lectura de un caracter, lo devuelve en AL
		int 21h
		mov ah, 0h
		mov numeros[si], ax
		pop ax										;recuperamos los datos del usuario
		ret
	leer endp
	
;========== desplegar un caracter en pantalla =================
;parametros: DL --> caracter a desplegar
	displayCaracter proc NEAR
		push ax 									;salvamos cualquier dato del usuario
		mov ah, 02h									;seleccionamos el servicio 02h para escritura de un caracter
		int 21h
		pop ax										;recuperamos los datos del usuario
		ret
	displayCaracter endp
	
;========= leer 5 caracteres del teclado ===================
	llenar proc NEAR
		mov cx, 5									;cargamos el contador con 5
		next: 
			call displayCadena			
			call leer
			
			push dx									;salvamos el contenido de DX
			mov dl, 0ah								;cargamos un salto de linea en dl para desplegarlo
			call displayCaracter					;desplegamos un caracter por pantalla
			pop dx									;restauramos el contenido de DX		
			
			inc si									;incrementamos SI
		loop next
		ret
	llenar endp		
													
end													;fin del programa

	