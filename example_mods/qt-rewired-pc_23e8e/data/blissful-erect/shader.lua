function onCreatePost()
    if shadersEnabled == true then
        runHaxeCode([[
            import flixel.math.FlxAngle;
            import flixel.FlxSprite;

            game.initLuaShader('dropShadow');

            setVar('setShaderFrameInfo', function(objectName:String) {
                var object:FlxSprite = null;
                switch(objectName) {
                    case 'boyfriend':
                        object = game.boyfriend;
                    case 'dad':
                        object = game.dad;
                    case 'gf':
                        object = game.gf;
                     case 'qtIntro':
    object = getVar('qtIntro');

case 'qtDance':
    object = getVar('qtDance');

case 'bfCaramella':
    object = getVar('bfCaramella');
                    default:
                        object = game.getLuaObject(objectName);
                }

                if (object != null) {
                    object.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int) {
                        if (object.shader != null) {
                            var shader = object.shader;
                            
                            var offX:Float = 0.0;
                            var offY:Float = 0.0;
                            
                            if (objectName == 'dad') {
                                offX = game.getLuaObject('dad_shadow_offsetX').x;
                                offY = game.getLuaObject('dad_shadow_offsetY').y;
                            }

                            shader.setFloatArray('uFrameBounds', [
                                object.frame.uv.x + offX, 
                                object.frame.uv.y + offY, 
                                object.frame.uv.width, 
                                object.frame.uv.height
                            ]);
                            shader.setFloat('angOffset', object.frame.angle * FlxAngle.TO_RAD);
                        }
                    };
                }
            });
        ]])

        makeLuaSprite('dad_shadow_offsetX', '', 0, 0)
        makeLuaSprite('dad_shadow_offsetY', '', 0, 0)

        ---------------------------------------------------------------------------------
        -- CONFIGURA AQUÍ EL DESFASE DEL DAD (Si la sombra sigue corrida del pelo)
        ---------------------------------------------------------------------------------
        setProperty('dad_shadow_offsetX.x', 0)  
        setProperty('dad_shadow_offsetY.y', 0) 
        ---------------------------------------------------------------------------------

        initLuaShader('dropShadow')
        
        for i, object in ipairs({
    'boyfriend',
    'dad',
    'gf',
    'qtIntro',
    'qtDance',
    'bfCaramella'
    }) do
            setSpriteShader(object, 'dropShadow')
            
            setShaderFloat(object, 'hue', -25)
            setShaderFloat(object, 'saturation', -20)
            setShaderFloat(object, 'contrast', 0)
            setShaderFloat(object, 'brightness', -40)
            setShaderFloat(object, 'thr', 0.1)
            setShaderFloat(object, 'AA_STAGES', 2)
            
            if object == 'boyfriend' then
                setShaderFloat(object, 'str', 1)
                setShaderFloat(object, 'ang', math.rad(45))
                setShaderFloat(object, 'dist', 13)           
                setShaderFloatArray(object, 'dropColor', {225 / 255, 157 / 255, 151 / 255})
            
            elseif object == 'dad' then
                setShaderFloat(object, 'str', 1)
                setShaderFloat(object, 'ang', math.rad(180)) 
                setShaderFloat(object, 'dist', 13/2.6)           
                setShaderFloatArray(object, 'dropColor', {200 / 255, 99 / 255, 185 / 255})
                setShaderFloat(object, 'thr', 0.05)

           elseif object == 'qtIntro' then
    setShaderFloat(object, 'str', 1)
    setShaderFloat(object, 'ang', math.rad(180))
    setShaderFloat(object, 'dist', 13/2.6)
    setShaderFloatArray(object, 'dropColor', {200/255,99/255,185/255})
    setShaderFloat(object, 'thr', 0.05)

    elseif object == 'qtDance' then
    setShaderFloat(object, 'str', 1)
    setShaderFloat(object, 'ang', math.rad(180))
    setShaderFloat(object, 'dist', 13/2.6)
    setShaderFloatArray(object, 'dropColor', {200/255,99/255,185/255})
    setShaderFloat(object, 'thr', 0.05)

    elseif object == 'bfCaramella' then
    setShaderFloat(object, 'str', 1)
    setShaderFloat(object, 'ang', math.rad(-45))
    setShaderFloat(object, 'dist', 13)
    setShaderFloatArray(object, 'dropColor', {225/255,157/255,151/255})
            
            elseif object == 'gf' then
                setShaderFloat(object, 'str', 0) 
                setShaderFloat(object, 'ang', math.rad(90))
                setShaderFloat(object, 'dist', 15/2)
                setShaderFloatArray(object, 'dropColor', {0, 0, 0})
            end
            
            runHaxeCode("getVar('setShaderFrameInfo')('"..object.."');")

            local imageFile = stringSplit(getProperty(object..'.imageFile'), '/')
            local maskPath = 'images/characters/masks/'..imageFile[#imageFile]..'_mask.png'
            
            if checkFileExists(maskPath) then
                setShaderSampler2D(object, 'altMask', 'characters/masks/'..imageFile[#imageFile]..'_mask')
                setShaderFloat(object, 'thr2', 1)
                setShaderBool(object, 'useMask', true)
            else
                setShaderBool(object, 'useMask', false)
            end

            if object == 'gf' and _G[object..'Name'] == 'gf-tankmen' then
                setShaderFloat(object, 'thr2', 0.4)
            end
        end
    end
end