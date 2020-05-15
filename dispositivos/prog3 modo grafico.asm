;Programa que imprime en pantalla LI E2
; en modo grafico de video de 640x480 en modo de 16 colores

.model small
.stack 100h
.data
    col dw 1
    fila dw 1   
.code
.startup   
main:
    mov ah,0h          ;funcion para seleccionar un modo de video  
    mov al,12h         ;modo grafico 640x480 16 colores
    int 10h            ;interrupcion para seleccionar el modo
    
;;;PINTAMOS TODA LA PANTALLA;;;;
    mov fila,1h        ;fila 1
    inicio:
    mov cx,27fh        ;columna final 
    columna:
          mov  col,cx  ;movemos el valor de la columna a col
          push cx      ;salvamos cx
          mov ah,0ch   ;funcion para pintar un pixel
          mov al,0fh   ;color del pixel
          mov bh,0h    ;pagina a pintar
          mov cx,col   ;columna del pixel a pintar
          mov dx,fila  ;fila del pixel a pintar
          int 10h      ;llamamos a la interrupcion para pintar el pixel
          pop cx       ;regresamos cx
    loop columna       ;regresamos a pintar la columna hasta que sea la columna 0
    inc fila           ;incrementamos la fila
    cmp fila,1e0h      ;comparamos si llegamos al final
    jl inicio:         ;si no hemos llegado regresamos a pintar toda la fila

;;;;ESCRIBIMOS LA LETRA L    
escribirL:
    mov fila,64h        ;iniciamos en la fila 100
    
    inicioL:            ;etiqueta para regresar a escribir la primera parte de la L
    
    mov col,14h         ;iniciamos la columna en 20 
    
    colL:               ;etiqueta para regresar a la columna 20
          mov ah,0ch    ;funcion para escribir un punto o pixel grafico
          mov al,1h    ;en el registro al se pone el color
          mov bh,0h     ;seleccionamos la pagina por defecto 0
          mov cx,col    ;seleccionamos la columna del pixel a dibujar
          mov dx,fila   ;seleccionamos la fila del pixel a dibujar
          int 10h       ;llamamos a la interrupcion para pintar el pixel
          
          inc col       ;incrementamos la columna en 1
          cmp col,28h   ;comparamos que la columna sea 40
          jl colL       ;si es menor regresa para pintar el siguiente pixel de la columna
          inc fila      ;incrementa la fila si se llega a la columna 40
          cmp fila,17Ch ;comparamos que la fila sea 380
          jl inicioL    ;si es menor regresa para seguir pintando el pixel en la columna
    
    inicioFL:           ;etiqueta para iniciar la parte final de la letra L
    mov col,14h         ;iniciamos la columna en 20
    
    colFL:
          mov ah,0ch    ;funcion para escribir un punto o pixel grafico
          mov al,1h    ;se selecciona el color azul
          mov bh,0h     ;se selecciona pagina 0
          mov cx,col    ;seleccion de columna
          mov dx,fila   ;sleeccion de fila
          int 10h       ;llamamos la interrupcion para pintar el pixel
          inc col       ;incrementamos la columna
          cmp col,64h   ;comparamos que sea menor a 100
          jl colFL      ;si es menor regresa para pintar la siguiente columna
          inc fila      ;si llega a 100 la columna, se incrementa la fila
          cmp fila,190h ;se compara que la fila sea menor a 400
          jl inicioFL   ;si es menor regresa para pintar toda la fila siguiente

;;ESCRIBIMOS LA LETRA I     
escribirI:
    mov fila,64h        ;iniciamos en la fila 100
    
    inicioI:            ;etiqueta para regresar a esscriir la I
    
    mov col,8ch         ;iniciamos la columna 
    
    colI:               ;etiqueta para regresar a la columna inicial
          mov ah,0ch    ;funcion para escribir un punto o pixel grafico
          mov al,2h    ;en el registro al se pone el color
          mov bh,0h     ;seleccionamos la pagina por defecto 0
          mov cx,col    ;seleccionamos la columna del pixel a dibujar
          mov dx,fila   ;seleccionamos la fila del pixel a dibujar
          int 10h       ;llamamos a la interrupcion para pintar el pixel
          
          inc col       ;incrementamos la columna en 1
          cmp col,0A0h   ;comparamos si es la columna final
          jl colI       ;si es menor regresa para pintar el siguiente pixel de la columna
          inc fila      ;incrementa la fila si se llega a la columna final
          cmp fila,190h ;comparamos que la fila sea la final
          jl inicioI    ;si es menor regresa para seguir pintando el pixel en la columna
         
         
