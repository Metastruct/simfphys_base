include("shared.lua")

function ENT:Initialize()	
	self.SmoothRPM = 0
	self.OldDist = 0
	self.PitchOffset = 0
	self.OldActive = false
	self.OldGear = 0
	self.OldThrottle = 0
	self.FadeThrottle = 0
	
	self.SoundMode = 0
	
	self.HighRPM = CreateSound(self, "")
	self.LowRPM = CreateSound(self, "")
	self.Idle = CreateSound(self, "")
	self.Valves = CreateSound(self, "")
	self.DamageSnd = CreateSound(self, "simulated_vehicles/engine_damaged.wav")
	
	self.Materials = {
		"particle/smokesprites_0001",
		"particle/smokesprites_0002",
		"particle/smokesprites_0003",
		"particle/smokesprites_0004",
		"particle/smokesprites_0005",
		"particle/smokesprites_0006",
		"particle/smokesprites_0007",
		"particle/smokesprites_0008",
		"particle/smokesprites_0009",
		"particle/smokesprites_0010",
		"particle/smokesprites_0011",
		"particle/smokesprites_0012",
		"particle/smokesprites_0013",
		"particle/smokesprites_0014",
		"particle/smokesprites_0015",
		"particle/smokesprites_0016"
	}
	self.EngineSounds = {}
	self.Emitter = {}
end

function ENT:Think()
	local curtime = CurTime()
	
	self.NextSound = self.NextSound or 0
	if self.NextSound < curtime then
		self:ManageSounds( self:GetActive() )
		self.NextSound = curtime + 0.03
	end
	
	self:SetPoseParameters( curtime )
	self:NextThink( curtime )
	
	return true
end

function ENT:SetPoseParameters( curtime )
	self:SetPoseParameter("vehicle_steer", self:GetVehicleSteer() )
	
	if !istable(self.pp_data) then
		self.ppNextCheck = self.ppNextCheck or curtime + 0.5
		if self.ppNextCheck < curtime then
			self.ppNextCheck = curtime + 0.5
			
			net.Start("simfphys_request_ppdata")
				net.WriteEntity( self )
			net.SendToServer()
		end
	else
		if !self.CustomWheels then
			for i = 1, table.Count( self.pp_data ) do
				local Wheel = self.pp_data[i].entity
				
				if IsValid(Wheel) then
					local addPos = Wheel:GetDamaged() and self.pp_data[i].dradius or 0
					
					local Pose = (self.pp_data[i].pos - self:WorldToLocal( Wheel:GetPos()).z + addPos ) / self.pp_data[i].travel
					self:SetPoseParameter( self.pp_data[i].name, Pose ) 
				end
			end
		end
	end
	
	self:InvalidateBoneCache()
end

function ENT:GetRPM()
	local RPM = self.SmoothRPM and self.SmoothRPM or 0
	return RPM
end

