local dodgeBeatsCooldown=1
local dodgeToggleAnim=0
local beatsSinceDodge=0

local warnSound='sawblades/alerts/alert'
local attackSound='sawblades/attacks/attack'

local interval=0
local hitWindow=0
local hitTime=0

local BASE_BEAT_COOLDOWN=0.4
local MIN_COOLDOWN_MS=300

local DODGE_TEXT_SWAP_DELAY=5
local DODGE_TEXT_FADE_DURATION=2

local sawType=1
local alertSuffix='1'

local warning=false
local attacking=false
local canDodge=false
local dodged=false
local dodgeKey='space'

function onCreate()
if not stringStartsWith(songName:lower(),'obliterated') then
return
end

makeLuaSprite('dimOverlay')
makeGraphic('dimOverlay',screenWidth,screenHeight,'000000')
setObjectCamera('dimOverlay','hud')
setProperty('dimOverlay.alpha',0)
addLuaSprite('dimOverlay')

makeFlxAnimateSprite('warning',650,0,'saw_mechanic/warning')
addAnimationBySymbol('warning','alert1','export real/alert 1',24,false)
addAnimationBySymbol('warning','alert2','export real/alert 2',24,false)
addAnimationBySymbol('warning','attack','export real/attack',24,false)
addAnimationBySymbol('warning','doubleAlert1','export real/doubleAlert 1',24,false)
addAnimationBySymbol('warning','doubleAlert2','export real/doubleAlert 2',24,false)
addAnimationBySymbol('warning','doubleAttack1','export real/doubleAttack 1',24,false)
addAnimationBySymbol('warning','doubleAttack2','export real/doubleAttack 2',24,false)
setObjectCamera('warning','hud')
screenCenter('warning','y')
setProperty('warning.visible',false)
addLuaSprite('warning',true)
end

function onCreatePost()
makeFlxAnimateSprite('Speaker',0,0,'characters/gf-qt/speakers')
addAnimationBySymbol('Speaker','idle','speaker assets/stereo boom',24,false)
addLuaSprite('Speaker')
scaleObject('Speaker',2,2)
playAnim('Speaker','idle')

createInstance('gfDodge','objects.Character',{getProperty('gf.x')-30,getProperty('gf.y')+150,'gf-qt'})
setObjectOrder('gfDodge',getObjectOrder('gfGroup')+2)
playAnim('gfDodge','dodge')
addInstance('gfDodge')

setProperty('Speaker.x',getProperty('gfDodge.x')-150)
setProperty('Speaker.y',getProperty('gfDodge.y')-15)
setScrollFactor('gfDodge',getProperty('gf.scrollFactor.x'),getProperty('gf.scrollFactor.y'))
setScrollFactor('Speaker',getProperty('gf.scrollFactor.x'),getProperty('gf.scrollFactor.y'))

setProperty('Speaker.visible',false)
setProperty('gfDodge.visible',false)

createInstance('bfDodge','objects.Character',{getProperty('boyfriend.x')+245,getProperty('boyfriend.y')+190,'bf-qt'})
setObjectOrder('bfDodge',getObjectOrder('boyfriendGroup')+1)
setProperty('bfDodge.visible',false)
playAnim('bfDodge','dodge-1')
addInstance('bfDodge')

makeFlxAnimateSprite('sawSprite',getProperty('dad.x')+240,getProperty('dad.y')-150,'saw_mechanic/saw_assets')
addAnimationBySymbol('sawSprite','saw anim attack','saw full',24,false)
addLuaSprite('sawSprite')
playAnim('sawSprite','saw anim attack',true)
setProperty('sawSprite.visible',false)
setObjectOrder('sawSprite',getObjectOrder('dadGroup')-1)

local isErectVariation=difficultyName=='erect' or  difficultyName=='nightmare'
local dodgeFormat=''

if buildTarget=='android' then
dodgeFormat='TAP the sign'
else
dodgeFormat='Press SPACE'
end

makeLuaText('dodgeText',dodgeFormat .. ' on third beat to dodge' .. (isErectVariation and '...' or '!'),
0,0,0)
setTextFont('dodgeText','vcr.ttf')
setTextSize('dodgeText',28)
setTextColor('dodgeText','FF0000')
setTextBorder('dodgeText',2,'000000')
setObjectCamera('dodgeText','other')
screenCenter('dodgeText','x')

setProperty('dodgeText.y', downscroll and 100 or 550)
setProperty('dodgeText.alpha',isErectVariation and songName=='obliterated-erect' and 1 or 0)
addLuaText('dodgeText')

