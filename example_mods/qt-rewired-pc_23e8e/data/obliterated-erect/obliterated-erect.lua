local inGhost=true
local shouldPlayEdit=false
local shouldHuzz=false

local timeVideo1=149673
local timeVideo2=153500

local timeFadeOut1Start=148300
local durFadeOut1=1.8

local timeLayoutChange=152220

local timeFadeInStart=152300
local durFadeIn=2.9

local timeFadeOut2Start=179200
local durFadeOut2=5

local timeCamFade2Start=147900
local durCamFade2=1.773

local timeCamFade3Start=178545
local durCamFade3=9.5

local timeCamFade4Start=189600
local durCamFade4=4.65

local video1Triggered=false
local video2Triggered=false
local fadeOut1Triggered=false
local layoutTriggered=false
local fadeInTriggered=false
local fadeOut2Triggered=false
local camFade2Triggered=false
local camFade3Triggered=false
local camFade4Triggered=false

function onStartCountdown()
setProperty('skipCountdown',true)
end

function onCreate()
addLuaScript('data/obliterated-erect/shader-kb')
makeLuaSprite('blackScreen')
makeGraphic('blackScreen',screenWidth,screenHeight,'000000')
setObjectCamera('blackScreen','hud')
setProperty('blackScreen.alpha',0)
addLuaSprite('blackScreen')
end

function onCreatePost()
createInstance('bfErect','objects.Character',{getProperty('boyfriend.x')-395,getProperty('boyfriend.y')+100,'extra/bf-qt'})
setObjectOrder('bfErect',getObjectOrder('boyfriendGroup')+1)
setProperty('bfErect.visible',false)
addInstance('bfErect')

createInstance('kbIntro','objects.Character',{getProperty('dad.x'),getProperty('dad.y'),'extra/kb-intro'})
setObjectOrder('kbIntro',getObjectOrder('boyfriendGroup')+1)
playAnim('kbIntro','idle')
addInstance('kbIntro')

createInstance('kbEnding','objects.Character',{getProperty('dad.x'),getProperty('dad.y'),'extra/kb-end'})
setObjectOrder('kbEnding',getObjectOrder('boyfriendGroup')+1)
playAnim('kbEnding','tsundere')
addInstance('kbEnding')

setProperty('dad.visible',false)
setProperty('kbEnding.visible',false)
end

function onSongStart()
doHudFade(0,0.0001,true)
setProperty('dad.visible',false)
cameraFlash('hud','000000',12.5)
end

function onStepHit()
if curStep==1 or curStep==2 then
inGhost=true
doHudFade(0,0.0001,true)

elseif curStep==34 then
playAnim('kbIntro','intro-erect')

elseif curStep==112 then
doHudFade(1,2.5,true)
inGhost=false

elseif curStep==132 then
setProperty('dad.visible',true)
setProperty('kbIntro.visible',false)

elseif curStep==1799 then
setProperty('camGame.visible',true)
setProperty('blackScreen.visible',true)

playAnim('kbEnding','tsundere')
setProperty('kbEnding.visible',true)
setProperty('dad.visible',false)

playAnim('bfErect','tired')
setProperty('bfErect.visible',true)
setProperty('boyfriend.visible',false)
end
end

function fade(dur,type)
if type then
doTweenAlpha('blackIn','blackScreen',0,dur)
else
doTweenAlpha('blackIn','blackScreen',1,dur)
end
end

function onUpdate(el)
local t=getSongPosition()
if not camFade2Triggered and t>=timeCamFade2Start then
camFade2Triggered=true
fade(durCamFade2,false)
end

if not camFade3Triggered and t>=timeCamFade3Start then
camFade3Triggered=true
fade(durCamFade3,true)
end

if not camFade4Triggered and t>=timeCamFade4Start then
camFade4Triggered=true
fade(durCamFade4,false)
end

if not fadeOut1Triggered and t>=timeFadeOut1Start then
fadeOut1Triggered=true
doHudFade(0,durFadeOut1,true)
end

if not layoutTriggered and t>=timeLayoutChange then
layoutTriggered=true
centerPlayerStrumline()
hideOpponentStrumline()
end

if not fadeInTriggered and t>=timeFadeInStart then
fadeInTriggered=true
doHudFade(1,durFadeIn,false)
end

if not fadeOut2Triggered and t>=timeFadeOut2Start then
fadeOut2Triggered=true
doHudFade(0,durFadeOut2,false)
end

if not video1Triggered and t>=timeVideo1 and t<timeVideo2 then
video1Triggered=true
setProperty('blackScreen.visible',false)
addVideo('midVideo','obliteratedErectMid',-320,-190)
setProperty('camGame.visible',false)
for _, cover in ipairs ({'Dad','BF'}) do
setOnScripts('Update'..cover..'HoldCover',false)
end
shouldHuzz=true
end

if not video2Triggered and t>=timeVideo2 then
video2Triggered=true
runHaxeCode([[
var video=game.variables.get('midVideo');
if(video != null){
if(video.bitmap != null)video.bitmap.stop();video.visible=false;}
]])

shouldHuzz=false
addVideo('editVideo','obliteratedErectEdit',-320,-190)
shouldPlayEdit=true
end
end

function onEvent(n,v1,v2)
if n=='PlayAnimation' then
if v1=='tsundere' and v2=='1' then
playAnim('kbEnding','tsundere')
setProperty('kbEnding.visible',true)
setProperty('dad.visible',false)
end

if v1=='tired' and v2=='0' then
playAnim('bfErect','tired')
setProperty('bfErect.visible',true)
setProperty('boyfriend.visible',false)
end
end
end

function centerPlayerStrumline()
for i=4,7 do
noteTweenX('center'..i,i,1+(112*i)-5,0.5,'quadInOut')
end
end

function hideOpponentStrumline()
for i=0,3 do
noteTweenAlpha('hide'..i,i,0,0.5,'quadInOut')
end
end

function noteMissPress(dir)
if inGhost then
return Function_Stop
end
end

function doHudFade(a,t,opp)
for _, spr in ipairs ({'healthBar','newScore','iconP1','iconP2'}) do
doTweenAlpha(spr,spr,a,t,'quadInOut')
end

for i=4,7 do
noteTweenAlpha('pl'..i,i,a,t,'quadInOut')
end

if opp then
for i=0,3 do
noteTweenAlpha('op'..i,i,a,t,'quadInOut')
end
end
end