function ENT:ManageSounds(Active)
	local FlyWheelRPM = self:GetFlyWheelRPM()
	local Active = Active and (FlyWheelRPM != 0)
	local LimitRPM = self:GetLimitRPM()
	local IdleRPM = self:GetIdleRPM()
	
	local IsCruise = self:GetIsCruiseModeOn()
	
	local CurDist =  (LocalPlayer():GetPos() - self:GetPos()):Length()
	local Throttle =  IsCruise and math.Clamp(self:GetThrottle() ^ 3,0.01,0.7) or self:GetThrottle()
	local Gear = self:GetGear()
	local Clutch = self:GetClutch()
	local FadeRPM = LimitRPM * 0.5
	
	self.FadeThrottle = self.FadeThrottle + math.Clamp(Throttle - self.FadeThrottle,-0.2,0.2)
	self.PitchOffset = self.PitchOffset + ((CurDist - self.OldDist) * 0.23 - self.PitchOffset) * 0.5
	self.OldDist = CurDist
	self.SmoothRPM = self.SmoothRPM + math.Clamp(FlyWheelRPM - self.SmoothRPM,-350,350)
	
	self.OldThrottle2 = self.OldThrottle2 or 0
	if (Throttle != self.OldThrottle2) then
		self.OldThrottle2 = Throttle
		if (Throttle == 0) then
			if (self.SmoothRPM > LimitRPM * 0.6) then
				self:Backfire()
			end
		end
	end
	
	if (self:GetRevlimiter() and LimitRPM > 2500) then
		if ((self.SmoothRPM >= LimitRPM - 200) and self.FadeThrottle > 0) then
			self.SmoothRPM = self.SmoothRPM - 1200
			self.FadeThrottle = 0.2
			self:Backfire()
		end
	end
	
	if (Active != self.OldActive) then
		local preset = self:GetEngineSoundPreset()
		local UseGearResetter = self:SetSoundPreset(preset)
		
		self.SoundMode = UseGearResetter and 2 or 1
		
		self.OldActive = Active
		
		if (Active) then
			local MaxHealth = self:GetMaxHealth()
			local Health = self:GetCurHealth()
			
			if Health <= (MaxHealth * 0.6) then
				self.DamageSnd:PlayEx(0,0)
			end
			
			if (self.SoundMode == 2) then
				self.HighRPM = CreateSound(self, self.EngineSounds[ "HighRPM" ] )
				self.LowRPM = CreateSound(self, self.EngineSounds[ "LowRPM" ])
				self.Idle = CreateSound(self, self.EngineSounds[ "Idle" ])
				
				self.HighRPM:PlayEx(0,0)
				self.LowRPM:PlayEx(0,0)
				self.Idle:PlayEx(0,0)
			else
				local IdleSound = self.EngineSounds[ "IdleSound" ]
				local LowSound = self.EngineSounds[ "LowSound" ]
				local HighSound = self.EngineSounds[ "HighSound" ]
				local ThrottleSound = self.EngineSounds[ "ThrottleSound" ]
				
				if (IdleSound) then
					self.Idle = CreateSound(self, IdleSound)
					self.Idle:PlayEx(0,0)
				end
				
				if (LowSound) then
					self.LowRPM = CreateSound(self, LowSound)
					self.LowRPM:PlayEx(0,0)
				end
				
				if (HighSound) then
					self.HighRPM = CreateSound(self, HighSound)
					self.HighRPM:PlayEx(0,0)
				end
				
				if (ThrottleSound) then
					self.Valves = CreateSound(self, ThrottleSound)
					self.Valves:PlayEx(0,0)
				end
			end
		else
			self.HighRPM:Stop()
			self.LowRPM:Stop()
			self.Idle:Stop()
			self.Valves:Stop()
			self.DamageSnd:Stop()
		end
	end
	
	if (Active) then		
		local Volume = 0.25 + 0.25 * ((self.SmoothRPM / LimitRPM) ^ 1.5) + self.FadeThrottle * 0.5
		local Pitch = math.Clamp( (20 + self.SmoothRPM / 50 - self.PitchOffset) * self.PitchMulAll,0,255)
		
		if self.DamageSnd then
			self.DamageSnd:ChangeVolume( (self.SmoothRPM / LimitRPM) * 0.6 ^ 1.5 )
			self.DamageSnd:ChangePitch( 100 ) 
		end
		
		if (self.SoundMode == 2) then
			if (self.FadeThrottle != self.OldThrottle) then
				self.OldThrottle = self.FadeThrottle
				if (self.FadeThrottle == 0 and Clutch == 0) then
					if (self.SmoothRPM >= FadeRPM) then
						if (IsCruise != true) then
							self.LowRPM:Stop()
							self.LowRPM = CreateSound(self, self.EngineSounds[ "RevDown" ] )
							self.LowRPM:PlayEx(0,0)
						end
					end
				end
			end
			
			if (Gear != self.OldGear) then
				if (self.SmoothRPM >= FadeRPM and Gear > 3) then
					if (Clutch != 1) then
						if (self.OldGear < Gear) then
							self.HighRPM:Stop()
							self.HighRPM = CreateSound(self, self.EngineSounds[ "ShiftUpToHigh" ] )
							self.HighRPM:PlayEx(0,0)
							
							if (self.SmoothRPM > LimitRPM * 0.6) then
								if (math.Round(math.random(0,4),1) >= 3) then
									timer.Simple(0.4, function()
										if (!IsValid(self)) then return end
										self:Backfire()
									end)
								end
							end
						else
							if (self.FadeThrottle > 0) then
								self.HighRPM:Stop()
								self.HighRPM = CreateSound(self, self.EngineSounds[ "ShiftDownToHigh" ] )
								self.HighRPM:PlayEx(0,0)
							end
						end
					end
				else 
					if (Clutch != 1) then
						if (self.OldGear > Gear and self.FadeThrottle > 0 and Gear >= 3) then
							self.HighRPM:Stop()
							self.HighRPM = CreateSound(self, self.EngineSounds[ "ShiftDownToHigh" ] )
							self.HighRPM:PlayEx(0,0)
						else 
							self.HighRPM:Stop()
							self.LowRPM:Stop()
							self.HighRPM = CreateSound(self, self.EngineSounds[ "HighRPM" ] )
							self.LowRPM = CreateSound(self, self.EngineSounds[ "LowRPM" ])
							self.HighRPM:PlayEx(0,0)
							self.LowRPM:PlayEx(0,0)
						end
					end
				end
				self.OldGear = Gear
			end
			
			self.Idle:ChangeVolume( math.Clamp( math.min((self.SmoothRPM / IdleRPM) * 3,1.5 + self.FadeThrottle  * 0.5) * 0.7 - self.SmoothRPM / 2000 ,0,1) )
			self.Idle:ChangePitch( math.Clamp( Pitch * 3,0,255) ) 
			
			self.LowRPM:ChangeVolume( math.Clamp(Volume - (self.SmoothRPM - 2000) / 2000 * self.FadeThrottle,0,1) )
			self.LowRPM:ChangePitch( math.Clamp( Pitch * self.PitchMulLow,0,255) )
			
			
			local hivol = math.max((self.SmoothRPM - 2000) / 2000,0) * Volume
			self.HighRPM:ChangeVolume( self.FadeThrottle < 0.4 and hivol * self.FadeThrottle or hivol * self.FadeThrottle * 2.5  )
			self.HighRPM:ChangePitch( math.Clamp( Pitch * self.PitchMulHigh,0,255) )
		else
			if (Gear != self.OldGear) then
				if (self.SmoothRPM >= FadeRPM and Gear > 3) then
					if (Clutch != 1) then
						if (self.OldGear < Gear) then
							if (self.SmoothRPM > LimitRPM * 0.6) then
								if (math.Round(math.random(0,4),1) >= 3) then
									timer.Simple(0.4, function()
										if (!IsValid(self)) then return end
										self:Backfire()
									end)
								end
							end
						end
					end
				end
				self.OldGear = Gear
			end
		
		
			local IdlePitch = self.Idle_PitchMul
			self.Idle:ChangeVolume( math.Clamp( math.min((self.SmoothRPM / IdleRPM) * 3,1.5 + self.FadeThrottle * 0.5) * 0.7 - self.SmoothRPM / 2000,0,1))
			self.Idle:ChangePitch( math.Clamp( Pitch * 3 * IdlePitch,0,255) )
			
			local LowPitch = self.Mid_PitchMul
			local LowVolume = self.Mid_VolumeMul
			local LowFadeOutRPM = LimitRPM * (self.Mid_FadeOutRPMpercent / 100)
			local LowFadeOutRate = LimitRPM * self.Mid_FadeOutRate
			self.LowRPM:ChangeVolume( math.Clamp( (Volume - math.Clamp((self.SmoothRPM - LowFadeOutRPM) / LowFadeOutRate,0,1)) * LowVolume,0,1))
			self.LowRPM:ChangePitch( math.Clamp(Pitch * LowPitch,0,255) ) 
			
			local HighPitch = self.High_PitchMul
			local HighVolume = self.High_VolumeMul
			local HighFadeInRPM = LimitRPM * (self.High_FadeInRPMpercent / 100)
			local HighFadeInRate = LimitRPM * self.High_FadeInRate
			self.HighRPM:ChangeVolume( math.Clamp( math.Clamp((self.SmoothRPM - HighFadeInRPM) / HighFadeInRate,0,Volume) * HighVolume,0,1))
			self.HighRPM:ChangePitch( math.Clamp(Pitch * HighPitch,0,255) ) 
			
			local ThrottlePitch = self.Throttle_PitchMul
			local ThrottleVolume = self.Throttle_VolumeMul
			self.Valves:ChangeVolume( math.Clamp((self.SmoothRPM - 2000) / 2000,0,Volume) * (0.2 + 0.15 * self.FadeThrottle) * ThrottleVolume)
			self.Valves:ChangePitch( math.Clamp(Pitch * ThrottlePitch,0,255) ) 
		end
	end
