function onCreatePost()
makeLuaText('subText','',0,0,0)
setTextAlignment('subText','center')
setTextSize('subText',32)
setTextFont('subText','vcr.ttf')
setObjectCamera('subText','other')
addLuaText('subText')
screenCenter('subText','x')
setProperty('subText.y',downscroll and getProperty('scoreTxt.y')+35 or getProperty('healthBar.y')-110)

makeLuaSprite('subTextBorder',nil,0,0)
makeGraphic('subTextBorder',1,1,'000000')
setObjectCamera('subTextBorder','other')
addLuaSprite('subTextBorder')
setProperty('subTextBorder.alpha',0.5)

setProperty('subText.visible',false)
setProperty('subTextBorder.visible',false)
end

function onEvent(n,v1,v2)
if n == 'LyricsInGame' then
if v1 == '' then
setProperty('subText.visible',false)
setProperty('subTextBorder.visible',false)
return
end

setProperty('subText.visible',true)
setProperty('subTextBorder.visible',true)

setTextString('subText',v1)
screenCenter('subText','x')

makeGraphic('subTextBorder',getProperty('subText.width')+5*2,getProperty('subText.height')+5*2,'000000')
setProperty('subTextBorder.x',getProperty('subText.x')-5)
setProperty('subTextBorder.y',getProperty('subText.y')-5)
end
end