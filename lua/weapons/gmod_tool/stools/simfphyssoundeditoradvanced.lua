TOOL.Category		= "simfphys"
TOOL.Name			= "#Sound Editor - Advanced"
TOOL.Command		= nil
TOOL.ConfigName		= ""

if CLIENT then
	language.Add( "tool.simfphyssoundeditoradvanced.name", "Sound Editor - Advanced" )
	language.Add( "tool.simfphyssoundeditoradvanced.desc", "A tool used to edit engine sounds on simfphys vehicles" )
	language.Add( "tool.simfphyssoundeditoradvanced.0", "Left click apply settings. Right click copy settings. Reload to reset" )
	language.Add( "tool.simfphyssoundeditoradvanced.1", "Left click apply settings. Right click copy settings. Reload to reset" )
end

function TOOL:LeftClick( trace )
	local ent = trace.Entity
	
	if not simfphys.IsCar( ent ) then return false end
	
	return true
end

function TOOL:RightClick( trace )
	local ent = trace.Entity
	
	if not simfphys.IsCar( ent ) then return false end
	
	if SERVER then
		local SoundType = ent:GetEngineSoundPreset()
		local Sounds = {}
		
		local vehiclelist = list.Get( "simfphys_vehicles" )[ ent:GetSpawn_List() ]
		
		Sounds.TurboBlowOff = ent.snd_blowoff or "simulated_vehicles/turbo_blowoff.ogg"
		Sounds.TurboSpin = ent.snd_spool or "simulated_vehicles/turbo_spin.wav"
		
		Sounds.SuperCharger1 = ent.snd_bloweroff or "simulated_vehicles/blower_spin.wav"
		Sounds.SuperCharger2 = ent.snd_bloweron or "simulated_vehicles/blower_gearwhine.wav"
		
		Sounds.HornSound = ent.snd_horn or "simulated_vehicles/horn_1.wav"
		
		if SoundType == -1 then
			Sounds.Type = -1
			
			Sounds.Idle = vehiclelist.Members.snd_idle or ""
			Sounds.Low = vehiclelist.Members.snd_low or ""
			Sounds.High = vehiclelist.Members.snd_mid or ""
			Sounds.RevDown = vehiclelist.Members.snd_low_revdown or Low
			Sounds.ShiftUp = vehiclelist.Members.snd_mid_gearup or High
			Sounds.ShiftDown = vehiclelist.Members.snd_mid_geardown or ShiftUp
			
			Sounds.Pitch_Low = vehiclelist.Members.snd_low_pitch or 1
			Sounds.Pitch_High = vehiclelist.Members.snd_mid_pitch or 1
			Sounds.Pitch_All = vehiclelist.Members.snd_pitch or 1
			
		elseif SoundType == 0 then
			Sounds.Type = 0
		
			local soundoverride = ent:GetSoundoverride()
			local data = string.Explode( ",", soundoverride)
			
			if soundoverride ~= "" then
				Sounds.IdleSound = data[1]
				Sounds.IdlePitch = data[2]
				
				Sounds.MidSound = data[3]
				Sounds.MidPitch = data[4]
				Sounds.MidVolume =  data[5]
				Sounds.MidFadeOutPercent =  data[6]
				Sounds.MidFadeOutRate = data[7]
				
				Sounds.HighSound = data[8]
				Sounds.HighPitch = data[9]
				Sounds.HighVolume = data[10]
				Sounds.HighFadeInPercent = data[11]
				Sounds.HighFadeRate = data[12]
				
				Sounds.ThrottleSound = data[13]
				Sounds.ThrottlePitch = data[14]
				Sounds.ThrottleVolume = data[15]
			else
				Sounds.IdleSound = vehiclelist and vehiclelist.Members.Sound_Idle or "simulated_vehicles/misc/e49_idle.wav"
				Sounds.IdlePitch = vehiclelist and vehiclelist.Members.Sound_IdlePitch or 1
				
				Sounds.MidSound = vehiclelist and vehiclelist.Members.Sound_Mid or "simulated_vehicles/misc/gto_onlow.wav"
				Sounds.MidPitch = vehiclelist and vehiclelist.Members.Sound_MidPitch or 1
				Sounds.MidVolume =  vehiclelist and vehiclelist.Members.Sound_MidVolume or 0.75
				Sounds.MidFadeOutPercent = vehiclelist and vehiclelist.Members.Sound_MidFadeOutRPMpercent or 68
				Sounds.MidFadeOutRate =  vehiclelist and vehiclelist.Members.Sound_MidFadeOutRate or 0.4
				
				Sounds.HighSound = vehiclelist and vehiclelist.Members.Sound_High or "simulated_vehicles/misc/nv2_onlow_ex.wav"
				Sounds.HighPitch = vehiclelist and vehiclelist.Members.Sound_HighPitch or 1 
				Sounds.HighVolume = vehiclelist and vehiclelist.Members.Sound_HighVolume or 1 
				Sounds.HighFadeInPercent = vehiclelist and vehiclelist.Members.Sound_HighFadeInRPMpercent or 26.6
				Sounds.HighFadeInRate = vehiclelist and vehiclelist.Members.Sound_HighFadeInRate or 0.266
				
				Sounds.ThrottleSound = vehiclelist and vehiclelist.Members.Sound_Throttle or "simulated_vehicles/valve_noise.wav"
				Sounds.ThrottlePitch = vehiclelist and vehiclelist.Members.Sound_ThrottlePitch or 0.65
				Sounds.ThrottleVolume = vehiclelist and vehiclelist.Members.Sound_ThrottleVolume or 1 
			end
		else
			local demSounds = simfphys.SoundPresets[ SoundType ]
			Sounds.Type = -1
			
			Sounds.Idle = demSounds[1]
			Sounds.Low = demSounds[2]
			Sounds.High = demSounds[3]
			Sounds.RevDown = demSounds[4]
			Sounds.ShiftUp = demSounds[5]
			Sounds.ShiftDown = demSounds[6]
			
			Sounds.Pitch_Low = demSounds[7]
			Sounds.Pitch_High = demSounds[8]
			Sounds.Pitch_All = demSounds[9]
		end
		
		PrintTable( Sounds )
	end
	
	return true
end

function TOOL:Reload( trace )
	local ent = trace.Entity
	
	if not simfphys.IsCar( ent ) then return false end
	
	if SERVER then
		local vname = ent:GetSpawn_List()
		local VehicleList = list.Get( "simfphys_vehicles" )[vname]
		
		ent:SetEngineSoundPreset( VehicleList.Members.EngineSoundPreset )
		ent:SetSoundoverride( "" )
	end
	
	return true
end

function TOOL.BuildCPanel( panel )
end
