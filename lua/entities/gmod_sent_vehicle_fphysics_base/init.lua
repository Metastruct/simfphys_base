AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include('shared.lua')

local frictiondata = {
	["ice"] = 0.35,
	["friction_00"] = 0.1,
	["gmod_ice"] = 0.1,
	["snow"] = 0.7,
}

function ENT:PostEntityPaste( ply , ent , createdEntities )
	self:SetValues()
	
	self:SetActive( false )
	self:SetDriver( NULL )
	self:SetLightsEnabled( false )
	self:SetLampsEnabled( false )
	self:SetFogLightsEnabled( false )
	
	self:SetDriverSeat( NULL )
	self:SetFlyWheelRPM( 0 )
	self:SetThrottle( 0 )
end

function ENT:UpdateTransmitState() 
	return TRANSMIT_ALWAYS
end

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetNotSolid( true )
	self:SetUseType( SIMPLE_USE )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:GetPhysicsObject():EnableMotion(false) 
	self:SetValues()
	
	timer.Simple( 0.1, function()
		if (!IsValid(self)) then return end
		self:InitializeVehicle()
	end)
end

function ENT:Think()
	local Time = CurTime()
	if IsValid(self.DriverSeat) then
		local Driver = self.DriverSeat:GetDriver()
		if self:GetDriver() != Driver then
			self:SetDriver( Driver )
			self:SetActive( IsValid( Driver ) )
		end
	end
	
	if (self.EnableSuspension == 1) then
		self:SetColors()
		self:SimulateVehicle( Time )
		self:ControlLighting( Time )
		self:ControlExFx()
		
		self.NextWaterCheck = self.NextWaterCheck or 0
		if (self.NextWaterCheck < Time) then
			self.NextWaterCheck = Time + 0.2
			self:WaterPhysics()
		end
		
		if self:GetActive() then
			self:SetPhysics( ((math.abs(self.ForwardSpeed) < 50) and (self.Brake > 0 or self.HandBrake > 0)) )
		else
			self:SetPhysics( true )
		end
	end
	
	self:NextThink(Time + 0.025)
	return true
end

function ENT:OnActiveChanged( name, old, new)
	if (new == old) then return end
	
	if self.EnableSuspension != 1 then return end
	
	local TurboCharged = self:GetTurboCharged()
	local SuperCharged = self:GetSuperCharged()
	
	if new == true then
		self.HandBrakePower = self:GetMaxTraction() + 20 - self:GetTractionBias() * self:GetMaxTraction()
		
		if (self:GetEMSEnabled()) then
			if (self.ems) then
				self.ems:Play()
			end
		end
		
		if (TurboCharged) then
			self.Turbo = CreateSound(self, self.snd_spool or "simulated_vehicles/turbo_spin.wav")
			self.Turbo:PlayEx(0,0)
		end
		
		if (SuperCharged) then
			self.Blower = CreateSound(self, self.snd_bloweroff or "simulated_vehicles/blower_spin.wav")
			self.BlowerWhine = CreateSound(self, self.snd_bloweron or "simulated_vehicles/blower_gearwhine.wav")
			
			self.Blower:PlayEx(0,0)
			self.BlowerWhine:PlayEx(0,0)
		end
		
		if IsValid( self:GetDriver() ) then
			self:SetupControls( self:GetDriver() )
		end
		
		self.CurrentGear = 2
		
		if !self.IsInWater then
			self.EngineRPM = self:GetEngineData().IdleRPM
			self.EngineIsOn = 1
		else
			if self:GetDoNotStall() then
				self.EngineRPM = self:GetEngineData().IdleRPM
				self.EngineIsOn = 1
			end
		end
	else
		self.EngineRPM = 0
		self.EngineIsOn = 0

		self.IsLocked = false
		
		if (self.ems) then
			self.ems:Stop()
		end

		if (self.horn) then
			self.horn:Stop()
		end
		
		if (TurboCharged) then
			self.Turbo:Stop()
		end

		if (SuperCharged) then
			self.Blower:Stop()
			self.BlowerWhine:Stop()
		end
		
		if (self.PressedKeys) then
			for k,v in pairs(self.PressedKeys) do
				self.PressedKeys[k] = false
			end
		end
		
		if (self.keys) then
			for i = 1, table.Count( self.keys ) do
				numpad.Remove( self.keys[i] )
			end
		end
		
		self:SetIsBraking( false )
		self:SetGear( 2 )
		self:SetFlyWheelRPM( 0 )
		
		self:SetIsCruiseModeOn( false )
	end
	
	if istable(self.Wheels) then
		for i = 1, table.Count( self.Wheels ) do
			local Wheel = self.Wheels[ i ]
			if (IsValid(Wheel)) then
				Wheel:SetOnGround( 0 )
			end
		end
	end
end

function ENT:OnThrottleChanged( name, old, new)
	if (new == old) then return end
	
	local Health = self:GetCurHealth()
	local MaxHealth = self:GetMaxHealth()
	local Active = self.EngineIsOn == 1
	
	if new == 1 then
		if Health < MaxHealth * 0.6 then
			if Active then
				if math.Round(math.random(0,4),0) == 1 then
					self:DamagedStall()
				end
			end
		end
	end
	
	if new == 0 then
		if self:GetTurboCharged() then
			if (self.SmoothTurbo > 350) then
				local Volume = math.Clamp( ((self.SmoothTurbo - 300) / 150) ,0, 1) * 0.5
				self.SmoothTurbo = 0
				self.BlowOff:Stop()
				self.BlowOff = CreateSound(self, self.snd_blowoff or "simulated_vehicles/turbo_blowoff.ogg")
				self.BlowOff:PlayEx(Volume,100)
			end
		end
	end
end

function ENT:WaterPhysics()
	if (self:WaterLevel() <= 1) then self.IsInWater = false return end
	if self:GetDoNotStall() == true then return end
	
	if (!self.IsInWater) then
		if (self.EngineIsOn == 1) then
			self:EmitSound( "vehicles/jetski/jetski_off.wav" )
		end
		self.IsInWater = true
		self.EngineIsOn = 0
		self.EngineRPM = 0
		self:SetFlyWheelRPM( 0 )
		
		self:SetOnFire( false )
		self:SetOnSmoke( false )
	end
	
	local phys = self:GetPhysicsObject()
	phys:ApplyForceCenter( -self:GetVelocity() * 0.5 * phys:GetMass() )
end

function ENT:SetColors()
	if (self.ColorableProps) then
		local Color = self:GetColor()
		local dot = Color.r * Color.g * Color.b * Color.a
		if (dot != self.OldColor) then
			for i, prop in pairs( self.ColorableProps ) do
				if (IsValid(prop)) then
					prop:SetColor( Color )
					prop:SetRenderMode( self:GetRenderMode() )
				end
			end
			self.OldColor = dot
		end
	end
end

function ENT:ControlLighting( curtime )
	if ((self.NextLightCheck or 0) < curtime) then
		if (self.LightsActivated != self.DoCheck) then
			self.DoCheck = self.LightsActivated
			if (self.LightsActivated) then
				self:SetLightsEnabled(true)
			end
		end
	end
end

function ENT:GetEngineData()
	local LimitRPM = math.max(self:GetLimitRPM(),4)
	local Powerbandend = math.Clamp(self:GetPowerBandEnd(),3,LimitRPM - 1)
	local Powerbandstart = math.Clamp(self:GetPowerBandStart(),2,Powerbandend - 1)
	local IdleRPM = math.Clamp(self:GetIdleRPM(),1,Powerbandstart - 1)
	local Data = {
		IdleRPM = IdleRPM,
		Powerbandstart = Powerbandstart,
		Powerbandend = Powerbandend,
		LimitRPM = LimitRPM,
	}
	return Data
end

function ENT:SimulateVehicle( curtime )
	local Active = self:GetActive()
	local TurboCharged = self:GetTurboCharged()
	local SuperCharged = self:GetSuperCharged()
	
	local EngineData = self:GetEngineData()
	
	local LimitRPM = EngineData.LimitRPM
	local Powerbandend = EngineData.Powerbandend
	local Powerbandstart = EngineData.Powerbandstart
	local IdleRPM = EngineData.IdleRPM
	
	self.Forward =  self:LocalToWorldAngles( self.VehicleData.LocalAngForward ):Forward() 
	self.Right = self:LocalToWorldAngles( self.VehicleData.LocalAngRight ):Forward() 
	self.Up = self:GetUp()
	
	self.Vel = self:GetVelocity()
	self.VelNorm = self.Vel:GetNormalized()
	
	self.MoveDir = math.acos( math.Clamp( self.Forward:Dot(self.VelNorm) ,-1,1) ) * (180 / math.pi)
	self.ForwardSpeed = math.cos(self.MoveDir * (math.pi / 180)) * self.Vel:Length()
	
	if self.poseon then
		if !self.LightsDisabled then
			self.cpose = self.cpose or self.LightsPP.min
			local anglestep = math.abs(math.max(self.LightsPP.max or self.LightsPP.min)) / 3
			self.cpose = self.cpose + math.Clamp(self.poseon - self.cpose,-anglestep,anglestep)
			self:SetPoseParameter(self.LightsPP.name, self.cpose)
		end
	end
	
	self:SetPoseParameter("vehicle_guage", (math.abs(self.ForwardSpeed) * 0.0568182 * 0.75) / (self.SpeedoMax or 120))
	
	if (self.RPMGaugePP) then
		local flywheelrpm = self:GetFlyWheelRPM()
		local rpm
		if (self:GetRevlimiter()) then
			local throttle = self:GetThrottle()
			local maxrpm = self:GetLimitRPM()
			local revlimiter = (maxrpm > 2500) and (throttle > 0)
			rpm = math.Round(((flywheelrpm >= maxrpm - 200) and revlimiter) and math.Round(flywheelrpm - 200 + math.sin(curtime * 50) * 600,0) or flywheelrpm,0)
		else
			rpm = flywheelrpm
		end
	
		self:SetPoseParameter(self.RPMGaugePP,  rpm / self.RPMGaugeMax)
	end
	
	
	if Active then
		local ply = self:GetDriver()
		local IsValidDriver = IsValid( ply )
		
		local GearUp = self.PressedKeys["M1"] and 1 or 0
		local GearDown = self.PressedKeys["M2"] and 1 or 0
		
		local W = self.PressedKeys["W"] and 1 or 0
		local A = self.PressedKeys["A"] and 1 or 0
		local S = self.PressedKeys["S"] and 1 or 0
		local D = self.PressedKeys["D"] and 1 or 0
		
		if IsValidDriver then self:PlayerSteerVehicle( ply, A, D ) end
		
		local aW = self.PressedKeys["aW"] and 1 or 0
		local aA = self.PressedKeys["aA"] and 1 or 0
		local aS = self.PressedKeys["aS"] and 1 or 0
		local aD = self.PressedKeys["aD"] and 1 or 0
		
		local cruise = self:GetIsCruiseModeOn()
		
		local k_sanic =  IsValidDriver and ply:GetInfoNum( "cl_simfphys_sanic", 0 ) or 1
		local sanicmode = isnumber( k_sanic ) and k_sanic or 0
		local k_Shift = self.PressedKeys["Shift"]
		local Shift = (sanicmode == 1) and (k_Shift and 0 or 1) or (k_Shift and 1 or 0)
		
		local sportsmode = IsValidDriver and ply:GetInfoNum( "cl_simfphys_sport", 0 ) or 1
		local k_auto = IsValidDriver and ply:GetInfoNum( "cl_simfphys_auto", 0 ) or 1
		local transmode = (k_auto == 1)
		
		local Alt = self.PressedKeys["Alt"] and 1 or 0
		local Space = self.PressedKeys["Space"] and 1 or 0
		
		local boost = (TurboCharged and self:SimulateTurbo(LimitRPM) or 0) * 0.3 + (SuperCharged and self:SimulateBlower(LimitRPM) or 0)
		
		if cruise then
			if (k_Shift) then
				self.cc_speed = math.Round(self:GetVelocity():Length(),0) + 70
			end
			if (Alt == 1) then
				self.cc_speed = math.Round(self:GetVelocity():Length(),0) -25
			end
		end
		
		self:SimulateTransmission(W,S,Shift,Alt,Space,GearUp,GearDown,transmode,IdleRPM,Powerbandstart,Powerbandend,sportsmode,cruise,curtime)
		self:SimulateEngine(W,S,aA,aD,boost,IdleRPM,LimitRPM,Powerbandstart,Powerbandend,curtime,aW,aS)
		self:SimulateWheels(A,D,math.max(Space,Alt),LimitRPM)
		
		if (self.WheelOnGroundDelay < curtime) then
			self:WheelOnGround()
			self.WheelOnGroundDelay = curtime + 0.15
		end
	end
	
	if (self.CustomWheels) then
		self:PhysicalSteer()
	else
		self:SetWheelHeight()
	end
end

function ENT:SetControl( Data )
	for k,v in pairs(Data) do
		self.PressedKeys[k] = v
	end
end

function ENT:ControlExFx()
	if (!self.ExhaustPositions) then return end
	
	local IsOn = self:GetActive()
	
	self.EnableExFx = (math.abs(self.ForwardSpeed) <= 420) and (self.EngineIsOn == 1) and IsOn
	self.CheckExFx = self.CheckExFx or false
	
	if (self.CheckExFx != self.EnableExFx) then
		self.CheckExFx = self.EnableExFx
		if (self.EnableExFx) then
			for i = 1, table.Count( self.ExhaustPositions ) do
				local Fx = self.exfx[i]
				if (IsValid(Fx)) then
					if (self.ExhaustPositions[i].OnBodyGroups) then
						if (self:BodyGroupIsValid( self.ExhaustPositions[i].OnBodyGroups )) then
							Fx:Fire( "Start" )
						end
					else
						Fx:Fire( "Start" )
					end
				end
			end
		else
			for i = 1, table.Count( self.ExhaustPositions ) do
				local Fx = self.exfx[i]
				if (IsValid(Fx)) then
					Fx:Fire( "Stop" )
				end
			end
		end
	end
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

