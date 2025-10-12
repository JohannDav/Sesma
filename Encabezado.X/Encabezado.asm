;Quirino Gonzalez Johann David
; HEADER para el PIC16F628A, usando el oscilador RC interno a 4MHz.

#include <p16f628a.inc>

;*********************************************************
; EQUATES SECTION
PORTA         EQU 0x05
PORTB         EQU 0x06
TRISA         EQU 0x85
TRISB         EQU 0x86
STATUS        EQU 0x03
CMCON         EQU 0x1F
COUNT1        EQU 0x20
COUNT2        EQU 0x21
COUNT3        EQU 0x22

;*********************************************************
; DIRECTIVAS DEL ENSAMBLADOR
    LIST      P=16F628A
    ORG       0x0000
    GOTO      START

;*********************************************************
; BITS DE CONFIGURACION
    __CONFIG _INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_ON & _LVP_OFF & _MCLRE_OFF & _BOREN_OFF & _CP_OFF & _CPD_OFF

;*********************************************************
; SUBRUTINAS DE RETARDO REALES

; Retardo de 1 SEGUNDO (REAL para 4MHz)
DELAY_1
    MOVLW   D'6'           ; 1 ciclo
    MOVWF   COUNT3         ; 1 ciclo
OUTER_LOOP
    MOVLW   D'255'         ; 1 ciclo  
    MOVWF   COUNT2         ; 1 ciclo
MID_LOOP
    MOVLW   D'255'         ; 1 ciclo
    MOVWF   COUNT1         ; 1 ciclo
INNER_LOOP
    DECFSZ  COUNT1, F      ; 1 ciclo (2 cuando salta)
    GOTO    INNER_LOOP     ; 2 ciclos
    DECFSZ  COUNT2, F      ; 1 ciclo (2 cuando salta)
    GOTO    MID_LOOP       ; 2 ciclos
    DECFSZ  COUNT3, F      ; 1 ciclo (2 cuando salta)
    GOTO    OUTER_LOOP     ; 2 ciclos
    RETURN                 ; 2 ciclos

;*********************************************************
; SECCION DE CONFIGURACION
START
    BSF     STATUS, RP0     ; Bank 1
    MOVLW   B'00000000'     ; PORTA como salidas
    MOVWF   TRISA
    MOVLW   B'00000000'     ; PORTB como salidas  
    MOVWF   TRISB
    BCF     STATUS, RP0     ; Bank 0
    
    MOVLW   0x07
    MOVWF   CMCON           ; Deshabilitar comparadores
    
    CLRF    PORTA
    CLRF    PORTB

;*********************************************************
; PROGRAMA PRINCIPAL
BEGIN
    BSF     PORTB,1         ; Enciende el LED en el pin RB0
    CALL    DELAY_1         ; Espera 1 segundo (REAL)
    BCF     PORTB,1         ; Apaga el LED en el pin RB0
    BSF	    PORTB,2	    ; Enciende el LED 2
    CALL    DELAY_1         ; Espera 1 segundo (REAL)
    CALL    DELAY_1	    ; Espera otro segundo
    BCF	    PORTB,2	    ; Apaga led 2
    BSF	    PORTB,3	    ; Enciende LED 3
    CALL    DELAY_1	    ; Espera 1 seg
    CALL    DELAY_1	    ; Espera 1 seg
    CALL    DELAY_1	    ; Espera 1 seg
    BCF	    PORTB,3	    ; Apaga LED 3
    BSF	    PORTB,4	    ; Enciende LED 4
    CALL    DELAY_1	    ; Espera 1 seg
    CALL    DELAY_1	    ; Espera 1 seg
    CALL    DELAY_1	    ; Espera 1 seg
    CALL    DELAY_1	    ; Espera 1 seg
    BCF	    PORTB,4	    ; Apaga LED 4
    BSF	    PORTB,5	    ; Enciende LED 5
    CALL    DELAY_1	    ; Espera 1 seg
    BCF	    PORTB,5	    ; Apaga LED 5
    BSF	    PORTB,6	    ; Enciende LED 6
    CALL    DELAY_1	    ; Espera 1 seg
    BCF	    PORTB,6	    ; Apaga LED 6
    CALL    DELAY_1	    ; Espera 1 seg
    GOTO    BEGIN           ; Repite el ciclo    
    END