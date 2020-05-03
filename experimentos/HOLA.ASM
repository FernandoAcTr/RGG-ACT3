;Programa que muestra una cadena de caracteres por pantalla mediante el servicio 09h de la interrupcion 21h
DOSSEG															; especifica que los segmentos deben ordenarse según la convención de DOS
.MODEL SMALL			 										;se selecciona el modelo SMALL
.STACK 100H				 										;se define el segmento de pila
.DATA 					 										;comienza el segmento de datos
	mensaje DB "Hola Mundo",0ah,"Como estas?","$" 				;se define una etiqueta con el mensaje 0ah es salto de linea
.CODE					 										;inicia segmento de codigo
.STARTUP				 										;se inicializa el registro de datos
	mov ah,09h													;se elije la funcion 09h de la interrupcion 21
	lea dx,mensaje												;se carga la direccion de la cadena a desplegar
	int 21h														;llamada a la interrupcion 21h para desplegar el mensaje
.EXIT															;salida del DOS
END																;fin del programa