function ENT:SetupControls( ply )

	if (self.keys) then
		for i = 1, table.Count( self.keys ) do
			numpad.Remove( self.keys[i] )
		end
	end

	if IsValid(ply) then
		local W = ply:GetInfoNum( "cl_simfphys_keyforward", 0 )
		local A = ply:GetInfoNum( "cl_simfphys_keyleft", 0 )
		local S = ply:GetInfoNum( "cl_simfphys_keyreverse", 0 )
		local D = ply:GetInfoNum( "cl_simfphys_keyright", 0 )
		
		local aW = ply:GetInfoNum( "cl_simfphys_key_air_forward", 0 )
		local aA = ply:GetInfoNum( "cl_simfphys_key_air_left", 0 )
		local aS = ply:GetInfoNum( "cl_simfphys_key_air_reverse", 0 )
		local aD = ply:GetInfoNum( "cl_simfphys_key_air_right", 0 )
		
		local GearUp = ply:GetInfoNum( "cl_simfphys_keygearup", 0 )
		local GearDown = ply:GetInfoNum( "cl_simfphys_keygeardown", 0 )
		
		local R = ply:GetInfoNum( "cl_simfphys_cruisecontrol", 0 )
		
		local F = ply:GetInfoNum( "cl_simfphys_lights", 0 )
		
		local V = ply:GetInfoNum( "cl_simfphys_foglights", 0 )
		
		local H = ply:GetInfoNum( "cl_simfphys_keyhorn", 0 )
		
		local I = ply:GetInfoNum( "cl_simfphys_keyengine", 0 )
		
		local Y = ply:GetInfoNum( "cl_simfphys_ms_keyfreelook", 0 )
		
		local Shift = ply:GetInfoNum( "cl_simfphys_keywot", 0 )
		
		local Alt = ply:GetInfoNum( "cl_simfphys_keyclutch", 0 )
		local Space = ply:GetInfoNum( "cl_simfphys_keyhandbrake", 0 )
		
		local lock = ply:GetInfoNum( "cl_simfphys_key_lock", 0 )
		
		local w_dn = numpad.OnDown( ply, W, "k_forward",self, true )
		local w_up = numpad.OnUp( ply, W, "k_forward",self, false )
		local s_dn = numpad.OnDown( ply, S, "k_reverse",self, true )
		local s_up = numpad.OnUp( ply, S, "k_reverse",self, false )
		local a_dn = numpad.OnDown( ply, A, "k_left",self, true )
		local a_up = numpad.OnUp( ply, A, "k_left",self, false )
		local d_dn = numpad.OnDown( ply, D, "k_right",self, true )
		local d_up = numpad.OnUp( ply, D, "k_right",self, false )
		
		local aw_dn = numpad.OnDown( ply, aW, "k_a_forward",self, true )
		local aw_up = numpad.OnUp( ply, aW, "k_a_forward",self, false )
		local as_dn = numpad.OnDown( ply, aS, "k_a_reverse",self, true )
		local as_up = numpad.OnUp( ply, aS, "k_a_reverse",self, false )
		local aa_dn = numpad.OnDown( ply, aA, "k_a_left",self, true )
		local aa_up = numpad.OnUp( ply, aA, "k_a_left",self, false )
		local ad_dn = numpad.OnDown( ply, aD, "k_a_right",self, true )
		local ad_up = numpad.OnUp( ply, aD, "k_a_right",self, false )
		
		local gup_dn = numpad.OnDown( ply, GearUp, "k_gup",self, true )
		local gup_up = numpad.OnUp( ply, GearUp, "k_gup",self, false )
		
		local gdn_dn = numpad.OnDown( ply, GearDown, "k_gdn",self, true )
		local gdn_up = numpad.OnUp( ply, GearDown, "k_gdn",self, false )
		
		local shift_dn = numpad.OnDown( ply, Shift, "k_wot",self, true )
		local shift_up = numpad.OnUp( ply, Shift, "k_wot",self, false )
		
		local alt_dn = numpad.OnDown( ply, Alt, "k_clutch",self, true )
		local alt_up = numpad.OnUp( ply, Alt, "k_clutch",self, false )
		
		local space_dn = numpad.OnDown( ply, Space, "k_hbrk",self, true )
		local space_up = numpad.OnUp( ply, Space, "k_hbrk",self, false )
		
		local k_cruise = numpad.OnDown( ply, R, "k_ccon",self, true )
		
		local k_lights_dn = numpad.OnDown( ply, F, "k_lgts",self, true )
		local k_lights_up = numpad.OnUp( ply, F, "k_lgts",self, false )
		
		local k_flights_dn = numpad.OnDown( ply, V, "k_flgts",self, true )
		local k_flights_up = numpad.OnUp( ply, V, "k_flgts",self, false )
		
		local k_horn_dn = numpad.OnDown( ply, H, "k_hrn",self, true )
		local k_horn_up = numpad.OnUp( ply, H, "k_hrn",self, false )
		
		local k_freelook_dn = numpad.OnDown( ply, Y, "k_frk",self, true )
		local k_freelook_up = numpad.OnUp( ply, Y, "k_frk",self, false )
		
		local k_engine_dn = numpad.OnDown( ply, I, "k_eng",self, true )
		local k_engine_up = numpad.OnUp( ply, I, "k_eng",self, false )
		
		local k_lock_dn = numpad.OnDown( ply, lock, "k_lock",self, true )
		local k_lock_up = numpad.OnUp( ply, lock, "k_lock",self, false )
		
		self.keys = {
			w_dn,w_up,
			s_dn,s_up,
			a_dn,a_up,
			d_dn,d_up,
			aw_dn,aw_up,
			as_dn,as_up,
			aa_dn,aa_up,
			ad_dn,ad_up,
			gup_dn,gup_up,
			gdn_dn,gdn_up,
			shift_dn,shift_up,
			alt_dn,alt_up,
			space_dn,space_up,
			k_cruise,
			k_lights_dn,k_lights_up,
			k_horn_dn,k_horn_up,
			k_flights_dn,k_flights_up,
			k_freelook_dn,k_freelook_up,
			k_engine_dn,k_engine_up,
			k_lock_dn,k_lock_up,
		}
	end
end

function ENT:PlayAnimation( animation )
	local anims = string.Implode( ",", self:GetSequenceList() )
	
	if !string.match( string.lower(anims), string.lower(animation), 1 ) then print(animation) return end
	
	local sequence = self:LookupSequence( animation )
	
	self:ResetSequence( sequence )
	self:SetPlaybackRate( 1 ) 
	self:SetSequence( sequence )
end

function ENT:SetupView()
	local AttachmentID = self:LookupAttachment( "vehicle_driver_eyes" )
	local AttachmentID2 = self:LookupAttachment( "vehicle_passenger0_eyes" )
	
	local a_data1 = self:GetAttachment( AttachmentID )
	local a_data2 = self:GetAttachment( AttachmentID2 )
	
	local ID
	local ViewPos
	
	if a_data1 then
		ID = AttachmentID
		ViewPos = a_data1
		
	elseif a_data2 then
		ID = AttachmentID2
		ViewPos = a_data2
		
	else
		ID = false
		ViewPos = {Ang = self:LocalToWorldAngles( Angle(0, 90,0) ),Pos = self:GetPos()}
	end
	
	local ViewAng = ViewPos.Ang - Angle(0,0,self.SeatPitch)
	ViewAng:RotateAroundAxis(self:GetUp(), -90 - (self.SeatYaw or 0))
	
	local data = {
		ID = ID,
		ViewPos = ViewPos.Pos,
		ViewAng = ViewAng,
	}
	
	return data
end

function ENT:SetupEnteringAnims()
	local attachments = self:GetAttachments()
	
	self.Exitpoints = {}
	self.Enterpoints = {}
	
	for _,i in pairs(attachments) do
		local curstring = string.lower( i.name )
		
		if string.match( curstring, "exit", 1 ) then
			table.insert(self.Exitpoints, curstring)
		end
		
		if string.match( curstring, "enter", 1 ) then
			table.insert(self.Enterpoints, curstring)
		end
	end
	
	if table.Count( self.Enterpoints ) < 1 then
		self.Enterpoints = nil
	end
	
	if table.Count( self.Exitpoints ) < 1 then
		self.Exitpoints = nil
	end
end

function ENT:InitializeVehicle()
	if !IsValid(self) then return end
	
	if self.LightsTable then
		local vehiclelist = list.Get( "simfphys_lights" )[self.LightsTable] or false
		if vehiclelist then
			if vehiclelist.PoseParameters then
				self.LightsPP = vehiclelist.PoseParameters
			end
			
			if vehiclelist.BodyGroups then
				self:SetBodygroup(vehiclelist.BodyGroups.Off[1], vehiclelist.BodyGroups.Off[2] )
			end
		end
	end
	
	self:GetPhysicsObject():SetDragCoefficient( self.AirFriction or -250 )
	self:GetPhysicsObject():SetMass( self.Mass * 0.75 )
	
	local View = self:SetupView()
	
	self.DriverSeat = ents.Create( "prop_vehicle_prisoner_pod" )
	self.DriverSeat:SetMoveType( MOVETYPE_NONE )
	
	self.DriverSeat:SetModel( "models/nova/airboat_seat.mdl" )
	self.DriverSeat:SetKeyValue( "vehiclescript","scripts/vehicles/prisoner_pod.txt" )
	self.DriverSeat:SetKeyValue( "limitview", self.LimitView and 1 or 0 )
	self.DriverSeat:SetPos( View.ViewPos )
	self.DriverSeat:SetAngles( View.ViewAng )
	self.DriverSeat:SetOwner( self )
	self.DriverSeat:Spawn()
	self.DriverSeat:Activate()
	self.DriverSeat:SetPos( View.ViewPos + self.DriverSeat:GetUp() * (-34 + self.SeatOffset.z) + self.DriverSeat:GetRight() * (self.SeatOffset.y) + self.DriverSeat:GetForward() * (-6 + self.SeatOffset.x) )
	
	if View.ID != false then
		self:SetupEnteringAnims()
		self.DriverSeat:SetParent( self , View.ID )
	else
		self.DriverSeat:SetParent( self )
	end
	
	self.DriverSeat:GetPhysicsObject():EnableDrag( false ) 
	self.DriverSeat:GetPhysicsObject():EnableMotion( false )
	self.DriverSeat:GetPhysicsObject():SetMass( 1 )
	self.DriverSeat.fphysSeat = true
	self.DriverSeat.base = self
	self.DriverSeat.DoNotDuplicate = true
	self:DeleteOnRemove( self.DriverSeat )
	self:SetDriverSeat( self.DriverSeat )
	self.DriverSeat:SetNotSolid( true )
	self.DriverSeat:SetNoDraw( true )
	self.DriverSeat:DrawShadow( false )
	self:s_MakeOwner( self.DriverSeat )
	
	if self.PassengerSeats then
		for i = 1, table.Count( self.PassengerSeats ) do
			self.pSeat[i] = ents.Create( "prop_vehicle_prisoner_pod" )
			self.pSeat[i]:SetModel( "models/nova/airboat_seat.mdl" )
			self.pSeat[i]:SetKeyValue( "vehiclescript","scripts/vehicles/prisoner_pod.txt" )
			self.pSeat[i]:SetKeyValue( "limitview", 0)
			self.pSeat[i]:SetPos( self:LocalToWorld( self.PassengerSeats[i].pos ) )
			self.pSeat[i]:SetAngles( self:LocalToWorldAngles( self.PassengerSeats[i].ang ) )
			self.pSeat[i]:SetOwner( self )
			self.pSeat[i]:Spawn()
			self.pSeat[i]:Activate()
			self.pSeat[i]:SetNotSolid( true )
			self.pSeat[i]:SetNoDraw( true )
			self.pSeat[i].fphysSeat = true
			self.pSeat[i].base = self
			self.pSeat[i].DoNotDuplicate = true
			self:s_MakeOwner( self.pSeat[i] )
			
			self.pSeat[i]:DrawShadow( false )
			self.pSeat[i]:GetPhysicsObject():EnableMotion( false )
			self.pSeat[i]:GetPhysicsObject():EnableDrag(false) 
			self.pSeat[i]:GetPhysicsObject():SetMass(1)
			
			self:DeleteOnRemove( self.pSeat[i] )
			
			self.pSeat[i]:SetParent( self )
		end
	end
	
	if self.ExhaustPositions then
		for i = 1, table.Count( self.ExhaustPositions ) do
			self.exfx[i] = ents.Create( "info_particle_system" )
			self.exfx[i]:SetKeyValue( "effect_name" , "Exhaust")
			self.exfx[i]:SetKeyValue( "start_active" , 0)
			self.exfx[i]:SetOwner( self )
			self.exfx[i]:SetPos( self:LocalToWorld( self.ExhaustPositions[i].pos ) )
			self.exfx[i]:SetAngles( self:LocalToWorldAngles( self.ExhaustPositions[i].ang ) )
			self.exfx[i]:Spawn()
			self.exfx[i]:Activate()
			self.exfx[i]:SetParent( self )
			self.exfx[i].DoNotDuplicate = true
			self:s_MakeOwner( self.exfx[i] )
		end
	end
	
	if self.Attachments then
		for i = 1, table.Count( self.Attachments ) do
			local prop = ents.Create( ((self.Attachments[i].IsGlass == true) and "gmod_sent_vehicle_fphysics_attachment_translucent" or "gmod_sent_vehicle_fphysics_attachment") )
			prop:SetModel( self.Attachments[i].model )			
			prop:SetMaterial( self.Attachments[i].material )
			prop:SetRenderMode( RENDERMODE_TRANSALPHA )
			prop:SetPos( self:LocalToWorld( self.Attachments[i].pos ) )
			prop:SetAngles( self:LocalToWorldAngles( self.Attachments[i].ang ) )
			prop:SetOwner( self )
			prop:Spawn()
			prop:Activate()
			prop:DrawShadow( true )
			prop:SetNotSolid( true )
			prop:SetParent( self )
			prop.DoNotDuplicate = true
			self:s_MakeOwner( prop )
			
			if self.Attachments[i].useVehicleColor == true then
				self.ColorableProps[i] = prop
				prop:SetColor( self:GetColor() )
			else
				prop:SetColor( self.Attachments[i].color )
			end
			
			self:DeleteOnRemove( prop )
		end
	end
	
	self:GetVehicleData()
