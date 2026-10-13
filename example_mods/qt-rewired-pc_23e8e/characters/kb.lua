local idle=true

function setPosition(t,x,y)
setProperty(t..'.x',x)
setProperty(t..'.y',y)
end

function onCreate()
makeAnimatedLuaSprite('eye','characters/kb_export/eyes',getProperty('dad.x')-130,getProperty('dad.y')-485)
setObjectOrder('eye',getObjectOrder('dadGroup')+1)
addAnimationByPrefix('eye','idle','idle',24,false)
addAnimationByPrefix('eye','singLEFT','left_0',24,false)
addAnimationByPrefix('eye','singDOWN','down_0',24,false)
addAnimationByPrefix('eye','singUP','up_0',24,false)
addAnimationByPrefix('eye','singRIGHT','right_0',24,false)
playAnim('eye','idle',true)
scaleObject('eye',2,2)
addLuaSprite('eye')
end

function opponentNoteHit(id,dir,t,s)
local a={'singLEFT','singDOWN','singUP','singRIGHT'}
idle=false
runTimer('back',0.85)
if not s then
playAnim('eye',a[dir+1])
playAnim('dad',a[dir+1])

if dir==0 then
setPosition('eye',getProperty('dad.x')-400,getProperty('dad.y')-385)
elseif dir==1 then
setPosition('eye',getProperty('dad.x')-85,getProperty('dad.y')-275)
elseif dir==2 then
setPosition('eye',getProperty('dad.x')-140,getProperty('dad.y')-575)
elseif dir==3 then
setPosition('eye',getProperty('dad.x')+130,getProperty('dad.y')-370)
end
end
end

function onTimerCompleted(t)
if t=='back' then
idle=true
playAnim('eye','idle',true)
setPosition('eye',getProperty('dad.x')-130,getProperty('dad.y')-485)
end
end

function onUpdatePost()
if getProperty('eye.animation.curAnim.finished') and idle then
playAnim('eye','idle',true)
playAnim('dad','idle',true)
end
setProperty('eye.visible',getProperty('dad.visible'))
end