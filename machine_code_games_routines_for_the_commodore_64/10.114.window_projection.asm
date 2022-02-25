BasicUpstart2(main)

.const WINDOW_HEIGHT  = 25
.const WINDOW_WIDTH   = 40
.const UNIVERSE_WIDTH = 400

// Variables ///////////////////////////////////////////////////////////////////

* = 251 virtual

universe_pointer_lo: .byte 0
universe_pointer_hi: .byte 0
window_pointer_lo:   .byte 0
window_pointer_hi:   .byte 0

// Data/Main ///////////////////////////////////////////////////////////////////

* = $081d

main:
        // jsr window_projection
        rts

// Core routine ////////////////////////////////////////////////////////////////

window_projection:
        ldx #WINDOW_HEIGHT
copy_rows:
        ldy #0
copy_row:
        lda (universe_pointer_lo), y
        sta (window_pointer_lo), y
        iny
        cpy WINDOW_WIDTH
        bne copy_row

        clc                     // Add (universe) row size to universe pointer
        lda universe_pointer_lo // ^16-bit addition
        adc #UNIVERSE_WIDTH
        sta universe_pointer_lo
        lda universe_pointer_hi
        adc #0
        sta universe_pointer_hi

        clc                     // Add (window) row size to window pointer
        lda window_pointer_lo   // ^16-bit addition
        adc #WINDOW_WIDTH
        sta window_pointer_lo
        lda window_pointer_hi
        adc #0
        sta window_pointer_hi

        dex
        bne copy_rows

        rts