;;ESCRIBIMOS LA LETRA E          
escribirE:
    mov fila,64h        ;iniciamos en la fila 100
    
    inicioE:            ;etiqueta para regresar a esscribir la primera parte de la E
    
    mov col,12ch         ;iniciamos la columna 
    
    colE:               ;etiqueta para regresar a la columna inicial
          mov ah,0ch    ;funcion para escribir un punto o pixel grafico
          mov al,15h    ;en el registro al se pone el color
          mov bh,0h     ;seleccionamos la pagina por defecto 0
          mov cx,col    ;seleccionamos la columna del pixel a dibujar
          mov dx,fila   ;seleccionamos la fila del pixel a dibujar
          int 10h       ;llamamos a la interrupcion para pintar el pixel
          
          inc col       ;incrementamos la columna en 1
          cmp col,140h   ;comparamos que la columna sea la final
          jl colE       ;si es menor regresa para pintar el siguiente pixel de la columna
          inc fila      ;incrementa la fila si se llega a la columna final
          cmp fila,190h ;comparamos que la fila sea la final
          jl inicioE    ;si es menor regresa para seguir pintando el pixel en la columna
         
    mov fila,64h
    inicioE2:            ;etiqueta para regresar a esscribir la segunda parte de la E
    
    mov col,140h         ;iniciamos la columna 
    
    colE2:               ;etiqueta para regresar a la columna 20
          mov ah,0ch    ;funcion para escribir un punto o pixel grafico
          mov al,4h    ;en el registro al se pone el color
          mov bh,0h     ;seleccionamos la pagina por defecto 0
          mov cx,col    ;seleccionamos la columna del pixel a dibujar
          mov dx,fila   ;seleccionamos la fila del pixel a dibujar
          int 10h       ;llamamos a la interrupcion para pintar el pixel
          
          inc col        ;incrementamos la columna en 1
          cmp col,190h   ;comparamos que la columna sea la final
          jl colE2       ;si es menor regresa para pintar el siguiente pixel de la columna
          inc fila       ;incrementa la fila si se llega a la columna final
          cmp fila,78h   ;comparamos que la fila sea la final
          jl inicioE2    ;si es menor regresa para seguir pintando el pixel en la columna
    
    mov fila,0f0h
    inicioE3:            ;etiqueta para regresar a escribir la tercera parte de la E
    
    mov col,140h         ;iniciamos la columna 
    
    colE3:               ;etiqueta para regresar a la columna inicial
          mov ah,0ch    ;funcion para escribir un punto o pixel grafico
          mov al,5h    ;en el registro al se pone el color 
          mov bh,0h     ;seleccionamos la pagina por defecto 0
          mov cx,col    ;seleccionamos la columna del pixel a dibujar
          mov dx,fila   ;seleccionamos la fila del pixel a dibujar
          int 10h       ;llamamos a la interrupcion para pintar el pixel
          
          inc col       ;incrementamos la columna en 1
          cmp col,172h   ;comparamos que la columna sea la final
          jl colE3       ;si es menor regresa para pintar el siguiente pixel de la columna
          inc fila      ;incrementa la fila si se llega a la columna final
          cmp fila,104h ;comparamos que la fila sea la final
          jl inicioE3    ;si es menor regresa para seguir pintando el pixel en la columna
     
      mov fila,17ch
    inicioE4:            ;etiqueta para regresar a escribir la ultima parte de la E
    
    mov col,140h         ;iniciamos la columna 
    
    colE4:               ;etiqueta para regrasar a la columna inicial
          mov ah,0ch     ;funcion para escribir un punto o pixel grafico
          mov al,6h     ;en el registro al se pone el color
          mov bh,0h      ;seleccionamos la pagina por defecto 0
          mov cx,col     ;seleccionamos la columna del pixel a dibujar
          mov dx,fila    ;seleccionamos la fila del pixel a dibujar
          int 10h        ;llamamos a la interrupcion para pintar el pixel
          
          inc col        ;incrementamos la columna en 1
          cmp col,190h   ;comparamos que la columna sea la final
          jl colE4       ;si es menor regresa para pintar el siguiente pixel de la columna
          inc fila       ;incrementa la fila si se llega a la columna final
          cmp fila,190h  ;comparamos que la fila sea final
          jl inicioE4    ;si es menor regresa para seguir pintando el pixel en la columna
                   

;;ESCRIBIMOS EL NUMERO 2

