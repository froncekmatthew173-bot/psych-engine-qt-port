local danceSide=false
local activeDance=false
local suffix='-alt'
local curChar='dad'

function onEvent(n,v1,v2)
if n=='PlayAnimation' then
if v1=='preDance' and v2=='1' then
runTimer('danceQT',1.30)
elseif v1=='cheer' and v2=='1' then
activeDance=false
setProperty('dad.visible',true)
setProperty('qtIntro.visible',false)
end
end
end

function onBeatHit()
if activeDance then
if curBeat % 1==0 then 
if danceSide then
playAnim(curChar,'danceRight'..suffix,true)
else
playAnim(curChar,'danceLeft'..suffix,true)
end
danceSide=not danceSide
end
end

if songName=='blissful-erect' then
if curBeat==511 then
setProperty('dad.visible',false)
setProperty('qtIntro.visible',true)

playAnim('qtIntro','preDance-erect')
suffix='-erect'
curChar='qtIntro'
end
end
end

function onTimerCompleted(t)
if t=='danceQT' then
activeDance=true
end
end