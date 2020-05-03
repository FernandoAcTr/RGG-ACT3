;programa que lee una cadena de texto mediante el servicio 3fh y su handler 0, de la interrupcion 21h 
;y la muestra por pantalla mediante el servicio 09h de la interrupcion 21h
dosseg 													;especifica que los segmentos deben ordenarse según la convención de DOS
.model small 
.stack 100h
.data
	msg db 10,13,7,'Ingresa una cadena de caracteres: ','$'		;definimos un mensaje 
	cadena db 100 dup(' '), '$'							;definimos un espacio de 100 bytes para almacenar la cadena de caracteres
.code 
.startup 
	mov ah,09h											;se elije la funcion 09h de la interrupcion 21
	lea dx,msg											;se carga la direccion de la cadena a desplegar
	int 21h												;llamada a la interrupcion 21h para desplegar el mensaje
	
	mov ah, 3fh											;seleccionamos el servicio 3fh de la interupcion 21
	mov bx, 0											;se elige el handler 00 del servicio 3fh
	mov cx, 100											;se cargan el numero de bytes a leer
	lea dx, cadena										;se carga la direccion del bloque donde se depositara la cadena
	int 21h												;llamada a la interrupcion 21h para leer la cadena
	
	mov ah, 09h											;se vuelve a cargar el servicio 09h para imprimir la cadena 
	int 21h 											;llamada a interrupcion 21h 
	
.exit
end
	
	