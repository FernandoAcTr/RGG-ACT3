;Programa que muestra una cadena de caracteres por pantalla mediante el servicio 09h de la interrupcion 21h
;Esto lo hace mediante un procedimiento creado por nosotros para imprimir la cadena

DOSSEG															;especifica que los segmentos deben ordenarse según la convención de DOS
.MODEL SMALL			 										;se selecciona el modelo SMALL
.STACK 100H				 										;se define el segmento de pila
.DATA 					 										;comienza el segmento de datos
	mensaje DB "Hola Mundo",0ah,"Como estas?","$" 				;se define una etiqueta con el mensaje 0ah es salto de linea
.CODE					 										;inicia segmento de codigo
.STARTUP				 										;se inicializa el registro de datos
	lea dx,mensaje												;cargamos la direccion del mensaje en dx
	call desplegar	
.EXIT															;salida del DOS

;========== desplegar un mensaje en pantalla =============
; parametros: dx, mensaje a desplegar
	desplegar proc NEAR 
		push ax 												;salvamos los datos del usuario
		mov ah,09h
		int 21h
		pop ax													;recuperamos los datos del usuario
		ret
	desplegar endp	
END																;fin del programa