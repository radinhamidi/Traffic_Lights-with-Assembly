;|**************************************|
;|									  	|
;|		       ..::/Rad!n\::..		  	|
;|		    	Final Project		  	|
;|		    	Spring 2016		    	|
;|									  	|
;|**************************************|	

	AREA	RESET, CODE
	
	ENTRY
	; disable watchdog timer
	LDR		R0, =0XFFFFFD44
	LDR		R1, =0X00008000
	STR		R1, [R0]
	
	; define base registers
	LDR		R1, =0XFFFFF400 ; GPIOA 
	LDR		R2, =0XFFFFFD20 ; Real Time Timer
	
	;initializing port A
	LDR		R0, =0X03F0FC3F
	STR		R0, [R1]

	;definition for Output
	LDR		R0, =0X7
	STR		R0, [R1, #0X10]

	;reset all output legs
	MVN		R0,#0X0
	STR		R0,[R1, #0X34]
		
	;start timer 1Hz
	LDR		R0,=0X48000
	STR		R0,[R2]
	LDR		R0,=0X8000
	STR		R0,[R2]
	
	;saving interval values into registers
	LDR		R10, =0XA ;Green light interval	  => 10s
	LDR		R9,  =0X1E ;Red light interval 	  => 30s

; Traffic Lights
Main	MVN		R4, #0X00		  ; clear output pins
		STR		R4, [R1, #0X34]
		LDR		R0, [R2, #0X8]  
Green	LDR		R4,	[R1, #0X3C]	  ; Reading input pins
		ANDS 	R5,	R4,#0X00000008; Masking to Check if PA3 status
		CMPEQ	R7,#0XFFFFFFFF
		LDREQ	R7, =0X0		  ; Clearing flag
		BEQ		imm_Y
		LDR		R3, [R2, #0X8]
		LDR		R4, =0X02		  ; turn Second bit on
		STR		R4, [R1, #0X30]   ; store it to SODR for setting this PIN
		LDR		R4,	[R1, #0X3C]	  ; Reading input pins
		ANDS 	R5,	R4,#0X00000020; Masking to Check if PA5 is High
		BNE		T_U				  ; Jumping to Interval Unpdating subroutine
G_res	AND 	R5,	R4,#0X00000018; Masking to Check if PA3 & PA4 status
		CMP		R5,	#0X00000018	  ; PA3 and PA4 rae High
		MVNEQ	R7, #0X0		  ; R7 would be set as flag 
		BEQ		imm_Y
		SUB		R3, R3, R10
		CMP		R3, R0
		BNE		Green
		MOV		R10, R11
		
imm_Y	MVN		R4, #0X00		  ; clear output pins
		STR		R4, [R1, #0X34]
		LDR		R0, [R2, #0X8]
Yellow	LDR		R4,	[R1, #0X3C]	  ; Reading input pins
		ANDS 	R5,	R4,#0X00000008; Masking to Check if PA3 status
		CMPEQ	R7,#0XFFFFFFFF
		LDREQ	R7, =0X0		  ; Clearing flag
		LDR		R3, [R2, #0X8]
		LDR		R4, =0X01		  ; turn First bit on
		STR		R4, [R1, #0X30]   ; store it to SODR for setting this PIN
		AND 	R5,	R4,#0X00000018; Masking to Check if PA3 & PA4 status
		CMP		R5,	#0X00000008	  ; PA3 is High and PA4 is Low
		MVNEQ	R7, #0X0		  ; R7 would be set as flag
		BEQ		Main
		SUB		R3, R3, #0X3
		CMP		R3, R0
		BNE		Yellow
	 	
		MVN		R4, #0X00		  ; clear output pins
		STR		R4, [R1, #0X34]
		LDR		R0, [R2, #0X8]
Red		LDR		R4,	[R1, #0X3C]	  ; Reading input pins
		ANDS 	R5,	R4,#0X00000008; Masking to Check if PA3 status
		CMPEQ	R7,#0XFFFFFFFF
		LDREQ	R7, =0X0		  ; Clearing flag
		LDREQ	R0, [R2, #0X8]	  ; Reseting timer
		LDR		R3, [R2, #0X8]
		LDR		R4, =0X04		  ; turn Third bit on
		STR		R4, [R1, #0X30]	  ; store it to SODR for setting this PIN
		AND 	R5,	R4,#0X00000018; Masking to Check if PA3 & PA4 status
		CMP		R5,	#0X00000008	  ; PA3 is High and PA4 is Low
		MVNEQ	R7, #0X0		  ; R7 would be set as flag
		BEQ		Main
		SUB		R3, R3, R9
		CMP		R3, R0
		BNE		Red
		
		B		Main

;Intervals updating subroutine
T_U		ANDS	R5, R4, #0X0000FC00 ; PA10-PA15 Mask
		MOV		R11, R5, LSR #9	    ; needed 10 lsr to reach the LSB but with considering the 2s multiplying then it would be 9lsr
		CMP		R11, #0X6			; checking to make sure value is greater than 6s
		MOVLS	R11, #0X6
		ANDS	R5, R4, #0X03F00000 ; PA20-PA25 Mask
		MOV		R9, R5, LSR #19	    ; needed 20 lsr to reach the LSB but with considering the 2s multiplying then it would be 19lsr
		CMP		R9, #0X6			; checking to make sure value is greater than 6s
		MOVLS	R9, #0X6
		B		G_res
		
		END
	 