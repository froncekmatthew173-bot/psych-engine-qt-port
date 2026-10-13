function onCreatePost()
	if shadersEnabled then
		-- REGISTRO DE CALLBACK HAXE CON OFFSET PARA DAD
		runHaxeCode([[
			import flixel.math.FlxAngle;
			import flixel.FlxSprite;

			setVar('setShaderFrameInfo', function(objectName:String) {
				var object:FlxSprite = null;
				switch(objectName) {
					case 'boyfriend': object = game.boyfriend;
					case 'dad': object = game.dad;
					case 'gf': object = game.gf;
					default: object = game.getLuaObject(objectName);
				}

				if (object != null) {
					object.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int) {
						if (object.shader != null && object.frame != null) {
							var offX:Float = 0.0;
							var offY:Float = 0.0;
							
							if (objectName == 'dad') {
								var sprX = game.getLuaObject('dad_shadow_offsetX');
								var sprY = game.getLuaObject('dad_shadow_offsetY');
								if (sprX != null) offX = sprX.x;
								if (sprY != null) offY = sprY.y;
							}

							object.shader.setFloatArray('uFrameBounds', [
								object.frame.uv.x + offX, 
								object.frame.uv.y + offY, 
								object.frame.uv.width, 
								object.frame.uv.height
							]);
							object.shader.setFloat('angOffset', object.frame.angle * FlxAngle.TO_RAD);
						}
					};
				}
			});
		]])

		-- SPRITES CONTENEDORES PARA CONTROLAR OFFSET DE LA SOMBRA DE DAD
		makeLuaSprite('dad_shadow_offsetX', '', 0, 0)
		makeLuaSprite('dad_shadow_offsetY', '', 0, 0)

		---------------------------------------------------------------------------------
		-- CONFIGURA AQUÍ EL DESFASE DEL DAD (Ajusta si la sombra sigue corrida)
		---------------------------------------------------------------------------------
		setProperty('dad_shadow_offsetX.x', 0)  
		setProperty('dad_shadow_offsetY.y', 0) 
		---------------------------------------------------------------------------------

		initLuaShader('dropShadow')

		-- APLICAR AL INICIO
		applyShader('dad')
		applyShader('boyfriend')
		applyShader('gf')
      applyShader('kbIntro')
      applyShader('kbEnding')
      applyShader('Speaker')
      applyShader('gfDodge')
      applyShader('bfDodge')
      applyShader('bfErect')
	end
end


