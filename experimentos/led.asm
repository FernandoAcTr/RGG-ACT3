STACK SEGMENT PARA STACK 'STACK' 
    DB 256 DUP(0)
STACK ENDS
    ASSUME CS:COD ,DS:COD
COD SEGMENT 
    
    MES1 DB 'Encender y Apagar LED con puerto paralelo','$'
    MES2 DB 'Oprimir S para salir','$'
    MES3 DB 'Fin del programa','$'
    MENSAJE DW 0
    
    
    MAIN PROC FAR
    MOV AX,CS
    MOV DS,AX
    
    MOV MENSAJE,OFFSET MES1
    CALL ESCRIBIR
    MOV MENSAJE,OFFSET MES2
    CALL ESCRIBIR  
    
    bucle: 
    
    MOV AH,1
    MOV DL,0FFH
    INT 21H
    CMP AL,'S'
    JE SALIR
    MOV DX,378H
    OUT DX,AL
    JMP bucle
    MAIN ENDP 
    
    
    ESCRIBIR PROC NEAR
    PUSH AX                     ;salvar los datos del usuario
    PUSH DX
    MOV AH,09H                  ;servicio para mostrar cadenas 
    MOV DX,MENSAJE              ;dezplazamiento de la cadena a desplegar
    INT 21H                     
                                
    MOV AH,06                   ;servicio de envio de caracter a pantalla
    MOV DL,0DH                  ;caracter enter que se va a desplegar
    INT 21H
    MOV AH,06H                  ;servicio de envio de caracter a pantalla
    MOV DL,0AH                  ;caracter nueva linea que se va a desplegar
    INT 21H                      
    POP DX                      ;regresamos los registros salvados a su estado original
    POP AX
    RET
    ESCRIBIR ENDP
        
        
    SALIR:                      ;se desplegan dos caracteres salto de linea
    MOV AH,06                   ;mediante el servicio 06h
    MOV DL,0DH
    INT 21H
    MOV AH,06H
    MOV DL,0AH
    INT 21H
    
    MOV MENSAJE,OFFSET MES3     ;se despliega un mensaje de despedida
    CALL ESCRIBIR
    
    MOV AH,4CH                ;se termina el programa mediante el servicio 4CH 
    MOV AL,00H                ;codigo 00 sin errores
    INT 21H 
    
COD ENDS
END MAIN