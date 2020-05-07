;muestra como se convierte el contenido binario de 16 bits de AX en una cadena
;de caracteres ASCII de cuatro digitos, mediante el uso de las instrucciones de division y AAM. Esto funciona
;para los números entre 0 y 9999. Primero DX se hace cero y luego DX-AX se divide entre 100. Por
;ejemplo, si AX = 245 decimal, despues de la division AX = 2 y DX = 45. Estas mitades separadas se convierten
;en BCD mediante el uso de AAM y después se suma el 3030H para convertirlo en codigo ASCII.

.MODEL SMALL			 						;se selecciona el modelo SMALL
.STACK 				 							;se define el segmento de pila
.DATA 					 						;comienza el segmento de datos


.CODE					 						;inicia segmento de codigo
.STARTUP				 						;se inicializa el registro de datos

    call reset
    
    ; ejemplo 1.  
    MOV ax, 245
     
    XOR  DX,DX       ;borra DX
    MOV  CX,100      ;divide DX-AX entre 100
    DIV  CX
    AAM              ;convierte a BCD
    ADD  AX,3030H    ;convierte a ASCII
    XCHG AX,DX       ;repite para el residuo
    AAM
    ADD  AX,3030H
    
    
    call reset
    
    ;ejemplo 2. Uso del DAA para sumar dos BCD empaquetados
    
    MOV DX,1234H ;carga el 1234 BCD
    MOV BX,3099H ;carga el 3099 BCD
    MOV AL,BL ;suma BL y DL
    ADD AL,DL
    DAA
    MOV CL,AL ;la respuesta va a CL
    MOV AL,BH ;suma BH, DH con acarreo
    ADC AL,DH
    DAA
    MOV CH,AL ;la respuesta va a CH 
    
    call reset  
    
    ;ejemplo 3 aritmetica ASCCI. Suma de dos digitos
    MOV AX,31H   ;carga el 1 ASCII
    ADD AL,39H   ;suma el 9 ASCII
    AAA          ;ajusta la suma
    ADD AX,3030H ;la respuesta se convierte a ASCII  
    
    
    ;ejemplo 4 sumar 26 + 5 digito a digito ASCII
    MOV AX, 36h  ;sumar 6+5
    ADD AL, 35H
    AAA
    ADD AX, 3030H
      
    mov BL, AL  ;salvamos el primer nible de AL, las unidades
      
    mov Al, ah
    adc AL, 32H
    AAA 
    ADD AX, 3030H
    mov bh, al                                                       
                                                             
    
.EXIT 

reset proc near
       xor ax,ax
       xor bx,bx
       xor cx,cx
       xor dx,dx
       ret
endp reset   
    
END