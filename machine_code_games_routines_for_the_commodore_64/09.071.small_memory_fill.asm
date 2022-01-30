BasicUpstart2(main)

// Constants ///////////////////////////////////////////////////////////////////

.const SCREEN_LOCATION = $0400
.const SCREEN_WIDTH    = 40

.const START_ADDR = SCREEN_LOCATION
.const FILL_COUNT = SCREEN_WIDTH * 6

// small_mem_fill variables ////////////////////////////////////////////////////

* = ($100 - 3) virtual

fill_count: .byte 0

// small_mem_fill variables ////////////////////////////////////////////////////

* = $080e

// Main ////////////////////////////////////////////////////////////////////////

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

// Note that this routine does not support filling with a zero count (see below).
//
small_mem_fill:

!loop:
          sta START_ADDR - 1, x
          dex
          bne !loop-

          rts

// This version of the routine supports a zero count:

small_mem_fill_unopt:

          clc         // since the counter can be also 0, we can't use a bnz instead of clc+bcc; additionally
          bcc !test+  // ...it requires X to be modified immediately before entering the routine

!loop:    sta START_ADDR - 1, x
          dex

!test:    cpx #0
          bne !loop-

          rts

// A nice and clean optimization can be applied, by normalizing X before performing the loop test:

          inx
          bne !test+

!loop:    sta START_ADDR - 1, x

!test:    dex
          bne !loop-

          rts
