BasicUpstart2(main)

.const SCREEN_LOCATION = $0400
.const START_POSITION = SCREEN_LOCATION
.const STOP_POSITION = START_POSITION + 25 * 40
.const INVERT_VALUE = 128                       // MSB set

// Routine params //////////////////////////////////////////////////////////////

* = ($100 - 2) virtual

start_position_lo: .byte 0
start_position_hi: .byte 0

// Main ////////////////////////////////////////////////////////////////////////

* = $080d

// Works better if hooked to the interrupt, or at least with a delay.
//
main:
          lda #<START_POSITION
          sta start_position_lo
          lda #>START_POSITION
          sta start_position_hi

          jsr inverting_16b
          // jsr inverting_8b

          clc
          bcc main

// Routines ////////////////////////////////////////////////////////////////////

// Version supporting a 16-bit interval.
//
inverting_16b:
          ldx #0

invert_char:
          lda (start_position_lo, x) // load the char
          eor #INVERT_VALUE          // ^ invert it
          sta (start_position_lo, x) // ^ and store it

          inc start_position_lo      // 16-bit increment of the position
          bne !+
          inc start_position_hi

!:        lda start_position_hi      // 16-bit comparison of the end position
          cmp #>STOP_POSITION        // the MS byte is compared first, as it's less likely to change
          bne invert_char
          lda start_position_lo
          cmp #<STOP_POSITION
          bne invert_char

          rts

// Version limited to an 8-bit interval.
// If we change the loop to be decreasing, we spare the comparison.
//
inverting_8b:
          ldx #0
!:
          lda (start_position_lo, x)
          eor #INVERT_VALUE
          sta (start_position_lo, x)

          inx

          cpx #40                    // number of bytes to invert
          bne !-

          rts
