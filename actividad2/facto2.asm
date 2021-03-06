;programa que pide un nuero del 1 al 100 y calcula su factorial

;Temas Puntuales: Lectura del teclado, uso de LOOP
dosseg 													;especifica que los segmentos deben ordenarse según la convención de DOS
.model small 
.stack 100h
.data
	msgEnt db 10,13,7,'Ingresa un numero del 1 al 100: ','$'
	res    dw 158 dup(8) 	;reservamos espacio para los 158 digitos maximos del 100!
	strNum dw ? 	
	carry  dw 0				;controla el acarreo 
	lengt  dw 1				;controla la longitud del resultado final, comienza con un digito por defecto
	x      dw 0				
	next   dw 1				;almacena el 1..2..3..4
	num    dw ? 
.code
.startup
	;pedimos el strNumero al usuario 
	lea dx, msgEnt					;cargamos el mensaje en dx 
	mov ah, 09h 					;servicio 09h de la int 21h 
	int 21h 
	
	;leemos la cadena de caracteres y se coloca en strNum
	mov ah, 3fh						;sevicio 3fh, lectura de cadenas 
	xor bx, bx						;bx = 0, lo requiere el serivicio 3fh 
	mov cx, 2						;strNumero de caracteres a leer
	lea dx, strNum						;donde se depositara la cadena leida
	int 21h 
	
	;convertimos a decimal con ATOI, el numero queda en BX
	lea si, strNum					;parametro SI
	call atoi;
	mov num, bx						;pasamos el numero a num
	
	;algoritmo para factorial 
	xor si, si						;si = 0
	mov res[si], 1					;res[0] = 1
	
	facto:							;ciclo exterior
		
		mov cx, lengt				;el ciclo interior se repetirá lengt veces
		xor si, si					;si = 0
		forj:						;ciclo interior
			;x = res[j]*i + carry;
			mov ax, res[si]
			mul next   
			AAM
			add ax, carry
			mov x, ax
			
			;res[j] = x%10;
			mov ax, x
			mov bx, 10
			AAD
			div bx					;AX = AX / 10 
			
			mov bx, res[si]         ;rescatamos la parte alta del byte
			mov dh,bh
			
			mov res[si], dx			;almacenamos el residuo (parte derecha)
			mov carry, ax			;almacenamos el acarreo (parte izquierda)	
			
			inc si
		loop forj
		
		cmp carry, 0
		ja  acarreo				 	; carry > 0
		jbe fin						; carry <= 0
		
		acarreo: 
			mov si, lengt
			mov ax, carry
			mov res[si], ax      ;res[lengt] = carry;
			mov carry, 0
			inc lengt
			jmp fin
	
	fin:
	inc next						;next++
	mov bx, num						
	cmp next, bx					
	jbe facto						;next <= num
	
	;mostramos un salto de linea
	mov dl, 0ah
	mov ah, 02h 
	int 21h
	
	;mostramos los n numeros resultantes
	mov si, lengt 
	dec si                          ;dec--   
	
	mov cx, lengt                   ;se muestra numero por numero en el ciclo
	mostrar:  
	    mov ax, res[si]             ;parametro para itoa   
	    mov ah, 0                   ;borramos la parte alta del byte
	    lea bx, strNum              ;cargamos la direccion de un word
	    call itoa                   ;la cadena queda en BX   
	    
	    lea dx,strNum               ;desplegamos el numero
	    mov ah, 09h
	    int 21h  
	    
	    dec si
	loop mostrar
	
	
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
