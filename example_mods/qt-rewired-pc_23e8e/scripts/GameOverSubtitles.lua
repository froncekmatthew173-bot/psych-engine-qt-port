local delayToAudio=4
local currentSound=getRandomInt(1,6)
local audioPath='qtgameover/bf/'
local dialogSet=nil

local bfLines={
[1]={
{0.050, 'Oh no! Are you okay?'},
{2.992, 'Is he okay...?'},
{5.163, ''}
},

[2]={
{0.018, 'Uh oh!'},
{0.632, ''}
},

[3]={
{0.250, 'Oh, that was not good!'},
{2.569, ''},
{2.999, 'Let\'s try again...'},
{4.808, ''}
},

[4]={
{0.077, 'Come on! I know you can do better than that!.'},
{3.051, ''}
},

[5]={
{0.192, 'Uhmm... Maybe we should leave it for another time...'},
{3.618, ''}
},

[6]={
{0.040, 'Ow... Was I singing too fast?'},
{2.653, ''}
},

[7]={
{0.024, 'Dude, do you need a break?'},
{1.814, ''}
}
}

function onGameOverStart()
if stringStartsWith(boyfriendName:lower(),'boyfriend') or boyfriendName=='bf' then
currentSound=getRandomInt(1,7)
dialogSet=bfLines
end
runTimer('audio',delayToAudio)

local dialog=dialogSet[currentSound]
for i=1,#dialog do
local time=dialog[i][1]
runTimer('line_'..i,time+delayToAudio)
end

makeLuaText('subTextQT','',0,0,550)
setTextAlignment('subTextQT','center')
setTextSize('subTextQT',32)
setTextFont('subTextQT','vcr.ttf')
setObjectCamera('subTextQT','other')
addLuaText('subTextQT')
screenCenter('subTextQT','x')

makeLuaSprite('subTextQTBorder',nil,0,0)
makeGraphic('subTextQTBorder',1,1,'000000')
setObjectCamera('subTextQTBorder','other')
addLuaSprite('subTextQTBorder')
setProperty('subTextQTBorder.alpha',0.5)
end

function onGameOverConfirm(t)
cancelTimer('audio')
soundFadeOut('qt',0.0001,0)
end

function onTimerCompleted(t)
if t=='audio' then
playSound(audioPath..'qtGameover-'..currentSound,1,'qt')
return
end

if stringStartsWith(t,'line_') then
local id=tonumber(t:match('line_(%d+)'))
local dialog=dialogSet[currentSound]
setSubtitle(dialog[id][2])
end
end

function setSubtitle(t)
setGraphicSize('subTextQTBorder',getProperty('subTextQT.width')+10*2,getProperty('subTextQT.height')+10*2)
callMethod('subTextQTBorder.setPosition',{getProperty('subTextQT.x')-10,getProperty('subTextQT.y')-10})
setTextString('subTextQT',t)
screenCenter('subTextQT','x')
if t=='' then
setTextString('subTextQT','')
end
end

function onUpdate()
setPropertyFromClass('substates.GameOverSubstate','loopSoundName','none')
end