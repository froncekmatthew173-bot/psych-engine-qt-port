local stop=true
local exitSong=true
local cutsceneTrigger=true
local dir='gameplay/cutsceneSfx/bf/'

function tween(x,y,d,e)
setProperty('isCameraOnForcedPos',true)
cancelTween('camx')
cancelTween('camy')
doTweenX('camx','camFollow',x,d,e)
doTweenY('camy','camFollow',y,d,e)
end

function tweenZoom(t,d,e)
doTweenZoom('cam','camGame',t,d,e)
end

function setUIVisible(v)
for _, t in ipairs ({'healthBar','newScore','iconP1','iconP2'}) do
setProperty(t..'.visible',v)
end
end

function triggerPinkFlash()
    cancelTween('pink')
    setProperty('pinkFlash.alpha', 0.3)
    doTweenAlpha('pink', 'pinkFlash', 0, 0.6, 'linear')
end

function onCreate()
    addLuaScript('data/blissful-erect/shader')
createInstance('qtIntro','objects.Character',{getProperty('dad.x')+285,getProperty('dad.y')+320,'extra/qt-erect'})
setObjectOrder('qtIntro',getObjectOrder('dadGroup')+1)
addInstance('qtIntro')

createInstance('qtDance','objects.Character',{getProperty('dad.x')+140,getProperty('dad.y')+190,'extra/qt-dance'})
setObjectOrder('qtDance',getObjectOrder('dadGroup')+1)
setProperty('qtDance.visible',false)
addInstance('qtDance')

createInstance('bfCaramella','objects.Character',{getProperty('boyfriend.x')-395,getProperty('boyfriend.y')+100,'extra/bf-qt'})
setObjectOrder('bfCaramella',getObjectOrder('boyfriendGroup')+1)
addInstance('bfCaramella')

if not seenCutscene then
setProperty('qtIntro.visible',true)
setProperty('bfCaramella.visible',true)
else
setProperty('qtIntro.visible',false)
setProperty('bfCaramella.visible',false)
end

makeLuaSprite('pinkFlash')
makeGraphic('pinkFlash', screenWidth, screenHeight, 'FF9BF6')
setObjectCamera('pinkFlash', 'hud')
setScrollFactor('pinkFlash', 0, 0)
setProperty('pinkFlash.x', 0)
setProperty('pinkFlash.y', 0)
setProperty('pinkFlash.alpha', 0)
setProperty('pinkFlash.blend', 'add')
addLuaSprite('pinkFlash', true)
end
function onCreatePost()
addLuaScript('custom_events/LyricsInGame')
if cutsceneTrigger and not seenCutscene then
triggerEvent('Camera Follow Pos','630','560')
setUIVisible(false)
end
end

function onStartCountdown()
if not seenCutscene then
if stop and cutsceneTrigger then
stop=false
playSound('../music/gameplay/introSong/introSong-erect',0.5,'music')
runTimer('playIntro',0.90)
runTimer('2',2.59)
runTimer('3',3.48)
runTimer('4',4.341)
runTimer('5',5.7)
runTimer('6',5.74)
runTimer('7',6.25)
runTimer('8',6)
runTimer('9',7.1)
runTimer('10',8.4)
runTimer('11',9.85)

cameraFlash('game','000000',1)
tween(630,860,1,'linear')
for _, c in ipairs ({'dad','boyfriend'}) do
setProperty(c..'.visible',false)
end
return Function_Stop
end
end
end

function onBeatHit()
if curBeat==222 then
setProperty('dad.visible',false)
setProperty('qtDance.visible',true)
playAnim('qtDance','idle')
end

if curBeat==221 then
for i=0,3 do
noteTweenAlpha('n'..i,i,0.3,1.5,'quadInOut')
end
end

if curBeat==296 then
triggerPinkFlash()
end

if curBeat==348 then
for i=0,3 do
noteTweenAlpha('n'..i,i,1,1.5,'quadInOut')
end
end

if curBeat==352 then
setProperty('qtDance.visible',false)
setProperty('dad.visible',true)
end

if curBeat==478 then
for i=0,3 do
noteTweenAlpha('n'..i,i,0.3,1.5,'quadInOut')
end
end

if curBeat==513 then
triggerPinkFlash()
end

if curBeat==544 then
for i=0,3 do
noteTweenAlpha('n'..i,i,1,1.5,'quadInOut')
end
end

if curBeat==573 then
triggerPinkFlash()
end
end

function onEndSong()
if exitSong then
exitSong=false
setProperty('camHUD.alpha',0)
setProperty('camHUD.visible',false)
playAnim('qtIntro','erectEnding')

