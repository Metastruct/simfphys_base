include("shared.lua")

local SpritesDisabled = false
cvars.AddChangeCallback( "cl_simfphys_hidesprites", function( convar, oldValue, newValue )
	SpritesDisabled = ( tonumber( newValue )~=0 )
end)
SpritesDisabled = GetConVar( "cl_simfphys_hidesprites" ):GetBool()

function ENT:Initialize()	
	self.SmoothRPM = 0
	self.OldDist = 0
	self.PitchOffset = 0
	self.OldActive = false
	self.OldGear = 0
	self.OldThrottle = 0
	self.FadeThrottle = 0
	self.EnableLights = 0
	self.ListFound = false
	
	self.SoundMode = 0
	
	self.HighRPM = CreateSound(self, "")
	self.LowRPM = CreateSound(self, "")
	self.Idle = CreateSound(self, "")
	self.Valves = CreateSound(self, "")
	
	self.mat = Material( "sprites/light_ignorez" )
	if (file.Exists( "materials/sprites/glow_headlight_ignorez.vmt", "GAME" )) then
		self.mat2 = Material( "sprites/glow_headlight_ignorez" )
	else
		self.mat2 = Material( "sprites/light_glow02_add_noz" )
	end
	
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
	local Active = self:GetActive()
	
	self.NextSound = self.NextSound or 0
	if ( self.NextSound < CurTime() ) then
		self:ManageSounds(Active)
		self.NextSound = CurTime() + 0.03
		
		if (self.EnableLights == 1 or self.EnableLights == -1) then return end
		local listname = self:GetLights_List() or false
		
		if (!listname) then return end
		if (listname != "no_lights") then
			self:SetUpLights( listname )
		else
			self.EnableLights = -1
		end
	end
	
	self:NextThink(CurTime())
	return true
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
	self.PitchOffset = self.PitchOffset + ((CurDist - self.OldDist) * 0.3 - self.PitchOffset) * 0.5
	self.OldDist = CurDist
	self.SmoothRPM = self.SmoothRPM + math.Clamp(FlyWheelRPM - self.SmoothRPM,-350,350)
	
	self.OldThrottle2 = self.OldThrottle2 or 0
	if (Throttle != self.OldThrottle2) then
		self.OldThrottle2 = Throttle
		if (Throttle == 0) then
			if (self.SmoothRPM > LimitRPM * 0.6) then
				self:HandleBackFiring()
			end
		end
	end
	
	if (self:GetRevlimiter() and LimitRPM > 2500) then
		if ((self.SmoothRPM >= LimitRPM - 200) and self.FadeThrottle > 0) then
			self.SmoothRPM = self.SmoothRPM - 1200
			self.FadeThrottle = 0.2
			self:HandleBackFiring()
		end
	end
	
	if (Active != self.OldActive) then
		local preset = self:GetEngineSoundPreset()
		local UseGearResetter = self:SetSoundPreset(preset)
		
		self.SoundMode = UseGearResetter and 2 or 1
		
		self.OldActive = Active
		
		if (Active) then
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
		end
	end
	
	if (Active) then		
		local Volume = 0.25 + 0.25 * ((self.SmoothRPM / LimitRPM) ^ 1.5) + self.FadeThrottle * 0.5
		local Pitch = math.Clamp( (20 + self.SmoothRPM / 50 - self.PitchOffset) * self.PitchMulAll,0,255)
		
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
										self:HandleBackFiring()
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
										self:HandleBackFiring()
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

function ENT:HandleBackFiring()
	if (!self:GetBackFire()) then return end
	
	local vehiclelist = list.Get( "simfphys_vehicles" )[self:GetSpawn_List()]
	if (vehiclelist) then
		local expos = vehiclelist.Members.ExhaustPositions
		
		if (expos) then
			for i = 1, table.Count( expos ) do
				if (math.Round(math.random(1,3),1) >= 2) then
					local Pos = expos[i].pos
					local Ang = expos[i].ang - Angle(90,0,0)
					
					if (expos[i].OnBodyGroups) then
						if (self:BodyGroupIsValid( expos[i].OnBodyGroups )) then
							self:BfFx(Pos,Ang)
						end
					else
						self:BfFx(Pos,Ang)
					end
				end
			end
		end
	end
end

