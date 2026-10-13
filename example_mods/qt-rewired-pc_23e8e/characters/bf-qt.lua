local precacheChars={
{'boyfriend','bf-qt'},
{'boyfriend','bf'},
}

function onCreate()
for i=1,#precacheChars do
local charData=precacheChars[i]
addCharacterToList(charData[2],charData[1])
end
end

function onCreatePost()
if stringStartsWith(songName:lower(),'obliterated') then
setProperty('boyfriend.x',getProperty('boyfriend.x')+365)
setProperty('boyfriend.y',getProperty('boyfriend.y')+95)
triggerEvent('Change Character','bf','bf')
end
end