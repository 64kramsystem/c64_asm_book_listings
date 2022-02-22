BasicUpstart2(main)

.const SPRITE_COORDINATES    = $d000 // 53248
.const SPRITE_SHAPE_POINTERS = $07f8 // 2040
.const SPRITES_ENABLE_STATE  = $d015 // 53269
.const INTERRUPT_VECTOR      = $0314 // 788
.const SERVICE_ROUTINE       = $ea31

// Variables ///////////////////////////////////////////////////////////////////

* = $334 virtual

// array (x, y)
sprite_vectors: .fill 16, 0
sprite_vectors_end:

* = $3c0 virtual

sprite_shape_data: .fill 63, 0
sprite_shape_data_end:

// Main ////////////////////////////////////////////////////////////////////////

* = $081d

main:
        jsr set_sprite_pointers
        jsr set_sprites_shapes_data
        jsr preset_rnd
        jsr set_sprite_vectors
        jsr hook_interrupt
        jsr enable_sprites

        rts

// Core routine ////////////////////////////////////////////////////////////////

sprite_vectoring:
        ldx #0

move_sprite_cycle:
        lda sprite_vectors, x
        clc
        adc SPRITE_COORDINATES, x
        sta SPRITE_COORDINATES, x
        inx
        cpx #(sprite_vectors_end - sprite_vectors)
        bne move_sprite_cycle

        jmp SERVICE_ROUTINE

// Helper routines /////////////////////////////////////////////////////////////

set_sprite_pointers:
        lda #(sprite_shape_data / 64)
        ldy #((sprite_vectors_end - sprite_vectors) / 2)
!:      dey
        sta SPRITE_SHAPE_POINTERS, y
        bne !-

        rts

set_sprites_shapes_data:
        lda #255
        ldy #(sprite_shape_data_end - sprite_shape_data)

!:      dey
        sta sprite_shape_data, y
        bne !-

        rts

// See https://www.atarimagazines.com/compute/issue72/random_numbers.php
//
preset_rnd:
        lda #$ff  // maximum frequency value
        sta $d40e // voice 3 frequency low byte
        sta $d40f // voice 3 frequency high byte
        lda #$80  // noise waveform, gate bit off
        sta $d412 // voice 3 control register

        rts

// Waste some cycles, since a new value is generated every 26 cycles.
// See https://www.lemon64.com/forum/viewtopic.php?t=70039.
//
get_rnd:
        lda #10
!:      sec
        sbc #1
        bcs !-
        lda $d41b

        rts

set_sprite_vectors:
        ldy #(sprite_vectors_end - sprite_vectors)

!:      jsr get_rnd            // Generate values in the interval [1, 4]
        and #3
        clc
        adc #1

        dey
        sta sprite_vectors, y
        bne !-

        rts

hook_interrupt:
        lda #<sprite_vectoring
        sta INTERRUPT_VECTOR
        lda #>sprite_vectoring
        sta INTERRUPT_VECTOR + 1

        rts

enable_sprites:
        lda #$ff
        sta SPRITES_ENABLE_STATE

        rts
