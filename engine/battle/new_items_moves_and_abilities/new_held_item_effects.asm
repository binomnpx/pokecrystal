

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


HandleBetweenMovesEffects::
; handles life orb damage and berries
; used in engine/battle/core.asm

	push bc
	push hl

	farcall GetUserItem
	ld a, b
	cp HELD_LIFE_ORB
	jr z, .LifeOrb
	jr .pop_ret
	
.LifeOrb
; the 30% damage increase is taken care of in engine/battle/effect_commands

; dont dmg if attack missed
	ld a, [wAttackMissed]
	and a
	jr nz, .pop_ret

;dont dmg if used status/fixed damage moves
	ld a, BATTLE_VARS_MOVE_POWER
	call GetBattleVar
	
; power = 0
	and a
	jr z, .pop_ret
	
; power = 1
	cp 1
	jr z, .pop_ret
	

; if opponent has fainted then
; delay dmg until HandleBetweenTurnsEffects is called

; who moved last?
	ldh a, [hBattleTurn]
	and a
	jr nz, .enemyturn

; player
	farcall HasEnemyFainted
	jr nz, .do_damage
	
; set flag for HandleBetweenTurnsEffects
	ld hl, wBattleItemFlags
	set BATTLEITEMFLAG_LIFEORB, [hl]
	jr .pop_ret

; enemy
.enemyturn
	farcall HasPlayerFainted
	jr nz, .do_damage
	
; set flag for HandleBetweenTurnsEffects
	ld hl, wBattleItemFlags
	set BATTLEITEMFLAG_LIFEORB, [hl]
	jr .pop_ret

; damage 1/10 HP
.do_damage

	call GetTenthMaxHP
	farcall SubtractHPFromUser
	ld hl, HurtByLifeOrbText
	call StdBattleTextbox
	
.pop_ret
	pop hl
	pop bc
	ret



GetTenthMaxHP::
; divide max hp by 10 and place in bc
	xor a
	ld hl, hDividend
	ld [hli], a
	ld [hl], a
	
	farcall GetMaxHP
	ld a, b
	ld [hDividend + 2], a
	ld a, c
	ld [hDividend + 3], a
	
	ld a, 10
	ld [hDividend + 4], a
	ld b, 4
	call Divide
	
	ld a, [hQuotient + 3]
	ld c, a
	xor a
	ld b, a
	
	ret



;;;


; ; divide max hp by 10 and place in bc
	; xor a
	; ld hl, hDividend
	; ld [hli], a
	; ld [hld], a
	
	; farcall GetMaxHP
	; ld a, b
	; ld [hli], a
	; ld a, c
	; ld [hli], a
	
	; ld a, 10
	; ld [hl], a
	; ld b, 2
	; call Divide
	
	; ld a, [hQuotient + 1]
	; ld c, a
	; xor a
	; ld b, a






