-- 🔥 FUNCIÓN SHADER
function applyShader(obj)

	removeSpriteShader(obj)
	setSpriteShader(obj, 'dropShadow')

	-- Ajustes generales de color e iluminación
	setShaderFloat(obj, 'hue', -30)
	setShaderFloat(obj, 'saturation', -65)
	setShaderFloat(obj, 'contrast', 10)
	setShaderFloat(obj, 'brightness', -60)
	setShaderFloat(obj, 'AA_STAGES', 2)

	-- Parámetros específicos por personaje
	if obj == 'boyfriend' then
		setShaderFloat(obj, 'str', 1)
		setShaderFloat(obj, 'ang', math.rad(45))
		setShaderFloat(obj, 'dist', 13)           
		setShaderFloatArray(obj, 'dropColor', {0, 0, 0})
		setShaderFloat(obj, 'thr', 0.1)

	elseif obj == 'dad' then
		setShaderFloat(obj, 'str', 1)
		setShaderFloat(obj, 'ang', math.rad(90)) 
		setShaderFloat(obj, 'dist', 13/2.6)           
		setShaderFloatArray(obj, 'dropColor', {1, 1, 1})
		setShaderFloat(obj, 'thr', 0.25)

   elseif obj == 'kbIntro' or obj == 'kbEnding' then
    setShaderFloat(obj, 'str', 1)
    setShaderFloat(obj, 'ang', math.rad(90))
    setShaderFloat(obj, 'dist', 13/2.6)
    setShaderFloatArray(obj, 'dropColor', {1, 1, 1})
    setShaderFloat(obj, 'thr', 0.25)

	elseif obj == 'gf' then
		setShaderFloat(obj, 'str', 1) 
		setShaderFloat(obj, 'ang', math.rad(135))
		setShaderFloat(obj, 'dist', 13/2)
		setShaderFloatArray(obj, 'dropColor', {1, 1, 1})
		setShaderFloat(obj, 'thr', 0.1)

   elseif obj == 'gfDodge' then
		setShaderFloat(obj, 'str', 1) 
		setShaderFloat(obj, 'ang', math.rad(135))
		setShaderFloat(obj, 'dist', 13/2)
		setShaderFloatArray(obj, 'dropColor', {1, 1, 1})
		setShaderFloat(obj, 'thr', 0.1)

   elseif obj == 'Speaker' then
		setShaderFloat(obj, 'str', 1)
		setShaderFloat(obj, 'ang', math.rad(45))
		setShaderFloat(obj, 'dist', 13)           
		setShaderFloatArray(obj, 'dropColor', {0, 0, 0})
		setShaderFloat(obj, 'thr', 0.1)

    elseif obj == 'bfDodge' then
		setShaderFloat(obj, 'str', 1)
		setShaderFloat(obj, 'ang', math.rad(45))
		setShaderFloat(obj, 'dist', 13)           
		setShaderFloatArray(obj, 'dropColor', {0, 0, 0})
		setShaderFloat(obj, 'thr', 0.1)
 
    elseif obj == 'bfErect' then
		setShaderFloat(obj, 'str', 1)
		setShaderFloat(obj, 'ang', math.rad(45))
		setShaderFloat(obj, 'dist', 13)           
		setShaderFloatArray(obj, 'dropColor', {0, 0, 0})
		setShaderFloat(obj, 'thr', 0.1)

	end

	-- Conectar actualización de frames/bounds
	runHaxeCode("getVar('setShaderFrameInfo')('"..obj.."');")

	-- MÁSCARA SECUNDARIA (altMask)
	local imageFile = stringSplit(getProperty(obj..'.imageFile'), '/')
	if imageFile ~= nil then
		local name = imageFile[#imageFile]
		local maskPath = 'images/characters/masks/'..name..'_mask.png'

		if checkFileExists(maskPath) then
			setShaderSampler2D(obj, 'altMask', 'characters/masks/'..name..'_mask')
			setShaderFloat(obj, 'thr2', 1)
			setShaderBool(obj, 'useMask', true)
		else
			setShaderBool(obj, 'useMask', false)
		end
	end

	-- Regla especial para gf-tankmen
	if obj == 'gf' and _G['gfName'] == 'gf-tankmen' then
		setShaderFloat(obj, 'thr2', 0.4)
	end
end


-- 🔥 CHANGE CHARACTER FIX
-- what the fuck is this, is this a ai made of???
-- vgph mods
function onEvent(event, v1, v2)
	if event == 'Change Character' then
		if shadersEnabled then

			-- limpiar duplicados
			runHaxeCode([[
				if (game.dadGroup.members.length > 1) {
					while (game.dadGroup.members.length > 1) {
						var old = game.dadGroup.members[0];
						game.dadGroup.remove(old, true);
						old.destroy();
					}
				}
			]])

			-- guardar quién cambió
			setProperty('shaderTarget', v1)

			-- pequeño delay necesario en 0.7.3
			runTimer('reapplyShader', 0.01)
		end
	end
end


function onTimerCompleted(tag)
	if tag == 'reapplyShader' then
		local target = getProperty('shaderTarget')

		if target == 'dad' or target == 'opponent' then
			applyShader('dad')
		elseif target == 'boyfriend' then
			applyShader('boyfriend')
		elseif target == 'gf' then
			applyShader('gf')
		end
	end
end


-- 🔥 MANTENER SHADER SIEMPRE ACTIVO
function onUpdate()
	if shadersEnabled then

		if getProperty('dad.shader') == nil then
			applyShader('dad')
		end

		if getProperty('boyfriend.shader') == nil then
			applyShader('boyfriend')
		end

		if getProperty('gf.shader') == nil then
			applyShader('gf')
		end
	end
end