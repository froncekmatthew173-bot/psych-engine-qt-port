function onEvent(n, v1, v2)
	if n == 'SetHealthIcon' then
		if v1 == 'bf' or v1 == 'boyfriend' or v1 == '0' then
			runHaxeCode("game.iconP1.changeIcon('" .. v2 .. "');")
		elseif v1 == 'dad' or v1 == '1' then
			runHaxeCode("game.iconP2.changeIcon('" .. v2 .. "');")
		end
	end
end
