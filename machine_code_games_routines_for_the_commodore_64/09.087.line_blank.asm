BasicUpstart2(main)

.const SCREEN_LOCATION = $0400
.const START_POSITION = SCREEN_LOCATION + 1
.const STOP_POSITION = START_POSITION + 25 * 40 // see note below
.const BLANK_CHAR = $20                         // space

// Routine variables ///////////////////////////////////////////////////////////

* = ($100 - 6) virtual

current_position_lo: .byte 0
current_position_hi: .byte 0

// Routine params //////////////////////////////////////////////////////////////

start_position_lo: .byte 0
start_position_hi: .byte 0
stop_position_lo:  .byte 0 // Must = start_position + 40 * lines
stop_position_hi:  .byte 0

// Main ////////////////////////////////////////////////////////////////////////

* = $080d

main:
          lda #<START_POSITION
          sta start_position_lo
          lda #>START_POSITION
          sta start_position_hi
          lda #<STOP_POSITION
          sta stop_position_lo
          lda #>STOP_POSITION
          sta stop_position_hi

          jsr line_blank

halt:
          clc
          bcc halt

// Routines ////////////////////////////////////////////////////////////////////

// The routine blanks a *vertical* line.

line_blank:
          lda start_position_lo
          sta current_position_lo
          lda start_position_hi
          sta current_position_hi

          ldy #0
blank_cycle:
          lda #BLANK_CHAR              // blank the current position
          sta (current_position_lo), y // ^

          clc                          // 16-bit addition of 40 (go to the position below)
          lda current_position_lo      // ^
          adc #40                      // ^
          sta current_position_lo      // ^
          lda current_position_hi      // ^
          adc #0                       // ^
          sta current_position_hi      // ^

          lda current_position_lo      // 16-bit comparison with the end position
          cmp stop_position_lo         // ^
          bne blank_cycle              // ^
          lda current_position_hi      // ^
          cmp stop_position_hi         // ^
          bne blank_cycle

          rts
