;=========== Macro displayCadena ============
;despliega una cadena por pantalla
;Parametros: 
;cadena: cadena en la memoria
;===================================
DisplayCadena macro cadena 
	push ax 						;salvamos cualquier dato del usuario 
	push bx 
	lea dx, cadena
	mov ah,09h
	int 21h        
	pop bx
	pop ax							;recuperamos los datos del usuario
endm
       
;=========== Macro leerNum ============
;lee un digito del teclado 
;Devuelve:
;BL: numero leido del teclado en decimal
;===================================
leerNum macro    
    push ax   
  
    mov AH, 01h     ;servicio de lectura de caracter
    int 21h  
    sub al, 30h  
    mov bl, al    
    
    pop ax 	
endm 

; ================= Macro ITOA ===================== 
; Convierte un valor numerico a una cadena de caracteres
; y la almacena en un buffer
; Parametros
; valor: valor entero
; buffer: buffer donde guardar la cadena final
; Devuelve:
; BX: Offset de la cadena de caracteres
; ====================================================  
itoa macro valor, buffer
  local itoa_1, itoa_2, itoa_3, itoa_4 
  push cx	 ;salvamos los datos del usuario
  push ax
  
  xor cx,cx  ;CX = 0
   
  lea bx, buffer
  mov ax, valor
   
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
  pop ax
  pop cx	  ; restauramos los datos del usuario
  
endm  

; ========= Macro ATOI =============
; Parametros
; cadena: cadena en memoria    
; Devuelve: 
; Valor en BX                                 
; ==================================
atoi macro cadena 
  local atoi_1, noascii
  push ax 	  ;salvamos los datos del usuario   
  push cx        
  push si
  
  lea si, cadena
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
  pop si         
  pop cx
  pop ax	  ;recuperamos los datos del usuario
           
endm 


