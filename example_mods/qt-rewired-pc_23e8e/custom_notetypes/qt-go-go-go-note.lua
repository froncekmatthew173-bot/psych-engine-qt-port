-- QT: Rewired - custom note type for "Go Go Go (CG5 Collab)" (port of the V-Slice
-- custom notekind `go-go-go-sing` from scripts/notekinds/go-go-go-sing.hxc).
--
-- Every note of this type is hit by three singers at once: CG5 (opponent / dad),
-- Ironmouse (GF slot) and QT (player). The animation each of them plays is picked
-- per note, from the note's params (see `resolveAnim` below), following the same
-- rules as the original:
--   - param1 -> which animation CG5 plays
--     (the V-Slice notekind sends "-lipsync" instead of "" for his base sing
--      anims, so his lipsync overlay pops on the "ah" poses)
--   - param2 -> which animation Ironmouse plays (also drives her tail loop)
--   - param3 -> which animation QT plays
--   0 = base sing anim, 1 = "beautiful", 2 = "cool", 3 = "go", 4 = "cool", but only
--   on Ironmouse's RIGHT (down) note hit; any other value = base sing anim.
-- The notetype itself forces noAnimation so the engine doesn't double-animate the
-- receivers (same approach as our other custom note types).
--
-- Isolated on purpose: it only touches characters during the notetype callbacks.
-- NOTE: like the rest of the port, written for Psych Engine 0.7.3.

local LANG = 'english' -- 'english' | 'spanish'

local MY_TYPE = 'qt-go-go-go-note'
local DIRS = {'LEFT', 'DOWN', 'UP', 'RIGHT'}
-- The three singers and which param drives them (in the same order as the
-- original notekind's singers array).
local SINGERS = {
	{char = 'dad', param = 1},
	{char = 'gf', param = 2},
	{char = 'boyfriend', param = 3},
}

local function getParam(noteId, n)
	local v = getPropertyFromGroup('notes', noteId, 'extra.' .. n)
	if v == nil then return '0' end
	return '' .. v
end

-- Port of GoGoGoSingNote.getSingAnim().
local function resolveAnim(base, value, char, dir)
	if value == '1' then return base .. '-beautiful' end
	if value == '2' or value == '4' then return base .. '-cool' end
	-- Param 4 is only "cool" on Ironmouse's down note, base anim otherwise.
	if value == '3' and not (char == 'gf' and dir == 1) then return base .. '-cool' end
	return base
end

local function singAnim(character, dir, noteId, paramIdx)
	local ok, err = pcall(function()
		local suffix = ''
		local value = getParam(noteId, 'param' .. paramIdx)
		if character == 'dad' and value == '1' then
			-- CG5's base "ah" anims get the lipsync overlay version.
			suffix = '-lipsync'
		end
		local anim = resolveAnim('sing' .. DIRS[dir], value, character, dir) .. suffix
		objectPlayAnim(character, anim, true)
		-- Stop the sing release early so the character can idle between
		-- hits, exactly like the notekind's `char.holdTimer = 0.001`.
		setProperty(character .. '.holdTimer', 0.001)
	end)
	if not ok then debugPrint(LANG == 'spanish'
		and ('[QT: Rewired] Error cantando (notetype): ' .. tostring(err))
		or ('[QT: Rewired] Error while singing (notetype): ' .. tostring(err))) end
end

function onCreate()
	setProperty('noAnimation', true) -- the notetype animates the singers itself
end

-- Called every time a note is hit, for the note's receiver.
function goodNoteHit(id, direction, noteType, isSustainNote)
	if noteType ~= MY_TYPE then return end
	for _, singer in ipairs(SINGERS) do
		singAnim(singer.char, direction, id, singer.param)
	end
end

function noteMiss(id, direction, noteType, isSustainNote)
	if noteType ~= MY_TYPE then return end
	for _, singer in ipairs(SINGERS) do
		objectPlayAnim(singer.char, 'sing' .. DIRS[direction] .. 'miss', true)
		setProperty(singer.char .. '.holdTimer', 0.001)
	end
end
