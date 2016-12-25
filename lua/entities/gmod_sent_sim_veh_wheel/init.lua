AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include('shared.lua')

function ENT:Initialize()	
	self:SetModel( "models/props_vehicles/tire001c_car.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON  ) 
	
	self:DrawShadow( false )

	self.OldMaterial = ""
	self.OldMaterial2 = ""
	self.OldVar = 0
	self.OldVar2 = 0
	
	local Color = self:GetColor()
	local dot = Color.r * Color.g * Color.b * Color.a
	self.OldColor = dot
	
	timer.Simple( 0.01, function()
		if (!IsValid(self)) then return end
		
		self.WheelDust = ents.Create( "info_particle_system" )
		self.WheelDust:SetKeyValue( "effect_name" , "WheelDust")
		self.WheelDust:SetKeyValue( "start_active" , 0)
		self.WheelDust:SetOwner( self )
		self.WheelDust:SetPos( self:GetPos() + Vector(0,0,-self:BoundingRadius() * 0.4) )
		self.WheelDust:SetAngles( self:GetAngles() )
		self.WheelDust:Spawn()
		self.WheelDust:Activate()
		self.WheelDust:SetParent( self )
		self.WheelDust.DoNotDuplicate = true
		self:s_MakeOwner( self.WheelDust )
	end)
	
	self.snd_roll = "simulated_vehicles/sfx/concrete_roll.wav"
	self.snd_roll_dirt = "simulated_vehicles/sfx/dirt_roll.wav"
	self.snd_roll_grass = "simulated_vehicles/sfx/grass_roll.wav"
	
	self.snd_skid = "simulated_vehicles/sfx/concrete_skid.wav"
	self.snd_skid_dirt = "simulated_vehicles/sfx/dirt_skid.wav"
	self.snd_skid_grass = "simulated_vehicles/sfx/grass_skid.wav"
	
	self.RollSound = CreateSound(self, self.snd_roll)
	self.RollSound_Dirt = CreateSound(self, self.snd_roll_dirt)
	self.RollSound_Grass = CreateSound(self, self.snd_roll_grass)
	
	self.Skid = CreateSound(self, self.snd_skid)
	self.Skid_Dirt = CreateSound(self, self.snd_skid_dirt)
	self.Skid_Grass = CreateSound(self, self.snd_skid_grass)
end

function ENT:Think()	
	local ForwardSpeed = math.abs( self:GetSpeed() )
	local SkidSound = math.Clamp( self:GetSkidSound(),0,255)
	local Speed = self:GetVelocity():Length()
	local WheelOnGround = self:GetOnGround()
	local EnableDust = (Speed * WheelOnGround > 200)	
	local Material = self:GetSurfaceMaterial()
	local GripLoss = self:GetGripLoss()
	
	if (self.GhostEnt) then
		local Color = self:GetColor()
		local dot = Color.r * Color.g * Color.b * Color.a
		if (dot != self.OldColor) then
			if (IsValid(self.GhostEnt)) then
				self.GhostEnt:SetColor( Color )
				self.GhostEnt:SetRenderMode( self:GetRenderMode() )
			end
			self.OldColor = dot
		end
	end
	
	if (EnableDust != self.OldVar) then
		self.OldVar = EnableDust
		if (EnableDust) then
			if (Material == "grass") then
				if (IsValid(self.WheelDust)) then
					self.WheelDust:Fire( "Start" )
				end
				self.RollSound_Grass = CreateSound(self, self.snd_roll_grass)
				self.RollSound_Grass:PlayEx(0,0)
				self.RollSound_Dirt:Stop()
				self.RollSound:Stop()
			elseif (Material == "dirt" or Material == "sand") then
				if (IsValid(self.WheelDust)) then
					self.WheelDust:Fire( "Start" )
				end
				self.RollSound_Dirt = CreateSound(self, self.snd_roll_dirt)
				self.RollSound_Dirt:PlayEx(0,0)
				self.RollSound_Grass:Stop()
				self.RollSound:Stop()
			else
				self.RollSound_Grass:Stop()
				self.RollSound_Dirt:Stop()
				self.RollSound = CreateSound(self, self.snd_roll)
				self.RollSound:PlayEx(0,0)
			end
		else
			if (IsValid(self.WheelDust)) then
				self.WheelDust:Fire( "Stop" )
			end
			self.RollSound:Stop()
			self.RollSound_Grass:Stop()
			self.RollSound_Dirt:Stop()
		end
	end
	
	if (EnableDust) then 
		if (Material != self.OldMaterial) then
			if (Material == "grass") then
				if (IsValid(self.WheelDust)) then
					self.WheelDust:Fire( "Start" )
				end
				self.RollSound_Grass = CreateSound(self, self.snd_roll_grass)
				self.RollSound_Grass:PlayEx(0,0)
				self.RollSound_Dirt:Stop()
				self.RollSound:Stop()
				
			elseif (Material == "dirt" or Material == "sand") then
				if (IsValid(self.WheelDust)) then
					self.WheelDust:Fire( "Start" )
				end
				self.RollSound_Grass:Stop()
				self.RollSound_Dirt = CreateSound(self, self.snd_roll_dirt)
				self.RollSound_Dirt:PlayEx(0,0)
				self.RollSound:Stop()
			else
				if (IsValid(self.WheelDust)) then
					self.WheelDust:Fire( "Stop" )
				end
				self.RollSound_Grass:Stop()
				self.RollSound_Dirt:Stop()
				self.RollSound = CreateSound(self, self.snd_roll)
				self.RollSound:PlayEx(0,0)
			end
			self.OldMaterial = Material
		end
		
		if (Material == "grass") then
			self.RollSound_Grass:ChangeVolume(math.Clamp((ForwardSpeed - 100) / 1600,0,1), 0) 
			self.RollSound_Grass:ChangePitch(80 + math.Clamp((ForwardSpeed - 100) / 250,0,255), 0) 
		elseif (Material == "dirt" or Material == "sand") then
			self.RollSound_Dirt:ChangeVolume(math.Clamp((ForwardSpeed - 100) / 1600,0,1), 0) 
			self.RollSound_Dirt:ChangePitch(80 + math.Clamp((ForwardSpeed - 100) / 250,0,255), 0) 
		else
			self.RollSound:ChangeVolume(math.Clamp((ForwardSpeed - 100) / 1500,0,1), 0) 
			self.RollSound:ChangePitch(100 + math.Clamp((ForwardSpeed - 400) / 200,0,255), 0) 
		end
	end
	
	
	if (WheelOnGround != self.OldVar2) then
		self.OldVar2 = WheelOnGround
		if (WheelOnGround == 1) then
			if (Material == "grass" or Material == "snow") then
				self.Skid:Stop()
				self.Skid_Grass = CreateSound(self, self.snd_skid_grass)
				self.Skid_Grass:PlayEx(0,0)
				self.Skid_Dirt:Stop()
			elseif (Material == "dirt" or Material == "sand") then
				self.Skid_Grass:Stop()
				self.Skid_Dirt = CreateSound(self, self.snd_skid_dirt)
				self.Skid_Dirt:PlayEx(0,0)
				self.Skid:Stop()
			elseif (Material == "ice") then
				self.Skid_Grass:Stop()
				self.Skid_Dirt:Stop()
				self.Skid:Stop()
			else
				self.Skid = CreateSound(self, self.snd_skid)
				self.Skid:PlayEx(0,0)
				self.Skid_Grass:Stop()
				self.Skid_Dirt:Stop()
			end
		else
			self.Skid:Stop()
			self.Skid_Grass:Stop()
			self.Skid_Dirt:Stop()
		end
	end
	
	if (WheelOnGround == 1) then 
		if (Material != self.OldMaterial2) then
			if (Material == "grass" or Material == "snow") then
				self.Skid:Stop()
				self.Skid_Grass = CreateSound(self, self.snd_skid_grass)
				self.Skid_Grass:PlayEx(0,0)
				self.Skid_Dirt:Stop()
				
			elseif (Material == "dirt" or Material == "sand") then
				self.Skid:Stop()
				self.Skid_Grass:Stop()
				self.Skid_Dirt = CreateSound(self, self.snd_skid_dirt)
				self.Skid_Dirt:PlayEx(0,0)
			elseif (Material == "ice") then
				self.Skid_Grass:Stop()
				self.Skid_Dirt:Stop()
				self.Skid:Stop()
			else
				self.Skid = CreateSound(self, self.snd_skid)
				self.Skid:PlayEx(0,0)
				self.Skid_Grass:Stop()
				self.Skid_Dirt:Stop()
			end
			self.OldMaterial2 = Material
		end
		
		if (Material == "grass" or Material == "snow") then
			self.Skid_Grass:ChangeVolume( math.Clamp(SkidSound,0,1) ) 
			self.Skid_Grass:ChangePitch(math.min(90 + (SkidSound * Speed / 500),150)) 
		elseif (Material == "dirt" or Material == "sand") then
			self.Skid_Dirt:ChangeVolume( math.Clamp(SkidSound,0,1) * 0.8) 
			self.Skid_Dirt:ChangePitch(math.min(120 + (SkidSound * Speed / 500),150)) 
		else
			self.Skid:ChangeVolume( math.Clamp(SkidSound * 0.5,0,1) ) 
			self.Skid:ChangePitch(math.min(85 + (SkidSound * Speed / 800) + GripLoss * 22,150)) 
		end
	end
	
	self:NextThink(CurTime() + 0.15)
	return true
end

function ENT:OnRemove()
	self.RollSound_Grass:Stop()
	self.RollSound_Dirt:Stop()
	self.RollSound:Stop()
	
	self.Skid:Stop()
	self.Skid_Grass:Stop()
	self.Skid_Dirt:Stop()
end

function ENT:PhysicsCollide( data, physobj )
	if ( data.Speed > 100 && data.DeltaTime > 0.2 ) then
		if ( data.Speed > 400 ) then 
			self:EmitSound( "Rubber_Tire.ImpactHard" )
			self:EmitSound( "simulated_vehicles/suspension_creak_".. math.Round(math.random(1,6),0) ..".wav" )
		else 
			self:EmitSound( "Rubber.ImpactSoft" )
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
