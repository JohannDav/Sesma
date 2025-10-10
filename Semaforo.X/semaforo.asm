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

; Retardo de 0.2 SEGUNDOS (200ms para 4MHz) "DELAY_0_2"
DELAY_0_2
    MOVLW   D'2'           ; 1 ciclo
    MOVWF   COUNT3         ; 1 ciclo
DELAY_0_2_OUTER
    MOVLW   D'255'         ; 1 ciclo  
    MOVWF   COUNT2         ; 1 ciclo
DELAY_0_2_MID
    MOVLW   D'165'         ; 1 ciclo
    MOVWF   COUNT1         ; 1 ciclo
DELAY_0_2_INNER
    DECFSZ  COUNT1, F      ; 1 ciclo (2 cuando salta)
    GOTO    DELAY_0_2_INNER ; 2 ciclos
    DECFSZ  COUNT2, F      ; 1 ciclo (2 cuando salta)
    GOTO    DELAY_0_2_MID  ; 2 ciclos
    DECFSZ  COUNT3, F      ; 1 ciclo (2 cuando salta)
    GOTO    DELAY_0_2_OUTER ; 2 ciclos
    RETURN                 ; 2 ciclos

; Retardo de 1 SEGUNDO (REAL para 4MHz) "DELAY_1"
DELAY_1
    MOVLW   D'6'           ; 1 ciclo
    MOVWF   COUNT3         ; 1 ciclo
DELAY_1_OUTER
    MOVLW   D'255'         ; 1 ciclo  
    MOVWF   COUNT2         ; 1 ciclo
DELAY_1_MID
    MOVLW   D'255'         ; 1 ciclo
    MOVWF   COUNT1         ; 1 ciclo
DELAY_1_INNER
    DECFSZ  COUNT1, F      ; 1 ciclo (2 cuando salta)
    GOTO    DELAY_1_INNER  ; 2 ciclos
    DECFSZ  COUNT2, F      ; 1 ciclo (2 cuando salta)
    GOTO    DELAY_1_MID    ; 2 ciclos
    DECFSZ  COUNT3, F      ; 1 ciclo (2 cuando salta)
    GOTO    DELAY_1_OUTER  ; 2 ciclos
    RETURN                 ; 2 ciclos

; Retardo de 2 SEGUNDOS (para 4MHz) "DELAY_2"
DELAY_2
    MOVLW   D'12'          ; 1 ciclo
    MOVWF   COUNT3         ; 1 ciclo
DELAY_2_OUTER
    MOVLW   D'255'         ; 1 ciclo  
    MOVWF   COUNT2         ; 1 ciclo
DELAY_2_MID
    MOVLW   D'255'         ; 1 ciclo
    MOVWF   COUNT1         ; 1 ciclo
DELAY_2_INNER
    DECFSZ  COUNT1, F      ; 1 ciclo (2 cuando salta)
    GOTO    DELAY_2_INNER  ; 2 ciclos
    DECFSZ  COUNT2, F      ; 1 ciclo (2 cuando salta)
    GOTO    DELAY_2_MID    ; 2 ciclos
    DECFSZ  COUNT3, F      ; 1 ciclo (2 cuando salta)
    GOTO    DELAY_2_OUTER  ; 2 ciclos
    RETURN                 ; 2 ciclos

; Retardo de 5 SEGUNDOS (para 4MHz) "DELAY_5"
DELAY_5
    MOVLW   D'30'          ; 1 ciclo
    MOVWF   COUNT3         ; 1 ciclo
DELAY_5_OUTER
    MOVLW   D'255'         ; 1 ciclo  
    MOVWF   COUNT2         ; 1 ciclo
DELAY_5_MID
    MOVLW   D'255'         ; 1 ciclo
    MOVWF   COUNT1         ; 1 ciclo
DELAY_5_INNER
    DECFSZ  COUNT1, F      ; 1 ciclo (2 cuando salta)
    GOTO    DELAY_5_INNER  ; 2 ciclos
    DECFSZ  COUNT2, F      ; 1 ciclo (2 cuando salta)
    GOTO    DELAY_5_MID    ; 2 ciclos
    DECFSZ  COUNT3, F      ; 1 ciclo (2 cuando salta)
    GOTO    DELAY_5_OUTER  ; 2 ciclos
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
    ; Retardo de 0.2 SEGUNDOS (200ms para 4MHz) "DELAY_0_2"
    ; Retardo de 1 SEGUNDO (REAL para 4MHz) "DELAY_1"
    ; Retardo de 2 SEGUNDOS (para 4MHz) "DELAY_2"
    ; Retardo de 5 SEGUNDOS (para 4MHz) "DELAY_5"
    
    BSF	PORTB,1	    ; Enciende el verde de 1
    BSF PORTB,4	    ; Enciende el rojo de 2
    CALL DELAY_2    ; Espera dos sefundos
    
		    ; Empieza el parpadedo del verde de 1
    BCF PORTB,1	    ; Apaga el verde de 1
    CALL DELAY_0_2  ; Espera .2 seg
    CALL DELAY_0_2  ; Espera .2 seg
    
    BSF PORTB,1	    ; Prende el Verde de 1
    CALL DELAY_0_2  ; Espera .2 seg
    CALL DELAY_0_2  ; Espera .2 seg
    
    BCF PORTB,1	    ; Apaga el verde de 1
    CALL DELAY_0_2  ; Espera .2 seg
    CALL DELAY_0_2  ; Espera .2 seg
    
    BSF PORTB,1	    ; Prende el Verde de 1
    CALL DELAY_0_2  ; Espera .2 seg
    CALL DELAY_0_2  ; Espera .2 seg
    
    BCF PORTB,1	    ; Apaga el verde de 1 y TERMINA PARPADEO DE VERDE 1
    BSF PORTB,2	    ; Enciende naranja de 1
    CALL DELAY_1    ; Espera 1 seg
    
    BCF PORTB,2	    ; Apaga el naranja de 1
    BSF PORTB,3	    ; Enciende el rojo de 1
    BCF PORTB,4	    ; Apaga el rojo de 2
    BSF PORTB,6	    ; Enciende el verde de 2
    CALL DELAY_2    ; Espera 2 segundos
    
		    ; EMPIEZA EL PARPADEO DE VERDE 2
    BCF PORTB,6	    ; Apaga verde 2
    CALL DELAY_0_2  ; Espera .2 seg
    CALL DELAY_0_2  ; Espera .2 seg
    
    BSF PORTB,6	    ; Enciende el verde 2
    CALL DELAY_0_2  ; Espera .2 seg
    CALL DELAY_0_2  ; Espera .2 seg
    
    BCF PORTB,6	    ; Apaga verde 2
    CALL DELAY_0_2  ; Espera .2 seg
    CALL DELAY_0_2  ; Espera .2 seg
    
    BSF PORTB,6	    ; Enciende el verde 2
    CALL DELAY_0_2  ; Espera .2 seg
    CALL DELAY_0_2  ; Espera .2 seg
    
    BCF PORTB,6	    ; Apaga verde 2 Y TERMINA EL PARPADEO de verde 2
    BSF PORTB,5	    ; Enciende el naranja de 2
    CALL DELAY_1    ; Espera 1 segundo
    
    BCF PORTB,5	    ; Apaga el naranja de 2
    BSF PORTB,4	    ; Enciende el rojo de 2
    BCF PORTB,3	    ; Apaga el rojo de 1
    
    GOTO    BEGIN           ; Repite el ciclo    
    END