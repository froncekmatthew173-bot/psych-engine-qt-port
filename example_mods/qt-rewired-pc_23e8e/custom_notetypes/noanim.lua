function onCreate()
local s='unspawnNotes'
for i=0,getProperty(s..'.length')-1 do
if getPropertyFromGroup(s,i,'noteType')=='noanim' then
setPropertyFromGroup(s,i,'noAnimation',true)
end
end
end