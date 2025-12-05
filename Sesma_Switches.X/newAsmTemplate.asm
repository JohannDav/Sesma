; Quirino Gonzalez Johann David
; Código adaptado para PIC16F628A

; Define una constante para usar como contador. 
COUNT   EQU     0CH     

LIST    P=16F628A       ; Estamos usando el 16F628A
#include <P16F628A.INC> ; Incluir archivo de definiciones
__CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _XT_OSC & _MCLRE_OFF & _BODEN_OFF

ORG     0               ; La dirección de inicio en memoria es 0
GOTO    START           ; Ir a START

; ***************************************
; El programa comienza ahora
; ***************************************
START
    BSF     STATUS, RP0 ; Seleccionar Banco 1
    MOVLW   b'00000001' ; RA0 como entrada, demás pines como salidas
    MOVWF   TRISA       ; Configurar PORTA
    MOVLW   b'00000000' ; Todos los pines como salidas
    MOVWF   TRISB       ; Configurar PORTB
    BCF     STATUS, RP0 ; Volver al Banco 0
    
    ; Configurar comparadores (necesario en 16F628A)
    MOVLW   0x07
    MOVWF   CMCON       ; Deshabilitar comparadores
    
    ; Inicializar PORTB - TODOS LOS PINES EN BAJO (LED APAGADO)
    CLRF    PORTB       ; Limpiar PORTB (todos en 0)
    
    ; Configurar salida constante de 5V en RB7
    BSF     PORTB, 7    ; RB7 siempre en alto (5V)

BEGIN
    MOVLW   .10         ; Poner 10 en W (Working Register)
    MOVWF   COUNT       ; Mover W a COUNT. Esto inicializa el contador.

; *** Rutina de Detección de Presión (PRESS) ***
PRESS
    BTFSC   PORTA,0     ; Bit Test F, Skip if Clear. ¿El switch está presionado?
                        ; Si PORTA,0 es 0 (Presionado), saltar la siguiente instrucción (GOTO PRESS).
    GOTO    PRESS       ; No: El switch no está presionado, seguir esperando.
                        ; Sí: El switch está presionado (PORTA,0=0), continuar.

    CALL    DELAY       ; Esperar por 3/32 segundos (para debounce/antirrebote).
    BCF     PORTB,0     ; Bit Clear F. Apagar el LED (PORTB,0=0).

; *** Rutina de Detección de Liberación (RELEASE) ***
RELEASE
    BTFSS   PORTA,0     ; Bit Test F, Skip if Set. ¿El switch se ha liberado?
                        ; Si PORTA,0 es 1 (Liberado), saltar la siguiente instrucción (GOTO RELEASE).
    GOTO    RELEASE     ; No: El switch sigue presionado, seguir esperando.
                        ; Sí: El switch se ha liberado (PORTA,0=1), continuar.

    CALL    DELAY       ; Esperar por 3/32 segundos (para debounce/antirrebote).
    DECFSZ  COUNT, F    ; Decrementar COUNT. Si el resultado es 0, saltar la siguiente instrucción.
    GOTO    PRESS       ; Esperar por otra pulsación (si COUNT no es 0).

; *** Lógica Final ***
    BSF     PORTB,0     ; Bit Set F. Encender el LED (PORTB,0=1).
    GOTO    BEGIN       ; Reiniciar el ciclo (vuelve a cargar el contador en BEGIN).

; *** Rutina de Retardo (DELAY) ***
DELAY
    MOVLW   .100        ; Cargar valor para el retardo
    MOVWF   0x20        ; Usar dirección de memoria 0x20 como contador
DELAY_LOOP
    DECFSZ  0x20, F     ; Decrementar contador
    GOTO    DELAY_LOOP  ; Repetir hasta que sea cero
    RETURN              ; Retornar de la subrutina
    
END                     ; Fin del código fuente