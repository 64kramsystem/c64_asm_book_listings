BasicUpstart2(main)

.const SCREEN_LOCATION = $0400
.const SPRITE_POSITION = SCREEN_LOCATION + 1
.const BLANK_CHAR = $20
.const STOP_VALUE = 0          // To be used in `table`

// Routine variables ///////////////////////////////////////////////////////////

* = 2 virtual

delete_flag: .byte 0           // anything other than zero erases the char

* = ($100 - 4) virtual

current_addr_lo: .byte 0
current_addr_hi: .byte 0

// Routine params ///////////////////////////////////////////////////////////

start_addr_lo: .byte 0
start_addr_hi: .byte 0

// Main ////////////////////////////////////////////////////////////////////////

* = $080d

// The encoding alternates sprite char and displacement of the next position; ends with STOP_VALUE.
//
// Encoded example sprite:
//
//    X
//   /%\
//   """
//
table:  .byte 86, 39
        .byte 78, 1, 37, 1, 77, 38
        .byte 34, 1, 34, 1, 34, 1
        .byte STOP_VALUE

main:
        lda #0
        sta delete_flag
        lda #<SPRITE_POSITION
        sta start_addr_lo
        lda #>SPRITE_POSITION
        sta start_addr_hi

        jsr draw_sprite

!:
        clc
        bcc !-

// Routines ////////////////////////////////////////////////////////////////////

draw_sprite:
        lda start_addr_lo
        sta current_addr_lo
        lda start_addr_hi
        sta current_addr_hi

        ldx #0                   // x is the table index; alternates chars and displacements
        ldy #0                   // not an index!! only used for comparison with the delete flag

        lda table, x             // load the char
write_char:
        cpy delete_flag
        beq !+
        lda #BLANK_CHAR
!:
        sta (current_addr_lo), y // Y is not significant; it just recycles the 0 above

compute_new_position:
        inx                      // odd bytes in the tables are the displacements
        clc
        lda current_addr_lo      // add the displacement to the current_address
        adc table, x
        sta current_addr_lo
        lda current_addr_hi
        adc #0
        sta current_addr_hi

load_next_char:
        inx
        lda table, x
        bne write_char           // proceed until the char value is 0

        rts
