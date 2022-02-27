// This is "Fundamental Bomb Update", with the (negligible) difference below.

      sta $fb
      lda #$07
      sta $fc
l033c:
      ldy #0       // in the reference routine, this is outside (above) the loop, as it's
                   // not necessary to update it.
      lda ($fb), y
      cmp #$24
      bne l034e
      ldy #$28
      sta ($fb), y
      ldy #0
      lda #$20
      sta ($fb), y

l034e:
      lda $fb
      sec
      sbc #1
      sta $fb
      lda $fc
      sbc #0
      sta $fc
      cmp #3
      bne l033c

      rts
