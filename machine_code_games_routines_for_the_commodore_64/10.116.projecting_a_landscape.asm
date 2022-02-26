BasicUpstart2(main)

.const SCREEN_WIDTH   = 40
.const SCREEN_HEIGHT  = 25
.const SCREEN_ADDRESS = $0400

.const RADIUS              = 15
.const SHIP_POSITION       = 20 // world coordinates, 0-based

// (last line base address) + ((screen width - drawn width) / 2)
.const LANDSCAPE_BASE_ADDR = (SCREEN_ADDRESS + SCREEN_WIDTH * (SCREEN_HEIGHT - 1)) + (SCREEN_WIDTH - (2 * RADIUS + 1)) / 2

// Variables ///////////////////////////////////////////////////////////////////

* = 251 virtual

table_ptr_lo: .byte 0
table_ptr_hi: .byte 0

// Data/Main ///////////////////////////////////////////////////////////////////

* = $081d

// World width = 256.
//
table: .fill 256, [i]

main:
        lda #<(table)
        sta table_ptr_lo
        lda #>(table)
        sta table_ptr_hi

        ldy #SHIP_POSITION

        jsr projecting_a_landscape

        rts

// Core routine ////////////////////////////////////////////////////////////////

// This is a modified version of the original routine, which uses the loop:
//
//   ldx #0
//   inx
//   cpx #(size)
//   bne loop
//
// instead of the original:
//
//   ldx #(size)
//   dex
//   bne loop
//
// It's slower, but it makes plot_element() extremely simple.
//
// In theory, if:
//
// - the complexity of plot_element() is not considered,
// - and the ship position is fixed
//
// then the X register operations can be removed by using:
//
// - cpy #(SHIP_POSITION + RADIUS + 1)
//
// however, it's stated requirement for plot_element() to be as simple as possible.
//
projecting_a_landscape:
        tya
        sec
        sbc #RADIUS
        tay                   // Y: Current element world position

        ldx #0                // X: Counter (both sides, plus the ship)
loop:
        lda (table_ptr_lo), y
        jsr plot_element

        iny
        inx

        cpx #(2 * RADIUS + 1)
        bne loop

        rts

// Helper routines /////////////////////////////////////////////////////////////

plot_element:
        sta LANDSCAPE_BASE_ADDR, x

        rts
