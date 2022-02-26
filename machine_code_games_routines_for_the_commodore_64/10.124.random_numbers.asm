BasicUpstart2(main)

.const RANDOM_NUMBER_ADDR = $d41b

// Data/Main ///////////////////////////////////////////////////////////////////

* = $081d

main:
        jsr preset_rnd

        lda RANDOM_NUMBER_ADDR

        rts

// Helper routines /////////////////////////////////////////////////////////////

preset_rnd:
        lda #$ff  // Set voice 3 to maximum frequency
        sta $d40e
        sta $d40f

        lda #$80  // Voice 3: Disable output and enable noise
        sta $d412

        rts
