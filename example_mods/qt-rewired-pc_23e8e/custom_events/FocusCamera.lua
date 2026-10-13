function curTarget(t)
if t=='0' then
return
getMidpointX('boyfriend')-getProperty('boyfriend.cameraPosition[0]')+getProperty('boyfriendCameraOffset[0]')-100,
getMidpointY('boyfriend')+getProperty('boyfriend.cameraPosition[1]')+getProperty('boyfriendCameraOffset[1]')-100
end

if t=='1' then
return
getMidpointX('dad')+getProperty('dad.cameraPosition[0]')+getProperty('opponentCameraOffset[0]')+150,
getMidpointY('dad')+getProperty('dad.cameraPosition[1]')+getProperty('opponentCameraOffset[1]')-100
end

if t=='2' then
return
getMidpointX('gf')+getProperty('gf.cameraPosition[0]')+getProperty('girlfriendCameraOffset[0]'),
getMidpointY('gf')+getProperty('gf.cameraPosition[1]')+getProperty('girlfriendCameraOffset[1]')
end
return 0,0
end

function move(x,y,steps,ease)
ease=string.upper(ease or 'LINEAR')
local duration=stepCrochet*steps/1000
if ease=='CLASSIC' then
ease='expoOut'
duration=duration+1
triggerEvent('Camera Follow Pos',x,y)
setProperty('cameraSpeed',1)

elseif ease=='INSTANT' then
triggerEvent('Camera Follow Pos',x,y)
setProperty('cameraSpeed',999999)
duration=0.0001
ease='linear'
else
ease=string.lower(ease)
doTweenX('camerax','camFollow',x,duration,ease)
doTweenY('camerax','camFollow',y,duration,ease)
setProperty('cameraSpeed',1)
end
end

function onEvent(n,v1,v2)
if n=='FocusCamera' then
if songName~='SPAGHETTI' then
setProperty('isCameraOnForcedPos',true)
local data=stringSplit(v1,',')
local target=data[1]
local offsetX=tonumber(data[2]) or 0
local offsetY=tonumber(data[3]) or 0
local x,y=curTarget(target)
x=x+offsetX
y=y+offsetY

local tween=stringSplit(v2,',')
local steps=tonumber(tween[1]) or 0
local ease =tween[2] or 'linear'
ease=ease:gsub("%s","")
cancelTween('camerax')
cancelTween('cameray')
move(x,y,steps,ease)
setOnScripts('curTargetCam',curTarget(target))
end
end
end