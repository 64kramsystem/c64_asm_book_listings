BasicUpstart2(spiral_fill)

// Constants ///////////////////////////////////////////////////////////////////

.const SCREEN_LOCATION = $0400
.const SCREEN_WIDTH    = 40
.const SCREEN_HEIGHT   = 25

.const START_HEIGHT    = 1
// The rows excluded the starting one, divided by 2 (top/bottom)
.const CYCLES          = (SCREEN_HEIGHT - START_HEIGHT) / 2
// On each cycle, 2 columns (left/right)
.const START_WIDTH     = SCREEN_WIDTH - CYCLES * 2
// Counting the locations filled (on each cycle: one row + one column); alternatively,
// can be interpreted as (on row for each cycle + one column for each cycles).
.const START_CORNER    = SCREEN_LOCATION + CYCLES * (SCREEN_WIDTH + 1)

// Routine params //////////////////////////////////////////////////////////////

* = 251 virtual

rect_fill_corner_lo: .byte 0
rect_fill_corner_hi: .byte 0
rect_fill_width:     .byte 0
rect_fill_height:    .byte 0

* = 2 virtual

rect_fill_code:      .byte 0

// Main variables //////////////////////////////////////////////////////////////

* = $080e

rect_corner_lo: .byte 0
rect_corner_hi: .byte 0
width:          .byte 0
height:         .byte 0

// Main ////////////////////////////////////////////////////////////////////////

spiral_fill:

fill_screen:
       lda #<START_CORNER           // Set the start data
       sta rect_corner_lo
       lda #>START_CORNER
       sta rect_corner_hi
       lda #START_WIDTH

       sta width
       lda #START_HEIGHT
       sta height

fill_box:
       lda rect_corner_lo           // Set/invoke the fill routine
       sta rect_fill_corner_lo
       lda rect_corner_hi
       sta rect_fill_corner_hi
       lda width
       sta rect_fill_width
       lda height
       sta rect_fill_height
       jsr rect_fill

       inc width                    // Increase the spiral size
       inc width
       inc height
       inc height

       lda rect_corner_lo           // Compute the next top corner (subtract 1 line + 1 column)
       sbc #SCREEN_WIDTH + 1
       sta rect_corner_lo
       lda rect_corner_hi
       sbc #0
       sta rect_corner_hi

       lda height                   // Reached a size greater than the screen?
       cmp #27
       bne fill_box                 // ... not yet; keep drawing!

       inc rect_fill_code           // Personal addition: change the char and repeat, instead of exiting
       clc
       bcc fill_screen
       // rts

// Routine /////////////////////////////////////////////////////////////////////

rect_fill:

fill_line:
       ldy #0                       // Preset: Y = column
       lda rect_fill_code           // ... A = color
fill_column:
       sta (rect_fill_corner_lo), y // Fill the line, for width_lo> chars
       iny
       cpy rect_fill_width
       bne fill_column

       dec rect_fill_height         // Exit if filled height_lo> lines
       beq exit

       lda rect_fill_corner_lo      // Add one line
       clc
       adc #SCREEN_WIDTH
       sta rect_fill_corner_lo
       lda rect_fill_corner_hi
       adc #0
       sta rect_fill_corner_hi

       clc                          // Return to main cycle
       bcc fill_line

exit:   rts
