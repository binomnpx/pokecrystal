BattleCommand_StartSun:
; startsun

	ld a, [wBattleWeather]
	cp WEATHER_SUN
	jr z, .failed

	xor a
	ld [wBattleWeather2], a
	ld a, WEATHER_SUN
	ld [wBattleWeather], a
	
	push bc
	call GetUserItem
	ld a, b
	cp HELD_HEAT_ROCK
	pop bc
	ld a, 8
	jr z, .eight
	ld a, 5
	
.eight
	ld [wWeatherCount], a
	call AnimateCurrentMove
	ld hl, SunGotBrightText
	jp StdBattleTextbox
	
.failed
	call AnimateFailedMove
	jp PrintButItFailed
