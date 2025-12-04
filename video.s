    seg     CODE_SEG



video_setup:
;      nextreg $68,%10000000   ;ula disable
       nextreg $15,%00100111 ; no low rez , LSU , no sprites , no over border

	nextreg $1c,%00001111	; reset all clipping

;       layer 3 clipping
	nextreg $1b,0
	nextreg $1b,+(320-1)/2
	nextreg $1b,8
	nextreg $1b,256-1

;       sprite 3 clipping

	nextreg $19,0
	nextreg $19,+(320-1)/2
	nextreg $19,8
	nextreg $19,256-1-8

       ret

 ReadNextReg:
       push bc
       ld bc,NEXTREG_OUT
       out (c),a
       inc b
       in a,(c)
       pop bc
       ret

swap_frames:
              ld a,$13
              call ReadNextReg
              push af
              ld a,$12
              call ReadNextReg
              nextreg $13,a
              pop af
              nextreg $12,a
              ret




