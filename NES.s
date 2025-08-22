.import Main

.segment "HEADER"
  .byte $4E, $45, $53, $1A  ; iNES header identifier
  .byte 2                   ; 2x 16KB PRG-ROM Banks
  .byte 1                   ; 1x  8KB CHR-ROM
  .byte $01, $00            ; mapper 0, vertical mirroring

.segment "VECTORS"
  .addr nmi
  .addr reset
  .addr 0

.segment "STARTUP"
RESET:
    SEI     ;disables interupts
    CLD     ;turn off decimal mode

    LDX #%1000000    ;disable sound IRQ
    STX $4017
    LDX #$00
    STX $4010       ;disable PCM

    ;initialize the stack register 
    LDX #$FF
    TXS             ;transfer x to the stack

    ;Clear PPU registers
    LDX #$00
    STX $2000
    STX $2001

    ;WAIT FOR VBLANK
:   
    BIT $2002
    BPL :-

    ;CLEARING 2K MEMORY
    TXA
CLEARMEMORY:        ;$0000 - $07FF
    STA $0000, x
    STA $0100, x
    STA $0300, x
    STA $0400, x
    STA $0500, x
    STA $0600, x
    STA $0700, x
        LDA #$FF
        STA $0200, x
        LDA #$00
    INX
    CPX #$00
    BNE CLEARMEMORY

    ;WAIT FOR VBLANK
:   
    BIT $2002
    BPL :-

    ;Setting Sprite Range
    LDA #$02
    STA $4014
    NOP

    LDA #$3F        ;$3F00
    STA $2006
    LDA #$00
    STA $2006

    ;LOAD DATA HERE
    LDX #$00
LOADPALETTES:
    LDA PALETTEDATA, x
    STA $2007
    INX
    CPX #$20
    BNE LOADPALETTES

    LDX #$00
LOADSPRITES:
    LDA SPRITEDATA, x
    STA $0200, x
    INX
    CPX #$20        ;16 bytes (4 bytes per sprite, 4 sprites total)
    BNE LOADSPRITES

;ENABLE INTERUPTS
    CLI 
    LDA #%10010000
    STA $2000       ;enable NMI, sprites, background
    
    LDA #%00011110
    STA $2001       ;enable rendering, sprites, background


    INFLOOP:
        JMP INFLOOP
NMI:

    LDA #$02        ;LOADING SPRITE Range
    STA $4014       ;write to OAM DMA register

    RTI

PALETTEDATA:
    .byte $00, $0F, $00, $10, 	$00, $0A, $15, $01, 	$00, $29, $28, $27, 	$00, $34, $24, $14 	;background palettes
	.byte $31, $0F, $15, $30, 	$00, $0F, $11, $30, 	$00, $0F, $30, $27, 	$00, $3C, $2C, $1C 	;sprite palettes

SPRITEDATA:
;Y, SPRITE NUM, attributes, X
    .byte $40, $00, $00, $40
    .byte $40, $01, $00, $48
    .byte $48, $10, $00, $40
    .byte $48, $11, $00, $48

    ;sword
    .byte $50, $08, %00000001, $80
    .byte $50, $08, %01000001, $88
    .byte $58, $18, %00000001, $80
    .byte $58, $18, %01000001, $88


.segment "VECTORS"
    .word NMI   ;Non-Maskable Interupts
    .word RESET
    ; specialized hardware interupts
.segment "CHARS"

.segment "CODE"

.proc nmi
  bit $2002
  lda #0
  sta $2006
  sta $2006
  rti
.endproc

.proc ResetPalettes
  bit $2002
  lda #$3f
  sta $2006
  lda #$00
  sta $2006
  lda #$0F
  ldx #$20
@paletteLoadLoop:
  sta $2007
  dex
  bne @paletteLoadLoop
  rts
.endproc

.proc reset
  sei
  cld
  ldx #%01000000
  stx $4017
  ldx #$ff
  txs
  ldx #0
  stx $2000
  stx $2001
  stx $4010
  bit $2002
@vblankWait1:
  bit $2002
  bpl @vblankWait1
@clearMemory:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0200, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  inx
  bne @clearMemory
@vblankWait2:
  bit $2002
  bpl @vblankWait2
  jsr ResetPalettes
main:
  jsr Main
  lda #%00001000
  sta $2001
endlessLoop:
  jmp endlessLoop
.endproc