; HEADER para el PIC16F628A, usando el oscilador RC interno a 4MHz.
;
; Este encabezado configura PORTA y PORTB como puertos de E/S digitales.
; Se incluyen subrutinas de retardo para 0.1, 0.5 y 1 segundo.
; Se desactiva el comparador para permitir el uso de todos los pines I/O.
;
#include <p16f628a.inc>

;*********************************************************
; EQUATES SECTION
; Define las etiquetas para los registros y bits que usaremos.

PORTA         EQU 5         ; PORTA es el archivo 5
PORTB         EQU 6         ; PORTB es el archivo 6
TRISA         EQU 85H       ; TRISA es el archivo 85H (Bank 1)
TRISB         EQU 86H       ; TRISB es el archivo 86H (Bank 1)
STATUS        EQU 3         ; STATUS es el archivo 3
COUNT1        EQU 20H       ; COUNT1 es un registro de usuario en 20H
COUNT2        EQU 21H       ; COUNT2 es un registro de usuario en 21H
COUNT3        EQU 22H       ; COUNT3 es un registro de usuario en 22H

;*********************************************************
; DIRECTIVAS DEL ENSAMBLADOR
; Le dice al ensamblador qué microcontrolador estamos usando y dónde empezar.

    LIST      P=16F628A   ; Usamos el microcontrolador 16F628A
    ORG       0           ; La dirección de inicio en la memoria es 0
    GOTO      START       ; Ir a la etiqueta START

;*********************************************************
; BITS DE CONFIGURACION
; Establece la configuración del microcontrolador.
; INTRC_OSC_NOCLKOUT = Oscilador RC interno sin salida de reloj en RA6
; WDT_OFF = Desactivar Watchdog Timer
; PWRTE_ON = Activar Power-up Timer
; LVP_OFF = Desactivar programación de bajo voltaje
; MCLRE_OFF = Pin MCLR está deshabilitado para usarlo como I/O digital.
; BOREN_OFF = Desactivar Brown-out Reset
; CP_OFF = Desactivar protección de código
; CPD_OFF = Desactivar protección de datos de EEPROM

    __CONFIG _INTRC_OSC_NOCLKOUT | _WDT_OFF | _PWRTE_ON | _LVP_OFF | _MCLRE_OFF | _BOREN_OFF | _CP_OFF | _CPD_OFF

;*********************************************************
; SUBRUTINAS DE RETARDO
; Rutinas de retardo calibradas para un oscilador de 4MHz.

; Retardo de 0.1 SEGUNDO
DELAY_0_1
    MOVLW   D'125'
    MOVWF   COUNT2
D0_1_LOOP
    MOVLW   D'190'
    MOVWF   COUNT1
D0_1_LOOP2
    NOP
    DECFSZ  COUNT1, F
    GOTO    D0_1_LOOP2
    DECFSZ  COUNT2, F
    GOTO    D0_1_LOOP
    RETLW   0

; Retardo de 0.5 SEGUNDO
DELAY_0_5
    MOVLW   D'5'
    MOVWF   COUNT1
D0_5_LOOP
    CALL    DELAY_0_1
    DECFSZ  COUNT1, F
    GOTO    D0_5_LOOP
    RETLW   0

; Retardo de 1 SEGUNDO
DELAY_1
    MOVLW   D'10'
    MOVWF   COUNT1
D1_LOOP
    CALL    DELAY_0_1
    DECFSZ  COUNT1, F
    GOTO    D1_LOOP
    RETLW   0

;*********************************************************
; SECCION DE CONFIGURACION
; Aquí se configura el hardware del microcontrolador al inicio del programa.

START
    BSF     STATUS, 5       ; Cambiar a Bank 1 para configurar I/O
    MOVLW   B'11111111'     ; Todos los pines de PORTA como entradas
    MOVWF   TRISA
    MOVLW   B'00000000'     ; Todos los pines de PORTB como salidas
    MOVWF   TRISB
    BCF     STATUS, 5       ; Regresar a Bank 0
    MOVLW   .7
    MOVWF   CMCON           ; Apagar los comparadores para usar los pines como I/O digital
    CLRF    PORTA           ; Limpiar los valores de PORTA
    CLRF    PORTB           ; Limpiar los valores de PORTB

;*********************************************************
; PROGRAMA PRINCIPAL
; El programa principal comienza aquí.

BEGIN
    BSF PORTB,0             ; Enciende el LED en B0
    CALL DELAY_1            ; Espera 1 segundo
    BCF PORTB,0             ; Apaga led
    CALL DELAY_0_5          ; Espera 0.5 segundos
    BSF PORTB,1             ; Prende B1
    CALL DELAY_1
    BCF PORTB,1
    CALL DELAY_0_5
    BSF PORTB,2
    CALL DELAY_1
    BCF PORTB,2
    CALL DELAY_0_5
    BSF PORTB,3
    CALL DELAY_1
    BCF PORTB,3
    CALL DELAY_0_5
    BSF PORTB,4
    CALL DELAY_1
    BCF PORTB,4
    CALL DELAY_0_5
    BSF PORTB,5
    CALL DELAY_1
    BCF PORTB,5
    CALL DELAY_0_5
    GOTO BEGIN
    END