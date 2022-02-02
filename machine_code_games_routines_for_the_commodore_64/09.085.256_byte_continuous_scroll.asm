BasicUpstart2(main)

.const SCREEN_LOCATION = $0400

// Routine params //////////////////////////////////////////////////////////////

* = ($100 - 2) virtual

start_position_lo: .byte 0
start_position_hi: .byte 0

// Main ////////////////////////////////////////////////////////////////////////

* = $080d

main:
          lda #<SCREEN_LOCATION
          sta start_position_lo
          lda #>SCREEN_LOCATION
          sta start_position_hi

          jsr continuous_scroll_256b_left
          // jsr continuous_scroll_256b_right

          clc
          bcc main

// Routines ////////////////////////////////////////////////////////////////////

// Note that this logic loses one character in both cases; on the very first iteration, the byte at
// start_position is overwritten with the subsequent; for a similar reason, the scrolled text will have
// a duplicated character.
// This is likely an intended strategy to keep the routine as simple as possible.
//
// The original code uses the X register as offset, which is the wrong indexing mode.

continuous_scroll_256b_left:
          ldy #0

rotate_bytes_to_left:
          iny                         // read from the following position
          lda (start_position_lo), y
          dey                         // write to the current position
          sta (start_position_lo), y
          iny                         // advance!
          bne rotate_bytes_to_left

          rts

continuous_scroll_256b_right:
          ldy #0

rotate_bytes_to_right:
          dey                         // read from the previous position
          lda (start_position_lo), y
          iny                         // write to the current position
          sta (start_position_lo), y
          dey                         // advance (backwards)!
          bne rotate_bytes_to_right

          rts
