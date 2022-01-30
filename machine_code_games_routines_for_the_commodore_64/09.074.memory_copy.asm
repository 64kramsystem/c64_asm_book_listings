BasicUpstart2(main)

// Constants ///////////////////////////////////////////////////////////////////

.const SCREEN_LOCATION = $0400
.const SCREEN_WIDTH    = 40
.const SCREEN_HEIGHT   = 25

// .const FILL_START      = SCREEN_LOCATION
// .const FILL_END        = FILL_START + SCREEN_WIDTH * SCREEN_HEIGHT
// .const START_FILL_CODE = 0

// Copy upper half to lower half, excluding middle row.
//
.const COPY_SOURCE        = SCREEN_LOCATION
.const COPY_BYTES         = 12 * SCREEN_WIDTH
.const COPY_DEST          = SCREEN_LOCATION + (SCREEN_WIDTH * SCREEN_HEIGHT) - COPY_BYTES

// Routine params //////////////////////////////////////////////////////////////

* = ($100 - 6) virtual

bytes_count_lo: .byte 0
bytes_count_hi: .byte 0
copy_source_lo: .byte 0
copy_source_hi: .byte 0
copy_dest_lo:   .byte 0
copy_dest_hi:   .byte 0

// Main ////////////////////////////////////////////////////////////////////////

* = $080e

main:
          lda #<COPY_SOURCE
          sta copy_source_lo
          lda #>COPY_SOURCE
          sta copy_source_hi
          lda #<COPY_DEST
          sta copy_dest_lo
          lda #>COPY_DEST
          sta copy_dest_hi
          lda #<COPY_BYTES
          sta bytes_count_lo
          lda #>COPY_BYTES
          sta bytes_count_hi

          jsr memory_copy

halt:
          clc
          bcc halt

// Routine /////////////////////////////////////////////////////////////////////

memory_copy:
          ldy #0

copy_byte:
          lda (copy_source_lo), y
          sta (copy_dest_lo), y

decr_bytes_count:
          sec                      // (Slow) 16-bit decrement bytes_count; on SBC, carry set counts
          lda bytes_count_lo       // as 0, and viceversa!!
          sbc #1                   // ^
          sta bytes_count_lo       // ^
          lda bytes_count_hi       // ^
          sbc #0                   // ^
          sta bytes_count_hi       // ^

incr_copy_source:
          inc copy_source_lo       // 16-bit increment copy_source
          bne incr_copy_dest
          inc copy_source_hi

incr_copy_dest:
          inc copy_dest_lo         // 16-bit increment copy_dest
          bne check_bytes_count
          inc copy_dest_hi

check_bytes_count:
          lda bytes_count_lo
          cmp #0                   // Redundant!
          bne copy_byte
          lda bytes_count_hi
          cmp #0                   // Redundant!
          bne copy_byte

          rts

// Besides check_bytes_count:, decr_bytes_count can be easily optimized:

decr_bytes_count_opt:
          lda bytes_count_lo
          bne !+                   // If the low byte is not zero, don't decrement the hi byte
          dec bytes_count_hi
!:        dec bytes_count_lo       // Always decrement the low byte
