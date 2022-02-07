BasicUpstart2(main)

.const JOY_1_POS_ADDR  = $dc01
.const SPRITE_0_X_ADDR = $d000
.const SPRITE_0_Y_ADDR = $d001

// Main ////////////////////////////////////////////////////////////////////////

* = $080d

// 16 pairs; each pair represents the (x, y) displacement (255 = -1).
// The first 5 and last 1 couples are never used.
//
joystick_mapping: .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                  .byte 1, 1, 1, 255, 1, 0, 0, 0, 255, 1, 255, 255, 255, 0, 0, 0, 0, 1, 0, 255
                  .byte 0, 0

main:
          jsr handle_joystick       // Best hooked to interrupt

          clc
          bcc main

// Routines ////////////////////////////////////////////////////////////////////

handle_joystick:

        lda JOY_1_POS_ADDR          // get joystick #1 position
        and #15                     // isolate meaningful bytes
        asl                         // multiply by 2 (each position is associated to two values)
        tax

        lda joystick_mapping, x     // lookup x displacement
        clc
        adc SPRITE_0_X_ADDR         // add displacement to sprite #0 x
        sta SPRITE_0_X_ADDR

        lda joystick_mapping + 1, x // lookup y displacement
        clc
        adc SPRITE_0_Y_ADDR         // add displacement to sprite #0 y
        sta SPRITE_0_Y_ADDR

        rts
