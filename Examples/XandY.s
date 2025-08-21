; Testing registers X and Y
.import Main

.segment "CODE"
    ldx #5
    ldy #5

    inx
    inx

    dex

    dey
    dey

    iny

    rts

.endproc