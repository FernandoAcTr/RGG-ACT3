;Programa que ilustra el paso de parametros a traves de la pila
;El programa convierte grados Centigrados a Farenheit

.model small   
.stack 

.data
     strNum db 0,0,0 
     result db 0
     msgIntro db 10,13, "Conversor de Centigrados a Fahrenheit", "$" 
     msgPedir db 7,10,13, 0F8h,"C: ","$"     
     msgFaren db 7,10,13, 0F8h,"F: ","$" 

.code
.startup   

    mov ah, 09h  		;se elije la funcion 09h para despliegue de cadenas
	lea dx, msgIntro	;se carga la direccion de la cadena a desplegar
	int 21h				;llamada a la interrupcion 21h para desplegar el mensaje
	lea dx, msgPedir
	int 21h

    lea bx, strNum     ;parametros por registro
    call leerNumStr    ;leer la cadena de numeros
      
    lea si, strNum     ;parametros por registro
    call atoi          ;convertir a numero con atoi  
    
    push bx            ;paso de parametros por pila
    call convertir
    
    mov ax, bx         ;paso de parametros por registros
    lea bx, result
    call itoa
    
    mov ah, 09h  	;se elije la funcion 09h para despliegue de cadenas
	lea dx, msgFaren	;se carga la direccion de la cadena a desplegar
	int 21h				;llamada a la interrupcion 21h para desplegar el mensaje
	lea dx, result
	  	;se carga la direccion de la cadena a desplegar
	int 21h				;llamada a la interrupcion 21h para desplegar el mensaje   
    
.exit


;=========== leerNumStr ============
;lee una cadena de maximo 3 caracteres 
;y los deposita en un buffer
;Parametros:
;bx: dezplazamiento del buffer
;===================================
leerNumStr proc near  
    push cx
    push ax  
    push si
    
    mov cx, 3  
	xor si,si    ;si = 0
	leer:    	    
        mov AH, 01h  ;servicio de lectura de caracter
        int 21h                     
        cmp al, 0dh   ;al == enter ? 
        je  enter                   
        mov [bx+si], al ;se coloca el caracter leido en el buffer
        inc si     ;incrementamos la posicion del buffer
    loop leer
    
    enter:
    mov [bx+si], "$" ;se adiciona un simbolo de final de cadena
     
	pop si
	pop ax
	pop cx  	
	ret

endp leerNumStr 


      

; ========= Funcion convertir ===========
; Parametros en Pila: 
; 1.Numero a convertir
; Devuelve: 
; BL: Grados Farenheit                                   
; ==================================      
convertir proc near 
    ; convertir Centigrados a Farenheit
    ; formula: F = C * 9 / 5 + 32 
    
    push ax
    push cx
    
    push BP
    mov bp, sp  ;direccionamos la pila
    
    mov bx,[bp+8] ;recuperamos el parametro
    
    mov cl, bl  
    mov al, 9
    mul cl      ;AX = C * 9
    mov cl, 5   
    div cl      ;AX = AX/5
    add al, 32  ;AL += 32
    mov bl, al
    
    pop bp 
    pop cx
    pop ax
    
    ret 2   ;descartamos el parametro al salir 
    
endp convertir 


; ========= Funcion ATOI ===========
; Parametros
; si: offset inicial de la cadena con respecto a DS    
; Devuelve: 
; Valor en BX                                 
; ==================================
atoi proc  
  push ax 	  ;salvamos los datos del usuario   
  push cx
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
  pop cx
  pop ax	  ;recuperamos los datos del usuario
  ret         
atoi endp 


; ================= Funcion ITOA ===================== 
; Convierte un valor numerico a una cadena de caracteres
; y la almacena en un buffer
; Parametros
; ax: valor
; bx: buffer donde guardar la cadena final
; Devuelve:
; BX: Cadena de caarcteres
; ====================================================  
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


end 