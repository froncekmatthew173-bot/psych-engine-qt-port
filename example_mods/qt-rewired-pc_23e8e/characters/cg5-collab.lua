-- QT: Rewired - CG5 (collab) character script for "Go Go Go (CG5 Collab)"
-- (port of scripts/characters/collab/cg5-collab.hxc from the V-Slice mod).
--
-- Adds the animated lipsync mouth overlay on top of CG5. In V-Slice the mouth
-- is an element injected into the character's atlas frames (replacing the
-- "mouth lipsync placeholder" symbol), posed per sing animation and frame-scrubbed
-- with the song position so it stays locked to the vocals. Here it is a separate
-- Sparrow sprite (images/characters/go-go-go/lipsync-cg5, converted from the
-- original Animate atlas) that follows the character and replicates that behavior.
-- Isolated on purpose: only touches its own overlay sprite.
-- NOTE: like the rest of the port, written for Psych Engine 0.7.3.

local LANG = 'english' -- 'english' | 'spanish'

local OVERLAY = 'cg5Lipsync'
-- Frame strips of the converted mouth sheet; the first one that has frames wins.
local PREFIXES = {'cg5 mouths library', 'Lip Sync Full', 'lipsync'}
local LIP_SCALE = 1.06 -- V-Slice customLipScaleX/Y
local FPS = 24

-- Port of CG5CollabCharacter.LIP_SYNC_OFFSETS: {offsetX, offsetY, angle}.
-- The V-Slice overlay is drawn inside the character frame at -offset from the
-- character origin, so we anchor it to the character sprite the same way.
local LIP_SYNC_OFFSETS = {
	['singLEFT-lipsync'] = {-37, -42.5, 0.2},
	['singDOWN-lipsync'] = {-36, -43.5, 0.8},
	['singUP-lipsync'] = {-32, -48, 0.1},
	['singRIGHT-lipsync'] = {-31, -49, -0.2},
}

local created = false

local function debugMsg(msg)
	debugPrint(LANG == 'spanish'
		and ('[QT: Rewired] cg5-collab: ' .. msg)
		or ('[QT: Rewired] cg5-collab: ' .. msg))
end

local function animFrameCount(name)
	local ok, res = pcall(function()
		return runHaxeCode('return getLuaObject("' .. OVERLAY .. '").animation.getByName("' .. name .. '").numFrames;')
	end)
	if ok and tonumber(res) then return tonumber(res) end
	return 0
end

function onCreate()
	local ok = pcall(function()
		makeAnimatedLuaSprite(OVERLAY, 'characters/go-go-go/lipsync-cg5', getProperty('dad.x'), getProperty('dad.y'))
		-- The mouth scales with the character (CG5 json scale ~= 1.04) plus its own 1.06.
		local charScale = getProperty('dad.scale.x')
		scaleObject(OVERLAY, LIP_SCALE * charScale, LIP_SCALE * charScale)

		local chosen = nil
		for _, prefix in ipairs(PREFIXES) do
			addAnimationByPrefix(OVERLAY, 'sync', prefix, FPS, false)
			if animFrameCount('sync') > 0 then
				chosen = prefix
				break
			end
		end
		if chosen == nil then
			debugMsg('no mouth frames found in lipsync-cg5 (tried: ' .. table.concat(PREFIXES, ', ') .. ')')
			return
		end

		playAnim(OVERLAY, 'sync', true)
		setProperty(OVERLAY .. '.animPaused', true) -- frames are scrubbed with the song below
		setProperty(OVERLAY .. '.visible', false)   -- only shown during the lipsync poses
		setObjectCamera(OVERLAY, 'game')
		setObjectOrder(OVERLAY, getObjectOrder('dad') + 1) -- draw right on top of CG5
		addLuaSprite(OVERLAY)
		created = true
	end)
	if not ok or not created then
		debugMsg('could not create the lipsync overlay (is images/characters/go-go-go/lipsync-cg5 present?)')
	end
end

-- Port of applyLipSyncPose() + the song-position frame scrub from onUpdate().
local function updateOverlay()
	local anim = getProperty('dad.animation.name')
	local pose = nil
	if anim ~= nil then
		pose = LIP_SYNC_OFFSETS[anim]
		if pose == nil then
			-- V-Slice getLipSyncPose() falls back to the name with "miss" stripped.
			pose = LIP_SYNC_OFFSETS[anim:gsub('miss', '')]
		end
	end

	if pose == nil then
		setProperty(OVERLAY .. '.visible', false)
		return
	end

	local ox, oy, ang = pose[1], pose[2], pose[3]
	local charScale = getProperty('dad.scale.x')

	-- Follow the character (V-Slice draws the overlay at -offset inside the frame).
	setProperty(OVERLAY .. '.x', getProperty('dad.x') + (-ox) * charScale)
	setProperty(OVERLAY .. '.y', getProperty('dad.y') + (-oy) * charScale)
	setProperty(OVERLAY .. '.angle', ang)
	-- V-Slice pivots the mouth around (frameWidth/2 + offsetX, frameHeight/2 + offsetY).
	setProperty(OVERLAY .. '.origin.x', getProperty(OVERLAY .. '.frameWidth') * 0.5 + ox)
	setProperty(OVERLAY .. '.origin.y', getProperty(OVERLAY .. '.frameHeight') * 0.5 + oy)

	setProperty(OVERLAY .. '.visible', getProperty('dad.visible'))
	setProperty(OVERLAY .. '.alpha', getProperty('dad.alpha'))
	setProperty(OVERLAY .. '.color', getProperty('dad.color'))
	setScrollFactor(OVERLAY, getProperty('dad.scrollFactor.x'), getProperty('dad.scrollFactor.y'))

	-- Scrub the mouth frames with the song position (V-Slice:
	-- targetFrame = songTime / 1000 * frameRate, clamped to the last frame).
	local songTime = getProperty('songPosition')
	if songTime < 0 then songTime = 0 end
	local frame = math.floor(songTime / 1000 * FPS)
	local lastFrame = (getProperty(OVERLAY .. '.animation.curAnim.numFrames') or 1) - 1
	if lastFrame < 0 then lastFrame = 0 end
	if frame > lastFrame then frame = lastFrame end
	setProperty(OVERLAY .. '.animation.curFrame', frame)
end

function onUpdate()
	if not created then return end
	local ok, err = pcall(updateOverlay)
	if not ok then debugMsg('overlay update error: ' .. tostring(err)) end
end
