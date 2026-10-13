function dance(c)
local anim=getProperty(c..'.animation.name')
if anim~=nil and not stringStartsWith(anim,'sing') then
callMethod(c..'.dance',{''})
end
end

function sing(c,d)
local a={'singLEFT','singDOWN','singUP','singRIGHT'}
playAnim(c,a[d+1],true)
setProperty(c..'.holdTimer', 0)
end

function goodNoteHit(id,dir,t,s)
if t=='caramella' then
if not s then
sing('bfCaramella',dir)
end
setProperty('boyfriend.visible',false)
setProperty('bfCaramella.visible',true)
else
setProperty('boyfriend.visible',true)
setProperty('bfCaramella.visible',false)
end
end

function onBeatHit()
if curBeat % 2==0 then
dance('bfCaramella')
end
end