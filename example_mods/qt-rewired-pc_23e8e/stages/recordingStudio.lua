-- QT: Rewired - recordingStudio (port of scripts/stages/recordingStudio.hxc)
-- Cinematic studio stage: darkness toggle, lamp hue shifts, white flashes and the outro buildup.
-- Each Psych Lua file is isolated, so the V-Slice stage functions are exposed through onEvent:
-- EnableDarkness / DisableDarkness / SetLightHueLinear (v1=hue, v2=duration) /
-- SetLightHueInstant (v1=hue, v2=duration) / EnableBlackScreen / DisableBlackScreen /
-- WhiteFlash (v1=duration) / StartOutroBuildup (v1=duration) / StopOutroBuildup

local darkProps = {
	'foregroundChairDark',
	'deskDark',
	'couchDark',
	'chairDark',
	'overlayGlowDark',
	'lightDark',
	'wallsDark'
}
local shaderTargets = {'overlayGlowDark', 'overlayLamp', 'lightDark'}

-- lightShader state (tweened by setLightHueLinear / setLightHueInstant)
local lightHue, lightHueStart, lightHueTarget = 0, 0, 0
local lightHueT, lightHueDur = 0, 0
local lightBright, lightBrightStart, lightBrightTarget = 0, 0, 0
local lightBrightT, lightBrightDur = 0, 0

-- outro buildup state
local hasHidden = false
local isShaking = false
local shakeDuration = 0
local shakeElapsed = 0
local shaderRetry = true

-- setProperty that quietly ignores props that don't exist
function setProp(p, v)
	pcall(setProperty, p, v)
end

-- attach the adjustColor shader to the lamp/glow overlays (buildStage in the hxc)
function applyLightShader()
	if not shadersEnabled or version:find('7.3') then return end
	for _, t in ipairs(shaderTargets) do
		pcall(function()
			setSpriteShader(t, 'adjustColor')
			setShaderFloat(t, 'hue', lightHue)
			setShaderFloat(t, 'saturation', 0)
			setShaderFloat(t, 'contrast', 0)
			setShaderFloat(t, 'brightness', lightBright)
		end)
	end
end

-- push the current hue/brightness into the already-attached shader (FlxTween on lightShader in the hxc)
function pushLightShader()
	if not shadersEnabled or version:find('7.3') then return end
	for _, t in ipairs(shaderTargets) do
		pcall(function()
			setShaderFloat(t, 'hue', lightHue)
			setShaderFloat(t, 'brightness', lightBright)
		end)
	end
end

-- stage-wide character shader (colorShader in the hxc)
function updateColorShader(h, s, c, b)
	if not shadersEnabled or version:find('7.3') then return end
	for _, t in ipairs({'boyfriend', 'dad', 'gf'}) do
		pcall(function()
			setSpriteShader(t, 'adjustColor')
			setShaderFloat(t, 'hue', h)
			setShaderFloat(t, 'saturation', s)
			setShaderFloat(t, 'contrast', c)
			setShaderFloat(t, 'brightness', b)
		end)
	end
end

