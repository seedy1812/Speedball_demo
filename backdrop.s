set_layer3pal:
        ld b,32+16
set_pal:
        nextreg PAL_INDEX ,a
.loop:
        ld a,(hl)
        inc hl
        Nextreg PAL_VALUE_8BIT,a
        djnz .loop
        ret


MAP_X: dw 0
MAP_Y: dw 0

backdrop_start:

; set where the map should be , add logic to scoll map to this position

        ld de,0
        ld (MAP_X),de
        ld (MAP_Y),de

	nextreg TILE_TRANS_INDEX,15 ; set transparent colour for tilemap

        ; layer 3 pal 1 to edit
        nextreg PAL_CTRL,%00110000
        ld a,0
        ld hl,bg_pal
        call set_layer3pal


        ;On , 40x32, 16 bit values , pal0 , no text,0 , 512 tile ,on top of ula
        nextreg LAYER_3_CTRL,%10000011
        ; using inline attributes , clear default just for fun of it
        ;nextreg TILE_DEF_ATTR,%000000000


        ; point to the where map will be store
        ld a,HI(bg_map)
        nextreg LAYER3_MAP_HI,a

        ; now the tiles offset
        ld a, HI(bg_tiles)
        nextreg LAYER3_TILE_HI,a


        ; layer 3 pal 2 to edit
        nextreg PAL_CTRL,%01110000
        ld a,0
        ld hl,hud_pal
        call set_layer3pal

        call backdrop_copy

        ret

backdrop_flags: db 0


backdrop_copy:
        ld a,MMU_6
        call ReadNextReg
        push af
        nextreg MMU_6,MAP_PAGE

        ld a,MMU_7
        call ReadNextReg
        push af
        nextreg MMU_7,14
        
        
        ld de,(MAP_Y)
        ld b,3
        bsra de,b
        ld d,40*2
        mul

        ld hl,bg_map- $2000 ; start of MMU_6
        add hl,de

        ld de, $e000    ; start of MMU_7
        ld bc, 31*40*2  ; copy 31 lines - 32nd line is the hud
        call dma_copy

        ld hl,hud_map-$2000    
        ld de,31*40*2 +  $e000
        ld bc,48*2
        call dma_copy
      


        pop af
        nextreg MMU_7,a
        pop af
        nextreg MMU_6,a

        ret


backdrop_move
        ld hl,backdrop_flags

        bit 0,(hl)
        jr z,.otherway
        
        ld bc,(MAP_Y)
        ld a,b
        or c
        jr z, .go_down
        dec bc
        ld (MAP_Y),bc
        ret
.go_down:
        res 0,(hl)
        ret
.otherway:
        push hl
        ld bc,(MAP_Y)
        ld hl,MAP_HEIGHT-256+8
        or a
        sbc hl,bc
        ld a,h
        or l
        pop hl
        jr z,.go_up
        inc bc
        ld (MAP_Y),bc
        ret
.go_up:
        set 0,(hl)
        ret


backdrop_update:
        border 7
        ld bc,(MAP_X)
        ld a,b
        and 1
        nextreg LAYER3_SCROLL_X_MSB,a

        ld a, c
        nextreg LAYER3_SCROLL_X_LSB,a

        // set at top of the map - rember 8 pixel border at top
        ld a, (MAP_Y)
        and 7
        sub 8
        nextreg LAYER3_SCROLL_Y,a

        my_break
    ; point to the where map will be store
        ld a,HI(bg_map)
        nextreg LAYER3_MAP_HI,a

        ld a, HI(bg_tiles)
        nextreg LAYER3_TILE_HI,a

        call backdrop_copy

        call backdrop_move

        ret

        SEG MAP_SEG


bg_map: incbin "gfx/bg.nxm"
bg_map_length: equ *-bg_map
hud_map: incbin "gfx/hud.nxm"
hud_map_length: equ *-hud_map
        SEG TILES_SEG

bg_tiles: incbin "gfx/bg.nxt"
bg_tiles_length: equ *-bg_tiles
        align 256
hud_tiles: incbin "gfx/hud.nxt"
hud_tiles_length: equ *-hud_tiles

        SEG CODE_SEG

bg_pal: incbin "gfx/bg.nxp"
bg_pal_length: equ *-bg_pal
hud_pal:        incbin "gfx/hud.nxp"
hud_pal_length: equ *-hud_pal
                