end

function ENT:SetWheelHeight()	
	local Ent_FL = self.Wheels[1]
	local Ent_FR = self.Wheels[2]
	local Ent_RL = self.Wheels[3]
	local Ent_RR = self.Wheels[4]
	
	if IsValid(Ent_FL) then
		local addPos = Ent_FL:GetDamaged() and Ent_FL.dRadius or 0
		local PoseFL = (self.posepositions.PoseL_Pos_FL.z - self:WorldToLocal( Ent_FL:GetPos()).z + addPos ) / self.VehicleData.suspensiontravel_fl
		self:SetPoseParameter("vehicle_wheel_fl_height",PoseFL) 
	end
	
	if IsValid(Ent_FR) then
		local addPos = Ent_FR:GetDamaged() and Ent_FR.dRadius or 0
		local PoseFR = (self.posepositions.PoseL_Pos_FR.z - self:WorldToLocal( Ent_FR:GetPos()).z + addPos ) / self.VehicleData.suspensiontravel_fr
		self:SetPoseParameter("vehicle_wheel_fr_height",PoseFR) 
	end
	
	if IsValid(Ent_RL) then
		local addPos = Ent_RL:GetDamaged() and Ent_RL.dRadius or 0
		local PoseRL = (self.posepositions.PoseL_Pos_RL.z - self:WorldToLocal( Ent_RL:GetPos()).z + addPos ) / self.VehicleData.suspensiontravel_rl
		self:SetPoseParameter("vehicle_wheel_rl_height",PoseRL) 
	end
	
	if IsValid(Ent_RR) then
		local addPos = Ent_RR:GetDamaged() and Ent_RR.dRadius or 0
		local PoseRR = (self.posepositions.PoseL_Pos_RR .z- self:WorldToLocal( Ent_RR:GetPos()).z + addPos ) / self.VehicleData.suspensiontravel_rr
		self:SetPoseParameter("vehicle_wheel_rr_height",PoseRR) 
	end
end

function ENT:PhysicalSteer()
	if IsValid(self.SteerMaster) then
		local physobj = self.SteerMaster:GetPhysicsObject()
		if !IsValid(physobj) then return end
		
		if physobj:IsMotionEnabled() then
			physobj:EnableMotion(false)
		end
		
		self.SteerMaster:SetAngles( self:LocalToWorldAngles( Angle(0,math.Clamp(-self.VehicleData[ "SteerAngle" ],-self.CustomSteerAngle,self.CustomSteerAngle),0) ) )
	end
	
	if IsValid(self.SteerMaster2) then
		local physobj = self.SteerMaster2:GetPhysicsObject()
		if !IsValid(physobj) then return end
		
		if physobj:IsMotionEnabled() then
			physobj:EnableMotion(false)
		end
		
		self.SteerMaster2:SetAngles( self:LocalToWorldAngles( Angle(0,math.Clamp(self.VehicleData[ "SteerAngle" ],-self.CustomSteerAngle,self.CustomSteerAngle),0) ) )
	end
end

function ENT:WheelOnGround()
	self.FrontWheelPowered = self:GetPowerDistribution() != 1
	self.RearWheelPowered = self:GetPowerDistribution() != -1
	
	for i = 1, table.Count( self.Wheels ) do
		local Wheel = self.Wheels[i]		
		if IsValid(Wheel) then
			local dmgMul = Wheel:GetDamaged() and 0.5 or 1
			local surfacemul = frictiondata[Wheel:GetSurfaceMaterial()]
			
			self.VehicleData[ "SurfaceMul_" .. i ] = (surfacemul and surfacemul or 1) * dmgMul
			
			local IsFrontWheel = i == 1 or i == 2
			local WheelRadius = IsFrontWheel and self.FrontWheelRadius or self.RearWheelRadius
			local startpos = Wheel:GetPos()
			local dir = -self.Up
			local len = WheelRadius + math.Clamp(-self.Vel.z / 50,2.5,6)
			local HullSize = Vector(WheelRadius,WheelRadius,0)
			local tr = util.TraceHull( {
				start = startpos,
				endpos = startpos + dir * len,
				maxs = HullSize,
				mins = -HullSize,
				filter = {Wheel,self}
			} )
			if (tr.Hit) then
				self.VehicleData[ "onGround_" .. i ] = 1
				Wheel:SetSpeed( Wheel.FX )
				Wheel:SetSkidSound( Wheel.skid )
				Wheel:SetSurfaceMaterial( util.GetSurfacePropName( tr.SurfaceProps ) )
				Wheel:SetOnGround(1)
			else
				self.VehicleData[ "onGround_" .. i ] = 0
				Wheel:SetOnGround(0)
			end
		end
	end
	
	if (self.FrontWheelPowered and self.RearWheelPowered) then
		self.DriveWheelsOnGround = self.VehicleData[ "onGround_1" ] and self.VehicleData[ "onGround_2" ] or self.VehicleData[ "onGround_3" ] and self.VehicleData[ "onGround_4" ]
	elseif (!self.FrontWheelPowered and self.RearWheelPowered) then
		self.DriveWheelsOnGround = self.VehicleData[ "onGround_3" ] and self.VehicleData[ "onGround_4" ]
	elseif (self.FrontWheelPowered and !self.RearWheelPowered) then
		self.DriveWheelsOnGround = self.VehicleData[ "onGround_1" ] and self.VehicleData[ "onGround_2" ]
	end
end

function ENT:GetRPM()
	local RPM = self.EngineRPM and self.EngineRPM or 0
	return RPM
end

function ENT:GetDiffGear()
	return math.max(self:GetDifferentialGear(),0.01)
end

function ENT:SimulateEngine(forward,back,tilt_left,tilt_right,torqueboost,IdleRPM,LimitRPM,Powerbandstart,Powerbandend,c_time,tilt_forward,tilt_back)
	local PObj = self:GetPhysicsObject()

	local Throttle = self:GetThrottle()
	
	if (self.DriveWheelsOnGround == 0) then
		self.Clutch = 1
	end
	
	if (self.Gears[self.CurrentGear] == 0) then
		self.GearRatio = 1
		self.Clutch = 1
		self.HandBrake = self.HandBrakePower
	else
		self.GearRatio = self.Gears[self.CurrentGear] * self:GetDiffGear()
	end
	self:SetClutch( self.Clutch )
	local InvClutch = (self.Clutch == 1) and 0 or 1
	
	local GearedRPM = self.WheelRPM / math.abs(self.GearRatio)
	
	local MaxTorque = self:GetMaxTorque()
	
	local DesRPM = (self.Clutch == 1) and math.max(IdleRPM + (LimitRPM - IdleRPM) * Throttle,0) or GearedRPM
	local Drag = (MaxTorque * (math.max( self.EngineRPM - IdleRPM, 0) / Powerbandend) * ( 1 - Throttle) / 0.15) * InvClutch
	
	local boost = torqueboost or 0
	
	self.EngineRPM = math.Clamp(self.EngineRPM + math.Clamp(DesRPM - self.EngineRPM,-math.max(self.EngineRPM / 15, 1 ),math.max(-self.RpmDiff / 1.5 * InvClutch + (self.Torque * 5) / 0.15 * self.Clutch, 1)) + self.RPM_DIFFERENCE * Throttle,0,LimitRPM) * self.EngineIsOn
	self.Torque = (Throttle + boost) * math.max(MaxTorque * math.min(self.EngineRPM / Powerbandstart, (LimitRPM - self.EngineRPM) / (LimitRPM - Powerbandend),1), 0)
	self:SetFlyWheelRPM( math.min(self.EngineRPM + self.exprpmdiff * 2 * InvClutch,LimitRPM) )
	
	self.RpmDiff = self.EngineRPM - GearedRPM
	
	local signGearRatio = ((self.GearRatio > 0) and 1 or 0) + ((self.GearRatio < 0) and -1 or 0)
	local signThrottle = (Throttle > 0) and 1 or 0
	local signSpeed = ((self.ForwardSpeed > 0) and 1 or 0) + ((self.ForwardSpeed < 0) and -1 or 0)
	
	local TorqueDiff = (self.RpmDiff / LimitRPM) * 0.15 * self.Torque
	local EngineBrake = (signThrottle == 0) and self.EngineRPM * (self.EngineRPM / LimitRPM) ^ 2 / 60 * signSpeed or 0
	
	local GearedPower = ((self.ThrottleDelay <= c_time and (self.Torque + TorqueDiff) * signThrottle * signGearRatio or 0) - EngineBrake) / math.abs(self.GearRatio) / 50
	
	self.EngineTorque = self.EngineIsOn == 1 and GearedPower * InvClutch or 0
	
	if (self:GetDoNotStall() != true) then
		if (self.EngineIsOn == 1) then
			if (self.EngineRPM <= IdleRPM * 0.2) then
				self.CurrentGear = 2
				self:StallAndRestart()
			end
		end
	end
	
	local ReactionForce = (self.EngineTorque * 2 - math.Clamp(self.ForwardSpeed,-self.Brake,self.Brake)) * self.DriveWheelsOnGround
	local BaseMassCenter = PObj:GetMassCenter()
	
	local FrontPos =(IsValid(self.Wheels[1]) and IsValid(self.Wheels[2])) and ((self.Wheels[1]:GetPos() + self.Wheels[2]:GetPos()) / 2) or BaseMassCenter
	local RearPos = (IsValid(self.Wheels[3]) and IsValid(self.Wheels[4])) and ((self.Wheels[3]:GetPos() + self.Wheels[4]:GetPos()) / 2) or BaseMassCenter
	
	local ReactionForcePos = (self:GetPowerDistribution() > 0) and RearPos or (self:GetPowerDistribution() < 0) and FrontPos or BaseMassCenter
	
	PObj:ApplyForceOffset( -self.Forward * self.Mass * ReactionForce, ReactionForcePos + self.Up ) 
	PObj:ApplyForceOffset( self.Forward * self.Mass * ReactionForce, ReactionForcePos - self.Up )
	
	local CountOnGround = self.VehicleData[ "onGround_1" ] + self.VehicleData[ "onGround_2" ] + self.VehicleData[ "onGround_3" ] + self.VehicleData[ "onGround_4" ]
	if (CountOnGround > 0) then return end
	
	local TiltForce = ((self.Right * (tilt_right - tilt_left) * 1.8) + (self.Forward * (tilt_forward - tilt_back) * 6)) * math.acos( math.Clamp( self.Up:Dot(Vector(0,0,1)) ,-1,1) ) * (180 / math.pi) * self.Mass
	PObj:ApplyForceOffset( TiltForce, PObj:GetMassCenter() + self.Up )
	PObj:ApplyForceOffset( -TiltForce, PObj:GetMassCenter() - self.Up )
end

function ENT:DamagedStall()
	if !self:GetActive() then return end
	
	local rtimer = 0.8
	timer.Simple( rtimer, function()
		if (!IsValid(self)) then return end
		net.Start( "simfphys_backfire" )
			net.WriteEntity( self )
		net.Broadcast()
	end)
	
	self:StallAndRestart( rtimer )
end

function ENT:StallAndRestart( nTimer )
	nTimer = nTimer or 1
	
	self.EngineIsOn = 0
	self:SetIsCruiseModeOn( false )
	
	self:EmitSound( "vehicles/jetski/jetski_off.wav" )
	
	timer.Simple( nTimer, function()
		if !IsValid(self) then return end
		if !self.IsInWater then
			self.EngineIsOn = 1
			self.EngineRPM = self:GetIdleRPM()
		end
	end)
end

