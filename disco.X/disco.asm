; =========================================================================
; Nombre del Archivo: disco.asm
; Microcontrolador: PIC16F628A
; Ambiente: MPLAB X IDE v5.35
; Compilador: MPASM
; Frecuencia del Oscilador: 4MHz (Oscilador interno)
; Descripción: Secuencia de luces tipo "disco" en el Puerto B
; =========================================================================

    LIST    P=16F628A           ; Define el microcontrolador
    #include <p16f628a.inc>
    
    ; --- Configuración del microcontrolador (Fuses) ---
    __CONFIG _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _INTRC_OSC_NOCLKOUT & _LVP_OFF & _MCLRE_OFF

; --- Definición de variables en RAM ---
    CBLOCK 0x20
        dly1_cnt    ; Contador para el primer bucle de retardo
        dly2_cnt    ; Contador para el segundo bucle de retardo
    ENDC

; --- Vector de Reset ---
    ORG     0x0000              ; Posición de inicio del programa (Reset Vector)
    GOTO    MAIN                ; Salta al programa principal

; --- Subrutina de Retardo ---
; Crea un retardo de tiempo. La duración del retardo es ajustable
; cambiando los valores cargados en dly1_cnt y dly2_cnt.
DELAY
    MOVLW   0x05                ; Cargar valor para el contador exterior
    MOVWF   dly1_cnt
dly_loop1
    MOVLW   0xFA                ; Cargar valor para el contador interior
    MOVWF   dly2_cnt
dly_loop2
    DECFSZ  dly2_cnt, F         ; Decrementa dly2_cnt. Si es 0, salta la siguiente línea
    GOTO    dly_loop2           ; Si no es 0, vuelve a dly_loop2
    DECFSZ  dly1_cnt, F         ; Decrementa dly1_cnt. Si es 0, salta la siguiente línea
    GOTO    dly_loop1           ; Si no es 0, vuelve a dly_loop1
    RETURN                      ; Regresa del la subrutina

; --- Programa Principal ---
MAIN
    BSF     STATUS, RP0         ; Cambia al Banco 1
    CLRF    TRISB               ; Configura el Puerto B como salida (todos los pines)
    BCF     STATUS, RP0         ; Vuelve al Banco 0

    CLRF    PORTB               ; Limpia el Puerto B, asegurando que todos los LEDs estén apagados al inicio

; --- Bucle principal de la secuencia de luces ---
LOOP
    ; Secuencia 1: LEDs alternos encendidos y apagados
    MOVLW   B'01010101'         ; Patrón 1 (RB0, RB2, RB4, RB6 encendidos)
    MOVWF   PORTB
    CALL    DELAY               ; Espera
    MOVLW   B'10101010'         ; Patrón 2 (RB1, RB3, RB5, RB7 encendidos)
    MOVWF   PORTB
    CALL    DELAY               ; Espera

    ; Secuencia 2: Encendido de LEDs del centro hacia afuera
    MOVLW   B'00011000'         ; Patrón 3 (RB3, RB4 encendidos)
    MOVWF   PORTB
    CALL    DELAY               ; Espera
    MOVLW   B'00100100'         ; Patrón 4 (RB2, RB5 encendidos)
    MOVWF   PORTB
    CALL    DELAY               ; Espera
    MOVLW   B'01000010'         ; Patrón 5 (RB1, RB6 encendidos)
    MOVWF   PORTB
    CALL    DELAY               ; Espera
    MOVLW   B'10000001'         ; Patrón 6 (RB0, RB7 encendidos)
    MOVWF   PORTB
    CALL    DELAY               ; Espera
    
    ; Secuencia 3: Todos los LEDs encendidos y apagados (efecto de parpadeo)
    MOVLW   B'11111111'
    MOVWF   PORTB
    CALL    DELAY
    CLRF    PORTB               ; Apaga todos los LEDs
    CALL    DELAY
    
    GOTO    LOOP                ; Regresa al inicio del bucle para repetir la secuencia

    END                         ; Fin del archivo


