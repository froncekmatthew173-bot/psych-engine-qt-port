-- QT: Rewired - Ironmouse (collab) character script for "Go Go Go (CG5 Collab)"
-- (port of scripts/characters/collab/ironmouse-collab.hxc from the V-Slice mod).
--
-- Adds two overlays on top of Ironmouse:
--   - the tail ("Wiggle Loop"), an element injected into the character's atlas
--     frames at the "Tail Placeholder" symbol, posed per animation and looping
--     at 24fps on its own;
--   - the animated lipsync mouth ("Mouth Placeholder"), frame-scrubbed with the
--     song position so it stays locked to the vocals.
-- Here both are separate Sparrow sprites (images/characters/go-go-go/tail-ironmouse
-- and lipsync-ironmouse, converted from the original Animate atlases) that follow
-- the character and replicate that behavior. If a sheet is missing the script
-- just skips that overlay instead of crashing.
-- Isolated on purpose: only touches its own overlay sprites.
-- NOTE: like the rest of the port, written for Psych Engine 0.7.3.

local LANG = 'english' -- 'english' | 'spanish'

local TAIL = 'ironTail'
local LIPS = 'ironLipsync'
-- Frame strips of the converted sheets; the first one that has frames wins.
local TAIL_PREFIXES = {'Wiggle Loop', 'wiggle', 'Tail', 'tail'}
local LIP_PREFIXES = {'Lip Sync Full', 'lipsync', 'Mouth', 'mouth', 'mouths library'}
local LIP_SCALE = 1 -- V-Slice customLipScaleX/Y
local FPS = 24

-- Port of IronmouseCollabCharacter.TAIL_OFFSETS (the per-animation part of the
-- tail pose; the V-Slice adds tailGlobalOffset on top of these).
local TAIL_OFFSETS = {
	['singLEFT'] = {5, -9.5},
	['singLEFT-beautiful'] = {5, -9.5},
	['singLEFT-cool'] = {5, -10},
	['singDOWN'] = {-4, 6},
	['singDOWN-beautiful'] = {-4, 6},
	['singDOWN-cool'] = {-8, 14},
	['singDOWN-go'] = {-8, 14},
	['singUP'] = {8, -15},
	['singUP-beautiful'] = {8, -15},
	['singUP-cool'] = {1, -1.5},
	['mistakeAnimation'] = {12, -24},
	['singRIGHT'] = {-2, 7},
	['singRIGHT-beautiful'] = {-2, 7},
	['singRIGHT-cool'] = {-20, 29},
}
local TAIL_GLOBAL = {2, 68} -- V-Slice tailGlobalOffsetX/Y

-- Port of IronmouseCollabCharacter.LIP_SYNC_OFFSETS: {offsetX, offsetY, angle}.
local LIP_SYNC_OFFSETS = {
	['singLEFT'] = {-43.5, -75, -0.2},
	['singDOWN'] = {-45, -74.5, 0.3},
	['singUP'] = {-42, -76.5, -0.8},
	['singRIGHT'] = {-42, -77, 0.2},
	['singLEFTmiss'] = {-43.5, -74.5, -0.2},
	['singDOWNmiss'] = {-45, -73, 0.3},
	['singUPmiss'] = {-42, -76, -0.8},
	['singRIGHTmiss'] = {-42, -76.5, 0.2},
	['singLEFT-beautiful'] = {-43.5, -74.5, -0.2},
	['singDOWN-beautiful'] = {-45, -73, 0.3},
	['singUP-beautiful'] = {-42, -76, -0.8},
	['singRIGHT-beautiful'] = {-42, -76.5, 0.2},
	['singLEFTmiss-beautiful'] = {-43.5, -74.5, -0.2},
	['singDOWNmiss-beautiful'] = {-45, -73, 0.3},
	['singUPmiss-beautiful'] = {-42, -76, -0.8},
	['singRIGHTmiss-beautiful'] = {-42, -76.5, 0.2},
	['singLEFT-cool'] = {-43.25, -75, -0.8},
	['singDOWN-cool'] = {-46.75, -71, -0.6},
	['singUP-cool'] = {-44, -74.75, 0.2},
	['singRIGHT-cool'] = {-43.75, -75, -0.4},
	['singDOWN-go'] = {-46.75, -71, -0.6},
	['singLEFTmiss-cool'] = {-43.25, -75, -0.8},
	['singDOWNmiss-cool'] = {-46.75, -71, -0.6},
	['singUPmiss-cool'] = {-44, -74.75, 0.2},
	['singRIGHTmiss-cool'] = {-43.75, -75, -0.4},
	['mistakeAnimation'] = {-40.75, -78, -0.6},
	['stayAnimation'] = {-47, -72, 1.2},
}

local tailReady = false
local lipsReady = false

local function debugMsg(msg)
	debugPrint('[QT: Rewired] ironmouse-collab: ' .. msg)
end

local function animFrameCount(name)
	local ok, res = pcall(function()
		return runHaxeCode('return getLuaObject("' .. LIPS .. '").animation.getByName("' .. name .. '").numFrames;')
	end)
	if ok and tonumber(res) then return tonumber(res) end
	return 0
end

local function makeOverlay(sprite, path, prefixes, animName, loop)
	local chosen = nil
	for _, prefix in ipairs(prefixes) do
		addAnimationByPrefix(sprite, animName, prefix, FPS, loop)
		if sprite == LIPS and animFrameCount(animName) > 0 then
			chosen = prefix
			break
		elseif sprite ~= LIPS then
			-- The tail sheet only needs any usable strip; frame counts are not
			-- easily readable from here, so take the first prefix that the atlas
			-- actually contains (an empty anim is harmless but stays on frame 0).
			chosen = prefix
			break
		end
	end
	return chosen
