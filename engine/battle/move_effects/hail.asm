BattleCommand_StartHail:
; starthail

	ld a, [wBattleWeather2]
	cp WEATHER_HAIL
	jr z, .failed

	xor a
	ld [wBattleWeather], a
	ld a, WEATHER_HAIL
	ld [wBattleWeather2], a
	ld a, 5
	ld [wWeatherCount], a
	call AnimateCurrentMove
	ld hl, HailStartedText
	jp StdBattleTextbox

.failed
	call AnimateFailedMove
	jp PrintButItFailed
