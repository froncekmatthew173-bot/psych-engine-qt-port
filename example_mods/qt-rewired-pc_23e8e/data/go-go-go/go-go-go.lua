-- QT: Rewired - go-go-go song script (port of songs/go-go-go.hxc)
-- Story intro cutscene (3 voiced lines with SRT subtitles), the recording-studio
-- dark/strobe rhythm driven through the recordingStudio.lua event bridge,
-- girlfriend reveal at beat 111, clap/outro SFX, and the outro logo sequence.
-- The in-song lyrics themselves are shown by scripts/AwesomeSubtitles.lua.

local LANG = 'english'
local introDone = false
local outroDone = false

local INTRO_LINES = {
	{ time = 0.0,  line = 'cg5-line-1' },
	{ time = 1.24, line = 'qt-line-1' },
	{ time = 2.9,  line = 'cg5-line-2' },
}
local INTRO_DURATION = 5.45

-- ── outro constants (songs/go-go-go.hxc) ───────────────────────────────
local REWIRED_START_SCALE, REWIRED_END_SCALE = 2.0, 0.88
local REWIRED_SHRINK_DURATION = 2.0
local REWIRED_TARGET_X, REWIRED_MOVE_DURATION = -175, 2.2
local COLLAB_X, COLLAB_Y, COLLAB_FADE = 695, 325, 0.4
local CG5_START_X, CG5_END_X, CG5_Y = 800, 865, 230
local CG5_FADE, CG5_MOVE_DURATION = 1.6, 2.5
local COLLAB_DELAY, CG5_DELAY = 0.9, 0.9
local SETTLE_DURATION, OUTRO_HOLD = 2.6, 0.4
local FALL_FADE_DURATION, OUTRO_TOTAL = 2.5, 8.8
local OUTRO_FLASH_ALPHA = 0.115

local function firstSRTLine(name)
	local path = 'data/subtitles/' .. LANG .. '/introGoGoGo/' .. name .. '.srt'
	local ok, raw = pcall(getTextFromFile, path)
	if not ok or not raw or raw == '' then return nil end
	-- grab the first text block after the first timecode line
	local afterArrow = raw:match('%-%->\n(.-)\n\n') or raw:match('%-%->\n(.+)$')
	if not afterArrow then return nil end
	return (afterArrow:gsub('<[^>]*>', ''):gsub('\r', ''))
end

local function showSub(text)
	if text and text ~= '' then
		triggerEvent('LyricsInGame', text, '')
	else
		triggerEvent('LyricsInGame', '', '')
	end
end

function onCreate()
	-- keep the girlfriend hidden until her reveal
	setProperty('gf.visible', false)
end

function onStartCountdown()
	if introDone then return end
	introDone = true

	setProperty('camHUD.visible', false)
	setProperty('camHUD.alpha', 0)
	cameraFade('game', '000000', 0.001, false)

	for _, l in ipairs(INTRO_LINES) do
		runTimer('ggline_' .. l.line, l.time)
	end
	runTimer('ggintro_end', INTRO_DURATION)
	return Function_Stop
end

function onTimerCompleted(t)
	local name = t:match('^ggline_(.+)$')
	if name then
		playSound('gameplay/introGoGoGo/' .. LANG .. '/' .. name, 1, 'ggvo')
		showSub(firstSRTLine(name))
		return
	end

	if t == 'ggintro_end' then
		showSub('')
		cameraFade('game', '000000', 1.2, true)
		setProperty('camHUD.visible', true)
		doTweenAlpha('gghud', 'camHUD', 1, 1, 'smoothStepInOut')
		startCountdown()
	end

	if t == 'ggoutro_end' then
		endSong()
	end
end

-- ── beat-driven light timeline ──────────────────────────────────────────
-- Each entry maps a beat to the recordingStudio.lua bridge calls that the
-- original SongSequence made at that beat (see songs/go-go-go.hxc).
-- gf = girlfriend idle state, one of: '', 'cool', '2', 'cool1', 'cool2'.

local GF_IDLE_SUFFIX = { [''] = '', ['cool'] = '-cool', ['2'] = '-2',
	['cool1'] = 'Cool-1', ['cool2'] = 'Cool-2' }

