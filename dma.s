MAP_HEIGHT equ 592
MAP_HALF equ MAP_HEIGHT/2

NUM_ITEMS equ 10

;d =  frame
dma_sprite:
        bit 0,(IX+SPRITE_FLAGS)
        ret nz
        set 0,(IX+SPRITE_FLAGS)

        ld d,(ix+SPRITE_FRAME)
        ld a,d
        and ~63
        rlc a
        rlc a
        add BANK(spr0)
        nextreg MMU_7,a

        res 7,d
        res 6,d

        rlc d
        rlc d
        ld e,128
        mul

        ld a,(IX+SPRITE_SLOT)
        rrc a
        ld   bc,4*128                     ; number to transfer (1)
        ld   hl,spr0               ; from 
        add   hl,de
        call TransferDMASprite            ; transfer to sprite ram
        ret

TransferDMASprite
        di
        ld (DMASourceSprite),hl
        ld (DMALengthSprite),bc
        ld   bc,SPRITE_STATUS_SLOT_SELECT
        out  (c),a                        ; set the sprite image number
        ld hl,DMACodeSprite
        ld bc,DMACode_LenSprite*256+DMA_PORT
        otir
        ei
        ret

DMA_Copy
        di
        ld (DMACopySource),hl
        ld (DMACopyLength),bc
        ld (DMACopyDestination),de
        ld   bc,SPRITE_STATUS_SLOT_SELECT
        out  (c),a                        ; set the sprite image number
        ld hl,DMACode_Copy
        ld bc,DMACode_Copy_Len*256+DMA_PORT
        otir
        ei
        ret

setPlayerPal:
        ; sprite pal 1 to edit
        nextreg PAL_CTRL,%00100001
        ld a,0  ; first entry
        ld b,32 ; 2 16 colour banks
        ld hl,spr1_pal
        call set_pal
        nextreg $4B,0
        ret


DMACodeSprite:
        db DMA_DISABLE
        db %01111101                   ; R0-Transfer mode, A -> B, write adress 
                                       ; + block length
DMASourceSprite:
        dw 0                           ; R0-Port A, Start address (source address)
DMALengthSprite:
        dw 0                           ; R0-Block length (length in bytes)
        db %01010100                   ; R1-read A time byte, increment, to 
                                       ; memory, bitmask
        db %00000010                   ; R1-Cycle length port A
        db %01101000                   ; R2-write B time byte, increment, to 
                                       ; memory, bitmask
        db %00000010                   ; R2-Cycle length port B
        db %10101101                   ; R4-Continuous mode (use this for block
                                       ; transfer), write dest adress
        dw SPRITE_IMAGE_PORT           ; R4-Dest address (destination address)
        db %10000010                   ; R5-Restart on end of block, RDY active
                                       ; LOW
        db DMA_LOAD                    ; R6-Load
        db DMA_ENABLE                  ; R6-Enable DMA
DMACode_LenSprite                   equ *-DMACodeSprite

DMACode_Copy:
	db $83
	db  %01111101                           ; R0-Transfer mode, A -> B
DMACopySource:
	dw  $4000                 		; R0-Port A, Start address (source)
DMACopyLength:
	dw  $4000                               ; R0-Block length

	db  %00010100                           ; R1 - A fixed memory
	db  %00010000                           ; R2 - B incrementing memory

	db      %10101101                 ; R4-Continuous
DMACopyDestination:
	dw      $0000                     ; R4-Block Address

	db      $cf                                                     ; R6 - Load
	db      $87                                                     ; R6 - enable DMA;
DMACode_Copy_Len                   equ *-DMACode_Copy


        SEG SPRITES_SEG
spr0: 
        incbin "gfx/anim1.spr"

        SEG CODE_SEG
spr1_pal: incbin "gfx/anim1.nxp"
spr2_pal: incbin "gfx/anim1.nxp"


rsm macro
\0:     equ RS
        RSSET(\0+\1)
        endm

	RSRESET
rsm SPRITE_X,2
rsm SPRITE_Y,2
rsm SPRITE_FRAME,1
rsm SPRITE_PAL,1
rsm SPRITE_SLOT,1
rsm SPRITE_ANIM,2
rsm SPRITE_ANIM_TIMER,1
rsm SPRITE_FLAGS,1
rsm SPRITE_SIZE,0

                RSRESET
rsm ANIM_SPEED,1
rsm ANIM_LAST_FRAME,1
rsm ANIM_FIRST_FRAME,1
rsm ANIM_SIZE,0


MAX_SPRITES             equ 10

