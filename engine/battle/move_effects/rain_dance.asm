BattleCommand_StartRain:
; startrain

	ld a, [wBattleWeather]
	cp WEATHER_RAIN
	jr z, .failed
	
	xor a
	ld [wBattleWeather2], a
	ld a, WEATHER_RAIN
	ld [wBattleWeather], a
	
	push bc
	call GetUserItem
	ld a, b
	cp HELD_DAMP_ROCK
	pop bc
	ld a, 8
	jr z, .eight
	ld a, 5
	
.eight
	ld [wWeatherCount], a
	call AnimateCurrentMove
	ld hl, DownpourText
	jp StdBattleTextbox
	
.failed
	call AnimateFailedMove
	jp PrintButItFailed
