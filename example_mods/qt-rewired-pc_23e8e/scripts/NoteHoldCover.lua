local holdGroup = {}
local isPixel = false

local pixelConfig = {
colors = {'purple','blue','green','orange','purple','blue','green','orange'},
spritesheet = 'noteHolding/pixelNoteSplash',
scale = {x=4,y=4},
antialiasing = false,
offsets = {px=-20, py=0, ox=-20, oy=0}}

local normalConfig = {
colors = {'Purple','Blue','Green','Red','Purple','Blue','Green','Red'},
spritesheet = 'noteHolding/holdCover',
scale = {x=1,y=1},
antialiasing = true,
offsets = {px=-100, py=-100, ox=-100, oy=-100}}

local sustainData = {
alpha=1,
xPos=0,
yPos={upscroll=0,downscroll=0},
holdDurations={0,0,0,0,0,0,0,0},
endDelay=10,
timeTillDisappear=0.3,
dadHoldSustains=true,
offsets={}}

function onCreatePost()
isPixel = getPropertyFromClass('states.PlayState', 'isPixelStage')
local cfg = isPixel and pixelConfig or normalConfig

setOnScripts('UpdateDadHoldCover',true)
setOnScripts('UpdateBFHoldCover',true)

for i=1,4 do
sustainData.offsets[i] = {x=cfg.offsets.px, y=cfg.offsets.py}
end
for i=5,8 do
sustainData.offsets[i] = {x=cfg.offsets.ox, y=cfg.offsets.oy}
end

for i=1,8 do
local tag = 'holdSplash'..i
local color = cfg.colors[i]

if isPixel then
makeAnimatedLuaSprite(tag, cfg.spritesheet, 0, 0)

addAnimationByPrefix(tag,'holdStart',color..'100',24,false)
addAnimationByPrefix(tag,'holding',color..'200',24,true)
addAnimationByPrefix(tag,'holdEnd',color..'300',24,false)

else
local path = cfg.spritesheet..color
makeAnimatedLuaSprite(tag, path, 0, 0)

addAnimationByPrefix(tag,'holdStart','holdCoverStart'..color,24,false)
addAnimationByPrefix(tag,'holding','holdCover'..color,24,true)
addAnimationByPrefix(tag,'holdEnd','holdCoverEnd'..color,24,false)
end

setObjectCamera(tag,'hud')
setProperty(tag..'.visible',false)

scaleObject(tag,cfg.scale.x,cfg.scale.y)
setProperty(tag..'.antialiasing',cfg.antialiasing)
setProperty(tag..'.alpha',sustainData.alpha)

addLuaSprite(tag,true)
table.insert(holdGroup,tag)
end
end

function onUpdate(elapsed)
updateHoldSplashPos()
end

function updateHoldSplashPos()
for i=1,4 do
local sx=getPropertyFromGroup('playerStrums',i-1,'x')+sustainData.offsets[i].x
local sy=getPropertyFromGroup('playerStrums',i-1,'y')+sustainData.offsets[i].y

setProperty(holdGroup[i]..'.x',sx+sustainData.xPos)
setProperty(holdGroup[i]..'.y',
downscroll and sy+sustainData.yPos.downscroll or sy+sustainData.yPos.upscroll)
end

for i=5,8 do
local idx=i-5
local sx=getPropertyFromGroup('opponentStrums',idx,'x')+sustainData.offsets[i].x
local sy=getPropertyFromGroup('opponentStrums',idx,'y')+sustainData.offsets[i].y

setProperty(holdGroup[i]..'.x',sx+sustainData.xPos)
setProperty(holdGroup[i]..'.y',
downscroll and sy+sustainData.yPos.downscroll or sy+sustainData.yPos.upscroll)
end

for i=1,#sustainData.holdDurations do
sustainData.holdDurations[i]=sustainData.holdDurations[i]+1

if sustainData.holdDurations[i]==sustainData.endDelay then
objectPlayAnimation(holdGroup[i],'holdEnd',false)
runTimer('hideHold'..i,sustainData.timeTillDisappear)
end
end
end

function onTimerCompleted(t)
for i=1,8 do
if t=='hideHold'..i then
setProperty(holdGroup[i]..'.visible',false)
end
end
end

function goodNoteHit(id,dir,noteType,isSustain)
if UpdateBFHoldCover then
if getPropertyFromClass('states.PlayState', 'isPixelStage') then
if not isSustain then
sustainHolding(dir+1)
end
else
if isSustain then
sustainHolding(dir+1)
end
end
end
end

function opponentNoteHit(id,dir,noteType,isSustain)
if UpdateDadHoldCover then
if not getPropertyFromClass('states.PlayState', 'isPixelStage') then
if isSustain and sustainData.dadHoldSustains then
sustainHolding(dir+5)
end
end
end
end

function sustainHolding(i)
setProperty(holdGroup[i]..'.visible',true)
objectPlayAnimation(holdGroup[i],'holding',true)
sustainData.holdDurations[i]=0
end