function onCreate()
	-- dark duplicates start hidden (alpha 0 in the V-Slice stage data)
	for _, p in ipairs(darkProps) do
		setProp(p..'.alpha', 0)
	end

	-- lamp/glow overlays use hardlight blending (blend isn't stored in the porter JSON)
	setProp('overlayLamp.blend', 5)
	setProp('overlayGlowDark.blend', 5)

	applyLightShader()
	updateColorShader(5, 5, 3, 3) -- brightness 3, hue 5, contrast 3, saturation 5
end

function onCreatePost()
	-- hxc onSongLoaded/onUpdate: hide the opponent strumline (cinematic stage)
	-- (combo popups are engine-side in Psych and can't be removed from here)
	if not hasHidden then
		hasHidden = true
		setProp('opponentStrums.visible', false)
	end
	applyLightShader()
	updateColorShader(5, 5, 3, 3)
end

function onUpdatePost(el)
	if shaderRetry then
		shaderRetry = false
		applyLightShader()
		updateColorShader(5, 5, 3, 3)
	end

	el = el or 1 / 60

	-- linear hue tween (setLightHueLinear)
	if lightHueDur > 0 then
		lightHueT = lightHueT + el
		local p = math.min(lightHueT / lightHueDur, 1)
		lightHue = lightHueStart + (lightHueTarget - lightHueStart) * p
		if p >= 1 then lightHueDur = 0 end
		pushLightShader()
	end

	-- brightness flash decaying quadOut (setLightHueInstant)
	if lightBrightDur > 0 then
		lightBrightT = lightBrightT + el
		local p = math.min(lightBrightT / lightBrightDur, 1)
		local eased = 1 - (1 - p) * (1 - p)
		lightBright = lightBrightStart + (lightBrightTarget - lightBrightStart) * eased
		if p >= 1 then lightBrightDur = 0 end
		pushLightShader()
	end

	-- increasing camera shake for the outro buildup (buildupTween in the hxc)
	if isShaking then
		shakeElapsed = shakeElapsed + el
		local p = math.min(shakeElapsed / math.max(shakeDuration, 0.01), 1)
		cameraShake('game', 0.0125 * (2 ^ (10 * (p - 1))), 0.05, true) -- expoIn ramp 0 -> 0.0125
	end
end

-- ===== V-Slice stage API =====

function enableDarkness()
	for _, p in ipairs(darkProps) do
		setProp(p..'.alpha', 1)
	end
	updateColorShader(-20, -21, -45, -95)
	for _, t in ipairs({'boyfriend', 'dad', 'gf'}) do
		setProp(t..'.color', getColorFromHex('CDCDD1'))
	end
end

function disableDarkness()
	for _, p in ipairs(darkProps) do
		setProp(p..'.alpha', 0)
	end
	updateColorShader(5, 5, 3, 3)
	for _, t in ipairs({'boyfriend', 'dad', 'gf'}) do
		setProp(t..'.color', getColorFromHex('FFFFFF'))
	end
end

function setLightHueLinear(targetHue, duration)
	lightHueStart = lightHue
	lightHueTarget = targetHue or 0
	lightHueT = 0
	lightHueDur = (duration and duration > 0) and duration or 0
	if lightHueDur == 0 then
		lightHue = lightHueTarget
		pushLightShader()
	end
end

function setLightHueInstant(targetHue, duration)
	lightHue = targetHue or 0
	lightHueTarget = lightHue
	lightHueDur = 0

	lightBright = 30
	lightBrightStart = 30
	lightBrightTarget = 0
	lightBrightT = 0
	lightBrightDur = (duration and duration > 0) and duration or 0
	if lightBrightDur == 0 then lightBright = 0 end
	pushLightShader()
end

function enableBlackScreen()
	cameraFade('game', '000000', 0.001, false)
end

function disableBlackScreen()
	cameraFade('game', '000000', 0.001, true)
end

function whiteFlash(duration)
	pcall(removeLuaSprite, 'whiteFlashSpr', true)
	makeLuaSprite('whiteFlashSpr', nil, 0, 0)
	makeGraphic('whiteFlashSpr', math.floor(screenWidth * 3), math.floor(screenHeight * 3), 'FFFFFF')
	setScrollFactor('whiteFlashSpr', 0, 0)
	screenCenter('whiteFlashSpr')
	setProperty('whiteFlashSpr.blend', 11) -- overlay
	setProperty('whiteFlashSpr.alpha', 0.8)
	addLuaSprite('whiteFlashSpr', true)

	duration = duration or 0
	if duration > 0 then
		doTweenAlpha('whiteFlashFade', 'whiteFlashSpr', 0, duration)
		runTimer('whiteFlashCleanup', duration + 0.1)
	else
		pcall(removeLuaSprite, 'whiteFlashSpr', true)
	end
end

function startOutroBuildup(duration)
	duration = (duration and duration > 0) and duration or 1

	pcall(removeLuaSprite, 'whiteFadeSpr', true)
	makeLuaSprite('whiteFadeSpr', nil, 0, 0)
	makeGraphic('whiteFadeSpr', math.floor(screenWidth * 3), math.floor(screenHeight * 3), 'FFFFFF')
	setScrollFactor('whiteFadeSpr', 0, 0)
	screenCenter('whiteFadeSpr')
	setProperty('whiteFadeSpr.blend', 11) -- overlay
	setProperty('whiteFadeSpr.alpha', 0)
	addLuaSprite('whiteFadeSpr', true)

	doTweenAlpha('whiteFade', 'whiteFadeSpr', 0.5, duration)

	isShaking = true
	shakeElapsed = 0
	shakeDuration = duration
end

function stopOutroBuildup()
	isShaking = false
	cameraShake('game', 0, 0, true)
	cancelTween('whiteFade')
	pcall(removeLuaSprite, 'whiteFadeSpr', true)
end

function onTimerCompleted(t)
	if t == 'whiteFlashCleanup' then
		pcall(removeLuaSprite, 'whiteFlashSpr', true)
	end
end

-- custom event bridge so songs can call the stage functions above
function onEvent(n, v1, v2)
	local name = string.lower(n or '')
	local val1 = tonumber(v1) or 0
	local val2 = tonumber(v2) or 0

	if name == 'enabledarkness' then
		enableDarkness()
	elseif name == 'disabledarkness' then
		disableDarkness()
	elseif name == 'setlighthuelinear' then
		setLightHueLinear(val1, val2)
	elseif name == 'setlighthueinstant' then
		setLightHueInstant(val1, val2)
	elseif name == 'enableblackscreen' then
		enableBlackScreen()
	elseif name == 'disableblackscreen' then
		disableBlackScreen()
	elseif name == 'whiteflash' then
		whiteFlash(val1)
	elseif name == 'startoutrobuildup' then
		startOutroBuildup(val1)
	elseif name == 'stopoutrobuildup' then
		stopOutroBuildup()
	end
end