function ENT:SimulateTransmission(k_throttle,k_brake,k_fullthrottle,k_clutch,k_handbrake,k_gearup,k_geardown,isauto,IdleRPM,Powerbandstart,Powerbandend,shiftmode,cruisecontrol,curtime)
	local GearsCount = table.Count( self.Gears ) 
	local ply = self:GetDriver()
	local cruiseThrottle = math.min( math.max(self.cc_speed - math.abs(self.ForwardSpeed),0) / 10 ^ 2, 1)
	
	if self.ForceTransmission == 1 then
		isauto = true
	elseif self.ForceTransmission == 2 then
		isauto = false
	end
	
	if (!isauto) then
		self.Brake = self:GetBrakePower() * k_brake
		self.HandBrake = self.HandBrakePower * k_handbrake
		self.Clutch = math.max(k_clutch,k_handbrake)
		
		local AutoThrottle = self.EngineIsOn != 0 and ((self.EngineRPM < IdleRPM) and (IdleRPM - self.EngineRPM) / IdleRPM or 0) or 0
		local Throttle = cruisecontrol and cruiseThrottle or ((0.5 + 0.5 * k_fullthrottle) * k_throttle + AutoThrottle)
		self:SetThrottle( Throttle )
		
		if (k_gearup != self.GearUpPressed) then
			self.GearUpPressed = k_gearup
			if (k_gearup == 1) then
				if (self.CurrentGear != GearsCount) then
					self.ThrottleDelay = curtime + 0.4 - 0.4 * k_clutch
				end
				self.CurrentGear = math.Clamp(self.CurrentGear + 1,1,GearsCount)
			end
		end
		if (k_geardown != self.GearDownPressed) then
			self.GearDownPressed = k_geardown
			if (k_geardown == 1) then
				self.CurrentGear = math.Clamp(self.CurrentGear - 1,1,GearsCount)
				if (self.CurrentGear == 1) then 
					self.ThrottleDelay = curtime + 0.25
				end
			end
		end
	else 
		local Throttle = cruisecontrol and cruiseThrottle or ((0.5 + 0.5 * k_fullthrottle) * (self.ForwardSpeed >= 50 and k_throttle or (self.ForwardSpeed < 50 and self.ForwardSpeed > -350) and math.max(k_throttle,k_brake) or (self.ForwardSpeed <= -350 and k_brake)))
		local CalcRPM = self.EngineRPM - self.RPM_DIFFERENCE * Throttle
		self:SetThrottle( Throttle )
		
		self.Clutch = math.max((self.EngineRPM < IdleRPM + (Powerbandstart - IdleRPM) * (self.CurrentGear <= 3 and Throttle or 0)) and 1 or 0,k_handbrake)
		self.HandBrake = self.HandBrakePower * k_handbrake
		
		self.Brake = self:GetBrakePower() * (self.ForwardSpeed >= 0 and k_brake or k_throttle)
		
		if (self.DriveWheelsOnGround) then
			if (self.ForwardSpeed >= 50) then	
				if (self.Clutch == 0) then
					local NextGear = self.CurrentGear + 1 <= GearsCount and math.min(self.CurrentGear + 1,GearsCount) or self.CurrentGear
					local NextGearRatio = self.Gears[NextGear] * self:GetDiffGear()
					local NextGearRPM = self.WheelRPM / math.abs(NextGearRatio)
					
					local PrevGear = self.CurrentGear - 1 <= GearsCount and math.max(self.CurrentGear - 1,3) or self.CurrentGear
					local PrevGearRatio = self.Gears[PrevGear] * self:GetDiffGear()
					local PrevGearRPM = self.WheelRPM / math.abs(PrevGearRatio)
					
					local minThrottle = shiftmode == 1 and 1 or math.max(Throttle,0.5)
					
					local ShiftUpRPM = Powerbandstart + (Powerbandend - Powerbandstart) * minThrottle
					local ShiftDownRPM = IdleRPM + (Powerbandend - Powerbandstart) * minThrottle
					
					local CanShiftUp = NextGearRPM > math.max(Powerbandstart * minThrottle,Powerbandstart - IdleRPM) and CalcRPM >= ShiftUpRPM and self.CurrentGear < GearsCount
					local CanShiftDown = CalcRPM <= ShiftDownRPM and PrevGearRPM < ShiftDownRPM and self.CurrentGear > 3
					
					if (CanShiftUp and self.NextShift < curtime) then
						self.CurrentGear = self.CurrentGear + 1
						self.NextShift = curtime + 0.5
						self.ThrottleDelay = curtime + 0.25
					end
					
					if (CanShiftDown and self.NextShift < curtime) then
						self.CurrentGear = self.CurrentGear - 1
						self.NextShift = curtime + 0.35
					end
					
					self.CurrentGear = math.Clamp(self.CurrentGear,3,GearsCount)
				end
			elseif (self.ForwardSpeed < 50 and self.ForwardSpeed > -350) then
				self.CurrentGear = (k_throttle == 1 and 3 or k_brake == 1 and 1) or 3
				self.Brake = self:GetBrakePower() * k_throttle * k_brake
			elseif (self.ForwardSpeed >= -350) then
				if (Throttle > 0) then
					self.Brake = 0
				end
				self.CurrentGear = 1
			end
			
			if (Throttle == 0 and math.abs(self.ForwardSpeed) <= 80) then
				self.CurrentGear = 2
				self.Brake = 0
			end
		end
	end
	self:SetIsBraking( self.Brake > 0 )
	self:SetGear( self.CurrentGear )
	self:SetHandBrakeEnabled( self.HandBrake > 0 or self.CurrentGear == 2 )
	
	if (self.Clutch == 1 or self.CurrentGear == 2) then
		if (math.abs(self.ForwardSpeed) <= 20) then
		local PObj = self:GetPhysicsObject()
			local TiltForce = self.Torque * (-1 + self:GetThrottle() * 2)
			PObj:ApplyForceOffset( self.Up * TiltForce, PObj:GetMassCenter() + self.Right * 1000 ) 
			PObj:ApplyForceOffset( -self.Up * TiltForce, PObj:GetMassCenter() - self.Right * 1000)
		end
	end
end

function ENT:SimulateWheels(left,right,k_clutch,LimitRPM)
	local SteerAngForward = self.Forward:Angle()
	local SteerAngRight = self.Right:Angle()
	local SteerAngForward2 = self.Forward:Angle()
	local SteerAngRight2 = self.Right:Angle()
	
	SteerAngForward:RotateAroundAxis(-self.Up, self.VehicleData[ "SteerAngle" ]) 
	SteerAngRight:RotateAroundAxis(-self.Up, self.VehicleData[ "SteerAngle" ]) 
	SteerAngForward2:RotateAroundAxis(-self.Up, -self.VehicleData[ "SteerAngle" ]) 
	SteerAngRight2:RotateAroundAxis(-self.Up, -self.VehicleData[ "SteerAngle" ]) 
	
	local SteerForward = SteerAngForward:Forward()
	local SteerRight = SteerAngRight:Forward()
	local SteerForward2 = SteerAngForward2:Forward()
	local SteerRight2 = SteerAngRight2:Forward()
	
	for i = 1, table.Count( self.Wheels ) do
		local Wheel = self.Wheels[i]
		
		if (IsValid(Wheel)) then
			local MaxGrip = self:GetMaxTraction()
			local GripOffset = self:GetTractionBias() * MaxGrip
			local IsFrontWheel = i == 1 or i == 2
			local IsRightWheel = i == 2 or i == 4 or i == 6
			local WheelRadius = IsFrontWheel and self.FrontWheelRadius or self.RearWheelRadius
			local WheelDiameter = WheelRadius * 2
			local SurfaceMultiplicator = self.VehicleData[ "SurfaceMul_" .. i ]
			local MaxTraction = (IsFrontWheel and (MaxGrip + GripOffset) or  (MaxGrip - GripOffset)) * SurfaceMultiplicator
			local Efficiency = self:GetEfficiency()
			
			local IsPoweredWheel = (IsFrontWheel and self.FrontWheelPowered or !IsFrontWheel and self.RearWheelPowered) and 1 or 0
			
			local Velocity = Wheel:GetVelocity()
			local VelForward = Velocity:GetNormalized()
			local OnGround = self.VehicleData[ "onGround_" .. i ]
			
			local Forward = IsFrontWheel and SteerForward or self.Forward
			local Right = IsFrontWheel and SteerRight or self.Right
			
			if (self.CustomWheels) then
				if (IsFrontWheel) then
					Forward = IsValid(self.SteerMaster) and SteerForward or self.Forward
					Right = IsValid(self.SteerMaster) and SteerRight or self.Right
				else
					if (IsValid(self.SteerMaster2)) then
						Forward = SteerForward2
						Right = SteerRight2
					end
				end
			end
			
			local Ax = math.acos( math.Clamp( Forward:Dot(VelForward) ,-1,1) ) * (180 / math.pi)
			local Ay = math.asin( math.Clamp( Right:Dot(VelForward) ,-1,1) ) * (180 / math.pi)
			
			local Fx = math.cos(Ax * (math.pi / 180)) * Velocity:Length()
			local Fy = math.sin(Ay * (math.pi / 180)) * Velocity:Length()
			
			local absFy = math.abs(Fy)
			local absFx = math.abs(Fx)
			
			local PowerBiasMul = IsFrontWheel and (1 - self:GetPowerDistribution()) * 0.5 or (1 + self:GetPowerDistribution()) * 0.5
			
			local ForwardForce = self.EngineTorque * PowerBiasMul * IsPoweredWheel + (!IsFrontWheel and math.Clamp(-Fx,-self.HandBrake,self.HandBrake) or 0) * SurfaceMultiplicator
			
			local TractionCycle = Vector(math.min(absFy,MaxTraction),ForwardForce,0):Length()
			local GripLoss = math.max(TractionCycle - MaxTraction,0)
			local GripRemaining = math.max(MaxTraction - GripLoss,math.min(absFy / 25,MaxTraction / 2))
			
			local signForwardForce = ((ForwardForce > 0) and 1 or 0) + ((ForwardForce < 0) and -1 or 0)
			local signEngineTorque = ((self.EngineTorque > 0) and 1 or 0) + ((self.EngineTorque < 0) and -1 or 0)
			local BrakeForce = math.Clamp(-Fx,-self.Brake,self.Brake) * SurfaceMultiplicator
			
			local Power = ForwardForce * Efficiency - GripLoss * signForwardForce + BrakeForce
			
			local Force = -Right * math.Clamp(Fy,-GripRemaining,GripRemaining) + Forward * Power * SurfaceMultiplicator
			
			local wRad = Wheel:GetDamaged() and Wheel.dRadius or WheelRadius
			local TurnWheel = ((Fx + GripLoss * 35 * signEngineTorque * IsPoweredWheel) / wRad * 1.85) + self.EngineRPM / 80 * (1 - OnGround) * IsPoweredWheel * (1 - k_clutch)
			
			Wheel.FX = Fx
			Wheel.skid = ((MaxTraction - (MaxTraction - Vector(absFy,math.abs(ForwardForce * 10),0):Length())) / MaxTraction) - 10
			
			local RPM = (absFx / (3.14 * WheelDiameter)) * 52 * OnGround
			local GripLossFaktor = math.Clamp(GripLoss,0,MaxTraction) / MaxTraction
			
			self.VehicleData[ "WheelRPM_".. i ] = RPM
			self.VehicleData[ "GripLossFaktor_".. i ] = GripLossFaktor
			self.VehicleData[ "Exp_GLF_".. i ] = GripLossFaktor ^ 2
			Wheel:SetGripLoss( GripLossFaktor )
			
			if (IsFrontWheel) then
				self.VehicleData[ "spin_" .. i ] = self.VehicleData[ "spin_" .. i ] + TurnWheel
			else
				if (self.HandBrake < MaxTraction) then
					self.VehicleData[ "spin_" .. i ] = self.VehicleData[ "spin_" .. i ] + TurnWheel
				end
			end
			
			if (self.CustomWheels) then
				local GhostEnt = self.GhostWheels[i]
				local Angle = GhostEnt:GetAngles()
				local offsetang = IsFrontWheel and self.CustomWheelAngleOffset or (self.CustomWheelAngleOffset_R or self.CustomWheelAngleOffset)
				local Direction = GhostEnt:LocalToWorldAngles( offsetang ):Forward()
				local AngleStep = IsFrontWheel and TurnWheel or (self.HandBrake < MaxTraction) and TurnWheel or 0
				Angle:RotateAroundAxis(Direction, IsRightWheel and AngleStep or -AngleStep)
				
				self.GhostWheels[i]:SetAngles( Angle )
			else
				self:SetPoseParameter(self.VehicleData[ "pp_spin_" .. i ],self.VehicleData[ "spin_" .. i ]) 
			end
			
			if (!self.PhysicsEnabled) then
				Wheel:GetPhysicsObject():ApplyForceCenter( Force * 185 * OnGround )
			end
		end
	end
	
	local target_diff = math.max(LimitRPM * 0.95 - self.EngineRPM,0)
	
	if (self.FrontWheelPowered and self.RearWheelPowered) then
		self.WheelRPM = math.max(self.VehicleData[ "WheelRPM_1" ] or 0,self.VehicleData[ "WheelRPM_2" ] or 0,self.VehicleData[ "WheelRPM_3" ] or 0,self.VehicleData[ "WheelRPM_4" ] or 0)
		self.RPM_DIFFERENCE = target_diff * math.max(self.VehicleData[ "GripLossFaktor_1" ] or 0,self.VehicleData[ "GripLossFaktor_2" ] or 0,self.VehicleData[ "GripLossFaktor_3" ] or 0,self.VehicleData[ "GripLossFaktor_4" ] or 0)
		self.exprpmdiff = target_diff * math.max(self.VehicleData[ "Exp_GLF_1" ] or 0,self.VehicleData[ "Exp_GLF_2" ] or 0,self.VehicleData[ "Exp_GLF_3" ] or 0,self.VehicleData[ "Exp_GLF_4" ] or 0)
		
	elseif (!self.FrontWheelPowered and self.RearWheelPowered) then
		self.WheelRPM = math.max(self.VehicleData[ "WheelRPM_3" ] or 0,self.VehicleData[ "WheelRPM_4" ] or 0)
		self.RPM_DIFFERENCE = target_diff * math.max(self.VehicleData[ "GripLossFaktor_3" ] or 0,self.VehicleData[ "GripLossFaktor_4" ] or 0)
		self.exprpmdiff = target_diff * math.max(self.VehicleData[ "Exp_GLF_3" ] or 0,self.VehicleData[ "Exp_GLF_4" ] or 0)
		
	elseif (self.FrontWheelPowered and !self.RearWheelPowered) then
		self.WheelRPM = math.max(self.VehicleData[ "WheelRPM_1" ] or 0,self.VehicleData[ "WheelRPM_2" ] or 0)
		self.RPM_DIFFERENCE = target_diff * math.max(self.VehicleData[ "GripLossFaktor_1" ] or 0,self.VehicleData[ "GripLossFaktor_2" ] or 0)
		self.exprpmdiff = target_diff * math.max(self.VehicleData[ "Exp_GLF_1" ] or 0,self.VehicleData[ "Exp_GLF_2" ] or 0)
		
	else 
		self.WheelRPM = 0
		self.RPM_DIFFERENCE = 0
		self.exprpmdiff = 0
	end	
end

