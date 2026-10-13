local group={}
local v=version or 'unknown'

--1.4 and 7.3 video
function ddVideo(tag,name,x,y)
table.insert(group,tag)

if buildTarget=='android' and v:find('7.3') then
runHaxeCode([[
var cam;
FlxG.cameras.remove(game.camHUD,false);
FlxG.cameras.remove(game.camOther,false);

cam= new FlxCamera();
cam.bgColor=0x00;
FlxG.cameras.add(cam,false);
FlxG.cameras.add(game.camHUD,false);
FlxG.cameras.add(game.camOther,false);

var tag="]]..tag..[[";
var video=new VideoSprite(]]..x..[[,]]..y..[[);
video.playVideo(Paths.video("]]..name..[["));
video.scale.set(0.67,0.67);
video.cameras=[cam];
video.updateHitbox();
game.add(video);
game.variables.set(tag,video);
]])
else
runHaxeCode([[
import objects.VideoSprite;
var cam;
FlxG.cameras.remove(game.camHUD,false);
FlxG.cameras.remove(game.camOther,false);

cam= new FlxCamera();
cam.bgColor=0x00;
FlxG.cameras.add(cam,false);
FlxG.cameras.add(game.camHUD,false);
FlxG.cameras.add(game.camOther,false);

var currentVideo:VideoSprite = null;

function video(name:String, cam:FlxCamera)
{
var v = new VideoSprite(Paths.video(name), false);
v.cameras = [cam];
add(v);

v.videoSprite.bitmap.rate = game.playbackRate;
v.videoSprite.bitmap.onEndReached.removeAll();

v.videoSprite.bitmap.onFormatSetup.add(() -> {
v.videoSprite.alpha = 1;
v.cover.alpha = 1;
});

v.play();

currentVideo = v;
game.variables.set("currentVideo", currentVideo);

return v;
}

if ("]]..name..[[" == "obliteratedErectMid") {
var introVideo = video("]]..name..[[", cam);
new flixel.util.FlxTimer().start(4.5, function(tmr) {
introVideo.destroy();
});
}

if ("]]..name..[[" == "obliteratedErectEdit") {
var introVideo = video("]]..name..[[", cam);
new flixel.util.FlxTimer().start(25.2, function(tmr) {
introVideo.destroy();
});
}
]])

end
end

function onCreatePost()
runHaxeCode([[
createGlobalCallback('addVideo',function(t,n,x,y){return game.callOnLuas('ddVideo',[t,n,x,y]);});
]])
end

function onPause()
pauseVideos()
end

function onResume()
resumeVideos()
end

function resumeVideos()
if buildTarget=='android' and v:find('7.3') then
for _,tag in ipairs(group) do
runHaxeCode([[
var video=game.variables.get("]]..tag..[[");
if(video != null && video.bitmap != null){video.bitmap.resume();}]])
end
else
runHaxeCode([[
var v = game.variables.get("currentVideo");
if (v != null && v.videoSprite != null && v.videoSprite.bitmap != null)
v.videoSprite.bitmap.resume();
]])
end
end

function pauseVideos()
if buildTarget=='android' and v:find('7.3') then
for _,tag in ipairs(group) do
runHaxeCode([[
var video=game.variables.get("]]..tag..[[");
if(video != null && video.bitmap != null){video.bitmap.pause();}]])
end
else
runHaxeCode([[
var v = game.variables.get("currentVideo");
if (v != null && v.videoSprite != null && v.videoSprite.bitmap != null)
v.videoSprite.bitmap.pause();
]])
end
end