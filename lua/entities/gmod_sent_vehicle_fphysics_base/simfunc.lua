function ENT:WheelOnGround()
	self.FrontWheelPowered = self:GetPowerDistribution() ~= 1
	self.RearWheelPowered = self:GetPowerDistribution() ~= -1
	
	for i = 1, table.Count( self.Wheels ) do
		local Wheel = self.Wheels[i]		
		if IsValid(Wheel) then
			local dmgMul = Wheel:GetDamaged() and 0.5 or 1
			local surfacemul = simfphys.TractionData[Wheel:GetSurfaceMaterial():lower()]
			
			self.VehicleData[ "SurfaceMul_" .. i ] = (surfacemul and math.max(surfacemul,0.001) or 1) * dmgMul
			
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
			if tr.Hit then
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
	
	local FrontOnGround = math.max(self.VehicleData[ "onGround_1" ],self.VehicleData[ "onGround_2" ])
	local RearOnGround = math.max(self.VehicleData[ "onGround_3" ],self.VehicleData[ "onGround_4" ])
	
	self.DriveWheelsOnGround = math.max(self.FrontWheelPowered and FrontOnGround or 0,self.RearWheelPowered and RearOnGround or 0)
end

function ENT:SimulateAirControls(tilt_forward,tilt_back,tilt_left,tilt_right)
	if self:IsDriveWheelsOnGround() then return end
	
	local PObj = self:GetPhysicsObject()
	
	local TiltForce = ((self.Right * (tilt_right - tilt_left) * 1.8) + (self.Forward * (tilt_forward - tilt_back) * 6)) * math.acos( math.Clamp( self.Up:Dot(Vector(0,0,1)) ,-1,1) ) * (180 / math.pi) * self.Mass
	PObj:ApplyForceOffset( TiltForce, PObj:GetMassCenter() + self.Up )
	PObj:ApplyForceOffset( -TiltForce, PObj:GetMassCenter() - self.Up )
end

function ENT:SimulateEngine(IdleRPM,LimitRPM,Powerbandstart,Powerbandend,c_time)
	local PObj = self:GetPhysicsObject()

	local Throttle = self:GetThrottle()
	
	if not self:IsDriveWheelsOnGround() then
		self.Clutch = 1
	end
	
	if self.Gears[self.CurrentGear] == 0 then
		self.GearRatio = 1
		self.Clutch = 1
		self.HandBrake = self.HandBrakePower
	else
		self.GearRatio = self.Gears[self.CurrentGear] * self:GetDiffGear()
	end
	
	self:SetClutch( self.Clutch )
	local InvClutch = 1 - self.Clutch
	
	local GearedRPM = self.WheelRPM / math.abs(self.GearRatio)
	
	local MaxTorque = self:GetMaxTorque()
	
	local DesRPM = Lerp(InvClutch, math.max(IdleRPM + (LimitRPM - IdleRPM) * Throttle,0), GearedRPM )
	local Drag = (MaxTorque * (math.max( self.EngineRPM - IdleRPM, 0) / Powerbandend) * ( 1 - Throttle) / 0.15) * InvClutch
	
	local TurboCharged = self:GetTurboCharged()
	local SuperCharged = self:GetSuperCharged()
	local boost = (TurboCharged and self:SimulateTurbo(LimitRPM) or 0) * 0.3 + (SuperCharged and self:SimulateBlower(LimitRPM) or 0)
	
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
	
	if not self:GetDoNotStall() then
		if self:EngineActive() then
			if self.EngineRPM <= IdleRPM * 0.2 then
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
end

