; Quirino Gonzalez Johann David
; Código para PIC16F628A - Secuencias de LEDs

; Definición de constantes
BUTTON1  EQU     0       ; Botón 1 en RA0 (Secuencia 1)
BUTTON2  EQU     1       ; Botón 2 en RA1 (Secuencia 2)
LED1     EQU     0       ; LED 1 en RB0
LED2     EQU     1       ; LED 2 en RB1
LED3     EQU     2       ; LED 3 en RB2
LED4     EQU     3       ; LED 4 en RB3

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
    MOVLW   b'00000011' ; RA0 y RA1 como entradas, demás pines como salidas
    MOVWF   TRISA       ; Configurar PORTA
    MOVLW   b'00000000' ; Todos los pines como salidas
    MOVWF   TRISB       ; Configurar PORTB
    BCF     STATUS, RP0 ; Volver al Banco 0
    
    ; Configurar comparadores (necesario en 16F628A)
    MOVLW   0x07
    MOVWF   CMCON       ; Deshabilitar comparadores
    
    ; Inicializar PORTB - TODOS LOS LEDS APAGADOS
    CLRF    PORTB       ; Limpiar PORTB (todos en 0)

; *** SECUENCIA 1 - SECUENCIAL ***
SECUENCIA_UNO
    ; LED 1 (RB0)
    BSF     PORTB, LED1     ; Enciende RB0
    CALL    DELAY_5S        ; Retardo de 5 segundos
    CLRF    PORTB           ; Apaga todos los LEDs
    
    ; LED 2 (RB1)
    BSF     PORTB, LED2     ; Enciende RB1
    CALL    DELAY_5S        ; Retardo de 5 segundos
    CLRF    PORTB           ; Apaga todos los LEDs
    
    ; LED 3 (RB2)
    BSF     PORTB, LED3     ; Enciende RB2
    CALL    DELAY_5S        ; Retardo de 5 segundos
    CLRF    PORTB           ; Apaga todos los LEDs
    
    ; LED 4 (RB3)
    BSF     PORTB, LED4     ; Enciende RB3
    CALL    DELAY_5S        ; Retardo de 5 segundos
    CLRF    PORTB           ; Apaga todos los LEDs
    
    ; Comprobar el switch de nuevo antes de repetir
    BTFSC   PORTA, BUTTON1  ; Salta si el bit 0 (RA0) es 1 (sigue presionado)
    GOTO    BUCLE_PRINCIPAL ; Si no está presionado, vuelve al principal
    GOTO    SECUENCIA_UNO   ; Si sigue presionado, repite la secuencia

; *** SECUENCIA 2 - SIMULTANEA ***
SECUENCIA_DOS
    ; 1. Enciende todos los 4 LEDs (RB0-RB3)
    MOVLW   b'00001111'     ; Carga el patrón de encendido
    MOVWF   PORTB           ; Mueve el patrón a PORTB
    CALL    DELAY_5S        ; Retardo de 5 segundos
    
    ; 2. Apaga todos los 4 LEDs
    CLRF    PORTB           ; Apaga RB0-RB7
    CALL    DELAY_5S        ; Retardo de 5 segundos
    
    ; Comprobar el switch de nuevo antes de repetir
    BTFSC   PORTA, BUTTON2  ; Salta si el bit 1 (RA1) es 1 (sigue presionado)
    GOTO    BUCLE_PRINCIPAL ; Si no está presionado, vuelve al principal
    GOTO    SECUENCIA_DOS   ; Si sigue presionado, repite la secuencia

; *** Retardo para debounce ***
DELAY_DEBOUNCE
    MOVLW   .100
    MOVWF   0x20
DELAY_DEBOUNCE_LOOP
    DECFSZ  0x20, F
    GOTO    DELAY_DEBOUNCE_LOOP
    RETURN

; *** Retardo de 5 segundos ***
DELAY_5S
    MOVLW   .50             ; Contador externo
    MOVWF   0x21
DELAY_5S_LOOP1
    MOVLW   .200            ; Contador medio
    MOVWF   0x22
DELAY_5S_LOOP2
    MOVLW   .250            ; Contador interno
    MOVWF   0x23
DELAY_5S_LOOP3
    DECFSZ  0x23, F
    GOTO    DELAY_5S_LOOP3
    DECFSZ  0x22, F
    GOTO    DELAY_5S_LOOP2
    DECFSZ  0x21, F
    GOTO    DELAY_5S_LOOP1
    RETURN

; *** BUCLE PRINCIPAL - AL FINAL DEL CÓDIGO ***
BUCLE_PRINCIPAL
    ; Verificar botón 1 (RA0) para Secuencia 1
    BTFSC   PORTA, BUTTON1  ; Salta si RA0 es 1 (no presionado)
    GOTO    CHECK_BOTON2    ; No presionado, verificar botón 2
    
    ; Botón 1 presionado - ejecutar SECUENCIA UNO
    CALL    DELAY_DEBOUNCE  ; Esperar por debounce
    GOTO    SECUENCIA_UNO   ; Ir a secuencia 1

CHECK_BOTON2
    ; Verificar botón 2 (RA1) para Secuencia 2
    BTFSC   PORTA, BUTTON2  ; Salta si RA1 es 1 (no presionado)
    GOTO    BUCLE_PRINCIPAL ; No presionado, volver al bucle principal
    
    ; Botón 2 presionado - ejecutar SECUENCIA DOS
    CALL    DELAY_DEBOUNCE  ; Esperar por debounce
    GOTO    SECUENCIA_DOS   ; Ir a secuencia 2

END                     ; Fin del código fuente