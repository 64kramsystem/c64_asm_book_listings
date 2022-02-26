BasicUpstart2(main)

.const SCREEN_ADDRESS = $0400

.const VECTOR_X = 1
.const VECTOR_Y = 2

// Variables ///////////////////////////////////////////////////////////////////

* = 168 virtual

table_ptr_lo: .byte 0
table_ptr_hi: .byte 0

* = 251 virtual

vector_x: .byte 0
vector_y: .byte 0

// Data/Main ///////////////////////////////////////////////////////////////////

* = $081d

table:
            .word SCREEN_ADDRESS
            .word SCREEN_ADDRESS + 2
            .word SCREEN_ADDRESS + 4
table_end:

main:
        lda #<(table)
        sta table_ptr_lo
        lda #>(table)
        sta table_ptr_hi

        lda #VECTOR_X
        sta vector_x
        lda #VECTOR_Y
        sta vector_y

        jsr move_characters

        rts

// Core routine ////////////////////////////////////////////////////////////////

move_characters:
        ldy #0

loop:
        lda (table_ptr_lo), y // Add the 16-bit vector to the current current
        clc                   // ^character, using the table_ptr as base and y
        adc vector_x          // ^as (incrementing) offset.
        sta (table_ptr_lo), y
        iny
        lda (table_ptr_lo), y
        adc vector_y
        sta (table_ptr_lo), y
        iny

        cpy #(table_end - table)
        bne loop

        rts