function ENT:SimulateTransmission(k_throttle,k_brake,k_fullthrottle,k_clutch,k_handbrake,k_gearup,k_geardown,isauto,IdleRPM,Powerbandstart,Powerbandend,shiftmode,cruisecontrol,curtime)
	local GearsCount = table.Count( self.Gears ) 
	local cruiseThrottle = math.min( math.max(self.cc_speed - math.abs(self.ForwardSpeed),0) / 10 ^ 2, 1)
	
	if isnumber(self.ForceTransmission) then
		isauto = self.ForceTransmission <= 1
	end
	
	if not isauto then
		self.Brake = self:GetBrakePower() * k_brake
		self.HandBrake = self.HandBrakePower * k_handbrake
		self.Clutch = math.max(k_clutch,k_handbrake)
		
		local AutoThrottle = self:EngineActive() and ((self.EngineRPM < IdleRPM) and (IdleRPM - self.EngineRPM) / IdleRPM or 0) or 0
		local Throttle = cruisecontrol and cruiseThrottle or ((0.5 + 0.5 * k_fullthrottle) * k_throttle + AutoThrottle)
		self:SetThrottle( Throttle )
		
		if k_gearup ~= self.GearUpPressed then
			self.GearUpPressed = k_gearup
			
			if k_gearup == 1 then
				
				if self.CurrentGear ~= GearsCount then
					self.ThrottleDelay = curtime + 0.4 - 0.4 * k_clutch
				end
				
				self.CurrentGear = math.Clamp(self.CurrentGear + 1,1,GearsCount)
			end
		end
		
		if k_geardown ~= self.GearDownPressed then
			self.GearDownPressed = k_geardown
			
			if k_geardown == 1 then
				
				self.CurrentGear = math.Clamp(self.CurrentGear - 1,1,GearsCount)
				
				if self.CurrentGear == 1 then 
					self.ThrottleDelay = curtime + 0.25
				end
			end
		end
	else 
		local Throttle = cruisecontrol and cruiseThrottle or ((0.5 + 0.5 * k_fullthrottle) * (self.ForwardSpeed >= 50 and k_throttle or (self.ForwardSpeed < 50 and self.ForwardSpeed > -350) and math.max(k_throttle,k_brake) or (self.ForwardSpeed <= -350 and k_brake)))
		local CalcRPM = self.EngineRPM - self.RPM_DIFFERENCE * Throttle
		self:SetThrottle( Throttle )
		
		if self.CurrentGear <= 3 and Throttle > 0 and self.CurrentGear ~= 2 then
			if Throttle < 1 and not cruisecontrol then
				local autoclutch = math.Clamp((Powerbandstart / self.EngineRPM) - 0.5,0,1)
				
				self.sm_autoclutch = self.sm_autoclutch and (self.sm_autoclutch + math.Clamp(autoclutch - self.sm_autoclutch,-0.2,0.1) ) or 0
			else
				self.sm_autoclutch = (self.EngineRPM < IdleRPM + (Powerbandstart - IdleRPM)) and 1 or 0
			end
		else
			self.sm_autoclutch = 0
		end
		
		self.Clutch = math.max(self.sm_autoclutch,k_handbrake)

		self.HandBrake = self.HandBrakePower * k_handbrake
		
		self.Brake = self:GetBrakePower() * (self.ForwardSpeed >= 0 and k_brake or k_throttle)
		
		if self:IsDriveWheelsOnGround() then
			if self.ForwardSpeed >= 50 then	
				if self.Clutch == 0 then
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
					
					if CanShiftUp and self.NextShift < curtime then
						self.CurrentGear = self.CurrentGear + 1
						self.NextShift = curtime + 0.5
						self.ThrottleDelay = curtime + 0.25
					end
					
					if CanShiftDown and self.NextShift < curtime then
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
	
	if self.Clutch == 1 or self.CurrentGear == 2 then
		if math.abs(self.ForwardSpeed) <= 20 then
		
			local PObj = self:GetPhysicsObject()
			local TiltForce = self.Torque * (-1 + self:GetThrottle() * 2)
			
			PObj:ApplyForceOffset( self.Up * TiltForce, PObj:GetMassCenter() + self.Right * 1000 ) 
			PObj:ApplyForceOffset( -self.Up * TiltForce, PObj:GetMassCenter() - self.Right * 1000)
		end
	end
end

