BasicUpstart2(main)

.const LO_FREQUENCY        = $d400 // 54272
.const HI_FREQUENCY        = $d401 // 54273
.const VOICE_1_CONTROL_REG = $d404 // 54276

.const INTERRUPT_VECTOR    = $0314 // 788
.const SERVICE_ROUTINE     = $ea31 // 59953

.const TRIANGLE_SYNC       = 17    // includes the sync bit
.const SAW_SYNC            = 33    // ^
.const RECTANGE_SYNC       = 65    // ^
.const NOISE_SYNC          = 129   // ^

// Variables ///////////////////////////////////////////////////////////////////

* = 251 virtual

tune_data_ptr_lo: .byte 0
tune_data_ptr_hi: .byte 0

* = 254 virtual

counter:          .byte 1

// Data/Main ///////////////////////////////////////////////////////////////////

* = $081d

// (lo_freq, hi_freq, duration)
//
tune_data: .byte 96 , 22, 1   * 60
           .byte 49 , 28, 1.5 * 60
           .byte 19 , 28, 0.5 * 60
           .byte 156, 26, 1   * 60
           .byte 96 , 22, 1   * 60
           .byte 223, 29, 1   * 60
           .byte 223, 29, 1   * 60
           .byte 49 , 28, 1   * 60
           .byte 156, 26, 1   * 60
           .byte 49 , 28, 1   * 60
           .byte 135, 33, 1   * 60
           .byte 135, 33, 1   * 60
           .byte 165, 31, 1   * 60
           .byte 135, 33, 3   * 60
           .byte 49 , 28, 1   * 60
           .byte 162, 37, 1.5 * 60
           .byte 135, 33, 0.5 * 60
           .byte 223, 29, 0.5 * 60
           .byte 49 , 28, 1   * 60
           .byte 156, 26, 1   * 60
           .byte 96 , 22, 1   * 60
           .byte 31 , 21, 1   * 60
           .byte 49 , 28, 1   * 60
           .byte 156, 26, 1   * 60
           .byte 96 , 22, 1   * 60
           .byte 96 , 22, 1   * 60
           .byte 31 , 22, 1   * 60
           .byte 96 , 22, 3   * 60
           .byte 0  , 0 , 0   * 60

main:

preset_vars:
        lda #1
        sta counter           // start immediately with a new note

        lda #<(tune_data - 3) // the routine starts with an increment, so we need
        sta tune_data_ptr_lo  // ^to start before
        lda #>(tune_data - 3)
        sta tune_data_ptr_hi

        jsr hook_interrupt

        rts

// Core routine ////////////////////////////////////////////////////////////////

// This can be restructured to:
//
// - tune_player
// - play_note (-> bne advance_tune_pointer)
// - reset_tune
// - exit_int
//
// which is more intuitive, and avoids having to start with a pre-decreased address.

tune_player:
        dec counter
        bne exit_int              // if the counter is > 0, continue playing

advance_tune_pointer:
        clc                       // increment tune data pointer by 3 bytes
        lda tune_data_ptr_lo      // ^(16-bit addition)
        adc #3
        sta tune_data_ptr_lo
        lda tune_data_ptr_hi
        adc #0
        sta tune_data_ptr_hi

play_note:
        ldy #0                    // cut sound
        sty VOICE_1_CONTROL_REG
        lda #SAW_SYNC             // trip gate
        sta VOICE_1_CONTROL_REG
        lda (tune_data_ptr_lo), y
        sta LO_FREQUENCY
        iny
        lda (tune_data_ptr_lo), y
        sta HI_FREQUENCY
        iny
        lda (tune_data_ptr_lo), y // set duration (counter)
        sta counter
        bne exit_int              // if the loaded (undecreased) counter is > 0, continue playing

reset_tune:
        lda #<tune_data
        sta tune_data_ptr_lo
        lda #>tune_data
        sta tune_data_ptr_hi
        clc
        bcc play_note

exit_int:
        jmp SERVICE_ROUTINE

// Helper routines /////////////////////////////////////////////////////////////

hook_interrupt:
        lda #<tune_player
        sta INTERRUPT_VECTOR
        lda #>tune_player
        sta INTERRUPT_VECTOR + 1

        rts
