SetHPPal::
; Set palette for hp bar pixel length e at hl.
	call GetHPPal
	ld [hl], d
	ret

GetHPPal::
; Get palette for hp bar pixel length e in d.
	ld d, HP_GREEN
	ld a, e
	cp (HP_BAR_LENGTH_PX * 50 / 100) ; 24
	jr z, .check_half
	ret nc
.yellow
	ld a, e
	inc d ; HP_YELLOW
	cp (HP_BAR_LENGTH_PX * 21 / 100) ; 10
	ret nc
	inc d ; HP_RED
	ret



.check_half
	push de
	push hl
	
	ld de, wEnemyMonHP + 1
	ld hl, wEnemyMonMaxHP
	ld a, [wWhichHPBar]
	and a
	jr z, .go
	ld de, wBattleMonHP + 1
	ld hl, wBattleMonMaxHP

.go
	push bc
	ld a, [de]
	add a
	ld c, a
	dec de
	ld a, [de]
	inc de
	adc a
	ld b, a
	cp [hl]
	ld a, c
	pop bc
	jr z, .equal
	pop hl
	pop de
	ret

.equal
	inc hl
	cp [hl]
	dec hl
	pop hl
	pop de
	jr z, .yellow
	ret
	
	
	
	
	
	
	
	
	
	