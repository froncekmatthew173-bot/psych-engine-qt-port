local SPEED_TWEEN=false
local DEFAULT_SCROLL=1
local TARGET_SPEED=1
local DEFAULT_DURATION=0
local TIMER=0
local DEFAULT_STRUMLINE='both'

function onEvent(n,v1,v2)
if n == 'ScrollSpeed' then
local VSliceValue,extraPart=v2:match("^%s*([^,]+)%s*,?%s*(.*)$")
VSliceValue=tonumber(VSliceValue) or 1
VSliceValue=math.max(0.1,VSliceValue - 2.5)
extraPart=extraPart~='' and extraPart or 'both'

if VSliceValue then
DEFAULT_STRUMLINE=extraPart
DEFAULT_SCROLL=getProperty('songSpeed')
TARGET_SPEED=DEFAULT_SCROLL+VSliceValue

if v1=='INSTANT' then
SPEED_TWEEN=false
changeSongSpeed(TARGET_SPEED)
return
end

DEFAULT_DURATION=tonumber(v1) or 1
TIMER=0
SPEED_TWEEN=true
end
end
end

function onUpdate(e)
if SPEED_TWEEN then
TIMER=TIMER+e
local progress=TIMER/DEFAULT_DURATION
if progress>=1 then
progress=1
SPEED_TWEEN=false
end
local newSpeed=DEFAULT_SCROLL+(TARGET_SPEED-DEFAULT_SCROLL)*progress
changeSongSpeed(newSpeed)
end
end

function changeSongSpeed(v)
if DEFAULT_STRUMLINE=='opponent' then
for i=0,getProperty('unspawnNotes.length')-1 do
if not getProperty('unspawnNotes['..i..'].mustPress') then
setProperty('unspawnNotes['..i..'].multSpeed',v)
end
end

elseif DEFAULT_STRUMLINE == 'player' then
for i=0,getProperty('unspawnNotes.length')-1 do
if getProperty('unspawnNotes['..i..'].mustPress') then
setProperty('unspawnNotes['..i..'].multSpeed',v)
end
end
else
setProperty('songSpeed',v)
end
end