function ENT:SimulateWheels(k_clutch,LimitRPM)
	local SteerAngForward = self.Forward:Angle()
	local SteerAngRight = self.Right:Angle()
	local SteerAngForward2 = self.Forward:Angle()
	local SteerAngRight2 = self.Right:Angle()
	
	SteerAngForward:RotateAroundAxis(-self.Up, self.VehicleData[ "Steer" ]) 
	SteerAngRight:RotateAroundAxis(-self.Up, self.VehicleData[ "Steer" ]) 
	SteerAngForward2:RotateAroundAxis(-self.Up, -self.VehicleData[ "Steer" ]) 
	SteerAngRight2:RotateAroundAxis(-self.Up, -self.VehicleData[ "Steer" ]) 
	
	local SteerForward = SteerAngForward:Forward()
	local SteerRight = SteerAngRight:Forward()
	local SteerForward2 = SteerAngForward2:Forward()
	local SteerRight2 = SteerAngRight2:Forward()
	
	for i = 1, table.Count( self.Wheels ) do
		local Wheel = self.Wheels[i]
		
		if IsValid(Wheel) then
			local MaxGrip = self:GetMaxTraction()
			local GripOffset = self:GetTractionBias() * MaxGrip
			local IsFrontWheel = i == 1 or i == 2
			local IsRightWheel = i == 2 or i == 4 or i == 6
			local WheelRadius = IsFrontWheel and self.FrontWheelRadius or self.RearWheelRadius
			local WheelDiameter = WheelRadius * 2
			local SurfaceMultiplicator = self.VehicleData[ "SurfaceMul_" .. i ]
			local MaxTraction = (IsFrontWheel and (MaxGrip + GripOffset) or  (MaxGrip - GripOffset)) * SurfaceMultiplicator
			local Efficiency = self:GetEfficiency()
			
			local IsPoweredWheel = (IsFrontWheel and self.FrontWheelPowered or not IsFrontWheel and self.RearWheelPowered) and 1 or 0
			
			local Velocity = Wheel:GetVelocity()
			local VelForward = Velocity:GetNormalized()
			local OnGround = self.VehicleData[ "onGround_" .. i ]
			
			local Forward = IsFrontWheel and SteerForward or self.Forward
			local Right = IsFrontWheel and SteerRight or self.Right
			
			if self.CustomWheels then
				if IsFrontWheel then
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
			
			local ForwardForce = self.EngineTorque * PowerBiasMul * IsPoweredWheel + (not IsFrontWheel and math.Clamp(-Fx,-self.HandBrake,self.HandBrake) or 0)
			
			local TractionCycle = Vector(math.min(absFy,MaxTraction),ForwardForce,0):Length()
			local GripLoss = math.max(TractionCycle - MaxTraction,0)
			local GripRemaining = math.max(MaxTraction - GripLoss,math.min(absFy / 25,MaxTraction / 2))
			
			local signForwardForce = ((ForwardForce > 0) and 1 or 0) + ((ForwardForce < 0) and -1 or 0)
			local signEngineTorque = ((self.EngineTorque > 0) and 1 or 0) + ((self.EngineTorque < 0) and -1 or 0)
			local BrakeForce = math.Clamp(-Fx,-self.Brake,self.Brake) * SurfaceMultiplicator
			
			local Power = ForwardForce * Efficiency - GripLoss * signForwardForce + BrakeForce
			
			local Force = -Right * math.Clamp(Fy,-GripRemaining,GripRemaining) + Forward * Power
			
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
			
			if IsFrontWheel then
				self.VehicleData[ "spin_" .. i ] = self.VehicleData[ "spin_" .. i ] + TurnWheel
			else
				if self.HandBrake < MaxTraction then
					self.VehicleData[ "spin_" .. i ] = self.VehicleData[ "spin_" .. i ] + TurnWheel
				end
			end
			
			if self.CustomWheels then
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
			
			if not self.PhysicsEnabled then
				Wheel:GetPhysicsObject():ApplyForceCenter( Force * 185 * OnGround )
			end
		end
	end
	
	local target_diff = math.max(LimitRPM * 0.95 - self.EngineRPM,0)
	
	if self.FrontWheelPowered and self.RearWheelPowered then
		self.WheelRPM = math.max(self.VehicleData[ "WheelRPM_1" ] or 0,self.VehicleData[ "WheelRPM_2" ] or 0,self.VehicleData[ "WheelRPM_3" ] or 0,self.VehicleData[ "WheelRPM_4" ] or 0)
		self.RPM_DIFFERENCE = target_diff * math.max(self.VehicleData[ "GripLossFaktor_1" ] or 0,self.VehicleData[ "GripLossFaktor_2" ] or 0,self.VehicleData[ "GripLossFaktor_3" ] or 0,self.VehicleData[ "GripLossFaktor_4" ] or 0)
		self.exprpmdiff = target_diff * math.max(self.VehicleData[ "Exp_GLF_1" ] or 0,self.VehicleData[ "Exp_GLF_2" ] or 0,self.VehicleData[ "Exp_GLF_3" ] or 0,self.VehicleData[ "Exp_GLF_4" ] or 0)
		
	elseif not self.FrontWheelPowered and self.RearWheelPowered then
		self.WheelRPM = math.max(self.VehicleData[ "WheelRPM_3" ] or 0,self.VehicleData[ "WheelRPM_4" ] or 0)
		self.RPM_DIFFERENCE = target_diff * math.max(self.VehicleData[ "GripLossFaktor_3" ] or 0,self.VehicleData[ "GripLossFaktor_4" ] or 0)
		self.exprpmdiff = target_diff * math.max(self.VehicleData[ "Exp_GLF_3" ] or 0,self.VehicleData[ "Exp_GLF_4" ] or 0)
		
	elseif self.FrontWheelPowered and not self.RearWheelPowered then
		self.WheelRPM = math.max(self.VehicleData[ "WheelRPM_1" ] or 0,self.VehicleData[ "WheelRPM_2" ] or 0)
		self.RPM_DIFFERENCE = target_diff * math.max(self.VehicleData[ "GripLossFaktor_1" ] or 0,self.VehicleData[ "GripLossFaktor_2" ] or 0)
		self.exprpmdiff = target_diff * math.max(self.VehicleData[ "Exp_GLF_1" ] or 0,self.VehicleData[ "Exp_GLF_2" ] or 0)
		
	else 
		self.WheelRPM = 0
		self.RPM_DIFFERENCE = 0
		self.exprpmdiff = 0
	end	
end

function ENT:SimulateTurbo(LimitRPM)
	if not self.Turbo then return end
	
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
	if not self.Blower or not self.BlowerWhine then return end
	
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