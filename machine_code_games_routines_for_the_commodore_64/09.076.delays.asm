BasicUpstart2(main)

// Routine params //////////////////////////////////////////////////////////////

* = ($100 - 2) virtual

p_delay_count_lo: .byte $FF
p_delay_count_hi: .byte $FF

// Main variables //////////////////////////////////////////////////////////////

* = $080d

v_delay_count_lo: .byte $FF
v_delay_count_hi: .byte $FF

// Main ////////////////////////////////////////////////////////////////////////

main:
          lda v_delay_count_lo
          sta p_delay_count_lo
          lda v_delay_count_hi
          sta p_delay_count_hi

          jsr delay_16_bit_direct

          ldx p_delay_count_lo

          jsr delay_8_bit

          ldy #0                     // optional (not present in the original) - makes the count exact
          ldx p_delay_count_hi
          jsr delay_16_bit_multiples

          clc
          bcc main

// Routines ////////////////////////////////////////////////////////////////////

// A very direct 16 bit decrease and comparison.
//
delay_16_bit_direct:
!loop:
          lda p_delay_count_lo  // 16-bit decrease
          sec                   // ^
          sbc #1                // ^
          sta p_delay_count_lo  // ^
          lda p_delay_count_hi  // ^
          sbc #0                // ^
          sta p_delay_count_hi  // ^

          lda p_delay_count_lo  // 16-bit comparison (against 0)
          cmp #0                // ^
          bne !loop-            // ^
          lda p_delay_count_hi  // ^
          cmp #0                // ^
          bne !loop-            // ^

          rts

// An 8-bit decrease loop.
//
delay_8_bit:
!loop:
          dex
          bne !loop-
          rts

// A 16 bits loop that works on multiples of 256.
//
delay_16_bit_multiples:
!loop:
          dey
          bne !loop-
          dex
          bne !loop-
          rts
