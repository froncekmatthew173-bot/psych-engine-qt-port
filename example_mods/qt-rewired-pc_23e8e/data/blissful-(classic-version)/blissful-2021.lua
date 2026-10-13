-- QT: Rewired - blissful-2021 song script (port of songs/blissful-2021.hx)
-- The chart starts against qt-legacy; at beat 287 the opponent swaps to qt-kb-legacy.
-- (The original also ships a heavy custom KE-style HUD; that was intentionally not
--  ported to avoid clashing with the shared HUD layer, so default scoring is used.)

function onCreate()
	addCharacterToList('qt-kb-legacy', 'dad')
	addCharacterToList('qt-legacy', 'dad')
end

function onBeatHit()
	if curBeat == 287 then
		triggerEvent('Change Character', 'dad', 'qt-kb-legacy')
	end
end
