BasicUpstart2(main)

// Variables ///////////////////////////////////////////////////////////////////

* = 168 virtual

table_ptr: .word 0

* = 253 virtual

last_element_ofs: .byte 0

// Data/Main ///////////////////////////////////////////////////////////////////

* = $081d

table:
        .word $dead
        .word $cafe
        .word $b020
        .word $face
        .word $feed
table_end:

main:
        lda #<(table)
        sta table_ptr
        lda #>(table)
        sta table_ptr + 1

        ldx #(table_end - table)
        ldy #2                   // delete $cafe

        jsr delete_entry

        rts

// Core routine ////////////////////////////////////////////////////////////////

// Input: X = (2 * number of entries), Y = (2 * deleting entry index)
delete_entry:
        dex                  // move X to last element
        dex

        sty last_element_ofs

        txa                  // load last element LSB in A
        tay                  // ^(transferring offset X to Y)
        lda (table_ptr), y   //

        ldy last_element_ofs // overwrite deleting entry LSB
        sta (table_ptr), y   // ^with last element LSB

        inx                  // increment last element and deleting entry pointers
        inc last_element_ofs

        txa                  // from here downwards, do the same as before
        tay
        lda (table_ptr), y

        ldy last_element_ofs
        sta (table_ptr), y

        rts
