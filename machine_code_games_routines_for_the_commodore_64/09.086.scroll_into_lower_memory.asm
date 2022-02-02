BasicUpstart2(main)

.const SCREEN_LOCATION = $0400
.const START_POSITION = SCREEN_LOCATION
.const STOP_POSITION = SCREEN_LOCATION + 40 * 25 - 1 // see note below

// Routine variables ///////////////////////////////////////////////////////////

* = ($100 - 6) virtual

current_position_lo: .byte 0
current_position_hi: .byte 0

// Routine params //////////////////////////////////////////////////////////////

start_position_lo: .byte 0
start_position_hi: .byte 0
stop_position_lo:  .byte 0 // This is the last position copied lower
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

          jsr scroll_into_lower_memory

halt:
          clc
          bcc halt

// Routines ////////////////////////////////////////////////////////////////////

// This is similar to `continuous_scroll_256b_left`, with the differences:
//
// 1. in order to scroll more than 256 bytes, it increases the start position instead of the Y register
// 2. it doesn't wrap around, because there is no Y register wraparound

scroll_into_lower_memory:
          ldy #0

rotate_bytes_to_left:
          iny                         // read from the following position
          lda (start_position_lo), y
          dey                         // write to the current position
          sta (start_position_lo), y

          inc start_position_lo       // 16-bit increment
          bne !+                      // ^
          inc start_position_hi       // ^
!:
          lda start_position_lo       // 16-bit comparison with stop position
          cmp stop_position_lo
          bne rotate_bytes_to_left
          lda start_position_hi
          cmp stop_position_hi
          bne rotate_bytes_to_left

          rts