end

function ENT:Backfire( damaged )
	if (!self:GetBackFire() and !damaged) then return end
	
	local vehiclelist = list.Get( "simfphys_vehicles" )[self:GetSpawn_List()]
	if (vehiclelist) then
		local expos = vehiclelist.Members.ExhaustPositions
		
		if (expos) then
			for i = 1, table.Count( expos ) do
				if (math.Round(math.random(1,3),1) >= 2 or damaged) then
					local Pos = expos[i].pos
					local Ang = expos[i].ang - Angle(90,0,0)
					
					if (expos[i].OnBodyGroups) then
						if (self:BodyGroupIsValid( expos[i].OnBodyGroups )) then
							self:BfFx(Pos,Ang,damaged)
						end
					else
						self:BfFx(Pos,Ang,damaged)
					end
				end
			end
		end
	end
end

function ENT:BfFx( lPos , lAng , bdamaged)
	local Delay = bdamaged and 0 or math.random(0,0.4)
	timer.Simple( Delay, function()
		if (!IsValid(self)) then return end
		
		local snd = bdamaged and "simulated_vehicles/sfx/ex_backfire_damaged_"..math.Round(math.random(1,3),1)..".ogg" or "simulated_vehicles/sfx/ex_backfire_"..math.Round(math.random(1,4),1)..".ogg"
		self:EmitSound( snd )	
		
		local Vel = self:GetVelocity() * (game.SinglePlayer() and 0 or 1)
		local Pos = self:LocalToWorld( lPos )
		local Ang = self:LocalToWorldAngles( lAng )
		
		local dlight = DynamicLight( self:EntIndex() * math.random(1,4) )
		if ( dlight ) then
			dlight.pos = Pos + Vel / 66
			dlight.r = 255
			dlight.g = 180
			dlight.b = 100
			dlight.brightness = 2
			dlight.Decay = 1000
			dlight.Size = 120
			dlight.DieTime = CurTime() + 0.5
		end
		
		for i = 1, 10 do
			local emitter1 = self:GetEmitter(i, Pos, false )
			local emitter2 = self:GetEmitter(i, Pos, false )

			local particle1 = emitter1:Add( "effects/muzzleflash2", Pos )
			local particle2 = emitter2:Add( self.Materials[math.Round(math.Rand(1, table.Count(self.Materials) ),0)], Pos )

			if ( particle1 ) then
				particle1:SetVelocity( Vel + Ang:Forward() * 5 )
				particle1:SetDieTime( 0.1 )
				particle1:SetStartAlpha( 255 )
				particle1:SetStartSize( math.random(4,12) )
				particle1:SetEndSize( 0 )
				particle1:SetRoll( math.Rand( -1, 1 ) )
				particle1:SetColor( 255,255,255 )
				particle1:SetCollide( false )
			end
			
			if ( particle2 ) then
				particle2:SetVelocity( Vel + Ang:Forward() * 10 )
				particle2:SetDieTime( 0.3 )
				particle2:SetStartAlpha( 60 )
				particle2:SetStartSize( 0 )
				particle2:SetEndSize( math.random(8,20) )
				particle2:SetRoll( math.Rand( -1, 1 ) )
				particle2:SetColor( 100,100,100 )
				particle2:SetCollide( false )
			end
			
			if bdamaged then
				local emitter3 = self:GetEmitter(i, Pos, false )

				local particle3 = emitter2:Add( self.Materials[math.Round(math.Rand(1, table.Count(self.Materials) ),0)], Pos )

				if ( particle3 ) then
					particle3:SetVelocity( Vel + Ang:Forward() * math.random(30,60) )
					particle3:SetDieTime( 0.5 )
					particle3:SetAirResistance( 20 ) 
					particle3:SetStartAlpha( 100 )
					particle3:SetStartSize( 0 )
					particle3:SetEndSize( math.random(25,50) )
					particle3:SetRoll( math.Rand( -1, 1 ) )
					particle3:SetColor( 40,40,40 )
					particle3:SetCollide( false )
				end
			end
		end
	end)