local TIMELINE = {
	[7] = { hue = {0, 2.0} },
	[15] = { black = true },
	[16] = { dark = false, black = false, flash = 6.0 },
	[111] = { black = true, dark = true },
	[112] = { hue = {75, 1.5}, black = false, flash = 6.0 },
	[127] = { hue = {-180, 1.5} },
	[129] = { hue = {-130, 1.5} },
	[131] = { hue = {-80, 1.5} },
	[133] = { hue = {-30, 1.5} },
	[135] = { hue = {20, 1.5} },
	[137] = { hue = {70, 1.5} },
	[139] = { hue = {120, 1.5} },
	[141] = { hue = {170, 1.5} },
	[144] = { hue = {75, 1.5}, gf = 'cool' },
	[160] = { hue = {100, 2.0}, hueLin = {0, 6.0} },
	[174] = { hue = {0, 1.5} },
	[175] = { black = true, gf = '' },
	[176] = { dark = false, black = false, flash = 6.0 },
	[192] = { gf = 'cool' },
	[211] = { gf = '2' },
	[221] = { gf = 'cool1' },
	[239] = { black = true, dark = true },
	[240] = { gf = 'cool2', black = false, flash = 6.0 },
	[242] = { hue = {120, 1.5} },
	[246] = { hue = {100, 1.5} },
	[250] = { hue = {80, 1.5} },
	[254] = { hue = {120, 1.5} },
	[258] = { hue = {80, 1.5} },
	[262] = { gf = '2', hue = {70, 1.5} },
	[266] = { hue = {120, 1.5}, hueLin = {0, 3.0} },
	[272] = { hue = {0, 1.5}, dark = false, flash = 6.0 },
	[300] = { outroBuildup = 2.5 },
}

local gfIdleState = ''

-- Switch girlfriend to a named idle state and force a re-evaluate + dance.
local function setGfIdleState(state)
	if GF_IDLE_SUFFIX[state] == nil then return end
	gfIdleState = state
	setProperty('gf.idleSuffix', GF_IDLE_SUFFIX[state])
	runHaxeCode([[if (game.gf != null) { game.gf.recalculateDanceIdle(); game.gf.dance(); }]])
end

function onSongStart()
	cameraFade('game', '000000', 6.8, true)
	-- song starts in darkness; the stage enables its own dark overlay at beat 0
	triggerEvent('EnableDarkness', '', '')
end

function onBeatHit()
	-- girlfriend reveal
	local vis = curBeat >= 111
	if getProperty('gf.visible') ~= vis then
		setProperty('gf.visible', vis)
	end

	-- clap / outro cues
	if curBeat == 110 then
		playSound('gameplay/collabClapClap', 1, 'clap')
	end
	if curBeat == 286 then
		playSound('gameplay/collabSongEnd', 1, 'outrosfx')
	end

	local ev = TIMELINE[curBeat]
	if not ev then return end

	if ev.hue then
		triggerEvent('SetLightHueInstant', tostring(ev.hue[1]), tostring(ev.hue[2]))
	end
	if ev.hueLin then
		triggerEvent('SetLightHueLinear', tostring(ev.hueLin[1]), tostring(ev.hueLin[2]))
	end
	if ev.dark == false then
		triggerEvent('DisableDarkness', '', '')
	end
	if ev.black == true then
		triggerEvent('EnableBlackScreen', '', '')
	elseif ev.black == false then
		triggerEvent('DisableBlackScreen', '', '')
	end
	if ev.flash then
		triggerEvent('WhiteFlash', tostring(ev.flash), '')
	end
	if ev.outroBuildup then
		triggerEvent('StartOutroBuildup', tostring(ev.outroBuildup), '')
	end
	if ev.gf ~= nil then
		setGfIdleState(ev.gf)
	end
end

-- block ghost taps during the intro
function noteMissPress()
	if curBeat <= 16 then
		return Function_Stop
	end
end

function onEndSong()
	if outroDone then return end
	outroDone = true
	setProperty('camHUD.visible', false)
	setProperty('isCameraOnForcedPos', true)
	doTweenAlpha('ggbk', 'ggBlack', 1, 0.4)
	setProperty('ggFlash.alpha', 0.115)
	doTweenAlpha('ggfl2', 'ggFlash', 0, 2, 'expoOut')
	runTimer('ggoutro_end', 2.6)
	return Function_Stop
end
