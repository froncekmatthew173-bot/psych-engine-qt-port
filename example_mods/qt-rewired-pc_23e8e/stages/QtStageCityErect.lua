local fastCarCanDrive=true
local lastCar=0
local sameCars=0

local baseChance=2
local currentChance=4
local chanceIncrease=6

function onCreate()
if not lowQuality then
makeAnimatedLuaSprite('stars','erectCity/stars',-685,-600)
scaleObject('stars', 2, 2)
addAnimationByPrefix('stars','idle','stars',24,true)
objectPlayAnimation('stars','idle',true)
setScrollFactor('stars',0.7,0.7)
addLuaSprite('stars',false)

makeLuaSprite('sky','erectCity/sky',-973,-1076)
scaleObject('sky', 2, 2)
addLuaSprite('sky',false)

createInstance('clouds','flixel.addons.display.FlxBackdrop',{nil,0x01})
loadGraphic('clouds','erectCity/clouds')
callMethod('clouds.setPosition',{-829,-716})
setProperty('clouds.velocity.x',-50)
setScrollFactor('clouds',0.4,0.4)
addInstance('clouds')
scaleObject('clouds', 2, 2)

makeLuaSprite('storeBg','erectCity/storeBg',-989,446)
scaleObject('storeBg', 2.0114, 2.0114)
addLuaSprite('storeBg',false)

makeLuaSprite('sign','erectCity/signBetterCallSahur',30,-425)
scaleObject('sign', 2, 2)
setScrollFactor('sign',0.85,0.85)
addLuaSprite('sign',false)

makeLuaSprite('building','erectCity/bgBuilding',-1075,-835)
scaleObject('building', 2, 2)
setScrollFactor('building',0.75,0.75)
addLuaSprite('building',false)

makeLuaSprite('bgBuildings2','erectCity/bgBuildings2',-606,-671)
scaleObject('bgBuildings2', 2, 2)
setScrollFactor('bgBuildings2',0.8,0.8)
addLuaSprite('bgBuildings2',false)

makeLuaSprite('storeInterior','erectCity/storeInterior',-985,437)
scaleObject('storeInterior', 1.3326, 1.3326)
setScrollFactor('storeInterior',0.95,0.95)
addLuaSprite('storeInterior',false)

makeLuaSprite('lampAndBuilding','erectCity/lampAndBuilding',875,125)
scaleObject('lampAndBuilding', 2, 2)
setScrollFactor('lampAndBuilding',0.8,0.8)
addLuaSprite('lampAndBuilding',false)
end

makeLuaSprite('mainGround','erectCity/mainGround',-992,-305)
scaleObject('mainGround', 2, 2)
addLuaSprite('mainGround',false)

makeAnimatedLuaSprite('poster','erectCity/poster',1665,846)
scaleObject('poster', 2, 2)
addAnimationByPrefix('poster','poster','poster',24,true)
objectPlayAnimation('poster','poster',true)
addLuaSprite('poster',false)

makeAnimatedLuaSprite('grass','erectCity/grass',1598,1115)
scaleObject('grass', 2, 2)
addAnimationByPrefix('grass','grass','grass',24,true)
objectPlayAnimation('grass','grass',true)
addLuaSprite('grass',false)

makeAnimatedLuaSprite('flower','erectCity/flower',-56,1080)
scaleObject('flower', 2, 2)
addAnimationByPrefix('flower','flower','flower',24,true)
objectPlayAnimation('flower','flower',true)
addLuaSprite('flower',false)

makeLuaSprite('storeLight_add','erectCity/storeLightAdd',-1249,161)
scaleObject('storeLight_add', 2, 2)
setProperty('storeLight_add.alpha',0.7)
setProperty('storeLight_add.blend',0)
addLuaSprite('storeLight_add',false)

makeLuaSprite('car','erectCity/car',-1048,810)
scaleObject('car', 2, 2)
setScrollFactor('car',1.03,1.03)
addLuaSprite('car',true)

fastCars={}
for i=1,3 do
local tag='car'..i
makeLuaSprite(tag,'erectCity/car'..i,-12600,1200)
setObjectOrder(tag,1000)
addLuaSprite(tag,true)
scaleObject(tag, 2, 2)
table.insert(fastCars,tag)
end

if not lowQuality then
makeLuaSprite('overlayAdd','erectCity/overlayAdd',-1242,-1060)
scaleObject('overlayAdd', 2, 2)
setProperty('overlayAdd.alpha',0.15)
setProperty('overlayAdd.blend',0)
setScrollFactor('overlayAdd',1,0.5)
addLuaSprite('overlayAdd',true)

makeLuaSprite('overlayOverlay','erectCity/overlayOverlay',-1025,-665)
scaleObject('overlayOverlay', 2, 2)
setProperty('overlayOverlay.alpha',0.6)
setProperty('overlayOverlay.blend',9)
setScrollFactor('overlayOverlay',1,0.5)
addLuaSprite('overlayOverlay',true)
end
end

function onStepHit()
if curStep % 16==0 and fastCarCanDrive then
if getRandomInt(1,100)<=currentChance then
fastCarDrive()
currentChance=baseChance
else
currentChance=currentChance + chanceIncrease
end
end
end

function fastCarDrive()
playSound('carPass'..getRandomInt(0,1),0.7)
local id=getRandomInt(1,2)
if id==lastCar then
sameCars=sameCars + 1
if sameCars >= 2 then
id=id==1 and 2 or 1
sameCars=0
end
else
sameCars=0
end

lastCar=id
local tag='car'..id
setProperty(tag..'.visible',true)
setProperty(tag..'.x',-1260)
setProperty(tag..'.y',getRandomInt(1150,1300)-120)
doTweenX(tag,tag,2500,0.5,'linear')
fastCarCanDrive=false
runTimer('resetCar',2)
end

function onTimerCompleted(t)
if t=='resetCar' then
fastCarCanDrive=true
setProperty('car1.visible',false)
setProperty('car2.visible',false)
end
end

local charGroup={'qtIntro','dad','qtDance','gf','boyfriend','bfCaramella'}

function setAdjustColor()
if shadersEnabled and not version:find('7.3') then
if not lowQuality then
initLuaShader('dropShadowAtlas')

setSpriteShader('gf','adjustColor')
setShaderFloat('gf','hue',-20)
setShaderFloat('gf','saturation',-25)
setShaderFloat('gf','contrast',0)
setShaderFloat('gf','brightness',-20)

for _, pl in ipairs ({'boyfriend','bfCaramella'}) do
setDropShadow(pl,0,13,0.8,-20,-25,0,-20,200/255,99/255,105/255)
end

for _, opp in ipairs ({'qtIntro','dad','qtDance'}) do
setDropShadow(opp,180,8,1,-10,-25,0,-20,200/255,99/255,185/255)
end
end
end
end

function onCreatePost()
setAdjustColor()
end

local up=true

function onUpdatePost()
if up then
up=false
setAdjustColor()
end
end