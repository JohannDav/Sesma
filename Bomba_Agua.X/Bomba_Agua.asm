;Quirino Gonzalez Johann David
; HEADER para el PIC16F628A, usando el oscilador RC interno a 4MHz.

#include <p16f628a.inc>

;*********************************************************
; EQUATES SECTION - Definición de registros importantes
PORTA         EQU 0x05      ; Dirección del registro de datos PORTA
PORTB         EQU 0x06      ; Dirección del registro de datos PORTB
TRISA         EQU 0x85      ; Dirección del registro de dirección de datos PORTA
TRISB         EQU 0x86      ; Dirección del registro de dirección de datos PORTB
STATUS        EQU 0x03      ; Registro de estado del PIC
CMCON         EQU 0x1F      ; Registro de control del comparador
COUNT1        EQU 0x20      ; Variable para contador 1 (retardos)
COUNT2        EQU 0x21      ; Variable para contador 2 (retardos)
COUNT3        EQU 0x22      ; Variable para contador 3 (retardos)

;*********************************************************
; DIRECTIVAS DEL ENSAMBLADOR
    LIST      P=16F628A     ; Especificar el modelo de PIC
    ORG       0x0000        ; Establecer el origen en la dirección 0
    GOTO      START         ; Saltar al inicio del programa

;*********************************************************
; BITS DE CONFIGURACION
    __CONFIG _INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_ON & _LVP_OFF & _MCLRE_OFF & _BOREN_OFF & _CP_OFF & _CPD_OFF
    ; Configuración: Oscilador interno, WDT off, Power-up Timer on, 
    ; Low Voltage Programming off, MCLR off, Brown-out Reset off, 
    ; Code Protection off, Data Code Protection off

;*********************************************************
; SUBRUTINAS DE RETARDO

; Retardo de 0.1 SEGUNDOS (100ms para 4MHz) para anti-rebote
DELAY_0_1
    MOVLW   D'1'           ; Cargar 1 en W (para el contador externo)
    MOVWF   COUNT3         ; Mover W a COUNT3 (contador de bucles externos)
DELAY_0_1_OUTER
    MOVLW   D'255'         ; Cargar 255 en W  
    MOVWF   COUNT2         ; Mover W a COUNT2 (contador de bucles medios)
DELAY_0_1_MID
    MOVLW   D'165'         ; Cargar 165 en W
    MOVWF   COUNT1         ; Mover W a COUNT1 (contador de bucles internos)
DELAY_0_1_INNER
    DECFSZ  COUNT1, F      ; Decrementar COUNT1, saltar si es cero
    GOTO    DELAY_0_1_INNER ; Repetir bucle interno
    DECFSZ  COUNT2, F      ; Decrementar COUNT2, saltar si es cero
    GOTO    DELAY_0_1_MID  ; Repetir bucle medio
    DECFSZ  COUNT3, F      ; Decrementar COUNT3, saltar si es cero
    GOTO    DELAY_0_1_OUTER ; Repetir bucle externo
    RETURN                 ; Retornar de la subrutina

;*********************************************************
; SECCION DE CONFIGURACION INICIAL
START
    BSF     STATUS, RP0     ; Cambiar al Banco 1 de memoria
    MOVLW   B'00001100'     ; Configurar RA2 y RA3 como entradas, otros como salidas
    ; Bit: 7     6     5     4     3     2     1     0
    ;     RA7   RA6   RA5   RA4   RA3   RA2   RA1   RA0
    ;      0     0     0     0     1     1     0     0
    ;      ?     ?     ?     ?     ?     ?     ?     ?
    ;     Sal  Sal  Sal  Sal  Ent  Ent  Sal  Sal
    MOVWF   TRISA           ; Cargar configuración en TRISA
    
    MOVLW   B'00000000'     ; Configurar todos los pines de PORTB como salidas  
    MOVWF   TRISB           ; Cargar configuración en TRISB
    BCF     STATUS, RP0     ; Regresar al Banco 0 de memoria
    
    MOVLW   0x07            ; Cargar valor 7 en W
    MOVWF   CMCON           ; Deshabilitar comparadores para usar PORTA como E/S digital
    
    CLRF    PORTA           ; Limpiar PORTA (poner todos los pines en 0)
    CLRF    PORTB           ; Limpiar PORTB (poner todos los pines en 0)

;*********************************************************
; PROGRAMA PRINCIPAL - DETECTAR CONDICIÓN A2=1 Y A3=1
BEGIN
    ; =====================================================
    ; LEER ESTADO DE LOS PUERTOS A2 Y A3
    ; =====================================================
    MOVF    PORTA, W        ; Leer todo el registro PORTA y guardar en W
    ANDLW   B'00001100'     ; Aplicar máscara para mantener solo los bits A2 y A3
    ; Resultado en W después de AND:
    ; - Si A3=1 y A2=1 ? W = 00001100 = 0x0C
    ; - Si A3=1 y A2=0 ? W = 00001000 = 0x08  
    ; - Si A3=0 y A2=1 ? W = 00000100 = 0x04
    ; - Si A3=0 y A2=0 ? W = 00000000 = 0x00
    
    ; =====================================================
    ; COMPARAR SI AMBOS BITS SON 1 (A2=1 Y A3=1)
    ; =====================================================
    XORLW   B'00001100'     ; Hacer XOR con el patrón deseado (A3=1, A2=1)
    ; El XOR produce 0 solo cuando ambos patrones son iguales
    ; Si W era 0x0C (A3=1 y A2=1) ? XOR 0x0C = 0x00
    ; Si W era cualquier otro valor ? XOR 0x0C ? 0x00
    
    BTFSS   STATUS, Z       ; Verificar el bit Zero en STATUS, saltar si es 1 (resultado fue 0)
    GOTO    CONDITION_FALSE ; Si Z=0 (resultado ? 0), la condición es FALSA
    
    ; =====================================================
    ; CONDICIÓN VERDADERA: A2=1 Y A3=1
    ; =====================================================
CONDITION_TRUE
    BSF     PORTB, 3        ; Poner RB3 en 1 (encender salida)
    GOTO    DELAY_AND_LOOP  ; Ir al retardo y continuar
    
    ; =====================================================
    ; CONDICIÓN FALSA: NO SE CUMPLE A2=1 Y A3=1
    ; =====================================================
CONDITION_FALSE
    BCF     PORTB, 3        ; Poner RB3 en 0 (apagar salida)

    ; =====================================================
    ; RETARDO PARA ESTABILIZACIÓN Y EVITAR REBOTES
    ; =====================================================
DELAY_AND_LOOP
    CALL    DELAY_0_1       ; Llamar retardo de 0.1 segundos para estabilizar
    
    GOTO    BEGIN           ; Volver al inicio para verificación continua
    
    END                    ; Fin del programa


