BasicUpstart2(main)

.const TARGET_SPRITE_BASE_ADDR  = $d000     // 53248
// Note that, due to DEX/BNE loop optimization, it's 1 byte lass than the referenced address.
.const HOMING_SPRITES_BASE_ADDR = $d001     // 53249
// The optimized version used a direct correspondence.
.const HOMING_SPRITES_BASE_ADDR_OPT = $d002 // 53250
.const LAST_SPRITE_IDX          = 7         // 0 is the target; 1-IDX are the homing ones

.const SPRITE_COORDINATES_ADDR    = $d000 // 53248
.const SPRITES_ENABLE_STATE_ADDR  = $d015 // 53269
.const SPRITE_SHAPE_POINTERS_ADDR = $07f8 // 2040
.const INTERRUPT_VECTOR_ADDR      = $0314 // 788
.const SERVICE_ROUTINE_ADDR       = $ea31 // 59953

// Variables ///////////////////////////////////////////////////////////////////

* = $334 virtual

// array (x, y)
sprite_vectors:
        .fill 16, 0
sprite_vectors_end:

* = $3c0 virtual

sprites_shape_data:
        .fill 63, 0
sprites_shape_data_end:

// Data/Main ///////////////////////////////////////////////////////////////////

* = $081d

main:
        jsr set_sprites_shape_data
        jsr set_sprite_pointers
        jsr preset_rnd
        jsr set_sprite_coordinates
        jsr enable_sprites
        jsr hook_interrupt           // hook homing motion routine

        rts

// Core routine ////////////////////////////////////////////////////////////////

// The comparison cycles:
//
// - the homing sprite cs., using the X register as index; starts from
//   sprite0/Y + 14 (= sprite7/Y), and ends at sprite0/Y + 1 (=sprite1/X)
// - the target sprite cs., using the Y register as index; cycles between
//   0 (= sprite0/X) and 1 (= sprite0/Y)
//
// The dec's+inc are a relatively compact way to conditionally decrement/increment
// by 1 a memory value. The optimized version of the routine is simpler, faster
// and more compact.
//
// "c[s]." = "coordinate[s]"

homing_motion:
        ldy #1                          // Y: target sprite offset
        ldx #(2 * LAST_SPRITE_IDX)      // X: homing sprites offsets (2: one for each c.)

compare_sprites_coordinate:
        lda HOMING_SPRITES_BASE_ADDR, x

        sec
        sbc TARGET_SPRITE_BASE_ADDR, y
        beq next_coordinate             // cs. are equal; switch to next c.
        bcc increment_coordinate        // if carry is clear -> target c. is >= homing c. ->
        dec HOMING_SPRITES_BASE_ADDR, x // increase; else -> decrease
        dec HOMING_SPRITES_BASE_ADDR, x
increment_coordinate:
        inc HOMING_SPRITES_BASE_ADDR, x

next_coordinate:
        tya                             // Invert Y 0<>1, so that alternate homing sprite
        eor #1                          // ^c. is compared
        tay

        dex                             // Repeate cycle; last x cycled = 1
        bne compare_sprites_coordinate

        jmp SERVICE_ROUTINE_ADDR

// Optimized and slightly simplified version.
//
// The optimization is simple - just use the A reg for the arithmetic. Core logic, original:
//
// - sec+sbc: 2+4 cycles
// - inc<>dec: 21<>7 cycles
//
// optimized:
//
// - cmp: 4 cycles
// - inc<>dec: 13<>9 cycles
//
// The simplification is that, instead of using XOR to alternate Y between 0 and 1, we set
// Y to the last bit of X; this is a more intuitive approach, since the connection between
// X (homing sprite offset) and Y (target sprite offset) is direct.
// This requires a `bpl` test (positive result) instead of `bne`, which is possible because
// X is never >= 128.
// As side effect, this logic also spares the first `ldy #1`.
//
homing_motion_improved:
        ldx #(2 * LAST_SPRITE_IDX - 1)      // X: homing sprites offsets (range: [0, 13])

compare_sprites_coordinate_imp:
        txa                                 // Y: target sprite offset; matches the LS bit of X
        and #1
        tay

        lda HOMING_SPRITES_BASE_ADDR + 1, x // See constant definition regarding the `+ 1`

        cmp TARGET_SPRITE_BASE_ADDR, y
        beq next_coordinate_imp
        bcc increment_coordinate_imp
        clc
        sbc #1
increment_coordinate_imp:
        sec
        adc #0
        sta HOMING_SPRITES_BASE_ADDR + 1, x

next_coordinate_imp:
        dex
        bpl compare_sprites_coordinate_imp

        jmp SERVICE_ROUTINE_ADDR

// Helper routines /////////////////////////////////////////////////////////////

set_sprites_shape_data:
        lda #255
        ldy #(sprites_shape_data_end - sprites_shape_data)

!:      dey
        sta sprites_shape_data, y
        bne !-

        rts

set_sprite_pointers:
        lda #(sprites_shape_data / 64)
        ldy #((sprite_vectors_end - sprite_vectors) / 2)
!:      dey
        sta SPRITE_SHAPE_POINTERS_ADDR, y
        bne !-

        rts

preset_rnd:
        lda #$ff
        sta $d40e
        sta $d40f
        lda #$80
        sta $d412

        rts

set_sprite_coordinates:
        ldx #(16 - 2)
!:
        jsr get_rnd
        dex
        sta SPRITE_COORDINATES_ADDR + 2, x
        bne !-

        jsr get_rnd                     // trivially set the target sprite in a guaranteed
        and #127
        clc
        adc #24                         // 24: left corner (x)
        sta TARGET_SPRITE_BASE_ADDR
        jsr get_rnd
        and #127
        clc
        adc #50                         // 50: top corner (y)
        sta TARGET_SPRITE_BASE_ADDR + 1

        rts

get_rnd:
        lda #10
!:      sec
        sbc #1
        bcs !-
        lda $d41b

        rts

enable_sprites:
        lda #$ff
        sta SPRITES_ENABLE_STATE_ADDR

        rts

hook_interrupt:
        lda #<homing_motion_improved
        sta INTERRUPT_VECTOR_ADDR
        lda #>homing_motion_improved
        sta INTERRUPT_VECTOR_ADDR + 1

        rts
