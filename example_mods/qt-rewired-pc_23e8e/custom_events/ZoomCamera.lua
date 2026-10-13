function onEvent(n,v1,v2)
if songName~='SPAGHETTI' and n=='ZoomCamera' then
local duration=tonumber(v1) or 1

local ease='linear'
local easeDir=''
local mode='direct'
local zoom=1

local parts={}
for v in (v2..','):gmatch('(.-),') do
table.insert(parts,v)
end

for _,v in ipairs(parts) do
if tonumber(v) then
zoom=tonumber(v)
elseif v=='stage' or v=='direct' then
mode=v
elseif v=='In' or v=='Out' or v=='InOut' then
easeDir=v
elseif v~='' then
ease=v
end
end

local target=zoom
if mode=='stage' or mode=='direct' then
target=zoom*callMethodFromClass('backend.StageData','getStageFile',{curStage}).defaultZoom
end

ease=ease..(ease=='linear' and '' or easeDir)
cancelTween('z')
if ease:upper()=='INSTANT' or duration==0 then
setProperty('camGame.zoom',target)
--setProperty('defaultCamZoom',target)
else
doTweenZoom('z','camGame',target,(stepCrochet/1000)*duration,ease)
setProperty('defaultCamZoom',target)
end
end
end