BattleCommand_StartHail:
; starthail

	ld a, [wBattleWeather2]
	cp WEATHER_HAIL
	jr z, .failed

	xor a
	ld [wBattleWeather], a
	ld a, WEATHER_HAIL
	ld [wBattleWeather2], a
	
	push bc
	call GetUserItem
	ld a, b
	cp HELD_ICY_ROCK
	pop bc
	ld a, 8
	jr z, .eight
	ld a, 5
	
.eight
	ld [wWeatherCount], a
	call AnimateCurrentMove
	ld hl, HailStartedText
	jp StdBattleTextbox

.failed
	call AnimateFailedMove
	jp PrintButItFailed
