function onEvent(n, v1,v2)
if n == 'PlayAnimation' then
if v2 == '0' then
triggerEvent('Play Animation',v1,'boyfriend')
elseif v2 == '1' then
triggerEvent('Play Animation',v1,'dad')
elseif v2 == '2' then
triggerEvent('Play Animation',v1,'gf')
end
end
end