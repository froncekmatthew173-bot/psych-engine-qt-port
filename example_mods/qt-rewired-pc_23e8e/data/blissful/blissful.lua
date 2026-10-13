-- QT: Rewired - blissful song script (port of songs/blissful.hxc)
-- Plays the "hi cutie" intro cutscene before the countdown, then a short outro transform.

local seenIntro = false
local exitSong = true
local dir = 'gameplay/cutsceneSfx/bf/'
local introMusic = 'gameplay/introSong/introSong-default'

local function tween(x, y, d, e)
	setProperty('isCameraOnForcedPos', true)
	cancelTween('camx')
	cancelTween('camy')
	doTweenX('camx', 'camFollow', x, d, e)
	doTweenY('camy', 'camFollow', y, d, e)
end

local function tweenZoom(t, d, e)
	cancelTween('camzb')
	doTweenZoom('camzb', 'camGame', t, d, e)
end

local function showHUD(d)
	setProperty('camHUD.visible', true)
	setProperty('camHUD.alpha', 0)
	doTweenAlpha('hudin', 'camHUD', d or 1, 0.6, 'smoothStepInOut')
end

function onStartCountdown()
	if seenIntro then return end
	seenIntro = true

	setProperty('camHUD.visible', false)
	setProperty('camHUD.alpha', 0)

	-- focus the opponent and start the intro music
	playSound(introMusic, 0.4, 'intromusic')
	playSound('gameplay/countdown/english/hi_cutie', 1, 'cutie')
	triggerEvent('LyricsInGame', 'Hi Cutie!', '')

	characterPlayAnim('dad', 'still', true)
	cameraFade('game', '000000', 2.75, true)

	local oppX = getMidpointX('dad') + 150
	local oppY = getMidpointY('dad') - 100
	tween(oppX, oppY - 235, 0.001, 'linear')
	tween(oppX, oppY, 2.75, 'expoOut')
	tweenZoom(getProperty('defaultCamZoom') * 1.1875, 2.75, 'expoOut')

	runTimer('introAnim', 0.5)
	runTimer('introStart', 4)

	return Function_Stop
end

function onTimerCompleted(t)
	if t == 'introAnim' then
		characterPlayAnim('dad', 'intro', true)
	end

	if t == 'introStart' then
		triggerEvent('LyricsInGame', '', '')
		soundFadeOut('cutie', 0.2, 0)
		soundFadeOut('intromusic', 0.2, 0)
		tweenZoom(getProperty('defaultCamZoom'), 4, 'smoothStepInOut')
		showHUD(1)
		startCountdown()
	end

	if t == 'endFade' then
		endSong()
	end
end

function onEndSong()
	if exitSong then
		exitSong = false
		setProperty('camHUD.alpha', 0)
		setProperty('camHUD.visible', false)
		characterPlayAnim('dad', 'transform', true)
		playSound(dir .. 'qt_transform', 1)
		cameraFade('game', '000000', 2.5, false)
		runTimer('endFade', 3)
		return Function_Stop
	end
end