sprites: 

        dw 160-16,MAP_HALF-10-20*2-32
        db 0,0
        db 0*4
        dw anim_1
        db 1
        db 0    // dma not uploaded

        dw 160-16+50,MAP_HALF-10-20*1-32
        db 1,0
        db 1*4
        dw anim_1
        db 2
        db 0    // dma not uploaded

        dw 160-16-50,MAP_HALF-10-20*1-32
        db 2,0
        db 2*4
        dw anim_1
        db 3
        db 0    // dma not uploaded

        dw 160-16+50*2,MAP_HALF-10-20*0-32
        db 3,0
        db 3*4
        dw anim_1
        db 4
        db 0    // dma not uploaded

        dw 160-16-50*2,MAP_HALF-10-20*0-32
        db 4,0
        db 4*4
        dw anim_1
        db 5
        db 0    // dma not uploaded


        dw 160-16,MAP_HALF+10+20*2
        db 5,1
        db 5*4
        dw anim_1
        db 6
        db 0    // dma not uploaded

        dw 160-16+50,MAP_HALF+10+20*1
        db 6,1
        db 6*4
        dw anim_1
        db 7
        db 0    // dma not uploaded

        dw 160-16-50,MAP_HALF+10+20*1
        db 7,1
        db 7*4
        dw anim_1
        db 7
        db 0    // dma not uploaded

        dw 160-16+50*2,MAP_HALF+10+20*0
        db 0,1
        db 8*4
        dw anim_1
        db 8
        db 0    // dma not uploaded

        dw 160-16-50*2,MAP_HALF+10+20*0
        db 1,1
        db 9*4
        dw anim_1
        db 9
        db 0    // dma not uploaded

        ds (MAX_SPRITES*SPRITE_SIZE) - (*-sprites)



anim_1  db 6,7,0


animate_sprite:
        dec (IX+SPRITE_ANIM_TIMER)
        ret nz
        ; addr of anim data
        ld h,(IX+SPRITE_ANIM+1)
        ld l,(IX+SPRITE_ANIM+0)

        push hl
        pop iy
        ; reset the timer
        ld a,(iy+ANIM_SPEED)
        ld (IX+SPRITE_ANIM_TIMER),a

        res 0,(IX+SPRITE_FLAGS)

        ld a,(IX+SPRITE_FRAME)
        cp (IY+ANIM_LAST_FRAME)
        jr nz, .no_loop

        ld a,(IY+ANIM_FIRST_FRAME)
        ld(IX+SPRITE_FRAME),a
        ret
        
.no_loop:
        inc  (IX+SPRITE_FRAME)
        ret



dma_init:
        call setPlayerPal
        call init_me
        nextreg $09,%00010000 
        ret

do_me:
 
        ld a,MMU_7
        call ReadNextReg
        push af
        nextreg MMU_7,14
   
        ld a, 0
        call start_sprite

        ld a, 0
        ld ix,sprites
        ld b, NUM_ITEMS
.dma_loop:
        push af
        push bc
        call animate_sprite
       	call dma_sprite
        pop bc
        pop af

        add 4
        ld de,SPRITE_SIZE
        add ix, de
        djnz .dma_loop

        pop af
        nextreg MMU_7,a

        ld a, 0
        call start_sprite

        ld c,$57
        ld ix,sprites
        ld b, NUM_ITEMS
.spr_loop
        push bc
        call draw_2x2sprite
        pop bc
        ld de,SPRITE_SIZE
        add ix, de
        djnz .spr_loop


        ret

init_me:

        ret


start_sprite:
        nextreg SPRITE_NUMBER,a
        ld bc,SPRITE_STATUS_SLOT_SELECT 
        out(c),a

        ret

draw_2x2sprite:
;;; TL
        ld h,(ix+SPRITE_X+1)
        ld l,(ix+SPRITE_X)
        ld de,(MAP_X)
        xor a
        sbc hl,de

        ld a,l
        nextreg $35,a

        ld a,(ix+SPRITE_PAL)
        and $0f
        swapnib
        ld b,a
        ld a,1
        and h
        or b
        nextreg $37,a

        ld h,(ix+SPRITE_Y+1)
        ld l,(ix+SPRITE_Y)
        ld de,(MAP_Y)
        xor a
        sbc hl,de
        ld a,l
        nextreg $36,a

        ld a,(ix+SPRITE_SLOT)
        rrc a
        ld l,a
        or %11000000
        nextreg $38,a

        ld a,l
        and %01000000
        or  %10000000
        ld l,a
        ld a,1
        and h
        or l
        nextreg $79,a
;TR
        nextreg $35,16
        nextreg $36,0
        nextreg $37,1
        nextreg $38,%11000000
        nextreg $79,%01100001
;BL
        nextreg $35,0
        nextreg $36,16
        nextreg $37,1
        nextreg $38,%11000001
        nextreg $79,%01000001

;BR
        nextreg $35,16
        nextreg $36,16
        nextreg $37,1
        nextreg $38,%11000001
        nextreg $79,%01100001

        ret
