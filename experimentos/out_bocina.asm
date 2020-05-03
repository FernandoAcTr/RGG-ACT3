.MODEL TINY            ;selecciona el modelo diminuto 
.DATA
.CODE                   ;inicio del segmento de codigo
.STARTUP                ;inicio del programa
    IN AL,61H           ;lee el puerto de E/S 61H
    OR AL,3             ;establece los dos bits de más a la derecha
    OUT 61H,AL          ;enciende la bocina
    MOV CX,8000H        ;carga el contador de retraso
    
    L1:
    LOOP L1             ;retraso de tiempo 
    
    IN AL,61H           ;apaga la bocina
    AND AL,0FCH
    OUT 61H,AL   
    
.EXIT
END