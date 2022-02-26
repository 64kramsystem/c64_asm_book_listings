BasicUpstart2(main)

// Variables ///////////////////////////////////////////////////////////////////

* = 168 virtual

table_ptr_lo: .byte 0
table_ptr_hi: .byte 0

* = 251 virtual

search_pattern_lo: .byte 0
search_pattern_hi: .byte 0

found_offset: .byte 0

// Data/Main ///////////////////////////////////////////////////////////////////

* = $081d

table:
        .word $dead
        .word $cafe
        .word $b020
table_end:

main:
        lda #<(table)
        sta table_ptr_lo
        lda #>(table)
        sta table_ptr_hi

        lda #$ca
        sta search_pattern_hi
        lda #$fe
        sta search_pattern_lo

        jsr search_entry_optimized

        rts

// Core routine ////////////////////////////////////////////////////////////////

search_entry:
        ldy #$00

compare_entry:
        lda (table_ptr_lo), y // 16 bit compare against search_pattern
        iny
        cmp search_pattern_lo
        bne inc_y_and_resume  // see comment
        lda (table_ptr_lo), y
        iny
        cmp search_pattern_hi
        bne compare_entry

        dey                  // If found, we need to decrese the offset
        dey
        sty found_offset

        rts

// When the first byte doesn't match, we need to interrupt the loop and increase
// Y. There's no super-clean way of structing the code; as equivalent alternative,
// the logic can be interleaved:
//
//             beq compare_hi_byte
//             iny
//             clc
//             bcc compare_entry
//     compare_hi_byte:
//             lda (table_ptr_lo), y
//
// However, a smarter placement of iny yield a faster and simpler routine - see
// search_entry_optimized().
//
inc_y_and_resume:
        iny
        clc
        bcc compare_entry

// Core routine, optimized /////////////////////////////////////////////////////

search_entry_optimized:
        ldy #$ff

iny_and_compare_entry:
        iny
!compare_entry:
        lda (table_ptr_lo), y
        iny
        cmp search_pattern_lo
        bne iny_and_compare_entry
        lda (table_ptr_lo), y
        iny
        cmp search_pattern_hi
        bne !compare_entry-

        dey
        dey
        sty found_offset

        rts
