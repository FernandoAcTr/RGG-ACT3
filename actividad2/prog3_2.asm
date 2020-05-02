;Programa que muestra la funcionalidad de 
		;saltos condicionales e incondicionales
		;comparacion de numeros y cadenas 
;Pide dos cadenas de caracteres al usuario y las compara para ver cual es mayor alfabeticamente
dosseg 													
.model small 
.stack 100h
.data
	strEnt   db 'Ingresa una cadena de caracteres: ', '$'
	nombre1  db 20 dup(?), '$'
	nombre2  db 20 dup(?), 0ah, '$'
	strMayor db ' Es mayor que $'
	strMenor db ' Es menor que $'
	strIgual db ' Es igual que $'
.code 
	;colocamos la direccion del segmento de datos en DS y tambien en ES porque CMPS lo requiere
	mov ax, @data
	mov ds, ax
	mov es, ax
	
	;seleccionamos el servicio 09h de la int 21h que se ocupara a lo largo del programa
	mov ah, 09h
	
	;leemos el primer nombre
	lea dx, strEnt
	int 21h 
	lea dx, nombre1
	call leer
	
	;leemos el segundo nombre 
	lea dx, strEnt
	int 21h 
	lea dx, nombre2
	call leer
	
	;cargamos los desplazamientos de las cadenas de caracteres para la instruccion CMPS
	lea si, nombre1  ;segmento  DS:SI origen
	lea di, nombre2	 ;segmento  ES:DI destino
	mov cx, 20		 ;se pone el contador en 20 para que se comparen los primeros 20 bytes de cada cadena
	rep cmpsb		 ;se comparan los primeros 20 bytes de las cadenas
	
	;imprimimos el primer nombre 
	lea dx, nombre1
	int 21h 
	
	;saltamos a la etiqueta correspondiente dependiendo el resultado de CMPS
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
		int 21h					;desplegamos el mensaje de igualdad o desigualdad que se cargo el alguna etiqueta 
		;se imprime el segundo nombre
		lea dx, nombre2			
		int 21h 
		
		;se finaliza el programa con la funcion 4CH de la interrupcion 21h
		mov ah, 4ch
		mov al, 0h
		int 21h
.exit

;========= lectura de una cadena de caracteres ================
;parametros: DX --> desplazamiento del bloque en donde depositar la cadena leída
	leer proc NEAR
		push ax
		mov ah, 3fh											;seleccionamos el servicio 3fh de la interupcion 21
		mov bx, 0											;se elige el handler 00 del servicio 3fh
		mov cx, 20											;se cargan el numero de bytes a leer
		int 21h												;llamada a la interrupcion 21h para leer la cadena
		pop ax
		ret
	leer endp

end
	