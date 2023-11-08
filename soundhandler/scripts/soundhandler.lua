ScriptedAudio = {
	Sounds = {}
}

function ScriptedAudio:pauseScriptedSounds(toggle)
	ScriptedAudio:cleanList()
	if toggle == true then
		for i, v in ipairs(ScriptedAudio.Sounds) do
			self:pauseSound(v)
		end
	else
		for i, v in ipairs(ScriptedAudio.Sounds) do
			self:resumeSound(v)
		end
	end
end

function ScriptedAudio:updateVolumes(voice)
	ScriptedAudio:cleanList()
	for i, v in ipairs(ScriptedAudio.Sounds) do
		if v.voice == voice then
			ScriptedAudio:SetVolume(v)
		end
	end
end

function ScriptedAudio:stopAll()
	for i, v in ipairs(ScriptedAudio.Sounds) do
		ScriptedAudio:stopSound(v)
	end
	ScriptedAudio:cleanList()
end

function ScriptedAudio:cleanList()
	for i=#ScriptedAudio.Sounds,1,-1 do
		if ScriptedAudio.Sounds[i].handle:isSoundValid() == false then
			table.remove(ScriptedAudio.Sounds, i)
		end
	end
end

function ScriptedAudio:playSound(file, is_voice, loop, var)
	local sound = ad.loadSoundfile(file)
	local sh = sound:play(1.0, 0, is_voice)
	
	local tbl = {}
	tbl.handle = sh
	tbl.voice = is_voice
	tbl.time = sound.Duration
	
	table.insert(ScriptedAudio.Sounds, tbl)
	
	if var and var:isValid() then
		var.Value = #ScriptedAudio.Sounds
	end
	
	if loop == true then
		local async_util = require("async_util")
		async.run(function()
			async.await(async_util.wait_for(tbl.time))
			ScriptedAudio:playSound(file, is_voice, loop, var)
		end, async.OnFrameExecutor)
	end
end

function ScriptedAudio:getSoundHandle(index)
	return ScriptedAudio.Sounds[index]
end

function ScriptedAudio:pauseSound(sound)
	if sound.handle:isSoundValid() == true then
		sound.handle:pause()
	end
end

function ScriptedAudio:resumeSound(sound)
	if sound.handle:isSoundValid() == true then
		sound.handle:resume()
	end
end

function ScriptedAudio:stopSound(sound)
	if sound.handle:isSoundValid() == true then
		sound.handle:stop()
	end
end

function ScriptedAudio:SetVolume(sound)
	if sound.handle:isSoundValid() == true then
		sound.handle:setVolume(1.0, sound.voice)
	end
end

return ScriptedAudio