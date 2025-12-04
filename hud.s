COPPER_WAIT	macro
		db	HI($8000+(\0&$1ff)+(( (\1/8) &$3f)<<9))
		db	LO($8000+(\0&$1ff)+(( ((\1/8) >>3) &$3f)<<9))
		endm
		// copper MOVE reg,val
COPPER_MOVE		macro
		db	HI($0000+((\0&$ff)<<8)+(\1&$ff))
		db	LO($0000+((\0&$ff)<<8)+(\1&$ff))
		endm

COPPER_NOP	macro
		db	0,0
		endm

COPPER_HALT     macro
                db 255,255
                endm


          seg     CODE_SEG          

hud_copper:
        COPPER_WAIT 215,320
        COPPER_MOVE LAYER3_SCROLL_X_MSB,0
        COPPER_MOVE LAYER3_SCROLL_X_LSB,0

        COPPER_MOVE LAYER3_SCROLL_Y,0

        COPPER_MOVE LAYER3_TILE_HI,HI(hud_tiles)
        COPPER_HALT
hud_copper_len: equ *-hud_copper


hud_start:

	nextreg COPPER_ADDR_LSB,0   ; LSB = 0
	nextreg COPPER_CTRL,0   ;// copper stop | MSBs = 00

        ld hl,hud_copper
        ld bc,hud_copper_len

        call DMA_Copper
        nextreg COPPER_CTRL,%01000000 ;// copper start | MSBs = 00
        ret

hud_update:
        nextreg COPPER_CTRL,%00000000 ;// copper start | MSBs = 00
        nextreg COPPER_CTRL,%01000000 ;// copper start | MSBs = 00
        ret


DMA_Copper
        di
        ld a, COPPER_DATA
        call ReadNextreg
        ld (DMASourceCopper),hl
        ld (DMALengthCopper),bc
        ld hl,DMACodeCopper
        ld bc,DMACode_LenCopper* 256 + DMA_PORT
        otir
        ei

        ret



DMACodeCopper:
        db DMA_DISABLE
        db %01111101                   ; R0-Transfer mode, A -> B, write adress 
                                       ; + block length
DMASourceCopper:
        dw 0                           ; R0-Port A, Start address (source address)
DMALengthCopper:
        dw 0                           ; R0-Block length (length in bytes)
        db %01010100                   ; R1-read A time byte, increment, to 
                                       ; memory, bitmask
        db %00000010                   ; R1-Cycle length port A
        db %01101000                   ; R2-write B time byte, increment, to 
                                       ; memory, bitmask
        db %00000010                   ; R2-Cycle length port B
        db %10101101                   ; R4-Continuous mode (use this for block
                                       ; transfer), write dest adress
        dw NEXTREG_DATA                ; R4-Dest address (destination address)
        db %10000010                   ; R5-Restart on end of block, RDY active
                                       ; LOW
        db DMA_LOAD                    ; R6-Load
        db DMA_ENABLE                  ; R6-Enable DMA
DMACode_LenCopper                   equ *-DMACodeCopper


