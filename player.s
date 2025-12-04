
LAYER_2_Y_OFFSET 	 	equ $17
LAYER2_CLIP_WINDOW   	equ $18
LINE_INT_LSB		 	equ $23
SPRITE_NUMBER		 	equ $34
PAL_INDEX            	equ $40
PAL_VALUE_8BIT       	equ $41
PAL_CTRL			 	equ $43
LAYER_3_CTRL		 	equ $6b


DMA_LOAD             	equ $cf ; %11001111
DMA_DISABLE          	equ $83
DMA_ENABLE           	equ $87
SPRITE_IMAGE_PORT    	equ $5b

COPPER_DATA				equ $60
COPPER_ADDR_LSB			equ $61
COPPER_CTRL				equ $62

TILE_TRANS_INDEX: 	 	equ $4c
TILE_DEF_ATTR		 	equ $6c
LAYER3_MAP_HI		 	equ $6e
LAYER3_TILE_HI		 	equ $6f
LAYER3_SCROLL_X_MSB	 	equ $2f
LAYER3_SCROLL_X_LSB	 	equ $30
LAYER3_SCROLL_Y		 	equ $31

MMU_0					equ $50
MMU_1					equ $51
MMU_2					equ $52
MMU_3					equ $53
MMU_4					equ $54
MMU_5					equ $55
MMU_6					equ $56
MMU_7					equ $57


SPRITE_STATUS_SLOT_SELECT      	equ $303B
LAYER2_OUT			 			equ $123B
NEXTREG_OUT			 			equ $243b
NEXTREG_DATA 					equ $253b
DMA_PORT    	     			equ $6b ;//: zxnDMA


border macro
;           ld a,\0
;           out ($fe),a
        endm

MY_BREAK	macro
        db $fd,00
		endm


	OPT Z80
	OPT ZXNEXTREG    

	CODE_PAGE equ 2*2

	MAP_PAGE equ 9*2

	TILES_PAGE equ 5*2

	SPRITES_PAGE equ 12*2

    seg     CODE_SEG, 			 	CODE_PAGE:$0000,$8000

	seg 	MAP_SEG,				MAP_PAGE:$0000,$e000
	seg 	TILES_SEG,				TILES_PAGE:$0000,$4000

	seg		SPRITES_SEG,			SPRITES_PAGE:$0000,$e000




    seg     CODE_SEG
start:
	ld sp , StackStart

	call backdrop_start
	call dma_init
	call hud_start

	call video_setup

	call init_vbl

	ld a, 6
	call ReadNextReg
	and %01011111 
	Nextreg 6,a

	nextreg 7,%11 ; 28mhz

frame_loop:
	call do_me
	call backdrop_update

	call hud_update


	call wait_vbl
	call swap_frames

	jp frame_loop

StackEnd:
	ds	128*3
StackStart:
	ds  2

include "dma.s"
include "irq.s"
include "hud.s"

include "video.s"

include "backdrop.s"

THE_END:

 	savenex "speedball.nex",start

