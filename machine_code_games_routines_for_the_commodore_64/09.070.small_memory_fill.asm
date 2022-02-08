BasicUpstart2(main)

// Constants ///////////////////////////////////////////////////////////////////

.const SCREEN_LOCATION = $0400
.const SCREEN_WIDTH    = 40

.const START_ADDR = SCREEN_LOCATION
.const FILL_COUNT = SCREEN_WIDTH * 6

// Routine params //////////////////////////////////////////////////////////////

* = ($100 - 1) virtual

fill_count: .byte 0

// Main ////////////////////////////////////////////////////////////////////////

* = $080e

main:
          lda #0                  // start filling with 0

!loop:
          ldx #FILL_COUNT
          jsr small_mem_fill

          clc
          adc #1

          clc
          bcc !loop-

// Routine /////////////////////////////////////////////////////////////////////

// Note that this routine does not support filling with a zero count (see below).
//
small_mem_fill:

!loop:
          sta START_ADDR - 1, x
          dex
          bne !loop-

          rts

// This version of the routine supports a zero count:

small_mem_fill_supports_zero:
          ldx #1
          beq exit              // In x86, typically this would be a jump; here, we take advantage of
                                // the fact that ldx affects the zero flag, and fall through if X is 0!
!loop:
          sta START_ADDR - 1, x
          dex
          bne !loop-

exit:
          rts