function ENT:BfFx(lPos,lAng)
	timer.Simple( math.random(0,0.4), function()
		if (!IsValid(self)) then return end
		
		self:EmitSound( "simulated_vehicles/ex_backfire_"..math.Round(math.random(1,4),1)..".wav" )	
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
			local emitter = self:GetEmitter(i, Pos, false )
			local emitter2 = self:GetEmitter(i, Pos, false )

			local particle = emitter:Add( "effects/muzzleflash2", Pos )
			local particle2 = emitter2:Add( self.Materials[math.Round(math.Rand(1, table.Count(self.Materials) ),0)], Pos )

			if ( particle ) then
				particle:SetVelocity( Vel + Ang:Forward() * 5 )
				particle:SetDieTime( 0.1 )
				particle:SetStartAlpha( 255 )
				particle:SetStartSize( math.random(4,12) )
				particle:SetEndSize( 0 )
				particle:SetRoll( math.Rand( -1, 1 ) )
				particle:SetColor( 255,255,255 )
				particle:SetCollide( false )
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

	if (self.EnableLights != 1) then return end
	
	if (self:GetEMSEnabled()) then
		self:DrawEMSLights()
	end
	
	if (SpritesDisabled) then return end
	
	if (self:GetFogLightsEnabled()) then
		self:DrawFogLights()
	end
	
	if (self:GetLightsEnabled()) then
		self:DrawLights()
	end
	
	if (self:GetLampsEnabled()) then
		self:DrawHighBeams()
	end
	
	if (self:GetIsBraking() and self.LightsBrake) then
		self:DrawBrakeLights()
	end
	
	if (self:GetGear() == 1 and self.LightsReverse) then
		self:DrawReverseLights()
	end
end

function ENT:DrawHighBeams()
	if (self.Lights_h) then
		for i = 1, table.Count( self.Lights_h ) do
			if (isvector(self.Lights_h[i])) then
				local LightPos = self:LocalToWorld( self.Lights_h[i] )
				local Visible = util.PixelVisible( LightPos, 4, self.PixVis_h[i] )
				
				if Visible and Visible >= 0.6 then
					Visible = (Visible - 0.6) / 0.4
					
					render.SetMaterial( self.mat )
					render.DrawSprite( LightPos, 16, 16,  Color( self.hl_col[1], self.hl_col[2], self.hl_col[3],  255 * Visible) )
					
					render.SetMaterial( self.mat2 )
					render.DrawSprite( LightPos, 64, 64,  Color( self.hl_col[1], self.hl_col[2], self.hl_col[3],  150 * Visible) )
				end
			else
				local LightPos = self:LocalToWorld( self.Lights_h[i].pos )
				local Visible = util.PixelVisible( LightPos, 4, self.PixVis_h[i] )
				local s_col = self.Lights_h[i].color
				local s_mat = self.Lights_h[i].material
				local s_size = self.Lights_h[i].size
				
				if (self.Lights_h[i].OnBodyGroups) then
					Visible = !self:BodyGroupIsValid( self.Lights_h[i].OnBodyGroups ) and 0 or Visible
				end
				
				if Visible and Visible >= 0.6 then
					Visible = (Visible - 0.6) / 0.4
					render.SetMaterial( s_mat )
					render.DrawSprite( LightPos, s_size, s_size,  Color( s_col["r"], s_col["g"], s_col["b"],  s_col["a"] * Visible) )
				end
			end
		end
	end
end

function ENT:DrawBrakeLights()
	for i = 1, table.Count( self.LightsBrake ) do
		if (isvector(self.LightsBrake[i])) then
			local LightPos = self:LocalToWorld( self.LightsBrake[i] )
			local Visible = util.PixelVisible( LightPos, 4, self.PixVisBrake[i] )
			
			if Visible and Visible >= 0.6 then
				Visible = (Visible - 0.6) / 0.4
				
				render.SetMaterial( self.mat2 )
				render.DrawSprite( LightPos, 12, 12,  Color( 255, 120, 0,  125 * Visible) )
				
				render.SetMaterial( self.mat )
				render.DrawSprite( LightPos, 32, 32,  Color( 255, 0, 0,  90 * Visible) )
			end
		else
			local LightPos = self:LocalToWorld( self.LightsBrake[i].pos )
			local Visible = util.PixelVisible( LightPos, 4, self.PixVisBrake[i] )
			local s_col = self.LightsBrake[i].color
			local s_mat = self.LightsBrake[i].material
			local s_size = self.LightsBrake[i].size
			
			if (self.LightsBrake[i].OnBodyGroups) then
					Visible = !self:BodyGroupIsValid( self.LightsBrake[i].OnBodyGroups ) and 0 or Visible
				end
			
			if Visible and Visible >= 0.6 then
				Visible = (Visible - 0.6) / 0.4
				render.SetMaterial( s_mat )
				render.DrawSprite( LightPos, s_size, s_size,  Color( s_col["r"], s_col["g"], s_col["b"],  s_col["a"] * Visible) )
			end
		end
	end
end

function ENT:DrawFogLights()
	if (self.Lights_f) then
		for i = 1, table.Count( self.Lights_f ) do
			if (isvector(self.Lights_f[i])) then
				local LightPos = self:LocalToWorld( self.Lights_f[i] )
				local Visible = util.PixelVisible( LightPos, 4, self.PixVis_f[i] )
				
				if Visible and Visible >= 0.6 then
					Visible = (Visible - 0.6) / 0.4
					
					render.SetMaterial( self.mat2 )
					render.DrawSprite( LightPos, 32, 32,  Color( self.hl_col[1], self.hl_col[2], self.hl_col[3],  200 * Visible) )
				end
			else
				local LightPos = self:LocalToWorld( self.Lights_f[i].pos )
				local Visible = util.PixelVisible( LightPos, 4, self.PixVis_f[i] )
				local s_col = self.Lights_f[i].color
				local s_mat = self.Lights_f[i].material
				local s_size = self.Lights_f[i].size
				
				if (self.Lights_f[i].OnBodyGroups) then
					Visible = !self:BodyGroupIsValid( self.Lights_f[i].OnBodyGroups ) and 0 or Visible
				end
				
				if Visible and Visible >= 0.6 then
					Visible = (Visible - 0.6) / 0.4
					render.SetMaterial( s_mat )
					render.DrawSprite( LightPos, s_size, s_size,  Color( s_col["r"], s_col["g"], s_col["b"],  s_col["a"] * Visible) )
				end
			end
		end
	end
end

function ENT:DrawEMSLights()
	local Time = CurTime()
	if (self.LightsEMS) then
		for i = 1, table.Count( self.LightsEMS ) do
			local size = self.LightsEMS[i].size
			local LightPos = self:LocalToWorld( self.LightsEMS[i].pos )
			local Visible = util.PixelVisible( LightPos, 4, self.PixVisEMS[i] )
			local mat = self.LightsEMS[i].material
			local numcolors = table.Count( self.LightsEMS[i].Colors )
			
			self.LightsEMS[i].Timer = self.LightsEMS[i].Timer or 0
			self.LightsEMS[i].Index = self.LightsEMS[i].Index or 0
			if (numcolors > 1) then
				if (self.LightsEMS[i].Timer < Time) then
					self.LightsEMS[i].Timer = Time + self.LightsEMS[i].Speed
					self.LightsEMS[i].Index = self.LightsEMS[i].Index + 1
					if (self.LightsEMS[i].Index > numcolors) then
						self.LightsEMS[i].Index = 1
					end
				end
			end
			local col = self.LightsEMS[i].Colors[self.LightsEMS[i].Index]
			
			if (self.LightsEMS[i].OnBodyGroups) then
				Visible = !self:BodyGroupIsValid( self.LightsEMS[i].OnBodyGroups ) and 0 or Visible
			end
			
			if Visible and Visible >= 0.6 and col != Color(0,0,0,0) then
				Visible = (Visible - 0.6) / 0.4
				
				render.SetMaterial( mat )
				render.DrawSprite( LightPos, size, size,  Color( col["r"], col["g"], col["b"],  col["a"] * Visible) )
			end
		end
	end
end

function ENT:DrawReverseLights()
	for i = 1, table.Count( self.LightsReverse ) do
		if (isvector(self.LightsReverse[i])) then
			local LightPos = self:LocalToWorld( self.LightsReverse[i] )
			local Visible = util.PixelVisible( LightPos, 4, self.PixVisReverse[i] )
			
			if Visible and Visible >= 0.6 then
				Visible = (Visible - 0.6) / 0.4
				
				render.SetMaterial( self.mat )
				render.DrawSprite( LightPos, 12, 12,  Color( 255, 255, 255,  255 * Visible) )
				
				render.SetMaterial( self.mat2 )
				render.DrawSprite( LightPos, 16, 16,  Color( 255, 255, 255,  150 * Visible) )
			end
		else
			local LightPos = self:LocalToWorld( self.LightsReverse[i].pos )
			local Visible = util.PixelVisible( LightPos, 4, self.PixVisReverse[i] )
			local s_col = self.LightsReverse[i].color
			local s_mat = self.LightsReverse[i].material
			local s_size = self.LightsReverse[i].size
			
			if (self.LightsReverse[i].OnBodyGroups) then
				Visible = !self:BodyGroupIsValid( self.LightsReverse[i].OnBodyGroups ) and 0 or Visible
			end
			
			if Visible and Visible >= 0.6 then
				Visible = (Visible - 0.6) / 0.4
				render.SetMaterial( s_mat )
				render.DrawSprite( LightPos, s_size, s_size,  Color( s_col["r"], s_col["g"], s_col["b"],  s_col["a"] * Visible) )
			end
		end
	end
end

function ENT:DrawLights()
	if (self.Lights) then
		for i = 1, table.Count( self.Lights ) do
			if (isvector(self.Lights[i])) then
				local LightPos = self:LocalToWorld( self.Lights[i] )
				local Visible = util.PixelVisible( LightPos, 4, self.PixVis[i] )
				
				if Visible and Visible >= 0.6 then
					Visible = (Visible - 0.6) / 0.4
					
					render.SetMaterial( self.mat )
					render.DrawSprite( LightPos, 16, 16,  Color( self.hl_col[1], self.hl_col[2], self.hl_col[3],  255 * Visible) )
					
					render.SetMaterial( self.mat2 )
					render.DrawSprite( LightPos, 64, 64,  Color( self.hl_col[1], self.hl_col[2], self.hl_col[3],  150 * Visible) )
				end
			else
				local LightPos = self:LocalToWorld( self.Lights[i].pos )
				local Visible = util.PixelVisible( LightPos, 4, self.PixVis[i] )
				local s_col = self.Lights[i].color
				local s_mat = self.Lights[i].material
				local s_size = self.Lights[i].size
				
				if (self.Lights[i].OnBodyGroups) then
					Visible = !self:BodyGroupIsValid( self.Lights[i].OnBodyGroups ) and 0 or Visible
				end
				
				if Visible and Visible >= 0.6 then
					Visible = (Visible - 0.6) / 0.4
					render.SetMaterial( s_mat )
					render.DrawSprite( LightPos, s_size, s_size,  Color( s_col["r"], s_col["g"], s_col["b"],  s_col["a"] * Visible) )
				end
			end
		end
	end

	if (self.LightsRear) then
		for i = 1, table.Count( self.LightsRear ) do
			if (isvector(self.LightsRear[i])) then
				local LightPos = self:LocalToWorld( self.LightsRear[i] )
				local Visible = util.PixelVisible( LightPos, 4, self.PixVisRear[i] )
				
				if Visible and Visible >= 0.6 then
					Visible = (Visible - 0.6) / 0.4
					
					render.SetMaterial( self.mat2 )
					render.DrawSprite( LightPos, 12, 12,  Color( 255, 120, 0,  125 * Visible) )
					
					render.SetMaterial( self.mat )
					render.DrawSprite( LightPos, 32, 32,  Color( 255, 0, 0,  90 * Visible) )
				end
			else
				local LightPos = self:LocalToWorld( self.LightsRear[i].pos )
				local Visible = util.PixelVisible( LightPos, 4, self.PixVisRear[i] )
				local s_col = self.LightsRear[i].color
				local s_mat = self.LightsRear[i].material
				local s_size = self.LightsRear[i].size
				
				if (self.LightsRear[i].OnBodyGroups) then
					Visible = !self:BodyGroupIsValid( self.LightsRear[i].OnBodyGroups ) and 0 or Visible
				end
				
				if Visible and Visible >= 0.6 then
					Visible = (Visible - 0.6) / 0.4
					render.SetMaterial( s_mat )
					render.DrawSprite( LightPos, s_size, s_size,  Color( s_col["r"], s_col["g"], s_col["b"],  s_col["a"] * Visible) )
				end
			end
		end
	end


	if (self.LightsFMarker) then
		for i = 1, table.Count( self.LightsFMarker ) do
			if (isvector(self.LightsFMarker[i])) then
				local LightPos = self:LocalToWorld( self.LightsFMarker[i] )
				local Visible = util.PixelVisible( LightPos, 4, self.PixVisFMarker[i] )
				
				if Visible and Visible >= 0.6 then
					Visible = (Visible - 0.6) / 0.4
					
					render.SetMaterial( self.mat )
					render.DrawSprite( LightPos, 12, 12,  Color( 200, 100, 0,  150 * Visible) )
				end
			end
		end
	end
	if (self.LightsRMarker) then
		for i = 1, table.Count( self.LightsRMarker ) do
			if (isvector(self.LightsRMarker[i])) then
				local LightPos = self:LocalToWorld( self.LightsRMarker[i] )
				local Visible = util.PixelVisible( LightPos, 4, self.PixVisRMarker[i] )
				
				if Visible and Visible >= 0.6 then
					Visible = (Visible - 0.6) / 0.4
					
					render.SetMaterial( self.mat )
					render.DrawSprite( LightPos, 12, 12,  Color( 205, 0, 0,  150 * Visible) )
				end
			end
		end
	end
end

function ENT:SetUpLights(vname)	
	local vehiclelist = list.Get( "simfphys_lights" )[vname]
	if (!vehiclelist) then return end
	
	self.Lights = vehiclelist.Headlight_sprites or false
	self.Lights_h = vehiclelist.Headlamp_sprites or false
	self.Lights_f = vehiclelist.FogLight_sprites or false
	self.LightsRear = vehiclelist.Rearlight_sprites or false
	self.LightsBrake = vehiclelist.Brakelight_sprites or false
	self.LightsReverse = vehiclelist.Reverselight_sprites or false
	self.LightsFMarker = vehiclelist.FrontMarker_sprites or false
	self.LightsRMarker = vehiclelist.RearMarker_sprites or false
	self.LightsEMS  = vehiclelist.ems_sprites or false 
	
	self.PixVis = {}
	self.PixVisEMS = {}
	self.PixVis_h = {}
	self.PixVis_f = {}
	self.PixVisRear = {}
	self.PixVisBrake = {}
	self.PixVisReverse = {}
	self.PixVisFMarker = {}
	self.PixVisRMarker = {}
	
	self.hl_col = vehiclelist.ModernLights and {215,240,255} or {220,205,160}
	
	if (self.Lights) then
		for i = 1, table.Count( self.Lights ) do
			self.PixVis[i] = util.GetPixelVisibleHandle()
			
			if (!isvector(self.Lights[i])) then
				self.Lights[i].color = self.Lights[i].color or Color( self.hl_col[1], self.hl_col[2], self.hl_col[3],  255)
				self.Lights[i].material = self.Lights[i].material and Material( self.Lights[i].material ) or self.mat2
				self.Lights[i].size = self.Lights[i].size or 16
			end
		end
	end
	if (self.LightsEMS) then
		for i = 1, table.Count( self.LightsEMS ) do
			self.PixVisEMS[i] = util.GetPixelVisibleHandle()
			
			self.LightsEMS[i].material = self.LightsEMS[i].material and Material( self.LightsEMS[i].material ) or self.mat2
		end
	end
	if (self.Lights_h) then
		for i = 1, table.Count( self.Lights_h ) do
			self.PixVis_h[i] = util.GetPixelVisibleHandle()
			
			if (!isvector(self.Lights_h[i])) then
				self.Lights_h[i].color = self.Lights_h[i].color and self.Lights_h[i].color or Color( self.hl_col[1], self.hl_col[2], self.hl_col[3],  255)
				self.Lights_h[i].material = self.Lights_h[i].material and Material( self.Lights_h[i].material ) or self.mat2
				self.Lights_h[i].size = self.Lights_h[i].size and self.Lights_h[i].size or 16
			end
		end
	end
	if (self.Lights_f) then
		for i = 1, table.Count( self.Lights_f ) do
			self.PixVis_f[i] = util.GetPixelVisibleHandle()
		
			if (!isvector(self.Lights_f[i])) then
				self.Lights_f[i].color = self.Lights_f[i].color and self.Lights_f[i].color or Color( self.hl_col[1], self.hl_col[2], self.hl_col[3],  255)
				self.Lights_f[i].material = self.Lights_f[i].material and Material( self.Lights_f[i].material ) or self.mat2
				self.Lights_f[i].size = self.Lights_f[i].size and self.Lights_f[i].size or 32
			end
		end
	end
	if (self.LightsRear) then
		for i = 1, table.Count( self.LightsRear ) do
			self.PixVisRear[i] = util.GetPixelVisibleHandle()
			
			if (!isvector(self.LightsRear[i])) then
				self.LightsRear[i].material = self.LightsRear[i].material and Material( self.LightsRear[i].material ) or self.mat2
				self.LightsRear[i].color = self.LightsRear[i].color and self.LightsRear[i].color or Color( 255, 0, 0,  125)
				self.LightsRear[i].size =  self.LightsRear[i].size and self.LightsRear[i].size or 16
			end
		end
	end
	if (self.LightsBrake) then
		for i = 1, table.Count( self.LightsBrake ) do
			self.PixVisBrake[i] = util.GetPixelVisibleHandle()
			
			if (!isvector(self.LightsBrake[i])) then
				self.LightsBrake[i].color = self.LightsBrake[i].color and self.LightsBrake[i].color or Color( 255, 0, 0,  125)
				self.LightsBrake[i].material = self.LightsBrake[i].material and Material( self.LightsBrake[i].material ) or self.mat2
				self.LightsBrake[i].size = self.LightsBrake[i].size and self.LightsBrake[i].size or 16
			end
		end
	end
	if (self.LightsReverse) then
		for i = 1, table.Count( self.LightsReverse ) do
			self.PixVisReverse[i] = util.GetPixelVisibleHandle()
			
			if (!isvector(self.LightsReverse[i])) then
				self.LightsReverse[i].color = self.LightsReverse[i].color and self.LightsReverse[i].color or Color( 255, 255, 255,  255)
				self.LightsReverse[i].material = self.LightsReverse[i].material and Material( self.LightsReverse[i].material ) or self.mat2
				self.LightsReverse[i].size = self.LightsReverse[i].size and self.LightsReverse[i].size or 16
			end
		end
	end
	if (self.LightsFMarker) then
		for i = 1, table.Count( self.LightsFMarker ) do
			self.PixVisFMarker[i] = util.GetPixelVisibleHandle()
		end
	end
	if (self.LightsRMarker) then
		for i = 1, table.Count( self.LightsRMarker ) do
			self.PixVisRMarker[i] = util.GetPixelVisibleHandle()
		end
	end
	
	self.EnableLights = 1
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
			self:PrecacheSounds()
			
			return true
		else
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
			self.EngineSounds[ "IdleSound" ] = vehiclelist.Members.Sound_Idle or "simulated_vehicles/misc/e49_idle.wav"
			self.Idle_PitchMul = (vehiclelist and vehiclelist.Members.Sound_IdlePitch) or 1
			
			self.EngineSounds[ "LowSound" ] = vehiclelist.Members.Sound_Mid or "simulated_vehicles/misc/gto_onlow.wav"
			self.Mid_PitchMul = (vehiclelist and vehiclelist.Members.Sound_MidPitch) or 1
			self.Mid_VolumeMul =  (vehiclelist and vehiclelist.Members.Sound_MidVolume) or 0.75
			self.Mid_FadeOutRPMpercent =  (vehiclelist and vehiclelist.Members.Sound_MidFadeOutRPMpercent) or 68
			self.Mid_FadeOutRate =  (vehiclelist and vehiclelist.Members.Sound_MidFadeOutRate) or 0.4
			
			self.EngineSounds[ "HighSound" ] = vehiclelist.Members.Sound_High or "simulated_vehicles/misc/nv2_onlow_ex.wav"
			self.High_PitchMul = (vehiclelist and vehiclelist.Members.Sound_HighPitch) or 1 
			self.High_VolumeMul = (vehiclelist and vehiclelist.Members.Sound_HighVolume) or 1 
			self.High_FadeInRPMpercent = (vehiclelist and vehiclelist.Members.Sound_HighFadeInRPMpercent) or 26.6
			self.High_FadeInRate = (vehiclelist and vehiclelist.Members.Sound_HighFadeInRate) or 0.266
			
			self.EngineSounds[ "ThrottleSound" ] = vehiclelist.Members.Sound_Throttle or "simulated_vehicles/valve_noise.wav"
			self.Throttle_PitchMul = (vehiclelist and vehiclelist.Members.Sound_ThrottlePitch) or 0.65
			self.Throttle_VolumeMul = (vehiclelist and vehiclelist.Members.Sound_ThrottleVolume) or 1 
		end
		
		self.PitchMulLow = 1
		self.PitchMulHigh = 1
		self.PitchMulAll = 1
		
		self:PrecacheSounds()
		
		return false
	end
	
	if (index > 0) then  -- to be honest nobody should be using these anymore...  but i keep them in for backwards compatibility
		local Oldpresets = {
			{
				"simulated_vehicles/gta5_dukes/dukes_idle.wav",
				"simulated_vehicles/gta5_dukes/dukes_low.wav",
				"simulated_vehicles/gta5_dukes/dukes_mid.wav",
				"simulated_vehicles/gta5_dukes/dukes_revdown.wav",
				"simulated_vehicles/gta5_dukes/dukes_second.wav",
				"simulated_vehicles/gta5_dukes/dukes_second.wav",
				0.8,
				1,
				0.8
			},
			{
				"simulated_vehicles/master_chris_charger69/charger_idle.wav",
				"simulated_vehicles/master_chris_charger69/charger_low.wav",
				"simulated_vehicles/master_chris_charger69/charger_mid.wav",
				"simulated_vehicles/master_chris_charger69/charger_revdown.wav",
				"simulated_vehicles/master_chris_charger69/charger_second.wav",
				"simulated_vehicles/master_chris_charger69/charger_shiftdown.wav",
				0.75,
				0.9,
				0.95
			},
			{
				"simulated_vehicles/shelby/shelby_idle.wav",
				"simulated_vehicles/shelby/shelby_low.wav",
				"simulated_vehicles/shelby/shelby_mid.wav",
				"simulated_vehicles/shelby/shelby_revdown.wav",
				"simulated_vehicles/shelby/shelby_second.wav",
				"simulated_vehicles/shelby/shelby_shiftdown.wav",
				0.8,
				1,
				0.85
			},
			{
				"simulated_vehicles/jeep/jeep_idle.wav",
				"simulated_vehicles/jeep/jeep_low.wav",
				"simulated_vehicles/jeep/jeep_mid.wav",
				"simulated_vehicles/jeep/jeep_revdown.wav",
				"simulated_vehicles/jeep/jeep_second.wav",
				"simulated_vehicles/jeep/jeep_second.wav",
				0.9,
				1,
				1
			},
			{
				"simulated_vehicles/v8elite/v8elite_idle.wav",
				"simulated_vehicles/v8elite/v8elite_low.wav",
				"simulated_vehicles/v8elite/v8elite_mid.wav",
				"simulated_vehicles/v8elite/v8elite_revdown.wav",
				"simulated_vehicles/v8elite/v8elite_second.wav",
				"simulated_vehicles/v8elite/v8elite_second.wav",
				0.8,
				1,
				1
			},
			{
				"simulated_vehicles/4banger/4banger_idle.wav",
				"simulated_vehicles/4banger/4banger_low.wav",
				"simulated_vehicles/4banger/4banger_mid.wav",
				"simulated_vehicles/4banger/4banger_low.wav",
				"simulated_vehicles/4banger/4banger_second.wav",
				"simulated_vehicles/4banger/4banger_second.wav",
				0.8,
				0.9,
				1
			},
			{
				"simulated_vehicles/jalopy/jalopy_idle.wav",
				"simulated_vehicles/jalopy/jalopy_low.wav",
				"simulated_vehicles/jalopy/jalopy_mid.wav",
				"simulated_vehicles/jalopy/jalopy_revdown.wav",
				"simulated_vehicles/jalopy/jalopy_second.wav",
				"simulated_vehicles/jalopy/jalopy_shiftdown.wav",
				0.95,
				1.1,
				0.9
			},
			{
				"simulated_vehicles/alfaromeo/alfaromeo_idle.wav",
				"simulated_vehicles/alfaromeo/alfaromeo_low.wav",
				"simulated_vehicles/alfaromeo/alfaromeo_mid.wav",
				"simulated_vehicles/alfaromeo/alfaromeo_low.wav",
				"simulated_vehicles/alfaromeo/alfaromeo_second.wav",
				"simulated_vehicles/alfaromeo/alfaromeo_second.wav",
				0.65,
				0.8,
				1
			},
			{
				"simulated_vehicles/generic1/generic1_idle.wav",
				"simulated_vehicles/generic1/generic1_low.wav",
				"simulated_vehicles/generic1/generic1_mid.wav",
				"simulated_vehicles/generic1/generic1_revdown.wav",
				"simulated_vehicles/generic1/generic1_second.wav",
				"simulated_vehicles/generic1/generic1_second.wav",
				0.8,
				1.1,
				1
			},
			{
				"simulated_vehicles/generic2/generic2_idle.wav",
				"simulated_vehicles/generic2/generic2_low.wav",
				"simulated_vehicles/generic2/generic2_mid.wav",
				"simulated_vehicles/generic2/generic2_revdown.wav",
				"simulated_vehicles/generic2/generic2_second.wav",
				"simulated_vehicles/generic2/generic2_second.wav",
				1,
				1.1,
				1
			},
			{
				"simulated_vehicles/generic3/generic3_idle.wav",
				"simulated_vehicles/generic3/generic3_low.wav",
				"simulated_vehicles/generic3/generic3_mid.wav",
				"simulated_vehicles/generic3/generic3_revdown.wav",
				"simulated_vehicles/generic3/generic3_second.wav",
				"simulated_vehicles/generic3/generic3_second.wav",
				0.9,
				0.9,
				1
			},
			{
				"simulated_vehicles/generic4/generic4_idle.wav",
				"simulated_vehicles/generic4/generic4_low.wav",
				"simulated_vehicles/generic4/generic4_mid.wav",
				"simulated_vehicles/generic4/generic4_revdown.wav",
				"simulated_vehicles/generic4/generic4_gear.wav",
				"simulated_vehicles/generic4/generic4_shiftdown.wav",
				1,
				1.1,
				1
			},
			{
				"simulated_vehicles/generic5/generic5_idle.wav",
				"simulated_vehicles/generic5/generic5_low.wav",
				"simulated_vehicles/generic5/generic5_mid.wav",
				"simulated_vehicles/generic5/generic5_revdown.wav",
				"simulated_vehicles/generic5/generic5_gear.wav",
				"simulated_vehicles/generic5/generic5_gear.wav",
				0.7,
				0.7,
				1
			},
			{
				"simulated_vehicles/gta5_gauntlet/gauntlet_idle.wav",
				"simulated_vehicles/gta5_gauntlet/gauntlet_low.wav",
				"simulated_vehicles/gta5_gauntlet/gauntlet_mid.wav",
				"simulated_vehicles/gta5_gauntlet/gauntlet_revdown.wav",
				"simulated_vehicles/gta5_gauntlet/gauntlet_gear.wav",
				"simulated_vehicles/gta5_gauntlet/gauntlet_gear.wav",
				0.95,
				1.1,
				1
			}
		}
		
		local clampindex = math.Clamp(index,1,14)
		self.EngineSounds[ "Idle" ] = Oldpresets[clampindex][1]
		self.EngineSounds[ "LowRPM" ] = Oldpresets[clampindex][2]
		self.EngineSounds[ "HighRPM" ] = Oldpresets[clampindex][3]
		self.EngineSounds[ "RevDown" ] = Oldpresets[clampindex][4]
		self.EngineSounds[ "ShiftUpToHigh" ] = Oldpresets[clampindex][5]
		self.EngineSounds[ "ShiftDownToHigh" ] = Oldpresets[clampindex][6]
		
		self.PitchMulLow = Oldpresets[clampindex][7]
		self.PitchMulHigh = Oldpresets[clampindex][8]
		self.PitchMulAll = Oldpresets[clampindex][9]
		
		self:PrecacheSounds()
		
		return true
	end
	
	return false
end

function ENT:PrecacheSounds()
	for index, sound in pairs( self.EngineSounds ) do
		if (sound != "") then
			util.PrecacheSound( sound )
		end
	end
end

function ENT:OnRemove()
	self.HighRPM:Stop()
	self.LowRPM:Stop()
	self.Idle:Stop()
	self.Valves:Stop()
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
