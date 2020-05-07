;programa que ilustra el uso de macros  
;se incluten en un fichero externo llamado macros.ext
;calcula el factorial de un numero del 1 al 8

INCLUDE macros.lib        

.model small 
.stack 100h
.data
	msgEnt db 10,13,7,'Ingresa un numero del 1 al 8: ','$'
	msgSalida db 10,13,7,'Factorial: ','$'
	;strNum db ?
	strNum db 0,0,0 
.code
.startup

	DisplayCadena msgEnt
	     
	leerNum
	mov bh,0	
	
	;Aplicamos el factorial. El nesultado queda en AX al final
	mov ax, bx						;ponemos el numero en el acumulador
	mov cx, bx
	dec cx							;el ciclo se repite N-1 veces. La primera entrada cuenta como una repeticion 
	facto: 
		dec bx						; decrementamos el numero inicial
		mul bx						; AX = AX * BX
	loop facto 
	
	;desplegar el resultado
	itoa ax, strNum					;macro itoa
		
	DisplayCadena msgSalida         ;macro DisplayCadena
	
	DisplayCadena strNum
	
.exit

end	