runTimer('end0',0)
runTimer('end1',0.458)
runTimer('end2',2.35)
runTimer('end3',4.65)
runTimer('end4',4.95)
runTimer('end5',5.75)
runTimer('end6',6.4)
runTimer('end7',7.942)
runTimer('end8',7.958)
runTimer('end9',8.4)
runTimer('end10',9.3)
runTimer('end11',14)
return Function_Stop
end
end

function onTimerCompleted(t)

    if t == 'loadShader' then
        addLuaScript('data/blissful-erect/shader')
        return
    end
if t=='playIntro' then
playSound(dir..'qt_erect_intro_1')
playAnim('qtIntro','erectIntro1')
triggerEvent('LyricsInGame','Alright, cutie...','')
end

if t=='2' then
tween(510,923,3,'expoOut')
tweenZoom(getProperty('defaultCamZoom')*1.16,3,'expoOut')
triggerEvent('LyricsInGame','Think you can keep up?','')
end

if t=='3' then
tween(1090,931,3,'expoOut')
tweenZoom(getProperty('defaultCamZoom')*1.30,2.6,'quartInOut')
end

if t=='4' then
triggerEvent('LyricsInGame','','')
playAnim('bfCaramella','superHey')
playSound(dir..'bf_erect_yeah')
end

if t=='5' then
tween(1040,931,0.8,'elasticOut')
tweenZoom(getProperty('defaultCamZoom')*1.16,0.8,'elasticOut')
end

if t=='6' then
triggerPinkFlash()
end

if t=='7' then
tween(510,923,2.5,'quartInOut')
tweenZoom(getProperty('defaultCamZoom')*1.16,2.5,'quartInOut')
end

if t=='8' then
playAnim('qtIntro','erectIntro2')
end

if t=='9' then
triggerEvent('LyricsInGame','Pfft, we\'ll see about that!','')
playSound(dir..'qt_erect_intro_2')
end

if t=='10' then
tween(getMidpointX('dad')+getProperty('dad.cameraPosition[0]')+getProperty('opponentCameraOffset[0]')+150,
getMidpointY('dad')+getProperty('dad.cameraPosition[1]')+getProperty('opponentCameraOffset[1]')-100,4.5,'quartInOut')
tweenZoom(getProperty('defaultCamZoom'),4.5,'quartInOut')
end

if t=='11' then
triggerEvent('LyricsInGame','','')
soundFadeOut('music',0.2,0)
startCountdown()
setProperty('boyfriend.visible',true)
setProperty('bfCaramella.visible',false)
setUIVisible(true)
runTimer('delayToAppearQT',0.8)
end

if t=='delayToAppearQT' then
setProperty('dad.visible',true)
setProperty('qtIntro.visible',false)
end

if t=='end0' then
for _, c in ipairs ({'dad','boyfriend'}) do
setProperty(c..'.visible',false)
end
setProperty('qtIntro.visible',true)
setProperty('bfCaramella.visible',true)

playSound(dir..'qt_erect_ending')
tween(510,923,2.7,'quartInOut')
tweenZoom(getProperty('defaultCamZoom')*1.20,2.7,'quartInOut')
end

if t=='end1' then
playAnim('qtIntro','erectEnding')
end

if t=='end2' then
triggerEvent('LyricsInGame','You\'re kind of a show-off, huh?','')
tween(538,923,2,'expoOut')
tweenZoom(getProperty('defaultCamZoom')*1.08,2,'expoOut')
end

if t=='end3' then
tween(538,923,0.8,'quartIn')
tweenZoom(getProperty('defaultCamZoom')*1.16,0.8,'quartIn')
end

if t=='end4' then
tween(538,923,2.2,'expoOut')
tweenZoom(getProperty('defaultCamZoom')*1.12,2.2,'expoOut')
end

if t=='end5' then
tween(538,923,1.4,'expoOut')
tweenZoom(getProperty('defaultCamZoom'),1.4,'expoOut')
end

if t=='end6' then
triggerEvent('LyricsInGame','','')
tween(1040,931,2.1,'quartInOut')
tweenZoom(getProperty('defaultCamZoom'),2.1,'quartInOut')
end

if t=='end7' then
playSound(dir..'bf_erect_shoulder_swish')
end

if t=='end8' then
playAnim('bfCaramella','shoulderSwish')
end

if t=='end9' then
tween(1040,320,2.9,'quartIn')
end

if t=='end10' then
cameraFade('game','000000',2)
end

if t=='end11' then
exitSong=false
endSong()
end
end