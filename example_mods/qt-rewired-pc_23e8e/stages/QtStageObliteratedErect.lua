local timer=0

local backFogOffsetY=380
local frontFogOffsetY=50
local backFogScale=0.7
local frontFogScale=1.0

function makeMist(t,i,x,scrollX,scrollY,order,alpha,color,velX,scale)
createInstance(t,'flixel.addons.display.FlxBackdrop',{nil,0x01})
loadGraphic(t,i)
setProperty(t..'.x',x)
setProperty(t..'.y',0)
setScrollFactor(t,scrollX,scrollY)
setObjectOrder(t,order)
setProperty(t..'.blend',0)
setProperty(t..'.alpha',alpha)
setProperty(t..'.color',getColorFromHex(color))
setProperty(t..'.velocity.x',velX)
scaleObject(t,scale,scale)
addInstance(t,true)
end

function onCreate()
if not lowQuality then
makeLuaSprite('sky','obliteratedErect/sky',-973,-1076)
scaleObject('sky', 2, 2)
addLuaSprite('sky',false)

makeLuaSprite('storeInterior','obliteratedErect/storeInterior',-985,437)
scaleObject('storeInterior', 1.3326, 1.3326)
setScrollFactor('storeInterior',0.95,0.95)
addLuaSprite('storeInterior',false)

makeLuaSprite('storeBg','obliteratedErect/storeBg',-989,446)
scaleObject('storeBg', 2.0114, 2.0114)
addLuaSprite('storeBg',false)

makeLuaSprite('lampAndBuilding','obliteratedErect/lampAndBuilding',875,125)
scaleObject('lampAndBuilding', 2, 2)
setScrollFactor('lampAndBuilding',0.8,0.8)
addLuaSprite('lampAndBuilding',false)

makeLuaSprite('sign','obliteratedErect/signBetterCallSahur',30,-425)
scaleObject('sign', 2, 2)
setScrollFactor('sign',0.85,0.85)
addLuaSprite('sign',false)

makeLuaSprite('building','obliteratedErect/bgBuilding',-1075,-835)
scaleObject('building', 2, 2)
setScrollFactor('building',0.75,0.75)
addLuaSprite('building',false)

makeLuaSprite('bgBuildings2','obliteratedErect/bgBuildings2',-606,-671)
scaleObject('bgBuildings2', 2, 2)
setScrollFactor('bgBuildings2',0.8,0.8)
addLuaSprite('bgBuildings2',false)

makeAnimatedLuaSprite('tvScreens','obliteratedErect/tvScreens',89,580)
scaleObject('tvScreens', 2, 2)
addAnimationByPrefix('tvScreens','tvStatic','tvStatic',24,true)
objectPlayAnimation('tvScreens','tvStatic',true)
addLuaSprite('tvScreens',false)
end

makeLuaSprite('mainGround','obliteratedErect/mainGround',-992,-305)
scaleObject('mainGround', 2, 2)
addLuaSprite('mainGround',false)

makeAnimatedLuaSprite('flower','obliteratedErect/flower',-56,1080)
scaleObject('flower', 2, 2)
addAnimationByPrefix('flower','flower','flower',24,true)
objectPlayAnimation('flower','flower',true)
addLuaSprite('flower',false)

makeAnimatedLuaSprite('tvScreens2','obliteratedErect/tvLightsAdd',-300,155)
scaleObject('tvScreens2', 2, 2)
addAnimationByPrefix('tvScreens2','tvLights','tvLights',24,true)
objectPlayAnimation('tvScreens2','tvLights',true)
setProperty('tvScreens2.blend',0)
addLuaSprite('tvScreens2',false)

makeAnimatedLuaSprite('grass','obliteratedErect/grass',1598,1115)
scaleObject('grass', 2, 2)
addAnimationByPrefix('grass','grass','grass',24,true)
objectPlayAnimation('grass','grass',true)
addLuaSprite('grass',false)

makeAnimatedLuaSprite('poster2','obliteratedErect/poster',1665,846)
scaleObject('poster2', 2, 2)
addAnimationByPrefix('poster2','poster','poster',24,true)
objectPlayAnimation('poster2','poster',true)
addLuaSprite('poster2',false)

makeLuaSprite('car','obliteratedErect/car',-1048,810)
scaleObject('car', 2, 2)
setScrollFactor('car',1.03,1.03)
addLuaSprite('car',true)

makeAnimatedLuaSprite('poster','obliteratedErect/wind',-1000,280)
scaleObject('poster', 2, 2)
addAnimationByPrefix('poster','wind','wind',24,true)
objectPlayAnimation('poster','wind',true)
addLuaSprite('poster',true)
if shadersEnabled then
makeMist('backMistBack','obliteratedErect/mistBack',-650,0.5,0.5,39,0.5,'5C5C5C',-20,1.1*backFogScale*2)
makeMist('backMistFront','obliteratedErect/mistFront',-650,0.95,0.95,41,0.5,'5C5C5C',50,0.8*backFogScale*2)
makeMist('frontMistBack','obliteratedErect/mistBack',-650,1.1,1.1,469,0.8,'5C5C5C',80,frontFogScale*2)
makeMist('frontMistMid','obliteratedErect/mistMid',-650,1.2,1.2,470,0.6,'5C5C5C',-150,frontFogScale*2)
makeMist('frontMistFront','obliteratedErect/mistFront',-650,1.3,1.3,471,0.6,'5C5C5C',-172,frontFogScale*2)

makeLuaSprite('overlayAdd','obliteratedErect/overlayAdd',-1242,-1060)
scaleObject('overlayAdd', 2, 2)
setProperty('overlayAdd.alpha',0.15)
setProperty('overlayAdd.blend',0)
setScrollFactor('overlayAdd',1,0.5)
addLuaSprite('overlayAdd',true)
end
end
function onUpdate(el)
if shadersEnabled then
timer=timer+el
setProperty('backMistBack.y',(backFogOffsetY-80)+math.sin(timer*0.08)*100)
setProperty('backMistFront.y',(backFogOffsetY+230)+math.sin(timer*0.3)*70)
setProperty('frontMistBack.y',(frontFogOffsetY+540)+math.sin(timer*0.4)*60)
setProperty('frontMistMid.y',(frontFogOffsetY+500)+math.sin(timer*0.3)*80)
setProperty('frontMistFront.y',(frontFogOffsetY+660)+math.sin(timer*0.35)*70)
end
end

function onSongStart()
if not version:find('7.3') then
initLuaShader('dropShadowAtlas')

for _,t in ipairs ({'boyfriend','bfErect','bfDodge','Speaker'}) do
updateColorShader(t,-30,-65,10,-60)
end

for _, opp in ipairs ({'gf','gfDodge','kbIntro','dad','kbEnding'}) do
setDropShadow(opp,280,10,1,-30,-65,10,-60,255/255,255/255,255/255)
end
end
end

function updateColorShader(t,h,s,co,b)
if shadersEnabled and not lowQuality and not version:find('7.3') then
setSpriteShader(t,'adjustColor')
setShaderFloat(t,'hue',h)
setShaderFloat(t,'saturation',s)
setShaderFloat(t,'contrast',co)
setShaderFloat(t,'brightness',b)
end
end