if isErectVariation and songName=='obliterated-erect' then
makeLuaText('dodgeText2','But watch out, some attacks strike twice!',0,0,getProperty('dodgeText.y'))
setTextFont('dodgeText2','vcr.ttf')
setTextSize('dodgeText2',28)
setTextColor('dodgeText2','FF0000')
setTextBorder('dodgeText2',2,'000000')
setObjectCamera('dodgeText2','other')
screenCenter('dodgeText2','x')
setProperty('dodgeText2.alpha',0)
addLuaText('dodgeText2')
runTimer('swapDodgeText', DODGE_TEXT_SWAP_DELAY)
end
end

function darkenScreen()
doTweenAlpha('b','dimOverlay',0.3,0.35,'linear')
end

function undarkenScreen()
doTweenAlpha('b','dimOverlay',0,0.35,'linear')
end

function hideAllVisuals()
for _, spr in ipairs ({'warning','sawBlade'}) do
setProperty(spr..'.visible',false)
end
undarkenScreen()
end

function addPopup(t)
setProperty(t..'.y',200)
setProperty(t..'.alpha',1)
runTimer('downPop',0.2)
doTweenAlpha('do',t,1,0.2)
setProperty(t..'.acceleration.y',-400)
end

function popup(t,image)
makeLuaSprite(t,image,0,0)
setObjectCamera(t,'hud')
scaleObject(t,0.6,0.6)
screenCenter(t,'x')
screenCenter(t)
addLuaSprite(t,true)

setProperty(t..'.y',150)
callMethod(t..'.velocity.set',{getRandomInt(-15,15),-160})
setProperty(t..'.acceleration.y',550)
setProperty(t..'.antialiasing',true)
runTimer(t..'Fade',0.3)
runTimer(t..'Kill',0.45)
end

function onEvent(n,v1,v2)
if n=='sawKB' then
sawType=tonumber(v1) or 1
if v1=='1' then
startWarning('one')
playSound(warnSound..'-'..alertSuffix)
end
if v1=='2' then
startWarning('double')
playSound(warnSound..'-'..alertSuffix)
end
end
end

function startWarning(t)
warning=true
darkenScreen()

if t=='one' then
setProperty('warning.visible',true)
playAnim('warning','alert1',true)
runTimer('warning2',BASE_BEAT_COOLDOWN)
runTimer('sawAnim',BASE_BEAT_COOLDOWN-0.05)
runTimer('canDodge',BASE_BEAT_COOLDOWN-0.1)
end

if t=='double' then
setProperty('warning.visible',true)
playAnim('warning','doubleAlert1',true)
runTimer('warningDouble2',BASE_BEAT_COOLDOWN)
runTimer('sawAnim',BASE_BEAT_COOLDOWN-0.05)
runTimer('canDodge',BASE_BEAT_COOLDOWN-0.1)
end
end

function doSawAnimation()
    setProperty('sawSprite.visible',true)
    playAnim('sawSprite','saw anim attack',true)

    runTimer('shakeSaw', 0.6)

    runTimer('removeSaw',1.3)
end

function onTimerCompleted(t)
if t == 'shakeSaw' then
    cameraShake('game', 0.02, 0.2)
end
if t:sub(-4)=='Fade' then
doTweenAlpha(t:gsub('Fade','')..'_apha',t:gsub('Fade',''),0,0.2,'linear')
end

if t:sub(-4)=='Kill' then
removeLuaSprite(t:gsub('Kill',''),true)
end

if t=='swapDodgeText' then
doTweenAlpha('fadeDodge1','dodgeText',0,DODGE_TEXT_FADE_DURATION,'smoothStepInOut')
doTweenAlpha('fadeDodge2','dodgeText2',1,DODGE_TEXT_FADE_DURATION,'smoothStepInOut')
runTimer('fadeDodg',6)
end

if t=='fadeDodg' then
doTweenAlpha('fadeDo2','dodgeText2',0,DODGE_TEXT_FADE_DURATION,'smoothStepInOut')
end

if t=='removeSaw' then
setProperty('sawSprite.visible',false)
setProperty('boyfriend.specialAnim',false)
end

if t=='hideAllVisuals' then
hideAllVisuals()
undarkenScreen()
end

if t=='warning2' then
playSound(warnSound..'-'..alertSuffix)
playAnim('warning','alert2',true)
runTimer('attackHit',BASE_BEAT_COOLDOWN)
runTimer('canDodge',BASE_BEAT_COOLDOWN-0.1)
if botPlay then
onGoodHit()
end
end

