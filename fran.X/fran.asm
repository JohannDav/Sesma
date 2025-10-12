
    LIST        P=16F628A       ; Define el procesador
    #INCLUDE    <P16F628A.INC>    ; Incluye las definiciones estándar

;--- CONFIGURACIÓN PARA OSCILADOR INTERNO ---
    __CONFIG    _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _BOREN_OFF & _LVP_OFF & _CP_OFF

;--- VARIABLES PARA EL RETARDO DE 1 SEGUNDO ---
    CBLOCK  0x20
        count1      ; Contador para el bucle más interno del retardo
        count2      ; Contador para el bucle medio
        count3      ; Contador para el bucle externo
    ENDC

;--- VECTOR DE RESET ---
    ORG     0x00
    GOTO    Inicio

;--- PROGRAMA PRINCIPAL ---
Inicio:
    ; --- Configuración de puertos ---
    BANKSEL TRISB           ; Sube al Banco 1
    MOVLW   b'10000001'     ; Configura RB1,2,3,4,5,6 como SALIDAS (0)
                            ; y RB0, RB7 como ENTRADAS (1) por seguridad.
    MOVWF   TRISB           ; Escribe la configuración en TRISB

    ; --- Regresamos al Banco 0 para el resto ---
    BANKSEL PORTB           ; Baja al Banco 0
    MOVLW   0x07            ; Carga el valor para desactivar comparadores
    MOVWF   CMCON           ; Escribe en CMCON
    CLRF    PORTB           ; Apaga todos los LEDs al iniciar

Principal:
    ; --- PRIMERA SECUENCIA: Retardo de 1 segundo ---
    MOVLW   b'01111110'     ; Patrón para encender los 6 LEDs (RB1 a RB6)
    MOVWF   PORTB           ; Enciende los LEDs
    CLRF    PORTB           ; Apaga los LEDs inmediatamente
    CALL    Retardo_1_Segundo ; Llama a la pausa de 1 segundo

    ; --- SEGUNDA SECUENCIA: Retardo de 2 segundos ---
    MOVLW   b'01111110'     ; Mismo patrón de encendido
    MOVWF   PORTB           ; Enciende los LEDs
    CLRF    PORTB           ; Apaga los LEDs inmediatamente
    CALL    Retardo_1_Segundo ; Llama a la pausa de 1 segundo (1)
    CALL    Retardo_1_Segundo ; Llama a la pausa de 1 segundo (2) -> Total 2 segundos

    ; --- TERCERA SECUENCIA: Retardo de 4 segundos ---
    MOVLW   b'01111110'     ; Mismo patrón de encendido
    MOVWF   PORTB           ; Enciende los LEDs
    CLRF    PORTB           ; Apaga los LEDs inmediatamente
    CALL    Retardo_1_Segundo ; Llama a la pausa de 1 segundo (1)
    CALL    Retardo_1_Segundo ; Llama a la pausa de 1 segundo (2)
    CALL    Retardo_1_Segundo ; Llama a la pausa de 1 segundo (3)
    CALL    Retardo_1_Segundo ; Llama a la pausa de 1 segundo (4) -> Total 4 segundos

    GOTO    Principal       ; Vuelve al inicio para repetir el ciclo completo

;--- SUBRUTINA DE RETARDO DE ~1 SEGUNDO ---
; (Idéntica a la del programa anterior)
Retardo_1_Segundo:
    MOVLW   d'10'
    MOVWF   count3
Bucle_Externo:
    MOVLW   d'250'
    MOVWF   count2
Bucle_Medio:
    MOVLW   d'200'
    MOVWF   count1
Bucle_Interno:
    DECFSZ  count1, F
    GOTO    Bucle_Interno
    DECFSZ  count2, F
    GOTO    Bucle_Medio
    DECFSZ  count3, F
    GOTO    Bucle_Externo
    RETURN

    END                     ; Fin del programa