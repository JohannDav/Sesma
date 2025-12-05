; ============================================================
; Programa: Control de 4 LEDs con 2 botones
; Micro: PIC16F628A
; Oscilador: Interno 4MHz
; Retardos: 29% más rápidos (0.71 segundos en lugar de 1 segundo)
; ============================================================

    LIST    P=16F628A
    #INCLUDE <P16F628A.INC>
    
    ; Configuración del PIC
    __CONFIG _FOSC_INTOSCIO & _WDT_OFF & _PWRTE_ON & _MCLRE_OFF & _BODEN_OFF

    ; Constantes para pines
BOTON1 EQU 0    ; Botón 1 en RA0
BOTON2 EQU 1    ; Botón 2 en RA1
SAL_5V EQU 2    ; Salida 5V en RA2

    ; Variables
    CBLOCK 0x20
        CONT1, CONT2, CONT3  ; Para delays
    ENDC

    ORG 0x00        ; Dirección de inicio
    GOTO INICIO     ; Saltar al programa principal

; ============================================================
; SUBRUTINAS DE RETARDO (29% MÁS RÁPIDAS)
; ============================================================

; Retardo de 0.71 SEGUNDOS (29% menos que 1 segundo)
RETARDO_0_71S
    MOVLW   D'3'        ; Contador externo (antes 4, ahora 3 - reducción 25%)
    MOVWF   CONT1
EXT_LOOP
    MOVLW   D'225'      ; Contador medio (antes 250, ahora 225 - reducción 10%)
    MOVWF   CONT2
MED_LOOP
    MOVLW   D'225'      ; Contador interno (antes 250, ahora 225 - reducción 10%)
    MOVWF   CONT3
INT_LOOP
    NOP
    NOP
    NOP
    NOP
    DECFSZ  CONT3, F
    GOTO    INT_LOOP
    DECFSZ  CONT2, F
    GOTO    MED_LOOP
    DECFSZ  CONT1, F
    GOTO    EXT_LOOP
    RETURN

; Retardo de 1.42ms para antirrebote (29% menos que 2ms)
RETARDO_1_42MS
    MOVLW   D'14'       ; (antes 20, ahora 14 - reducción 30%)
    MOVWF   CONT1
DEL_1_42MS
    NOP
    NOP
    NOP
    NOP
    NOP
    DECFSZ  CONT1, F
    GOTO    DEL_1_42MS
    RETURN

; ============================================================
; PROGRAMA PRINCIPAL
; ============================================================
INICIO
    ; Configurar comparadores como digitales
    MOVLW   0x07
    MOVWF   CMCON
    
    ; Configurar puertos
    BSF     STATUS, RP0  ; Banco 1
    MOVLW   b'00000011'  ; RA0 y RA1 como entradas, RA2 como salida
    MOVWF   TRISA
    MOVLW   b'00000000'  ; Todo PORTB como salidas
    MOVWF   TRISB
    BCF     STATUS, RP0  ; Banco 0
    
    ; Inicializar puertos
    CLRF    PORTA
    CLRF    PORTB
    
    ; Configurar RA2 como salida constante de 5V
    BSF     PORTA, SAL_5V

; ============================================================
; BUCLE PRINCIPAL INFINITO
; ============================================================
BUCLE_MAIN
    ; Verificar si está presionado B1 (detección de flanco)
    BTFSS   PORTA, BOTON1   ; ¿Está presionado B1?
    GOTO    CHECAR_B2       ; No, verificar B2
    
    ; Botón 1 presionado - ESPERAR ANTIRREBOTE
    CALL    RETARDO_1_42MS
    BTFSS   PORTA, BOTON1   ; Verificar nuevamente después del antirrebote
    GOTO    CHECAR_B2       ; Falso positivo, verificar B2
    
    ; ===== EJECUTAR SECUENCIA COMPLETA BOTÓN 1 =====
    ; Enciende L1, L2, L3 y L4 simultáneamente
    MOVLW   b'00001111'
    MOVWF   PORTB
    
    ; Espera 0.71 segundos (29% menos que 1 segundo)
    CALL    RETARDO_0_71S
    
    ; Apaga L1, L2, L3 y L4
    CLRF    PORTB
    
    ; Esperar a que se SUELTE el botón antes de continuar
ESPERA_SUELTO_B1
    BTFSC   PORTA, BOTON1
    GOTO    ESPERA_SUELTO_B1
    
    CALL    RETARDO_1_42MS     ; Antirrebote al soltar
    
    GOTO    BUCLE_MAIN      ; Volver al bucle principal

CHECAR_B2
    ; Verificar si está presionado B2 (detección de flanco)
    BTFSS   PORTA, BOTON2   ; ¿Está presionado B2?
    GOTO    BUCLE_MAIN      ; No, volver a verificar
    
    ; Botón 2 presionado - ESPERAR ANTIRREBOTE
    CALL    RETARDO_1_42MS
    BTFSS   PORTA, BOTON2   ; Verificar nuevamente después del antirrebote
    GOTO    BUCLE_MAIN      ; Falso positivo, volver
    
    ; ===== EJECUTAR SECUENCIA COMPLETA BOTÓN 2 =====
    ; Enciende LED 1
    MOVLW   b'00000001'
    MOVWF   PORTB
    CALL    RETARDO_0_71S      ; 0.71 segundos
    
    ; Enciende LED 2
    MOVLW   b'00000011'
    MOVWF   PORTB
    CALL    RETARDO_0_71S      ; 0.71 segundos
    
    ; Enciende LED 3
    MOVLW   b'00000111'
    MOVWF   PORTB
    CALL    RETARDO_0_71S      ; 0.71 segundos
    
    ; Enciende LED 4 (todos encendidos)
    MOVLW   b'00001111'
    MOVWF   PORTB
    CALL    RETARDO_0_71S      ; 0.71 segundos
    
    ; Apaga LED1, LED2, LED3 y LED4
    CLRF    PORTB
    
    ; Esperar a que se SUELTE el botón antes de continuar
ESPERA_SUELTO_B2
    BTFSC   PORTA, BOTON2
    GOTO    ESPERA_SUELTO_B2
    
    CALL    RETARDO_1_42MS     ; Antirrebote al soltar
    
    GOTO    BUCLE_MAIN      ; Volver al bucle principal

; ============================================================
; FIN DEL PROGRAMA
; ============================================================
    END