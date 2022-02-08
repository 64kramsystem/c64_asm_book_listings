BasicUpstart2(main)

.const SCREEN_LOCATION = $0400
.const START_POSITION = SCREEN_LOCATION - 1     // WATCH OUT THE -1!
.const SCREEN_LINES = 25
.const SCREEN_COLUMNS = 40
.const INVERT_VALUE = 128                       // MSB set
.const WAIT_COUNT = 60

// Use in invert_table.
//
.const INV = 255
.const NOINV = 0

// Routine variables ///////////////////////////////////////////////////////////

* = ($100 - 3) virtual

current_position_lo: .byte 0
current_position_hi: .byte 0
counter:             .byte 0

// Main ////////////////////////////////////////////////////////////////////////

* = $080d

invert_table:
              .byte NOINV, NOINV, NOINV, NOINV, NOINV
              .byte NOINV, NOINV, NOINV, NOINV, NOINV
              .byte NOINV, NOINV, NOINV, NOINV, NOINV
              .byte NOINV, NOINV, NOINV, NOINV, NOINV
              .byte INV, INV, INV, INV, INV

// Works better if hooked to the interrupt.
//
main:
          lda #WAIT_COUNT
          sta counter

!:
          jsr attribute_flasher

          clc
          bcc !-

// Routines ////////////////////////////////////////////////////////////////////

// X holds the line counter
// Y holds the column counter
//
attribute_flasher:
          dec counter
          bne return
          lda #WAIT_COUNT

          lda #<START_POSITION
          sta current_position_lo
          lda #>START_POSITION
          sta current_position_hi

          ldx #SCREEN_LINES

test_invert_line:
          ldy #SCREEN_COLUMNS
          lda invert_table - 1, x          // x is in [1, SCREEN_LINES]
          cmp #INV
          bne increment_line

invert_line:
          lda (current_position_lo), y
          eor #INVERT_VALUE
          sta (current_position_lo), y
          dey
          bne invert_line

increment_line:
          clc
          lda current_position_lo
          adc #SCREEN_COLUMNS
          sta current_position_lo
          lda current_position_hi
          adc #0
          sta current_position_hi

          dex
          bne test_invert_line

return:
          rts