escribir2:
    mov fila,64h        ;iniciamos en la fila 100
    
    inicio2:            ;etiqueta para regresar a escribir la primera parte del numero 2
    
    mov col,1F4h         ;iniciamos la columna 
    
    col2:               ;etiqueta para regresar a la columna inicial
          mov ah,0ch    ;funcion para escribir un punto o pixel grafico
          mov al,7h    ;en el registro al se pone el color
          mov bh,0h     ;seleccionamos la pagina por defecto 0
          mov cx,col    ;seleccionamos la columna del pixel a dibujar
          mov dx,fila   ;seleccionamos la fila del pixel a dibujar
          int 10h       ;llamamos a la interrupcion para pintar el pixel
          
          inc col       ;incrementamos la columna en 1
          cmp col,258h   ;comparamos que la columna sea final
          jl col2       ;si es menor regresa para pintar el siguiente pixel de la columna
          inc fila      ;incrementa la fila si se llega a la columna final
          cmp fila,78h ;comparamos que la fila sea final
          jl inicio2    ;si es menor regresa para seguir pintando el pixel en la columna
         
    mov fila,78h
    inicio21:            ;etiqueta para regresar a escribir la primera segunda parte del numero 2
    
    mov col,244h         ;iniciamos la columna 
    
    col21:               ;etiqueta para regresar a la columna inicial
          mov ah,0ch    ;funcion para escribir un punto o pixel grafico
          mov al,8h    ;en el registro al se pone el color
          mov bh,0h     ;seleccionamos la pagina por defecto 0
          mov cx,col    ;seleccionamos la columna del pixel a dibujar
          mov dx,fila   ;seleccionamos la fila del pixel a dibujar
          int 10h       ;llamamos a la interrupcion para pintar el pixel
          
          inc col       ;incrementamos la columna en 1
          cmp col,258h   ;comparamos que la columna sea la final
          jl col21       ;si es menor regresa para pintar el siguiente pixel de la columna
          inc fila      ;incrementa la fila si se llega a la columna final
          cmp fila,0f0h ;comparamos que la fila sea final
          jl inicio21    ;si es menor regresa para seguir pintando el pixel en la columna
    
    mov fila,0f0h
    inicio22:            ;etiqueta para regresar a escribir la tercera parte del numero 2
    
    mov col,258h         ;iniciamos la columna 
    
    col22:               ;etiqueta para regresar a la columna inicial
          mov ah,0ch    ;funcion para escribir un punto o pixel grafico
          mov al,9h    ;en el registro al se pone el color
          mov bh,0h     ;seleccionamos la pagina por defecto 0
          mov cx,col    ;seleccionamos la columna del pixel a dibujar
          mov dx,fila   ;seleccionamos la fila del pixel a dibujar
          int 10h       ;llamamos a la interrupcion para pintar el pixel
          
          dec col       ;incrementamos la columna en 1
          cmp col,1f4h   ;comparamos que la columna sea final
          jg col22       ;si es menor regresa para pintar el siguiente pixel de la columna
          inc fila      ;incrementa la fila si se llega a la columna final
          cmp fila,104h ;comparamos que la fila sea final
          jl inicio22    ;si es menor regresa para seguir pintando el pixel en la columna
     
    mov fila,104h
    inicio23:            ;etiqueta para regresar a escribir la cuarta parte del numero 2
    
    mov col,1F4h         ;iniciamos la columna
    
    col23:               ;etiqueta para regresar a la columna inicial
          mov ah,0ch     ;funcion para escribir un punto o pixel grafico
          mov al,13h     ;en el registro al se pone el color
          mov bh,0h      ;seleccionamos la pagina por defecto 0
          mov cx,col     ;seleccionamos la columna del pixel a dibujar
          mov dx,fila    ;seleccionamos la fila del pixel a dibujar
          int 10h        ;llamamos a la interrupcion para pintar el pixel
          
          inc col        ;incrementamos la columna en 1
          cmp col,208h   ;comparamos que la columna sea final
          jl col23       ;si es menor regresa para pintar el siguiente pixel de la columna
          inc fila       ;incrementa la fila si se llega a la columna final
          cmp fila,17ch  ;comparamos que la fila sea final
          jl inicio23    ;si es menor regresa para seguir pintando el pixel en la columna
                   

    mov fila,17ch
    inicio24:            ;etiqueta para regresar a escribir la ultima parte del numero 2
    
    mov col,1F4h         ;iniciamos la columna 
    
    col24:               ;etiqueta para regresar a la columna inicial
          mov ah,0ch    ;funcion para escribir un punto o pixel grafico
          mov al,14h    ;en el registro al se pone el color en este caso azul
          mov bh,0h     ;seleccionamos la pagina por defecto 0
          mov cx,col    ;seleccionamos la columna del pixel a dibujar
          mov dx,fila   ;seleccionamos la fila del pixel a dibujar
          int 10h       ;llamamos a la interrupcion para pintar el pixel
          
          inc col       ;incrementamos la columna en 1
          cmp col,258h   ;comparamos que la columna sea final
          jl col24       ;si es menor regresa para pintar el siguiente pixel de la columna
          inc fila      ;incrementa la fila si se llega a la columna final
          cmp fila,190h ;comparamos que la fila sea final
          jl inicio24    ;si es menor regresa para seguir pintando el pixel en la columna
    
    
    ;;;LIMPIAMOS TODA LA PANTALLA;;;;
    mov fila,1h
    fin:
    mov cx,27fh
    columnaf:
          mov  col,cx
          push cx
          mov ah,0ch
         mov al,00h
          mov bh,0h
          mov cx,col
          mov dx,fila
          int 10h
          pop cx
    loop columnaf
    inc fila
    cmp fila,1e0h
    jl fin   
     
    
    
.exit  

END main