if t=='warningDouble2' then
playSound(warnSound..'-'..alertSuffix)
playAnim('warning','doubleAlert2',true)
runTimer('attackHitDouble',BASE_BEAT_COOLDOWN)
runTimer('canDodge',BASE_BEAT_COOLDOWN-0.1)
if botPlay then
onGoodHit()
end
end

if t=='sawAnim' then
doSawAnimation()
end

if t=='canDodge' then
canDodge=true
end

if t=='attackHit' then
executeAttack()
playAnim('warning','attack')
playSound(attackSound..'-'..alertSuffix)

if not dodged then
badHit()
end
end

if t=='attackHitDouble' then
canDodge=true
alertSuffix='2'
executeAttack()
playAnim('warning','doubleAttack1')
playSound(attackSound..'-'..alertSuffix)

if not dodged then
badHit()
end
runTimer('attackHitDouble2',BASE_BEAT_COOLDOWN)
runTimer('canDodge',BASE_BEAT_COOLDOWN-0.1)
end

if t=='attackHitDouble2' then
alertSuffix='2'
executeAttack()
playAnim('warning','doubleAttack2')
playSound(attackSound..'-'..alertSuffix)
cameraFlash('hud','FF0000',1)

if not dodged then
badHit()
end
end

if t=='changeGF' then
setProperty('Speaker.visible',false)
setProperty('gfDodge.visible',false)
setProperty('gf.visible',true)
end

if t=='changeBF' then
setProperty('bfDodge.visible',false)
setProperty('boyfriend.visible',true)
end

if t=='disableDodged' then
dodged=false
end
end

function opponentNoteHit(id,direction,noteType,isSustainNote)
local anims={'LEFT','DOWN','UP','RIGHT'}
if isSustainNote then
characterPlayAnim('dad','sing'..anims[direction+1]..'-hold',true)
else
characterPlayAnim('dad','sing'..anims[direction+1],true)
end
end

function onGoodNoteHit()
if dodged then
runTimer('changeBF',0.001)
end
end

function onBeatHit()
playAnim('Speaker','idle',true)
end

function executeAttack()
warning=false
playAnim('gfDodge','dodge',true)
setProperty('Speaker.visible',true)
setProperty('gfDodge.visible',true)
setProperty('gf.visible',false)
runTimer('changeGF',0.6)
if botPlay then
onGoodHit()
end
end

function onUpdate()
for _, key in ipairs ({'left','down','up','right'}) do
if canDodge and getPropertyFromClass('flixel.FlxG','keys.justPressed.ENTER') or canDodge and buildTarget=='android' and keyJustPressed(key) then
onGoodHit()
end
end
end

function onGoodHit()
canDodge=false
dodged=true
attacking=false

for _, spr in ipairs ({'warning','sawBlade'}) do
setProperty(spr..'.visible',true)
end

popup('dodgePo','ui/dodged')
runTimer('hideAllVisuals',0.65)
runTimer('disableDodged',0.15)
setProperty('boyfriend.specialAnim',true)

if songName=='obliterated-erect' then
setProperty('bfErect.visible',false)
end

if sawType==2 then
setProperty('bfDodge.visible',false)
setProperty('boyfriend.visible',true)
characterPlayAnim('boyfriend','dodge',true)
else
setProperty('bfDodge.visible',true)
setProperty('boyfriend.visible',false)
playAnim('bfDodge','dodge-1')
runTimer('changeBF',0.6)
end

addScore(350)
setProperty('health',getProperty('health')+0.2)
local go='substates.GameOverSubstate'
setPropertyFromClass(go,'characterName','bf-dead')
setPropertyFromClass(go'deathSoundName','fnf_loss_sfx')
end

function badHit()
undarkenScreen()
attacking=false
canDodge=false
if songName=='obliterated-erect' then
setProperty('bfErect.visible',false)
end
setProperty('warning.visible',false)
setProperty('health',getProperty('health')-1)

if sawType==2 then
setProperty('bfDodge.visible',false)
setProperty('boyfriend.visible',true)
setProperty('boyfriend.specialAnim',true)
characterPlayAnim('boyfriend','hurt',true)
else
setProperty('bfDodge.visible',true)
setProperty('boyfriend.visible',false)
playAnim('bfDodge','sawHit-1')
runTimer('changeBF',0.6)
end

cameraShake('game',0.01,0.3)
local go='substates.GameOverSubstate'
setPropertyFromClass(go,'characterName','bf-qt-dead')
setPropertyFromClass(go,'deathSoundName','fnf_loss_sfx-sawblade')
end