end

function ENT:GetEmitter( In, Pos, b3D )
	if ( self.Emitter[In] ) then
		if ( self.EmitterIs3Dr == b3D && self.EmitterTimer > CurTime() ) then
			return self.Emitter[In] 
		end
	end
	
	self.Emitter[In] = ParticleEmitter( Pos, b3D )
	self.EmitterIs3Dr = b3D
	self.EmitterTimer = CurTime() + 2
	return self.Emitter[In]
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:SetSoundPreset(index)
	if (index == -1) then
		local vehiclelist = list.Get( "simfphys_vehicles" )[self:GetSpawn_List()]
		if (vehiclelist) then
			local idle = vehiclelist.Members.snd_idle or ""
			local low = vehiclelist.Members.snd_low or ""
			local mid = vehiclelist.Members.snd_mid or ""
			local revdown = vehiclelist.Members.snd_low_revdown or ""
			local gearup = vehiclelist.Members.snd_mid_gearup or ""
			local geardown = vehiclelist.Members.snd_mid_geardown or ""
			
			self.EngineSounds[ "Idle" ] = idle != "" and idle or false
			self.EngineSounds[ "LowRPM" ] = low != "" and low or false
			self.EngineSounds[ "HighRPM" ] = mid != "" and mid or false
			self.EngineSounds[ "RevDown" ] = revdown != "" and revdown or low
			self.EngineSounds[ "ShiftUpToHigh" ] = gearup != "" and gearup or mid
			self.EngineSounds[ "ShiftDownToHigh" ] = geardown != "" and geardown or gearup
			
			self.PitchMulLow = vehiclelist.Members.snd_low_pitch or 1
			self.PitchMulHigh = vehiclelist.Members.snd_mid_pitch or 1
			self.PitchMulAll = vehiclelist.Members.snd_pitch or 1
		else
			local ded = "common/bugreporter_failed.wav"
			
			self.EngineSounds[ "Idle" ] = ded
			self.EngineSounds[ "LowRPM" ] = ded
			self.EngineSounds[ "HighRPM" ] = ded
			self.EngineSounds[ "RevDown" ] = ded
			self.EngineSounds[ "ShiftUpToHigh" ] = ded
			self.EngineSounds[ "ShiftDownToHigh" ] = ded
			
			self.PitchMulLow = 0
			self.PitchMulHigh = 0
			self.PitchMulAll = 0
		end
		
		if (self.EngineSounds[ "Idle" ] != false and self.EngineSounds[ "LowRPM" ] != false and self.EngineSounds[ "HighRPM" ] != false) then
			self:ValidateSounds()
			
			return true
		else
			self:SetSoundPreset( 0 )
			return false
		end
	end

	if (index == 0) then
		local vehiclelist = list.Get( "simfphys_vehicles" )[self:GetSpawn_List()] or false
		
		local soundoverride = self:GetSoundoverride()
		local data = string.Explode( ",", soundoverride)
		
		if (soundoverride != "") then
			self.EngineSounds[ "IdleSound" ] = data[1]
			self.Idle_PitchMul = data[2]
			
			self.EngineSounds[ "LowSound" ] = data[3]
			self.Mid_PitchMul = data[4]
			self.Mid_VolumeMul =  data[5]
			self.Mid_FadeOutRPMpercent =  data[6]
			self.Mid_FadeOutRate = data[7]
			
			self.EngineSounds[ "HighSound" ] = data[8]
			self.High_PitchMul = data[9]
			self.High_VolumeMul = data[10]
			self.High_FadeInRPMpercent = data[11]
			self.High_FadeInRate = data[12]
			
			self.EngineSounds[ "ThrottleSound" ] = data[13]
			self.Throttle_PitchMul = data[14]
			self.Throttle_VolumeMul = data[15]
		else
			self.EngineSounds[ "IdleSound" ] = vehiclelist and vehiclelist.Members.Sound_Idle or "simulated_vehicles/misc/e49_idle.wav"
			self.Idle_PitchMul = (vehiclelist and vehiclelist.Members.Sound_IdlePitch) or 1
			
			self.EngineSounds[ "LowSound" ] = vehiclelist and vehiclelist.Members.Sound_Mid or "simulated_vehicles/misc/gto_onlow.wav"
			self.Mid_PitchMul = (vehiclelist and vehiclelist.Members.Sound_MidPitch) or 1
			self.Mid_VolumeMul =  (vehiclelist and vehiclelist.Members.Sound_MidVolume) or 0.75
			self.Mid_FadeOutRPMpercent =  (vehiclelist and vehiclelist.Members.Sound_MidFadeOutRPMpercent) or 68
			self.Mid_FadeOutRate =  (vehiclelist and vehiclelist.Members.Sound_MidFadeOutRate) or 0.4
			
			self.EngineSounds[ "HighSound" ] = vehiclelist and vehiclelist.Members.Sound_High or "simulated_vehicles/misc/nv2_onlow_ex.wav"
			self.High_PitchMul = (vehiclelist and vehiclelist.Members.Sound_HighPitch) or 1 
			self.High_VolumeMul = (vehiclelist and vehiclelist.Members.Sound_HighVolume) or 1 
			self.High_FadeInRPMpercent = (vehiclelist and vehiclelist.Members.Sound_HighFadeInRPMpercent) or 26.6
			self.High_FadeInRate = (vehiclelist and vehiclelist.Members.Sound_HighFadeInRate) or 0.266
			
			self.EngineSounds[ "ThrottleSound" ] = vehiclelist and vehiclelist.Members.Sound_Throttle or "simulated_vehicles/valve_noise.wav"
			self.Throttle_PitchMul = (vehiclelist and vehiclelist.Members.Sound_ThrottlePitch) or 0.65
			self.Throttle_VolumeMul = (vehiclelist and vehiclelist.Members.Sound_ThrottleVolume) or 1 
		end
		
		self.PitchMulLow = 1
		self.PitchMulHigh = 1
		self.PitchMulAll = 1
		
		self:ValidateSounds()
		
		return false
	end
	
	if (index > 0) then  -- to be honest nobody should be using these anymore...  but i keep them in for backwards compatibility
		local clampindex = math.Clamp(index,1,table.Count(simfphys.SoundPresets))
		self.EngineSounds[ "Idle" ] = simfphys.SoundPresets[clampindex][1]
		self.EngineSounds[ "LowRPM" ] = simfphys.SoundPresets[clampindex][2]
		self.EngineSounds[ "HighRPM" ] = simfphys.SoundPresets[clampindex][3]
		self.EngineSounds[ "RevDown" ] = simfphys.SoundPresets[clampindex][4]
		self.EngineSounds[ "ShiftUpToHigh" ] = simfphys.SoundPresets[clampindex][5]
		self.EngineSounds[ "ShiftDownToHigh" ] = simfphys.SoundPresets[clampindex][6]
		
		self.PitchMulLow = simfphys.SoundPresets[clampindex][7]
		self.PitchMulHigh = simfphys.SoundPresets[clampindex][8]
		self.PitchMulAll = simfphys.SoundPresets[clampindex][9]
		
		self:ValidateSounds()
		
		return true
	end
	
	return false
end

function ENT:ValidateSounds()
	for index, sound in pairs( self.EngineSounds ) do
		if not isbool(sound) then
			if not file.Exists( "sound/"..sound, "GAME" ) then
				print("Warning soundfile \""..sound.."\" not found. Using \"common/null.wav\" instead to prevent fps rape")
				self.EngineSounds[index] = "common/null.wav"
			end
		end
	end
end

function ENT:OnRemove()
	self.HighRPM:Stop()
	self.LowRPM:Stop()
	self.Idle:Stop()
	self.Valves:Stop()
	self.DamageSnd:Stop()
end

function ENT:BodyGroupIsValid( bodygroups )
	for index, groups in pairs( bodygroups ) do
		local mygroup = self:GetBodygroup( index )
		for g_index = 1, table.Count( groups ) do
			if (mygroup == groups[g_index]) then return true end
		end
	end
	return false
end