function ENT:PlayerSteerVehicle( ply, left, right )
	if IsValid(ply) then
		local CounterSteeringEnabled = (ply:GetInfoNum( "cl_simfphys_ctenable", 0 ) or 1) == 1
		local CounterSteeringMul =  math.Clamp(ply:GetInfoNum( "cl_simfphys_ctmul", 0 ) or 0.7,0.1,2)
		local MaxHelpAngle = math.Clamp(ply:GetInfoNum( "cl_simfphys_ctang", 0 ) or 15,1,90)
		
		local Ang = self.MoveDir
		local TurnSpeed = self:GetSteerSpeed()
		local fadespeed = self:GetFastSteerConeFadeSpeed()
		
		local SlowSteeringRate = (Ang > 20) and ((math.Clamp((self.ForwardSpeed - 150) / 25,0,1) == 1) and 60 or self.VehicleData["steerangle"]) or self.VehicleData["steerangle"]
		local FastSteeringAngle = math.Clamp(self:GetFastSteerAngle() * self.VehicleData["steerangle"],1,SlowSteeringRate)
		
		local FastSteeringRate = FastSteeringAngle + ((Ang > (FastSteeringAngle-1)) and 1 or 0) * math.min(Ang,90 - FastSteeringAngle)
		
		local Ratio = 1 - math.Clamp((math.abs(self.ForwardSpeed) - fadespeed) / 25,0,1)
		
		local SteerRate = FastSteeringRate + (SlowSteeringRate - FastSteeringRate) * Ratio
		local Steer =  (right - left) * SteerRate
		local LocalDrift = math.acos( math.Clamp( self.Right:Dot(self.VelNorm) ,-1,1) ) * (180 / math.pi) - 90
		
		local CounterSteer = CounterSteeringEnabled and (math.Clamp(LocalDrift * CounterSteeringMul * (((left + right) == 0) and 1 or 0),-MaxHelpAngle,MaxHelpAngle) * ((self.ForwardSpeed > 50) and 1 or 0)) or 0
		
		if (ply:GetInfoNum( "cl_simfphys_mousesteer", 0 ) >= 1) then
			local MoveX = self:GetFreelook() and 0 or (self.GetMouseX or 0) * 0.05 * ply:GetInfoNum( "cl_simfphys_ms_sensitivity", 1 )
			local ms_fade = ply:GetInfoNum( "cl_simfphys_ms_return", 1 )
			
			self.SmoothMouse = self.SmoothMouse * 0.5 + MoveX
			local NotMoving = MoveX == 0
			local deadzone = ply:GetInfoNum( "cl_simfphys_ms_deadzone", 1.5 )
			local exponent = ply:GetInfoNum( "cl_simfphys_ms_exponent", 2 )
			
			self.SmoothMouseX = Steer == 0 and (math.Clamp(self.SmoothMouseX - (NotMoving and math.Clamp(self.SmoothMouseX,-ms_fade,ms_fade) or 0) + self.SmoothMouse,-self.VehicleData["steerangle"],self.VehicleData["steerangle"])) or 0
			local m_Steer = ((math.max(math.abs(self.SmoothMouseX) - deadzone,0) / (self.VehicleData["steerangle"] - deadzone)) ^ exponent * self.VehicleData["steerangle"]) * (self.SmoothMouseX < 0 and -1 or 1)
			
			self:SetDeadZone( deadzone / self.VehicleData["steerangle"] )
			self:SetMousePos( self.SmoothMouseX / self.VehicleData["steerangle"] )
			self:SetctPos( -CounterSteer / self.VehicleData["steerangle"] )
			
			local mturn = self.SmoothMouseX == 0 and TurnSpeed or self.VehicleData["steerangle"]
			self.SmoothAng = self.SmoothAng + math.Clamp((m_Steer == 0 and (Steer - CounterSteer) or m_Steer) - self.SmoothAng,-mturn,mturn)
		else
			self.SmoothAng = self.SmoothAng + math.Clamp((Steer - CounterSteer) - self.SmoothAng,-TurnSpeed,TurnSpeed)
		end
		
		self:SteerVehicle( self.SmoothAng )
	end
end

function ENT:SteerVehicle( steer )
	self.VehicleData[ "SteerAngle" ] = steer
	
	local pp_steer = steer / self.VehicleData["steerangle"]
	self:SetVehicleSteer( pp_steer )
	
	self:SetPoseParameter("vehicle_steer",pp_steer) 
end

function ENT:Lock()
	self.IsLocked = true
end

function ENT:UnLock()
	self.IsLocked = false
end

function ENT:ForceLightsOff()
	local vehiclelist = list.Get( "simfphys_lights" )[self.LightsTable] or false
	if !vehiclelist then return end
	
	if vehiclelist.Animation then -- if the vehicle has lightcover animations the lights will be turned off because the door animations will overwrite them
		if self.LightsActivated then
			self.LightsActivated = false
			self.LampsActivated = false
			
			self:SetLightsEnabled(false)
			self:SetLampsEnabled(false)
		end
	end
end

function ENT:EnteringSequence( ply )
	local LinkedDoorAnims = istable(self.ModelInfo) and istable(self.ModelInfo.LinkDoorAnims)
	if !istable(self.Enterpoints) and !LinkedDoorAnims then return end
	
	local sequence
	local pos
	local dist
	
	if LinkedDoorAnims then
		for i,_ in pairs( self.ModelInfo.LinkDoorAnims ) do
			local seq_ = self.ModelInfo.LinkDoorAnims[ i ].enter
			
			local a_pos = self:GetAttachment( self:LookupAttachment( i ) ).Pos
			local a_dist = (ply:GetPos() - a_pos):Length()
			
			if !sequence then
				sequence = seq_
				pos = a_pos
				dist = a_dist
			else
				if  (a_dist < dist) then
					sequence = seq_
					pos = a_pos
					dist = a_dist
				end
			end
		end
	else
		for i = 1, table.Count( self.Enterpoints ) do
			local a_ = self.Enterpoints[ i ]
			
			local a_pos = self:GetAttachment( self:LookupAttachment( a_ ) ).Pos
			local a_dist = (ply:GetPos() - a_pos):Length()
			
			if i == 1 then
				sequence = a_
				pos = a_pos
				dist = a_dist
			else
				if  (a_dist < dist) then
					sequence = a_
					pos = a_pos
					dist = a_dist
				end
			end
		end
	end
	
	self:PlayAnimation( sequence )
	self:ForceLightsOff()
end

function ENT:Use( ply )
	if (self.IsLocked == true) then 
		self:EmitSound( "doors/default_locked.wav" )
		return
	end
	
	if !IsValid(self:GetDriver()) and !ply:KeyDown(IN_WALK) then
		ply:SetAllowWeaponsInVehicle( false ) 
		if IsValid(self.DriverSeat) then
			
			self:EnteringSequence( ply )
			ply:EnterVehicle( self.DriverSeat )
			
			timer.Simple( 0.01, function()
				if IsValid(ply) then
					local angles = Angle(0,90,0)
					ply:SetEyeAngles( angles )
				end
			end)
		end
	else
		if self.PassengerSeats then
			local closestSeat = self:GetClosestSeat( ply )
			
			if (!closestSeat or IsValid(closestSeat:GetDriver())) then
				for i = 1, table.Count( self.pSeat ) do
					if (IsValid(self.pSeat[i])) then
						local HasPassenger = IsValid(self.pSeat[i]:GetDriver())
						if (!HasPassenger) then
							ply:EnterVehicle( self.pSeat[i] )
							break
						end
					end
				end
			else
				ply:EnterVehicle( closestSeat )
			end
		end
	end
end

function ENT:GetClosestSeat( ply )
	local Seat = self.pSeat[1]
	if !IsValid(Seat) then return false end
	
	local Distance = (Seat:GetPos() - ply:GetPos()):Length()
	
	for i = 1, table.Count( self.pSeat ) do
		local Dist = (self.pSeat[i]:GetPos() - ply:GetPos()):Length()
		if (Dist < Distance) then
			Seat = self.pSeat[i]
		end
	end
	
	return Seat
end

function ENT:GetVehicleData()	
	self:SetPoseParameter("vehicle_steer",1) 
	self:SetPoseParameter("vehicle_wheel_fl_height",1) 
	self:SetPoseParameter("vehicle_wheel_fr_height",1) 
	self:SetPoseParameter("vehicle_wheel_rl_height",1) 
	self:SetPoseParameter("vehicle_wheel_rr_height",1)
	
	timer.Simple( 0.15, function()
		if (!IsValid(self)) then return end
		self.posepositions["Pose0_Steerangle"] = self.CustomWheels and Angle(0,0,0) or self:GetAttachment( self:LookupAttachment( "wheel_fl" ) ).Ang
		self.posepositions["Pose0_Pos_FL"] = self.CustomWheels and self:LocalToWorld( self.CustomWheelPosFL ) or self:GetAttachment( self:LookupAttachment( "wheel_fl" ) ).Pos
		self.posepositions["Pose0_Pos_FR"] = self.CustomWheels and self:LocalToWorld( self.CustomWheelPosFR ) or self:GetAttachment( self:LookupAttachment( "wheel_fr" ) ).Pos
		self.posepositions["Pose0_Pos_RL"] = self.CustomWheels and self:LocalToWorld( self.CustomWheelPosRL ) or self:GetAttachment( self:LookupAttachment( "wheel_rl" ) ).Pos
		self.posepositions["Pose0_Pos_RR"] = self.CustomWheels and self:LocalToWorld( self.CustomWheelPosRR ) or self:GetAttachment( self:LookupAttachment( "wheel_rr" ) ).Pos	
		
		self:WriteVehicleDataTable()
	end )
end

function ENT:SetPhysics( enable )
	if enable then
		if !self.PhysicsEnabled then
			for i = 1, table.Count( self.Wheels ) do
				local Wheel = self.Wheels[i]
				if IsValid(Wheel) then
					Wheel:GetPhysicsObject():SetMaterial("jeeptire")
				end
			end
			self.PhysicsEnabled = true
		end
	else
		if self.PhysicsEnabled != false then
			for i = 1, table.Count( self.Wheels ) do
				local Wheel = self.Wheels[i]
				if IsValid(Wheel) then
					Wheel:GetPhysicsObject():SetMaterial("friction_00")
				end
			end
			self.PhysicsEnabled = false
		end
	end
end

function ENT:SetValues()
	self.EnableSuspension = 0
	self.WheelOnGroundDelay = 0
	self.SmoothAng = 0
	self.Steer = 0
	self.EngineIsOn = 0
	self.EngineTorque = 0
	
	self.pSeat = {}
	self.exfx = {}
	self.Wheels = {}
	self.Elastics = {}
	self.GhostWheels = {}
	self.PressedKeys = {}
	self.ColorableProps = {}
	
	self.posepositions = {}
	
	self.HandBrakePower = 0
	self.DriveWheelsOnGround = 0
	self.WheelRPM = 0
	self.EngineRPM = 0
	self.RpmDiff = 0
	self.Torque = 0
	self.CurrentGear = 2
	self.GearUpPressed = 0
	self.GearDownPressed = 0
	self.RPM_DIFFERENCE = 0
	self.exprpmdiff = 0
	self.OldLockBrakes = 0
	self.ThrottleDelay = 0
	self.Brake = 0
	self.HandBrake = 0
	self.AutoClutch = 0
	self.NextShift = 0
	self.ForwardSpeed = 0
	self.EngineWasOn = 0
	self.SmoothTurbo = 0
	self.SmoothBlower = 0
	self.cc_speed = 0
	self.LightsActivated = false
	self.SmoothMouse = 0
	self.SmoothMouseX = 0

	self.VehicleData = {}
	for i = 1, 6 do
		self.VehicleData[ "spin_"..i ] = 0
		self.VehicleData[ "SurfaceMul_"..i ] = 1
		self.VehicleData[ "onGround_"..i ] = 0
	end
	
	self.VehicleData[ "SteerAngle" ] = 0
end

function ENT:WriteVehicleDataTable()	
	self:SetPoseParameter("vehicle_steer",0) 
	self:SetPoseParameter("vehicle_wheel_fl_height",0) 
	self:SetPoseParameter("vehicle_wheel_fr_height",0) 
	self:SetPoseParameter("vehicle_wheel_rl_height",0) 
	self:SetPoseParameter("vehicle_wheel_rr_height",0)
	
	timer.Simple( 0.15, function()
		if (!IsValid(self)) then return end
		self.posepositions["Pose1_Steerangle"] = self.CustomWheels and Angle(0,0,0) or self:GetAttachment( self:LookupAttachment( "wheel_fl" ) ).Ang
		self.posepositions["Pose1_Pos_FL"] = self.CustomWheels and self:LocalToWorld( self.CustomWheelPosFL ) or self:GetAttachment( self:LookupAttachment( "wheel_fl" ) ).Pos
		self.posepositions["Pose1_Pos_FR"] = self.CustomWheels and self:LocalToWorld( self.CustomWheelPosFR ) or self:GetAttachment( self:LookupAttachment( "wheel_fr" ) ).Pos
		self.posepositions["Pose1_Pos_RL"] = self.CustomWheels and self:LocalToWorld( self.CustomWheelPosRL ) or self:GetAttachment( self:LookupAttachment( "wheel_rl" ) ).Pos
		self.posepositions["Pose1_Pos_RR"] = self.CustomWheels and self:LocalToWorld( self.CustomWheelPosRR ) or self:GetAttachment( self:LookupAttachment( "wheel_rr" ) ).Pos
		self.posepositions["PoseL_Pos_FL"] = self:WorldToLocal( self.posepositions.Pose1_Pos_FL )
		self.posepositions["PoseL_Pos_FR"] = self:WorldToLocal( self.posepositions.Pose1_Pos_FR )
		self.posepositions["PoseL_Pos_RL"] = self:WorldToLocal( self.posepositions.Pose1_Pos_RL )
		self.posepositions["PoseL_Pos_RR"] = self:WorldToLocal( self.posepositions.Pose1_Pos_RR )
		
		self.VehicleData["suspensiontravel_fl"] = self.CustomWheels and self.FrontHeight or math.Round( (self.posepositions.Pose0_Pos_FL - self.posepositions.Pose1_Pos_FL):Length() , 2)
		self.VehicleData["suspensiontravel_fr"] = self.CustomWheels and self.FrontHeight or math.Round( (self.posepositions.Pose0_Pos_FR - self.posepositions.Pose1_Pos_FR):Length() , 2)
		self.VehicleData["suspensiontravel_rl"] = self.CustomWheels and self.RearHeight or math.Round( (self.posepositions.Pose0_Pos_RL - self.posepositions.Pose1_Pos_RL):Length() , 2)
		self.VehicleData["suspensiontravel_rr"] = self.CustomWheels and self.RearHeight or math.Round( (self.posepositions.Pose0_Pos_RR - self.posepositions.Pose1_Pos_RR):Length() , 2)
		
		local Figure1 = math.Round( math.acos( math.Clamp(self.posepositions.Pose0_Steerangle:Up():Dot(self.posepositions.Pose1_Steerangle:Up()),-1,1) ) * (180 / math.pi) , 2)
		local Figure2 = math.Round( math.acos( math.Clamp(self.posepositions.Pose0_Steerangle:Forward():Dot(self.posepositions.Pose1_Steerangle:Forward()),-1,1) ) * (180 / math.pi) , 2)
		local Figure3 = math.Round( math.acos( math.Clamp(self.posepositions.Pose0_Steerangle:Right():Dot(self.posepositions.Pose1_Steerangle:Right()),-1,1) ) * (180 / math.pi) , 2)
		self.VehicleData["steerangle"] = self.CustomWheels and self.CustomSteerAngle or math.max(Figure1,Figure2,Figure3)
		
		local pFL = self.posepositions.Pose0_Pos_FL
		local pFR = self.posepositions.Pose0_Pos_FR
		local pRL = self.posepositions.Pose0_Pos_RL
		local pRR = self.posepositions.Pose0_Pos_RR
		local pAngL = self:WorldToLocalAngles( ((pFL + pFR) / 2 - (pRL + pRR) / 2):Angle() )
		pAngL.r = 0
		
		self.VehicleData["LocalAngForward"] = pAngL
		self.VehicleData["LocalAngRight"] = self.VehicleData.LocalAngForward - Angle(0,90,0)
		self.VehicleData[ "pp_spin_1" ] = "vehicle_wheel_fl_spin"
		self.VehicleData[ "pp_spin_2" ] = "vehicle_wheel_fr_spin"
		self.VehicleData[ "pp_spin_3" ] = "vehicle_wheel_rl_spin"
		self.VehicleData[ "pp_spin_4" ] = "vehicle_wheel_rr_spin"
		
		self.Turbo = CreateSound(self, "")
		self.Blower = CreateSound(self, "")
		self.BlowerWhine = CreateSound(self, "")
		self.BlowOff = CreateSound(self, "")
		
		self:SetFastSteerAngle(self.FastSteeringAngle / self.VehicleData["steerangle"])
		self:SetNotSolid( false )
		self:SetupVehicle()
	end )
