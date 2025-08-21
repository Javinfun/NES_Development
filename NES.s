; Testing register Data passthrough
.export Main
.segment "CODE"

.proc Main
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