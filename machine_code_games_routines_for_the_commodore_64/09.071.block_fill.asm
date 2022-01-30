BasicUpstart2(main)

// Constants ///////////////////////////////////////////////////////////////////

.const SCREEN_LOCATION = $0400
.const SCREEN_WIDTH    = 40
.const SCREEN_HEIGHT   = 25

.const FILL_START      = SCREEN_LOCATION
.const FILL_END        = FILL_START + SCREEN_WIDTH * SCREEN_HEIGHT
.const START_FILL_CODE = 0

// Routine variables ///////////////////////////////////////////////////////////

* = ($100 - 4) virtual

fill_start_lo: .byte 0
fill_start_hi: .byte 0
fill_end_lo:   .byte 0 // the fill_end address is not included in the copy
fill_end_hi:   .byte 0 // ^^

// Main ////////////////////////////////////////////////////////////////////////

* = $080e

main:
          lda #<FILL_END
          sta fill_end_lo
          lda #>FILL_END
          sta fill_end_hi
          ldx #START_FILL_CODE

!fill_loop:
          lda #<FILL_START
          sta fill_start_lo
          lda #>FILL_START
          sta fill_start_hi

          jsr block_fill

          inx

          clc
          bcc !fill_loop-

// Routine /////////////////////////////////////////////////////////////////////

block_fill:

          ldy #0                 // 16-bit indirect is only supported by JMP, so we need to work this
                                 // around...
!fill_loop:
          txa
          sta (fill_start_lo), y // ...and use the indirect indexed mode
          inc fill_start_lo      // 16-bit increase fill_start
          bne check_end          // ^
          inc fill_start_hi      // ^
check_end:
          lda fill_start_lo      // 16-bit comparison fill_start <> fill_end
          cmp fill_end_lo        // ^
          bne !fill_loop-        // ^
          lda fill_start_hi      // ^
          cmp fill_end_hi        // ^
          bne !fill_loop-        // ^

          rts
