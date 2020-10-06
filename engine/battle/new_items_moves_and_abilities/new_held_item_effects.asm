

UnevolvedEviolite::
; get the defender's species
	ld a, MON_SPECIES
	call BattlePartyAttr
	ldh a, [hBattleTurn]
	and a
	ld a, [hl]
	jr nz, .Unevolved
	ld a, [wTempEnemyMonSpecies]

.Unevolved:
; check if the defender has any evolutions
; hl := EvosAttacksPointers + (species - 1) * 2
	dec a
	push hl
	push bc
	ld c, a
	ld b, 0
	ld hl, EvosAttacksPointers
	add hl, bc
	add hl, bc
; hl := the species' entry from EvosAttacksPointers
	ld a, BANK(EvosAttacksPointers)
	call GetFarHalfword
; a := the first byte of the species' *EvosAttacks data
	ld a, BANK("Evolutions and Attacks")
	call GetFarByte
; if a == 0, there are no evolutions, so don't boost stats
	and a
	pop bc
	pop hl
	ret z

; check if the defender's item is Eviolite
	push bc
	farcall GetOpponentItem
	ld a, b
	cp HELD_EVIOLITE
	pop bc
	ret nz

; boost the relevant defense stat in bc by 50%
	ld a, c
	srl a
	add c
	ld c, a
	ret nc

	srl b
	ld a, b
	and a
	jr nz, .done
	inc b
.done
	scf
	rr c
	ret


AssaultVest::
; check if the defender's item is Assault Vest
	push bc
	farcall GetOpponentItem
	ld a, b
	cp HELD_ASSAULT_VEST
	pop bc
	ret nz

; boost special defense stat in bc by 50%
	ld a, c
	srl a
	add c
	ld c, a
	ret nc

	srl b
	ld a, b
	and a
	jr nz, .done
	inc b
.done
	scf
	rr c
	ret


LightClay::
; check if the user's item is Light Clay
	push bc
	farcall GetUserItem
	ld a, b
	cp HELD_LIGHT_CLAY
	pop bc
	
; if yes, then 8 turns, if no, then 5 turns
	ld a, 8
	jr z, .eight
	ld a, 5
.eight
	ret


ChoiceBand::
; check if the user's item is Choice Band
	push hl
	push bc
	farcall GetUserItem
	ld a, b
	cp HELD_CHOICE_BAND
	pop bc
	pop hl
	ret nz

; boost attack stat in hl by 50%
	ld a, l
	srl a
	add l
	ld l, a
	ret nc

	srl h
	ld a, h
	and a
	jr nz, .done
	inc h
.done
	scf
	rr l
	ret