end

function ENT:SetupVehicle()
	local BaseMass = self:GetPhysicsObject():GetMass()
	local MassCenterOffset = self.CustomMassCenter or Vector(0,0,0)
	local BaseMassCenter = self:LocalToWorld( self:GetPhysicsObject():GetMassCenter() - MassCenterOffset )
	
	local OffsetMass = BaseMass * 0.25
	local CenterWheels = (self.posepositions["Pose1_Pos_FL"] + self.posepositions["Pose1_Pos_FR"] + self.posepositions["Pose1_Pos_RL"] + self.posepositions["Pose1_Pos_RR"]) / 4
	
	local Sub = CenterWheels - BaseMassCenter
	local Dir = Sub:GetNormalized()
	local Dist = Sub:Length()
	local DistAdd = BaseMass * Dist / OffsetMass

	local OffsetMassCenter = BaseMassCenter + Dir * (Dist + DistAdd)
	
	self.MassOffset = ents.Create( "prop_physics" )
	self.MassOffset:SetModel( "models/hunter/plates/plate.mdl" )
	self.MassOffset:SetPos( OffsetMassCenter )
	self.MassOffset:SetAngles( Angle(0,0,0) )
	self.MassOffset:Spawn()
	self.MassOffset:Activate()
	self.MassOffset:GetPhysicsObject():EnableMotion(false)
	self.MassOffset:GetPhysicsObject():SetMass( OffsetMass )
	self.MassOffset:GetPhysicsObject():EnableDrag( false ) 
	self.MassOffset:SetOwner( self )
	self.MassOffset:DrawShadow( false )
	self.MassOffset:SetNotSolid( true )
	self.MassOffset:SetNoDraw( true )
	self.MassOffset.DoNotDuplicate = true
	self:s_MakeOwner( self.MassOffset )
	
	local constraint = constraint.Weld(self.MassOffset,self, 0, 0, 0,true, true) 
	constraint.DoNotDuplicate = true
	
	if (self.CustomWheels) then
		if (self.CustomWheelModel) then
			if (!file.Exists( self.CustomWheelModel, "GAME" )) then 
				self.EntityOwner:PrintMessage( HUD_PRINTTALK, "ERROR: \""..self.CustomWheelModel.."\" does not exist! Removing vehicle. (Class: "..self:GetSpawn_List()..")")
				self:Remove()
				return
			end
		
			if (self.SteerFront != false) then
				self.SteerMaster = ents.Create( "prop_physics" )
				self.SteerMaster:SetModel( self.CustomWheelModel )
				self.SteerMaster:SetPos( self:GetPos() )
				self.SteerMaster:SetAngles( self:GetAngles() )
				self.SteerMaster:Spawn()
				self.SteerMaster:Activate()
				
				local pobj = self.SteerMaster:GetPhysicsObject()
				if (IsValid(pobj)) then
					pobj:EnableMotion(false)
				else
					self.EntityOwner:PrintMessage( HUD_PRINTTALK, "ERROR: \""..self.CustomWheelModel.."\" doesn't have an collision model! Removing vehicle. (Class: "..self:GetSpawn_List()..")")
					self.SteerMaster:Remove()
					self:Remove()
					return
				end
				
				self.SteerMaster:SetOwner( self )
				self.SteerMaster:DrawShadow( false )
				self.SteerMaster:SetNotSolid( true )
				self.SteerMaster:SetNoDraw( true )
				self.SteerMaster.DoNotDuplicate = true
				self:DeleteOnRemove( self.SteerMaster )
				self:s_MakeOwner( self.SteerMaster )
			end
			
			if (self.SteerRear) then
				self.SteerMaster2 = ents.Create( "prop_physics" )
				self.SteerMaster2:SetModel( self.CustomWheelModel )
				self.SteerMaster2:SetPos( self:GetPos() )
				self.SteerMaster2:SetAngles( self:GetAngles() )
				self.SteerMaster2:Spawn()
				self.SteerMaster2:Activate()
				
				local pobj = self.SteerMaster2:GetPhysicsObject()
				if (IsValid(pobj)) then
					pobj:EnableMotion(false)
				else
					self.EntityOwner:PrintMessage( HUD_PRINTTALK, "ERROR: \""..self.CustomWheelModel.."\" doesn't have an collision model! Removing vehicle. (Class: "..self:GetSpawn_List()..")")
					self.SteerMaster2:Remove()
					self:Remove()
					return
				end
				
				self.SteerMaster2:SetOwner( self )
				self.SteerMaster2:DrawShadow( false )
				self.SteerMaster2:SetNotSolid( true )
				self.SteerMaster2:SetNoDraw( true )
				self.SteerMaster2.DoNotDuplicate = true
				self:DeleteOnRemove( self.SteerMaster2 )
				self:s_MakeOwner( self.SteerMaster2 )
			end
			
			local radius = IsValid(self.SteerMaster) and (self.SteerMaster:OBBMaxs() - self.SteerMaster:OBBMins()) or (self.SteerMaster2:OBBMaxs() - self.SteerMaster2:OBBMins())
			self.FrontWheelRadius = self.FrontWheelRadius or math.max( radius.x, radius.y, radius.z ) * 0.5
			self.RearWheelRadius = self.RearWheelRadius or self.FrontWheelRadius
			
			self:CreateWheel(1, WheelFL, self:LocalToWorld( self.CustomWheelPosFL ), self.FrontHeight, self.FrontWheelRadius, false , self:LocalToWorld( self.CustomWheelPosFL + Vector(0,0,self.CustomSuspensionTravel * 0.5) ),self.CustomSuspensionTravel, self.FrontConstant, self.FrontDamping, self.FrontRelativeDamping)
			self:CreateWheel(2, WheelFR, self:LocalToWorld( self.CustomWheelPosFR ), self.FrontHeight, self.FrontWheelRadius, true , self:LocalToWorld( self.CustomWheelPosFR + Vector(0,0,self.CustomSuspensionTravel * 0.5) ),self.CustomSuspensionTravel, self.FrontConstant, self.FrontDamping, self.FrontRelativeDamping)
			self:CreateWheel(3, WheelRL, self:LocalToWorld( self.CustomWheelPosRL ), self.RearHeight, self.RearWheelRadius, false , self:LocalToWorld( self.CustomWheelPosRL + Vector(0,0,self.CustomSuspensionTravel * 0.5) ),self.CustomSuspensionTravel, self.RearConstant, self.RearDamping, self.RearRelativeDamping)
			self:CreateWheel(4, WheelRR, self:LocalToWorld( self.CustomWheelPosRR ), self.RearHeight, self.RearWheelRadius, true , self:LocalToWorld( self.CustomWheelPosRR + Vector(0,0,self.CustomSuspensionTravel * 0.5) ), self.CustomSuspensionTravel, self.RearConstant, self.RearDamping, self.RearRelativeDamping)
			
			if (self.CustomWheelPosML) then
				self:CreateWheel(5, WheelML, self:LocalToWorld( self.CustomWheelPosML ), self.RearHeight, self.RearWheelRadius, false , self:LocalToWorld( self.CustomWheelPosML + Vector(0,0,self.CustomSuspensionTravel * 0.5) ),self.CustomSuspensionTravel, self.RearConstant, self.RearDamping, self.RearRelativeDamping)
			end
			if (self.CustomWheelPosMR) then
				self:CreateWheel(6, WheelMR, self:LocalToWorld( self.CustomWheelPosMR ), self.RearHeight, self.RearWheelRadius, true , self:LocalToWorld( self.CustomWheelPosMR + Vector(0,0,self.CustomSuspensionTravel * 0.5) ), self.CustomSuspensionTravel, self.RearConstant, self.RearDamping, self.RearRelativeDamping)
			end
		else
			self.EntityOwner:PrintMessage( HUD_PRINTTALK, "ERROR: no wheel model defined. Removing vehicle. (Class: "..self:GetSpawn_List()..")")
			self:Remove()
		end
	else
		self:CreateWheel(1, WheelFL, self:GetAttachment( self:LookupAttachment( "wheel_fl" ) ).Pos, self.FrontHeight, self.FrontWheelRadius, false , self.posepositions.Pose1_Pos_FL, self.VehicleData.suspensiontravel_fl, self.FrontConstant, self.FrontDamping, self.FrontRelativeDamping)
		self:CreateWheel(2, WheelFR, self:GetAttachment( self:LookupAttachment( "wheel_fr" ) ).Pos, self.FrontHeight, self.FrontWheelRadius, true , self.posepositions.Pose1_Pos_FR, self.VehicleData.suspensiontravel_fr, self.FrontConstant, self.FrontDamping, self.FrontRelativeDamping)
		self:CreateWheel(3, WheelRL, self:GetAttachment( self:LookupAttachment( "wheel_rl" ) ).Pos, self.RearHeight, self.RearWheelRadius, false , self.posepositions.Pose1_Pos_RL, self.VehicleData.suspensiontravel_rl, self.RearConstant, self.RearDamping, self.RearRelativeDamping)
		self:CreateWheel(4, WheelRR, self:GetAttachment( self:LookupAttachment( "wheel_rr" ) ).Pos, self.RearHeight, self.RearWheelRadius, true , self.posepositions.Pose1_Pos_RR, self.VehicleData.suspensiontravel_rr, self.RearConstant, self.RearDamping, self.RearRelativeDamping)
	end
	
	timer.Simple( 0.01, function()		
		local tb = self.Wheels
		
		if !istable(tb) then return end
		
		for i = 1, table.Count( tb ) do
			local Ent = self.Wheels[ i ]
			local PhysObj = Ent:GetPhysicsObject()
			
			if (IsValid(PhysObj)) then
				PhysObj:EnableMotion(true)
			end
		end
		
		timer.Simple( 0.1, function()
			if (!IsValid(self)) then return end
			self:GetPhysicsObject():EnableMotion(true)
			
			local PhysObj = self.MassOffset:GetPhysicsObject()
			if (IsValid(PhysObj)) then
				PhysObj:EnableMotion(true)
			end
		end )
	end )
	
	self.EnableSuspension = 1
end