end

function onCreate()
	local charScale = getProperty('gf.scale.x')

	local okTail = pcall(function()
		makeAnimatedLuaSprite(TAIL, 'characters/go-go-go/tail-ironmouse', getProperty('gf.x'), getProperty('gf.y'))
		scaleObject(TAIL, charScale, charScale)
		local chosen = makeOverlay(TAIL, nil, TAIL_PREFIXES, 'wiggle', true)
		if chosen == nil then return end
		playAnim(TAIL, 'wiggle', true)
		setObjectCamera(TAIL, 'game')
		setObjectOrder(TAIL, getObjectOrder('gf') + 1) -- draw right on top of Ironmouse
		addLuaSprite(TAIL)
		tailReady = true
	end)
	if not okTail or not tailReady then
		debugMsg('tail overlay skipped (is images/characters/go-go-go/tail-ironmouse present?)')
	end

	local okLips = pcall(function()
		makeAnimatedLuaSprite(LIPS, 'characters/go-go-go/lipsync-ironmouse', getProperty('gf.x'), getProperty('gf.y'))
		scaleObject(LIPS, LIP_SCALE * charScale, LIP_SCALE * charScale)
		local chosen = makeOverlay(LIPS, nil, LIP_PREFIXES, 'sync', false)
		if chosen == nil then
			debugMsg('no mouth frames found in lipsync-ironmouse (tried: ' .. table.concat(LIP_PREFIXES, ', ') .. ')')
			return
		end
		playAnim(LIPS, 'sync', true)
		setProperty(LIPS .. '.animPaused', true) -- frames are scrubbed with the song below
		setProperty(LIPS .. '.visible', false)   -- only shown while a mapped pose is active
		setObjectCamera(LIPS, 'game')
		setObjectOrder(LIPS, getObjectOrder('gf') + 1)
		addLuaSprite(LIPS)
		lipsReady = true
	end)
	if not okLips or not lipsReady then
		debugMsg('lipsync overlay skipped (is images/characters/go-go-go/lipsync-ironmouse present?)')
	end
end

local function updateOverlays()
	local anim = getProperty('gf.animation.name')
	local charScale = getProperty('gf.scale.x')

	-- Port of the tail pose from playAnimation(): per-anim offset + global offset,
	-- drawn at -offset inside the character frame, always visible.
	if tailReady then
		local off = TAIL_OFFSETS[anim] or {0, 0}
		local ox = off[1] + TAIL_GLOBAL[1]
		local oy = off[2] + TAIL_GLOBAL[2]
		setProperty(TAIL .. '.x', getProperty('gf.x') + (-ox) * charScale)
		setProperty(TAIL .. '.y', getProperty('gf.y') + (-oy) * charScale)
		-- V-Slice pivots the tail around (frameWidth/2 + offsetX, frameHeight/2 + offsetY).
		setProperty(TAIL .. '.origin.x', getProperty(TAIL .. '.frameWidth') * 0.5 + ox)
		setProperty(TAIL .. '.origin.y', getProperty(TAIL .. '.frameHeight') * 0.5 + oy)
		setProperty(TAIL .. '.visible', getProperty('gf.visible'))
		setProperty(TAIL .. '.alpha', getProperty('gf.alpha'))
		setProperty(TAIL .. '.color', getProperty('gf.color'))
		setScrollFactor(TAIL, getProperty('gf.scrollFactor.x'), getProperty('gf.scrollFactor.y'))
		-- Restart the wiggle loop if it ever stopped (V-Slice does the same).
		if getProperty(TAIL .. '.animation.curAnim.finished') then
			playAnim(TAIL, 'wiggle', true)
		end
	end

	-- Port of applyLipSyncPose() + the song-position frame scrub.
	if lipsReady then
		local pose = nil
		if anim ~= nil then
			pose = LIP_SYNC_OFFSETS[anim]
			if pose == nil then
				-- V-Slice getLipSyncPose() falls back to the name with "miss" stripped.
				pose = LIP_SYNC_OFFSETS[anim:gsub('miss', '')]
			end
		end

		if pose == nil then
			setProperty(LIPS .. '.visible', false)
		else
			local ox, oy, ang = pose[1], pose[2], pose[3]
			setProperty(LIPS .. '.x', getProperty('gf.x') + (-ox) * charScale)
			setProperty(LIPS .. '.y', getProperty('gf.y') + (-oy) * charScale)
			setProperty(LIPS .. '.angle', ang)
			setProperty(LIPS .. '.origin.x', getProperty(LIPS .. '.frameWidth') * 0.5 + ox)
			setProperty(LIPS .. '.origin.y', getProperty(LIPS .. '.frameHeight') * 0.5 + oy)
			setProperty(LIPS .. '.visible', getProperty('gf.visible'))
			setProperty(LIPS .. '.alpha', getProperty('gf.alpha'))
			setProperty(LIPS .. '.color', getProperty('gf.color'))
			setScrollFactor(LIPS, getProperty('gf.scrollFactor.x'), getProperty('gf.scrollFactor.y'))

			local songTime = getProperty('songPosition')
			if songTime < 0 then songTime = 0 end
			local frame = math.floor(songTime / 1000 * FPS)
			local lastFrame = (getProperty(LIPS .. '.animation.curAnim.numFrames') or 1) - 1
			if lastFrame < 0 then lastFrame = 0 end
			if frame > lastFrame then frame = lastFrame end
			setProperty(LIPS .. '.animation.curFrame', frame)
		end
	end
end

function onUpdate()
	if not tailReady and not lipsReady then return end
	local ok, err = pcall(updateOverlays)
	if not ok then debugMsg('overlay update error: ' .. tostring(err)) end
end
