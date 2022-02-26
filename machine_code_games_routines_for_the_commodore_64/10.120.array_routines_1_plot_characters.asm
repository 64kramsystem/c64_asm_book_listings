BasicUpstart2(main)

.const SCREEN_ADDRESS = $0400

.const CHARACTER = $2a

// Variables ///////////////////////////////////////////////////////////////////

* = 168 virtual

table_ptr_lo: .byte 0
table_ptr_hi: .byte 0

* = 253 virtual

current_char_ptr_lo: .byte 0
current_char_ptr_hi: .byte 0

// Data/Main ///////////////////////////////////////////////////////////////////

* = $081d

table:      .word SCREEN_ADDRESS
            .word SCREEN_ADDRESS + 2
            .word SCREEN_ADDRESS + 4
table_end:

main:
        lda #<(table)
        sta table_ptr_lo
        lda #>(table)
        sta table_ptr_hi

        jsr plot_characters

        rts

// Core routine ////////////////////////////////////////////////////////////////

plot_characters:
        ldy #0

loop:
        lda (table_ptr_lo), y
        sta current_char_ptr_lo
        iny
        lda (table_ptr_lo), y
        sta current_char_ptr_hi // In the original code, these two are inverted;
        iny                     // ^while it works, it's a bit confusing.

        tya
        pha
        jsr plot_character
        pla
        tay

        cpy #(table_end - table)
        bne loop

        rts

// Helper routines /////////////////////////////////////////////////////////////

plot_character:
        lda #CHARACTER
        ldy #0
        sta (current_char_ptr_lo), y

        rts