function ENT:CreateWheel(index, name, attachmentpos, height, radius, swap_y , poseposition, suspensiontravel, constant, damping, rdamping)
	local fAng = self:LocalToWorldAngles( self.VehicleData.LocalAngForward )
	local rAng = self:LocalToWorldAngles( self.VehicleData.LocalAngRight )
	
	local Forward = fAng:Forward() 
	local Right = swap_y and -rAng:Forward() or rAng:Forward()
	local Up = self:GetUp()
	
	local RopeLength = 150
	local LimiterLength = 60
	local LimiterRopeLength = math.sqrt( (suspensiontravel * 0.5) ^ 2 + LimiterLength ^ 2 )
	local WheelMass = self.Mass / 32
	
	if (self.FrontWheelMass and (index == 1 or index == 2)) then
		WheelMass = self.FrontWheelMass
	end
	if (self.RearWheelMass and (index == 3 or index == 4 or index == 5 or index == 6)) then
		WheelMass = self.RearWheelMass
	end
	
	self.name = ents.Create( "gmod_sent_vehicle_fphysics_wheel" )
	self.name:SetPos( attachmentpos - Up * height)
	self.name:SetAngles( fAng )
	self.name:Spawn()
	self.name:Activate()
	self.name:PhysicsInitSphere( radius, "jeeptire" )
	self.name:SetCollisionBounds( Vector(-radius,-radius,-radius), Vector(radius,radius,radius) )
	self.name:GetPhysicsObject():EnableMotion(false)
	self.name:GetPhysicsObject():SetMass( WheelMass ) 
	self.name:SetBaseEnt( self )
	self:s_MakeOwner( self.name )
	self.name.EntityOwner = self.EntityOwner
	self.name.Index = index
	self.name.Radius = radius
	
	if self.CustomWheels then
		local Model = (self.CustomWheelModel_R and (index == 3 or index == 4 or index == 5 or index == 6)) and self.CustomWheelModel_R or self.CustomWheelModel
		local ghostAng = Right:Angle()
		local mirAng = swap_y and 1 or -1
		ghostAng:RotateAroundAxis(Forward,self.CustomWheelAngleOffset.p * mirAng)
		ghostAng:RotateAroundAxis(Right,self.CustomWheelAngleOffset.r * mirAng)
		ghostAng:RotateAroundAxis(Up,-self.CustomWheelAngleOffset.y)
		
		local Camber = self.CustomWheelCamber or 0
		ghostAng:RotateAroundAxis(Forward, Camber * mirAng)
		
		self.GhostWheels[index] = ents.Create( "gmod_sent_vehicle_fphysics_attachment" )
		self.GhostWheels[index]:SetModel( Model )
		self.GhostWheels[index]:SetPos( self.name:GetPos() )
		self.GhostWheels[index]:SetAngles( ghostAng )
		self.GhostWheels[index]:SetOwner( self )
		self.GhostWheels[index]:Spawn()
		self.GhostWheels[index]:Activate()
		self.GhostWheels[index]:SetNotSolid( true )
		self.GhostWheels[index].DoNotDuplicate = true
		self.GhostWheels[index]:SetParent( self.name )
		self:DeleteOnRemove( self.GhostWheels[index] )
		self:s_MakeOwner( self.GhostWheels[index] )
		
		self.GhostWheels[index]:SetRenderMode( RENDERMODE_TRANSALPHA )
		
		if self.ModelInfo then
			if self.ModelInfo.WheelColor then
				self.GhostWheels[index]:SetColor( self.ModelInfo.WheelColor )
			end
		end
		
		self.name.GhostEnt = self.GhostWheels[index]
		
		local nocollide = constraint.NoCollide(self,self.name,0,0)
		nocollide.DoNotDuplicate = true
	end

	local targetentity = self
	if self.CustomWheels then
		if (index == 1 or index == 2) then
			targetentity = self.SteerMaster or self
		end
		if (index == 3 or index == 4) then
			targetentity = self.SteerMaster2 or self
		end
	end
	
	local Ballsocket = constraint.AdvBallsocket(targetentity,self.name,0,0,Vector(0,0,0),Vector(0,0,0),0,0, -0.01, -0.01, -0.01, 0.01, 0.01, 0.01, 0, 0, 0, 1, 1) 
	local Rope1 = constraint.Rope(self,self.name,0,0,self:WorldToLocal( self.name:GetPos() + Forward * RopeLength * 0.5 + Right * RopeLength), Vector(0,0,0), Vector(RopeLength * 0.5,RopeLength,0):Length(), 0, 0, 0,"cable/cable2", true )
	local Rope2 = constraint.Rope(self,self.name,0,0,self:WorldToLocal( self.name:GetPos() - Forward * RopeLength * 0.5 + Right * RopeLength), Vector(0,0,0), Vector(RopeLength * 0.5,RopeLength,0):Length(), 0, 0, 0,"cable/cable2", true )
	if self.StrengthenSuspension == true then
		local Rope3 = constraint.Rope(self,self.name,0,0,self:WorldToLocal( poseposition - Up * suspensiontravel * 0.5 + Right * LimiterLength), Vector(0,0,0),LimiterRopeLength * 0.99, 0, 0, 0,"cable/cable2", false )
		local Rope4 = constraint.Rope(self,self.name,0,0,self:WorldToLocal( poseposition - Up * suspensiontravel * 0.5 - Right * LimiterLength), Vector(0,0,0),LimiterRopeLength * 1, 0, 0, 0,"cable/cable2", false )
		local elastic1 = constraint.Elastic(self.name, self, 0, 0, Vector(0,0,height), self:WorldToLocal( self.name:GetPos() ), constant * 0.5, damping * 0.5, rdamping * 0.5,"cable/cable2",0, false)
		local elastic2 = constraint.Elastic(self.name, self, 0, 0, Vector(0,0,height), self:WorldToLocal( self.name:GetPos() ), constant * 0.5, damping * 0.5, rdamping * 0.5,"cable/cable2",0, false)
		
		Rope3.DoNotDuplicate = true
		Rope4.DoNotDuplicate = true
		elastic1.DoNotDuplicate = true
		elastic2.DoNotDuplicate = true
		self.Elastics[index] = elastic1
		self.Elastics[index * 10] = elastic2
	else
		local Rope3 = constraint.Rope(self,self.name,0,0,self:WorldToLocal( poseposition - Up * suspensiontravel * 0.5 + Right * LimiterLength), Vector(0,0,0),LimiterRopeLength, 0, 0, 0,"cable/cable2", false )
		local elastic = constraint.Elastic(self.name, self, 0, 0, Vector(0,0,height), self:WorldToLocal( self.name:GetPos() ), constant, damping, rdamping,"cable/cable2",0, false) 
		
		Rope3.DoNotDuplicate = true
		elastic.DoNotDuplicate = true
		self.Elastics[index] = elastic
	end
	
	self.Wheels[index] = self.name
	
	Ballsocket.DoNotDuplicate = true
	Rope1.DoNotDuplicate = true
	Rope2.DoNotDuplicate = true
end

function ENT:SetSuspension( index , bIsDamaged )
	local bIsDamaged = bIsDamaged or false
	
	local h_mod = index <= 2 and self:GetFrontSuspensionHeight() or self:GetRearSuspensionHeight()
	
	local heights = {
		[1] = self.FrontHeight + self.VehicleData.suspensiontravel_fl * -h_mod,
		[2] = self.FrontHeight + self.VehicleData.suspensiontravel_fl * -h_mod,
		[3] = self.RearHeight + self.VehicleData.suspensiontravel_rl * -h_mod,
		[4] = self.RearHeight + self.VehicleData.suspensiontravel_rr * -h_mod,
		[5] = self.RearHeight + self.VehicleData.suspensiontravel_rl * -h_mod,
		[6] = self.RearHeight + self.VehicleData.suspensiontravel_rr * -h_mod
	}
	local Wheel = self.Wheels[index]
	if !IsValid(Wheel) then return end
	
	local subRadius = bIsDamaged and Wheel.dRadius or 0
	
	local newheight = heights[index] + subRadius

	local Elastic = self.Elastics[index]
	if IsValid(Elastic) then
		Elastic:Fire( "SetSpringLength", newheight )
	end
	
	if self.StrengthenSuspension == true then
		local Elastic2 = self.Elastics[index * 10]
		if (IsValid(Elastic2)) then
			Elastic2:Fire( "SetSpringLength", newheight )
		end
	end
end

function ENT:OnFrontSuspensionHeightChanged( name, old, new )
	if ( old == new ) then return end
	if (!self.CustomWheels and (new > 0)) then new = 0 end
	if (self.EnableSuspension != 1) then return end
	
	if (IsValid(self.Wheels[1])) then
		local Elastic = self.Elastics[1]
		if (IsValid(Elastic)) then
			Elastic:Fire( "SetSpringLength", self.FrontHeight + self.VehicleData.suspensiontravel_fl * -new )
		end
		if (self.StrengthenSuspension == true) then
			local Elastic2 = self.Elastics[10]
			if (IsValid(Elastic2)) then
				Elastic2:Fire( "SetSpringLength", self.FrontHeight + self.VehicleData.suspensiontravel_fl * -new )
			end
		end
	end
	if (IsValid(self.Wheels[2])) then
		local Elastic = self.Elastics[2]
		if (IsValid(Elastic)) then
			Elastic:Fire( "SetSpringLength", self.FrontHeight + self.VehicleData.suspensiontravel_fr * -new )
		end
		if (self.StrengthenSuspension == true) then
			local Elastic2 = self.Elastics[20]
			if (IsValid(Elastic2)) then
				Elastic2:Fire( "SetSpringLength", self.FrontHeight + self.VehicleData.suspensiontravel_fr * -new )
			end
		end
	end
end

function ENT:OnRearSuspensionHeightChanged( name, old, new )
	if ( old == new ) then return end
	if (!self.CustomWheels and (new > 0)) then new = 0 end
	if (self.EnableSuspension != 1) then return end
	
	if (IsValid(self.Wheels[3])) then
		local Elastic = self.Elastics[3]
		if (IsValid(Elastic)) then
			Elastic:Fire( "SetSpringLength", self.RearHeight + self.VehicleData.suspensiontravel_rl * -new )
		end
		if (self.StrengthenSuspension == true) then
			local Elastic2 = self.Elastics[30]
			if (IsValid(Elastic2)) then
				Elastic2:Fire( "SetSpringLength", self.RearHeight + self.VehicleData.suspensiontravel_rl * -new )
			end
		end
	end
	
	if (IsValid(self.Wheels[4])) then
		local Elastic = self.Elastics[4]
		if (IsValid(Elastic)) then
			Elastic:Fire( "SetSpringLength", self.RearHeight + self.VehicleData.suspensiontravel_rr * -new )
		end
		if (self.StrengthenSuspension == true) then
			local Elastic2 = self.Elastics[40]
			if (IsValid(Elastic2)) then
				Elastic2:Fire( "SetSpringLength", self.RearHeight + self.VehicleData.suspensiontravel_rr * -new )
			end
		end
	end
	
	if (IsValid(self.Wheels[5])) then
		local Elastic = self.Elastics[5]
		if (IsValid(Elastic)) then
			Elastic:Fire( "SetSpringLength", self.RearHeight + self.VehicleData.suspensiontravel_rl * -new )
		end
		if (self.StrengthenSuspension == true) then
			local Elastic2 = self.Elastics[50]
			if (IsValid(Elastic2)) then
				Elastic2:Fire( "SetSpringLength", self.RearHeight + self.VehicleData.suspensiontravel_rl * -new )
			end
		end
	end
	
	if (IsValid(self.Wheels[6])) then
		local Elastic = self.Elastics[6]
		if (IsValid(Elastic)) then
			Elastic:Fire( "SetSpringLength", self.RearHeight + self.VehicleData.suspensiontravel_rr * -new )
		end
		if (self.StrengthenSuspension == true) then
			local Elastic2 = self.Elastics[60]
			if (IsValid(Elastic2)) then
				Elastic2:Fire( "SetSpringLength", self.RearHeight + self.VehicleData.suspensiontravel_rr * -new )
			end
		end
	end
end

function ENT:SimulateTurbo(LimitRPM)
	if (!self.Turbo) then return end
	
	local Throttle = self:GetThrottle()
	
	self.SmoothTurbo = self.SmoothTurbo + math.Clamp((self.EngineRPM / LimitRPM) * 600 * (0.75 + 0.25 * Throttle) - self.SmoothTurbo,-15,15)
	
	local Volume = math.Clamp( ((self.SmoothTurbo - 300) / 150) ,0, 1) * 0.5
	local Pitch = math.Clamp( self.SmoothTurbo / 7 , 0 , 255)
	
	local boost = math.Clamp( -0.25 + (self.SmoothTurbo / 500) ^ 5,0,1)
	
	self.Turbo:ChangeVolume( Volume )
	self.Turbo:ChangePitch( Pitch )
	
	return boost
end

function ENT:SimulateBlower(LimitRPM)
	if (!self.Blower or !self.BlowerWhine) then return end
	
	local Throttle = self:GetThrottle()
	
	self.SmoothBlower = self.SmoothBlower + math.Clamp((self.EngineRPM / LimitRPM) * 500 - self.SmoothBlower,-20,20)
	
	local Volume1 = math.Clamp( self.SmoothBlower / 400 * (1 - 0.4 * Throttle) ,0, 1)
	local Volume2 = math.Clamp( self.SmoothBlower / 400 * (0.10 + 0.4 * Throttle) ,0, 1)
	
	local Pitch1 = 50 + math.Clamp( self.SmoothBlower / 4.5 , 0 , 205)
	local Pitch2 = Pitch1 * 1.2
	
	local boost = math.Clamp( (self.SmoothBlower / 600) ^ 4 ,0,1)
	
	self.Blower:ChangeVolume( Volume1 )
	self.Blower:ChangePitch( Pitch1 )
	
	self.BlowerWhine:ChangeVolume( Volume2 )
	self.BlowerWhine:ChangePitch( Pitch2 )
	
	return boost
end

function ENT:OnTurboCharged( name, old, new )
	if ( old == new ) then return end
	local Active = self:GetActive()
	
	if (new == true and Active) then
		self.Turbo:Stop()
		self.Turbo = CreateSound(self, self.snd_spool or "simulated_vehicles/turbo_spin.wav")
		self.Turbo:PlayEx(0,0)
	elseif (new == false) then
		if (self.Turbo) then
			self.Turbo:Stop()
		end
	end
end

function ENT:OnSuperCharged( name, old, new )
	if ( old == new ) then return end
	local Active = self:GetActive()
	
	if (new == true and Active) then
		self.Blower:Stop()
		self.BlowerWhine:Stop()
		
		self.Blower = CreateSound(self, self.snd_bloweroff or "simulated_vehicles/blower_spin.wav")
		self.BlowerWhine = CreateSound(self, self.snd_bloweron or "simulated_vehicles/blower_gearwhine.wav")
	
		self.Blower:PlayEx(0,0)
		self.BlowerWhine:PlayEx(0,0)
	elseif (new == false) then
		if (self.Blower) then
			self.Blower:Stop()
		end
		if (self.BlowerWhine) then
			self.BlowerWhine:Stop()
		end
	end
end

function ENT:OnRemove()
	if (self.Wheels) then
		for i = 1, table.Count( self.Wheels ) do
			local Ent = self.Wheels[ i ]
			if (IsValid(Ent)) then
				Ent:Remove()
			end
		end
	end
	if (self.keys) then
		for i = 1, table.Count( self.keys ) do
			numpad.Remove( self.keys[i] )
		end
	end
	if (self.Turbo) then
		self.Turbo:Stop()
	end
	if (self.Blower) then
		self.Blower:Stop()
	end
	if (self.BlowerWhine) then
		self.BlowerWhine:Stop()
	end
	if (self.horn) then
		self.horn:Stop()
	end
	if (self.ems) then
		self.ems:Stop()
	end
end

