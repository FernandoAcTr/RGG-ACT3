;programa que pide un nuero del 1 al 100 y calcula su factorial

;Temas Puntuales: Lectura del teclado, uso de LOOP
;dosseg 													;especifica que los segmentos deben ordenarse según la convención de DOS
.model small 
.stack 100h
.data
	msgEnt db 10,13,7,'Ingresa un numero del 1 al 100: ','$'
	;strNum db ?
	strNum db 0,0,0 
.code
.startup
	;pedimos el strNumero al usuario 
	lea dx, msgEnt					;cargamos el mensaje en bx 
	mov ah, 09h 					;servicio 09h de la int 21h 
	int 21h 
	
	;leemos la cadena de caracteres y se coloca en strNum
	;mov ah, 3fh						;sevicio 3fh, lectura de cadenas 
	;xor bx, bx						;bx = 0, lo requiere el serivicio 3fh 
	;mov cx, 3						;strNumero de caracteres a leer
	;lea dx, strNum						;donde se depositara la cadena leida
	;int 21h   
	     
	;El servicio anterior no lo soporta emu8086 por lo tanto se lee caracter por caracter en 
	;un ciclo, comparando si es un enter cada vez     
	mov cx, 3  
	xor si,si    
	leer:    	    
        mov AH, 01h                 ;servicio de lectura de caracter
        int 21h                     
        cmp al, 0dh                 ; al == enter ? 
        je  enter                   ;se coloca el caracter leido en el buffer
        mov strNum[si], al 
        inc si                      ;incrementamos la posicion del buffer
    loop leer
    
	enter:
	;convertimos a decimal con ATOI, el numero queda en BX
	lea si, strNum					;parametro SI
	call atoi;
	
	;Aplicamos el factorial. El nesultado queda en AX al final
	mov ax, bx						;podemos el numero en el acumulador
	mov cx, bx
	dec cx							;el ciclo se repite N-1 veces. La primera entrada cuenta como una repeticion 
	facto: 
		dec bx						; decrementamos el numero inicial
		mul bx						; AX = AX * BX
	loop facto 
	
	;desplegar el resultado
	lea bx, strNum					;parametro BX
	call itoa
	
	lea dx, strNum					;cargamos el mensaje en bx 
	mov ah, 09h 					;servicio 09h de la int 21h 
	int 21h 
	
.exit													;salida del DOS

; ========= Funcion ATOI ===========
; Parametros
; si: offset inicial de la cadena con respecto a DS
; Retorna: Valor en BX
atoi proc  
  push ax 	  ;salvamos los datos del usuario
  CLD		  ;borramos la bandera de direccion (incremento)
  xor bx,bx   ;BX = 0

atoi_1:
  lodsb       ;carga byte apuntado por SI en AL e incrementa si
  
			  ;Comparamos si el caracter leído es <'0' o >'9' en ascii 
  cmp al,'0'  
  jb noascii  ;al < '0'
  cmp al,'9'
  ja noascii  ;al > '9'

  sub al,30h  ;restamos el valor del 0 en ascii para convertir a decimal
  cbw         ;extiende el byte en AL a un word para ocupar todo AX
  push ax     ;salvamos el digito temporal
  
  mov ax,bx   ;BX tendra el valor final
  mov cx,10
  mul cx      ;AX=AX*10
  
  mov bx,ax	  ;ponemos en bx el valor calculado hasta el momento
  pop ax	  ;recuperamos el digito temporal
  add bx,ax   ;sumamos al valor final el digito temporal
  jmp atoi_1  ;seguir mientras SI apunte a un strNumero ascii
  
  noascii:
  pop ax	  ;recuperamos los datos del usuario
  ret         
atoi endp


; ================= Funcion ITOA =====================
; Parametros
; ax: valor
; bx: donde guardar la cadena final
; Retorna: Cadena en BX
itoa proc
  push cx	 ;salvamos los datos del usuario
  xor cx,cx  ;CX = 0

  ; El ciclo itoa_1 extrae los digitos del
  ; menos al mas significativo de AX y los
  ; guarda en el stack. Al finalizar el 
  ; ciclo el digito mas significativo esta
  ; arriba del stack.
  ; CX contiene el strNumero de digitos
  itoa_1:
  cmp ax,0   
  je itoa_2  	;Salta si AX == 0
             
  xor dx,dx  	;dx = 0
  push bx    	;salva la direccion de la cadena 
  mov bx,10  	
  div bx		; AX = AX-DX / BX el residuo lo deja en DX
  pop bx		; regresa la direccion de la cadena
  push dx		; Nos interesa meter al stack los residuos
  inc cx		; strNumDigitos++
  jmp itoa_1

  ; Esta seccion maneja el caso cuando
  ; el strNumero a convertir (AX) es 0.
  ; En este caso, el ciclo anterior
  ; no guarda valores en el stack y
  ; CX tiene el valor 0
  itoa_2:
  cmp cx,0    	; strNumDigitos == 0 
  ja itoa_3   	; Salta si CX > 0 significa que hay digitos en la pila
  mov ax,'0'  	
  mov [bx],ax 	; pone un '0' en la cadena
  inc bx      	; apunta al siguiente byte de la cadena
  jmp itoa_4	; salta a la seccion final

  ;Esta seccion se encarga de extraer los digitos
  ;de la pila y convertirlos a ASCII
  ;al llegar a este punto CX ya contiene el strNumero 
  ;de digitos
  itoa_3:
  pop ax      ; Extraemos los strNumero del stack
  add ax,30h  ; lo pasamos a su valor ascii
  mov [bx],ax ; lo guardamos en la cadena final
  inc bx
  loop itoa_3

  itoa_4:
  mov ax,'$'  ; terminar cadena con '$' para 
  mov [bx],ax ; imprimirla con 09H de la INT 21h
  pop cx	  ; restauramos los datos del usuario
  ret
itoa endp



end														;fin del programa
