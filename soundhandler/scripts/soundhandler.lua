ScriptedAudio = {
	Sounds = {}
}

function ScriptedAudio:pauseScriptedSounds(toggle)
	ScriptedAudio:cleanList()
	if toggle == true then
		for i, v in ipairs(ScriptedAudio.Sounds) do
			self:pauseSound(i)
		end
	else
		for i, v in ipairs(ScriptedAudio.Sounds) do
			self:resumeSound(i)
		end
	end
end

function ScriptedAudio:updateVolumes(voice)
	ScriptedAudio:cleanList()
	for i, v in ipairs(ScriptedAudio.Sounds) do
		if v.voice == voice then
			ScriptedAudio:SetVolume(i)
		end
	end
end

function ScriptedAudio:stopAll()
	for i, v in ipairs(ScriptedAudio.Sounds) do
		ScriptedAudio:stopSound(i)
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
	tbl.file = file
	tbl.voice = is_voice
	tbl.time = sound.Duration
	tbl.isClosed = false
	tbl.isPaused = false
	tbl.var = var

	table.insert(ScriptedAudio.Sounds, tbl)
	
	if var and var:isValid() then
		var.Value = #ScriptedAudio.Sounds
	end
	
	if loop == true then
		ScriptedAudio:loopSound(#ScriptedAudio.Sounds)
	end
end

function ScriptedAudio:waitForSound(sound)
	return async.run(function()
		while ((sound.isPaused == true) or sound.handle:isPlaying()) do
			async.await(async.yield())
		end
	end, async.OnFrameExecutor)
end

function ScriptedAudio:loopSound(index)
	local async_util = require("async_util")
	
	local sound = ScriptedAudio:getSoundHandle(index)
	
	async.run(function()
		--Wait for sound to be finished playing and to not be paused
		async.await(ScriptedAudio:waitForSound(sound))
		
		--Check that we haven't stopped a looping sound before playing it again
		if sound.isClosed == false then
		
			--Play the sound again and save it back to the original ScriptedAudio handle
			local new_sound = ad.loadSoundfile(sound.file)
			sound.handle = new_sound:play(1.0, 0, sound.voice)
			
			--Loop again
			ScriptedAudio:loopSound(index)
		end
	end, async.OnFrameExecutor)
end

function ScriptedAudio:getSoundHandle(index)
	return ScriptedAudio.Sounds[index]
end

function ScriptedAudio:pauseSound(index)
	local sound = ScriptedAudio:getSoundHandle(index)
	sound.isPaused = true
	if sound.handle:isSoundValid() == true then
		sound.handle:pause()
	end
end

function ScriptedAudio:resumeSound(index)
	local sound = ScriptedAudio:getSoundHandle(index)
	if sound.handle:isSoundValid() == true then
		sound.handle:resume()
	end
	sound.isPaused = false
end

function ScriptedAudio:stopSound(index)
	local sound = ScriptedAudio:getSoundHandle(index)
	if sound.handle:isSoundValid() == true then
		sound.handle:stop()
	end
	sound.isClosed = true
end

function ScriptedAudio:SetVolume(index)
	local sound = ScriptedAudio:getSoundHandle(index)
	if sound.handle:isSoundValid() == true then
		sound.handle:setVolume(1.0, sound.voice)
	end
end

return ScriptedAudio