numpad.Register( "k_forward", function( pl, ent, keydown )
	if (!IsValid(pl) or !IsValid(ent)) then return false end
	if (ent.PressedKeys) then
		ent.PressedKeys["W"] = keydown
	end
	if (keydown and ent:GetIsCruiseModeOn()) then
		ent:SetIsCruiseModeOn( false )
	end
end )
numpad.Register( "k_reverse", function( pl, ent, keydown ) 
	if (!IsValid(pl) or !IsValid(ent)) then return false end
	if (ent.PressedKeys) then
		ent.PressedKeys["S"] = keydown
	end
	if (keydown and ent:GetIsCruiseModeOn()) then
		ent:SetIsCruiseModeOn( false )
	end
end )
numpad.Register( "k_left", function( pl, ent, keydown ) 
	if (!IsValid(pl) or !IsValid(ent)) then return false end
	if (ent.PressedKeys) then
		ent.PressedKeys["A"] = keydown
	end
end )
numpad.Register( "k_right", function( pl, ent, keydown )
	if (!IsValid(pl) or !IsValid(ent)) then return false end
	if (ent.PressedKeys) then
		ent.PressedKeys["D"] = keydown
	end
end )
numpad.Register( "k_a_forward", function( pl, ent, keydown )
	if (!IsValid(pl) or !IsValid(ent)) then return false end
	if (ent.PressedKeys) then
		ent.PressedKeys["aW"] = keydown
	end
end )
numpad.Register( "k_a_reverse", function( pl, ent, keydown ) 
	if (!IsValid(pl) or !IsValid(ent)) then return false end
	if (ent.PressedKeys) then
		ent.PressedKeys["aS"] = keydown
	end
end )
numpad.Register( "k_a_left", function( pl, ent, keydown ) 
	if (!IsValid(pl) or !IsValid(ent)) then return false end
	if (ent.PressedKeys) then
		ent.PressedKeys["aA"] = keydown
	end
end )
numpad.Register( "k_a_right", function( pl, ent, keydown )
	if (!IsValid(pl) or !IsValid(ent)) then return false end
	if (ent.PressedKeys) then
		ent.PressedKeys["aD"] = keydown
	end
end )
numpad.Register( "k_gup", function( pl, ent, keydown )
	if (!IsValid(pl) or !IsValid(ent)) then return false end
	if (ent.PressedKeys) then
		ent.PressedKeys["M1"] = keydown
	end
	if (keydown and ent:GetIsCruiseModeOn()) then
		ent:SetIsCruiseModeOn( false )
	end
end )
numpad.Register( "k_gdn", function( pl, ent, keydown )
	if (!IsValid(pl) or !IsValid(ent)) then return false end
	if (ent.PressedKeys) then
		ent.PressedKeys["M2"] = keydown
	end
	if (keydown and ent:GetIsCruiseModeOn()) then
		ent:SetIsCruiseModeOn( false )
	end
end )
numpad.Register( "k_wot", function( pl, ent, keydown )
	if (!IsValid(pl) or !IsValid(ent)) then return false end
	if (ent.PressedKeys) then
		ent.PressedKeys["Shift"] = keydown
	end
end )
numpad.Register( "k_clutch", function( pl, ent, keydown )
	if (!IsValid(pl) or !IsValid(ent)) then return false end
	if (ent.PressedKeys) then
		ent.PressedKeys["Alt"] = keydown
	end
end )
numpad.Register( "k_hbrk", function( pl, ent, keydown )
	if (!IsValid(pl) or !IsValid(ent)) then return false end
	if (ent.PressedKeys) then
		ent.PressedKeys["Space"] = keydown
	end
	if (keydown and ent:GetIsCruiseModeOn()) then
		ent:SetIsCruiseModeOn( false )
	end
end )

numpad.Register( "k_ccon", function( pl, ent, keydown )
	if (!IsValid(pl) or !IsValid(ent)) then return false end
	if (keydown) then
		if ent:GetIsCruiseModeOn() then
			ent:SetIsCruiseModeOn( false )
		else
			ent:SetIsCruiseModeOn( true )
			ent.cc_speed = math.Round(ent:GetVelocity():Length(),0)
		end
	end
end )

numpad.Register( "k_frk", function( pl, ent, keydown )
	if (!IsValid(pl) or !IsValid(ent)) then return false end
	ent:SetFreelook( keydown )
end )

numpad.Register( "k_hrn", function( pl, ent, keydown )
	if (!IsValid(pl) or !IsValid(ent)) then return false end
	
	local v_list = list.Get( "simfphys_lights" )[ent.LightsTable] or false
	
	if (keydown) then
		ent.HornKeyIsDown = true
		if (v_list and v_list.ems_sounds and !ent.LightsDisabled) then
			if (!ent.emson) then
				timer.Simple( 0.1, function()
					if (!IsValid(ent) or !ent.HornKeyIsDown) then return end
					ent.horn = CreateSound(ent, ent.snd_horn or "simulated_vehicles/horn_1.wav")
					ent.horn:Play()
				end)
			end
		else
			ent.horn = CreateSound(ent, ent.snd_horn or "simulated_vehicles/horn_1.wav")
			ent.horn:Play()
		end
	else
		ent.HornKeyIsDown = false
		if (ent.horn) then
			ent.horn:Stop()
		end
	end
	
	if ent.LightsDisabled then return end
	
	if (!v_list) then return end
	
	if (v_list.ems_sounds) then
		
		local Time = CurTime()

		if (keydown) then
			ent.KeyPressedTime = Time
		else
			if ((Time - ent.KeyPressedTime) < 0.15) then
				if (!ent.emson) then
					ent.emson = true
					ent.cursound = 0
				end
			end
			
			if ((Time - ent.KeyPressedTime) >= 0.22) then
				if (ent.emson) then
					ent.emson = false
					if (ent.ems) then
						ent.ems:Stop()
					end
				end
			else
				if (ent.emson) then
					if (ent.ems) then ent.ems:Stop() end
					local sounds = v_list.ems_sounds
					local numsounds = table.Count( sounds )
					
					if (numsounds <= 1 and ent.ems) then
						ent.emson = false
						ent.ems = nil
						ent:SetEMSEnabled( false )
						return
					end
					
					ent.cursound = ent.cursound + 1
					if (ent.cursound > table.Count( sounds )) then
						ent.cursound = 1
					end
					
					ent.ems = CreateSound(ent, sounds[ent.cursound])
					ent.ems:Play()
				end
			end
			ent:SetEMSEnabled( ent.emson )
		end
	end
end)

numpad.Register( "k_eng", function( pl, ent, keydown )
	if (!IsValid(pl) or !IsValid(ent)) then return false end
	
	if (keydown) then
		if (ent.EngineIsOn == 1) then
			ent.EngineIsOn = 0
			ent.EngineRPM = 0
			ent:SetFlyWheelRPM( 0 )
			
			ent:EmitSound( "vehicles/jetski/jetski_off.wav" )
		elseif (ent.EngineIsOn == 0 and !ent.IsInWater or (ent:GetDoNotStall() == true)) then
			ent.EngineIsOn = 1
			ent.EngineRPM = ent:GetIdleRPM()
			ent:SetFlyWheelRPM( ent:GetIdleRPM() )
		end
	end
end)

numpad.Register( "k_lock", function( pl, ent, keydown )
	if (!IsValid(pl) or !IsValid(ent)) then return false end
	if (keydown) then
		if (ent.IsLocked) then
			ent.IsLocked = false
			ent:EmitSound( "doors/latchunlocked1.wav" )
		else
			ent.IsLocked = true
			ent:EmitSound( "doors/latchlocked2.wav" )
		end
	end
end )

numpad.Register( "k_flgts", function( pl, ent, keydown )
	if (!IsValid(pl) or !IsValid(ent) or !ent.LightsTable) then return false end
	if (keydown) then
		ent:EmitSound( "buttons/lightswitch2.wav" )
		
		if (ent:GetFogLightsEnabled()) then
			ent:SetFogLightsEnabled( false )
		else
			ent:SetFogLightsEnabled( true )
		end
	end
end)

numpad.Register( "k_lgts", function( pl, ent, keydown )
	if (!IsValid(pl) or !IsValid(ent) or !ent.LightsTable or ent.LightsDisabled) then return false end
	local Time = CurTime()
	
	if (keydown) then
		ent.KeyPressedTime = Time
	else
		if ((Time - ent.KeyPressedTime) >= (ent.LightsActivated and 0.22 or 0)) then
			if ((ent.NextLightCheck or 0) > Time) then return end
			
			local vehiclelist = list.Get( "simfphys_lights" )[ent.LightsTable] or false
			if (!vehiclelist) then return end
			
			if (ent.LightsActivated) then
				ent.NextLightCheck = Time + (vehiclelist.DelayOff or 0)
				ent.LightsActivated = false
				ent:SetLightsEnabled(false)
				ent:EmitSound( "buttons/lightswitch2.wav" )
				ent.LampsActivated = false
				ent:SetLampsEnabled( ent.LampsActivated )
			else
				ent.NextLightCheck = Time + (vehiclelist.DelayOn or 0)
				ent.LightsActivated = true
				ent:EmitSound( "buttons/lightswitch2.wav" )
			end
			
			if (ent.LightsActivated) then
				if (vehiclelist.BodyGroups) then
					ent:SetBodygroup(vehiclelist.BodyGroups.On[1], vehiclelist.BodyGroups.On[2] )
				end
				if (vehiclelist.Animation) then
					ent:PlayAnimation( vehiclelist.Animation.On )
				end
				if (ent.LightsPP) then
					ent:PlayPP(ent.LightsActivated)
				end
			else
				if (vehiclelist.BodyGroups) then
					ent:SetBodygroup(vehiclelist.BodyGroups.Off[1], vehiclelist.BodyGroups.Off[2] )
				end
				if (vehiclelist.Animation) then
					ent:PlayAnimation( vehiclelist.Animation.Off )
				end
				if (ent.LightsPP) then
					ent:PlayPP(ent.LightsActivated)
				end
			end
		else
			if ((ent.NextLightCheck or 0) > Time) then return end
			
			if (ent.LampsActivated) then
				ent.LampsActivated = false
			else
				ent.LampsActivated = true
			end
			
			ent:SetLampsEnabled( ent.LampsActivated )
			
			ent:EmitSound( "items/flashlight1.wav" )
		end
	end
end )

function ENT:PlayPP( On )
	self.poseon = On and self.LightsPP.max or self.LightsPP.min
end

function ENT:DisableLights()
	self:SetNWBool( "lights_disabled", true)
	self.LightsDisabled = true
	
	if (self.ems) then
		self.ems:Stop()
		self.ems = nil
	end
end

function ENT:GetEnginePos()
	local Attachment = self:GetAttachment( self:LookupAttachment( "vehicle_engine" ) )
	local pos = self:GetPos()
	if Attachment then
		pos = Attachment.Pos
	end
	if isvector(self.EnginePos) then
		pos = self:LocalToWorld( self.EnginePos )
	end
	
	return pos
end

function ENT:DamageLoop()
	if !self.IamOnFire then return end
	
	local CurHealth = self:GetNWFloat( "Health", 0 )
	
	if CurHealth <= 0 then return end
	
	self:TakeDamage(1, Entity(0), Entity(0) )
	
	timer.Simple( 0.15, function()
		if IsValid(self) then
			self:DamageLoop()
		end
	end)
end

function ENT:SetOnFire( bOn )
	if bOn == self.IamOnFire then return end
	self.IamOnFire = bOn
	
	if bOn then
		if !IsValid(self.EngineFire) then
			local pos = self:GetEnginePos()
			local ang = isvector(self.Forward) and self.Forward:Angle() or Angle(0,0,0)
		
			self.EngineFire = ents.Create( "info_particle_system" )
			self.EngineFire:SetKeyValue( "effect_name" , "burning_engine_01")
			self.EngineFire:SetKeyValue( "start_active" , 1)
			self.EngineFire:SetOwner( self )
			self.EngineFire:SetPos( pos )
			self.EngineFire:SetAngles( ang )
			self.EngineFire:Spawn()
			self.EngineFire:Activate()
			self.EngineFire:SetParent( self )
			self.EngineFire.DoNotDuplicate = true
			self.EngineFire:EmitSound( "ambient/fire/mtov_flame2.wav" )
			
			self:s_MakeOwner( self.EngineFire )
			
			self.EngineFire.snd = CreateSound(self, "ambient/fire/fire_small1.wav")
			self.EngineFire.snd:Play()
			
			self.EngineFire:CallOnRemove( "stopdemfiresounds", function( vehicle )
				if IsValid(self.EngineFire) then
					if self.EngineFire.snd then
						self.EngineFire.snd:Stop()
					end
				end
			end)
			
			self:DamagedStall()
			self:DamageLoop()
		end
	else
		if IsValid(self.EngineFire) then
			if self.EngineFire.snd then
				self.EngineFire.snd:Stop()
			end
			self.EngineFire:Remove()
			self.EngineFire = nil
		end
	end
end

function ENT:SetOnSmoke( bOn )
	if bOn == self.IamOnSmoke then return end
	self.IamOnSmoke = bOn
	
	if bOn then
		if !IsValid(self.EngineSmoke) then
			local pos = self:GetEnginePos()
			local ang = isvector(self.Forward) and self.Forward:Angle() or Angle(0,0,0)
			
			self.EngineSmoke = ents.Create( "info_particle_system" )
			self.EngineSmoke:SetKeyValue( "effect_name" , "smoke_gib_01")
			self.EngineSmoke:SetKeyValue( "start_active" , 1)
			self.EngineSmoke:SetOwner( self )
			self.EngineSmoke:SetPos( pos )
			self.EngineSmoke:SetAngles( ang )
			self.EngineSmoke:Spawn()
			self.EngineSmoke:Activate()
			self.EngineSmoke:SetParent( self )
			self.EngineSmoke.DoNotDuplicate = true
			self:s_MakeOwner( self.EngineSmoke )
			
			self.EngineSmoke.snd = CreateSound(self, "ambient/gas/steam2.wav")
			self.EngineSmoke.snd:PlayEx(0.2,90)
			
			self.EngineSmoke:CallOnRemove( "stopdemsmokesounds", function( vehicle )
				if IsValid(self.EngineSmoke) then
					if self.EngineSmoke.snd then
						self.EngineSmoke.snd:Stop()
					end
				end
			end)
			
			self:DamagedStall()
		end
	else
		if IsValid(self.EngineSmoke) then
			if self.EngineSmoke.snd then
				self.EngineSmoke.snd:Stop()
			end
			self.EngineSmoke:Remove()
			self.EngineSmoke = nil
		end
	end
end

function ENT:s_MakeOwner( entity )
	if CPPI then
		if (IsValid( self.EntityOwner )) then
			entity:CPPISetOwner( self.EntityOwner )
		end
	end
end
