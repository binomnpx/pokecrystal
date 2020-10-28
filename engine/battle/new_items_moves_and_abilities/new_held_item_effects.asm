

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

	call PhysOrSpec
	ret c

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

	push bc
	farcall GetUserItem
	ld a, b
	cp HELD_CHOICE_BAND
	pop bc
	ret nz

	call PhysOrSpec
	ret nc

; boost attack stat in de by 50%
	ld a, e
	srl a
	add e
	ld e, a
	ret nc

	srl d
	ld a, d
	and a
	jr nz, .done
	inc d
.done
	scf
	rr e
	ret

ChoiceSpecs::
; check if the user's item is Choice Specs

	push bc
	farcall GetUserItem
	ld a, b
	cp HELD_CHOICE_SPECS
	pop bc
	ret nz

	call PhysOrSpec
	ret c

; boost special attack stat in de by 50%
	ld a, e
	srl a
	add e
	ld e, a
	ret nc

	srl d
	ld a, d
	and a
	jr nz, .done
	inc d
.done
	scf
	rr e
	ret

PhysOrSpec: ; nc mean special, c means physical
; check who's attacking
	push hl
	ldh a, [hBattleTurn]
	and a
	jr nz, .enemyatk

; check if physical attack was used
	ld hl, wPlayerMoveStructPower + 1
	ld a, [hl]
	cp SPECIAL
	jr .done
	
.enemyatk
	ld hl, wEnemyMoveStructPower + 1
	ld a, [hl]
	cp SPECIAL
	
.done
	pop hl
	ret


ChoiceScarf::
; modifies speed stat for player/enemy
; called right before speed checks

	ld a, [wBattleMonSpeed]
	ld d, a
	ld a, [wBattleMonSpeed + 1]
	ld e, a

	ld a, [wBattleMonItem]
	cp CHOICE_SCARF
	jr nz, .finish

	; boost speed stat by 50%
	
	ld a, e
	srl a
	add e
	ld e, a
	jr nc, .finish

	srl d
	ld a, d
	and a
	jr nz, .done
	inc d
.done
	scf
	rr e

.finish
	ld a, d
	ld [wBattleMonChoiceScarfSpeed], a
	ld a, e
	ld [wBattleMonChoiceScarfSpeed + 1], a

; enemy

	ld a, [wEnemyMonSpeed]
	ld d, a
	ld a, [wEnemyMonSpeed + 1]
	ld e, a

	ld a, [wEnemyMonItem]
	cp CHOICE_SCARF
	jr nz, .finish2
	
	; boost speed stat by 50%
	
	ld a, e
	srl a
	add e
	ld e, a
	jr nc, .finish2

	srl d
	ld a, d
	and a
	jr nz, .done2
	inc d
.done2
	scf
	rr e

.finish2
	ld a, d
	ld [wEnemyMonChoiceScarfSpeed], a
	ld a, e
	ld [wEnemyMonChoiceScarfSpeed + 1], a
	
	ret



HandleBetweenMovesEffects::
; handles life orb damage and berries
; used in engine/battle/core.asm

	push bc
	push hl
	
	farcall HandleHPHealingItem
	farcall UseHeldStatusHealingItem
	farcall HandleMysteryberry
	
	farcall SwitchTurnCore
	
	farcall HandleHPHealingItem
	farcall UseHeldStatusHealingItem
	farcall HandleMysteryberry
	
	farcall SwitchTurnCore

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
	ld hl, wPlayerItemFlags
	set BATTLEITEMFLAG_LIFEORB, [hl]
	jr .pop_ret

; enemy
.enemyturn
	farcall HasPlayerFainted
	jr nz, .do_damage
	
; set flag for HandleBetweenTurnsEffects
	ld hl, wEnemyItemFlags
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



HandleFlameOrbToxicOrb::
	ld a, [wEnemyGoesFirst]
	and a
	jr nz, .EnemyFirst
	call SetPlayerTurn
	call .do_it
	call SetEnemyTurn
	jp .do_it

.EnemyFirst:
	call SetEnemyTurn
	call .do_it
	call SetPlayerTurn

.do_it
; check for status
	ld a, BATTLE_VARS_STATUS
	call GetBattleVar
	and a
	ret nz

	callfar GetUserItem
	ld a, b
	cp HELD_FLAME_ORB
	jr z, .flame_orb
	cp HELD_TOXIC_ORB
	ret nz
	
; toxic_orb
; check for poison-type
	ld de, wEnemyMonType1
	ldh a, [hBattleTurn]
	and a
	jr nz, .ok1
	ld de, wBattleMonType1
.ok1
	ld a, [de]
	inc de
	cp POISON
	ret z
	ld a, [de]
	cp POISON
	ret z

	ld de, ANIM_PSN
	farcall Call_PlayBattleAnim_OnlyIfVisible
	
	ld a, BATTLE_VARS_STATUS
	call GetBattleVarAddr
	set PSN, [hl]
	set TOX, [hl]
	call UpdateUserInParty
	call UpdateBattleHuds
	ld hl, ToxicOrbText
	jp StdBattleTextbox

.flame_orb	
; check for fire-type
	ld de, wEnemyMonType1
	ldh a, [hBattleTurn]
	and a
	jr nz, .ok2
	ld de, wBattleMonType1
.ok2
	ld a, [de]
	inc de
	cp FIRE
	ret z
	ld a, [de]
	cp FIRE
	ret z

	ld de, ANIM_BRN
	farcall Call_PlayBattleAnim_OnlyIfVisible
	
	ld a, BATTLE_VARS_STATUS
	call GetBattleVarAddr
	set BRN, [hl]
	call UpdateUserInParty
	call UpdateBattleHuds
	ld hl, FlameOrbText
	jp StdBattleTextbox




FocusSash::
; get correct HP
	ld hl, wEnemyMonMaxHP
	ld de, wEnemyMonHP
	ldh a, [hBattleTurn]
	and a
	jr z, .got_hp
	ld hl, wBattleMonMaxHP
	ld de, wBattleMonHP
.got_hp
; checks if opponent is at full HP
	ld c, 2
	push hl
	push de
	call CompareBytes
	pop de
	pop hl
	ret c ; HP < Max HP

; checks if wCurDamage >= opponent's max HP
	ld de, wCurDamage
	ld c, 2
	push hl
	push de
	call CompareBytes
	pop de
	pop hl
	ret c ; if there's no carry then wCurDamage >= opponent's max HP

	ld hl, wEnemyMonHP
	ldh a, [hBattleTurn]
	and a
	jr z, .got_hp_again
	ld hl, wBattleMonHP
.got_hp_again
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	dec a
	ld [de], a

	inc a
	jr nz, .okay
	dec de
	ld a, [de]
	dec a
	ld [de], a

.okay
	and a
	ret

ConsumeFocusSash::
	push hl
	push de
	push bc
	ldh a, [hBattleTurn]
	and a
	ld hl, wOTPartyMon1Item
	ld de, wEnemyMonItem
	ld a, [wCurOTMon]
	jr z, .theirturn
	ld hl, wPartyMon1Item
	ld de, wBattleMonItem
	ld a, [wCurBattleMon]

.theirturn
	xor a
	ld [de], a
	call GetPartyLocation
	ld [hl], NO_ITEM
	pop bc
	pop de
	pop hl
	ret





