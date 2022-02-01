BasicUpstart2(main)

.const BOMB_CHAR = $2a  // `*` symbol
.const BLANK_CHAR = $20 // space
.const LINES_COUNT = 25
.const LINE_SIZE = 40
// Start from the end of the beforelast line ($07bf); the update routine processes the screen backwards.
.const START_LOCATION = $0400 + (LINES_COUNT - 1) * LINE_SIZE - 1

// Routine variables ///////////////////////////////////////////////////////////

* = ($100 - 2) virtual

current_location_lo: .byte $FF
current_location_hi: .byte $FF

// Main variables //////////////////////////////////////////////////////////////

total_screen_updates: .byte LINES_COUNT - 1

// Main ////////////////////////////////////////////////////////////////////////

* = $080d

main:
          jsr update_bomb

          ldx total_screen_updates
          dex
          bne main

halt:
          clc
          bcc halt

// Routines ////////////////////////////////////////////////////////////////////

update_bomb:
set_start_location:
          lda #<START_LOCATION
          sta current_location_lo
          lda #>START_LOCATION
          sta current_location_hi

          ldy #0

handle_current_position:
          lda (current_location_lo), y // Copy the character at position
          cmp #BOMB_CHAR               // Bomb?
          bne move_to_next_position

          ldy #LINE_SIZE               // Move down one line
          sta (current_location_lo), y // Copy to the position below

          ldy #0                       // Move to the original position
          lda #BLANK_CHAR
          sta (current_location_lo), y // Overwrite!

move_to_next_position:
          lda current_location_lo      // Move to previous screen location, via standard 16 bit decrement.
          sec
          sbc #1
          sta current_location_lo
          lda current_location_hi
          sbc #0
          sta current_location_hi

          cmp #3                       // Out of screen ($03xx)?
          bne handle_current_position

          rts
