local neneMissCombo,percent=0,50

function startCamera(c,v)
	triggerEvent('Camera Follow Pos',getMidpointX(c),getMidpointY(c))
	cameraSetTarget(c)
	for _,v in ipairs({'skipNextTransIn','skipNextTransOut'}) do
		setPropertyFromClass('flixel.addons.transition.FlxTransitionableState',v,true)
	end
	runHaxeCode([[game.cameraSpeed=9999;new flixel.util.FlxTimer().start(0.02,function(tmr){game.cameraSpeed=1;});]])
end

function onCreatePost()
	if songName~='SPAGHETTI' then
		startCamera('dad')
	end

	setProperty('healthBar.y',downscroll and getProperty('healthBar.y')-12 or getProperty('healthBar.y')+7)
	setProperty('iconP1.y',downscroll and getProperty('iconP1.y')-12 or getProperty('iconP1.y')+10)
	setProperty('iconP2.y',downscroll and getProperty('iconP2.y')-12 or getProperty('iconP2.y')+10)
	setProperty('scoreTxt.visible',false)

	makeLuaText('newScore',botPlay and 'Enabled Botplay' or 'Score: 0',0,780,downscroll and 100 or 675.8)
	setObjectCamera('newScore','hud')
	setTextBorder('newScore',1.25,'black')
	setProperty('newScore.antialiasing',true)
	setTextSize('newScore',16)
	addLuaText('newScore')

	local s='unspawnNotes'
	for i=0,getProperty(s..'.length')-1 do
		if getPropertyFromGroup(s,i,'isSustainNote') then
			setPropertyFromGroup(s,i,'noAnimation',true)
		end
	end

	setProperty('comboGroup.x',50)
	setProperty('botplayTxt.visible',false)
end

function onCountdownStarted()
	for i=0,3 do
		setPropertyFromGroup('playerStrums',i,'x',getPropertyFromGroup('playerStrums',i,'x')-55)
		setPropertyFromGroup('opponentStrums',i,'x',getPropertyFromGroup('opponentStrums',i,'x')-55)
	end
end

function onSongStart()
	for _,time in ipairs({'timeBar','timeTxt'}) do
		setProperty(time..'.visible',false)
	end
end

function updateScoreView()
	setTextString('newScore',botPlay and 'Enabled Botplay' or 'Score: '..callMethodFromClass('flixel.util.FlxStringUtil','formatMoney',{score or 0,false}))
end

function onUpdateScore()
	updateScoreView()
end

function goodNoteHit(id,dir,t,sus)
	neneMissCombo=neneMissCombo+1
	setProperty('boyfriend.holdTimer',0)

	if sus and not botPlay then
		holdingNote=true
		runTimer('stopScoreLerp',0.25)
	else
		holdingNote=false
	end

	if combo==50 then
		playAnim('gf',gfName:lower()=='nene' and 'combo50' or 'cheer',true)
		setProperty('gf.specialAnim',true)
	elseif combo==200 then
		playAnim('gf',gfName:lower()=='nene' and 'combo200' or 'cheer',true)
		setProperty('gf.specialAnim',true)
	end
end
function opponentNoteHit()
	setProperty('dad.holdTimer',0)
end

function noteMiss(id,dir,t,s)
	holdingNote=false
	playSound('missnote'..getRandomInt(1,3),1)

	if neneMissCombo>=70 then
		neneMissCombo=0
		playAnim('gf',gfName:lower()=='nene' and 'drop70' or 'sad',true)
		setProperty('gf.specialAnim',true)
	end
end

function onTimerCompleted(t)
	if t=='stopScoreLerp' then
		holdingNote=false
	end
end

function onUpdate()
	setHealthBarColors('FE0101','64FF36')
end

function onUpdatePost(e)
	local bar='healthBar'
	local flip=getProperty(bar..'.flipX') or getProperty(bar..'.angle')==180 or getProperty(bar..'.scale.x')<0
	local target=math.max(getProperty('health')*50,0)

	percent=math.min(percent+(target-percent)*e*10,100)
	setProperty(bar..'.percent',percent)

	local x=getProperty(bar..'.x')+getProperty(bar..'.width')*((flip and percent or (100-percent))*0.01)

	for i=1,2 do
		local icon='iconP'..i
		local off=(150*getProperty(icon..'.scale.x'))/2+50

		setProperty(icon..'.x',i==1 and x+off-150 or x-off)
		setProperty(icon..'.flipX',flip)
	end

	if holdingNote then
		addScore(100)
	end
end