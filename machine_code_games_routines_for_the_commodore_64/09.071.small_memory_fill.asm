BasicUpstart2(main)

// Constants ///////////////////////////////////////////////////////////////////

.const SCREEN_LOCATION = $0400
.const SCREEN_WIDTH    = 40

.const START_ADDR = SCREEN_LOCATION
.const FILL_COUNT = SCREEN_WIDTH * 6

// small_mem_fill variables ////////////////////////////////////////////////////

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

// Routine: Small memory fill //////////////////////////////////////////////////

small_mem_fill:

!loop:
          sta START_ADDR - 1, x
          dex
          bne !loop-

          rts
