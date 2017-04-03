include('shared.lua')

function ENT:Initialize()	
	self.FadeHeat = 0
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
	self.Emitter = {}
	
	timer.Simple( 0.01, function()
		if (!IsValid(self)) then return end
		self.Radius = self:BoundingRadius()
	end)
end

function ENT:Think()
	local curtime = CurTime()
	self.SmokeTimer = self.SmokeTimer or 0
	if self.SmokeTimer < curtime then
		self:ManageSmoke()
		self.SmokeTimer = curtime + 0.005
	end
	
	self:NextThink( curtime )
	return true
end

function ENT:ManageSmoke()
	local BaseEnt = self:GetBaseEnt()
	if !IsValid(BaseEnt) then return end
	
	local WheelOnGround = self:GetOnGround()
	local GripLoss = self:GetGripLoss()
	local Material = self:GetSurfaceMaterial()
	
	if WheelOnGround > 0 and (Material == "concrete" or Material == "rock" or Material == "tile") and GripLoss > 0 then
		self.FadeHeat = math.Clamp( self.FadeHeat + GripLoss * 0.07,0,10)
	else
		self.FadeHeat = self.FadeHeat * 0.995
	end
		
	local Scale = self.FadeHeat ^ 3 / 1000
	local SmokeOn = (self.FadeHeat >= 7)
	local DirtOn = GripLoss > 0.05
	local lcolor = BaseEnt:GetTireSmokeColor() * 255
	local Speed = self:GetVelocity():Length()
	local OnRim = self:GetDamaged()
	
	local Forward = self:GetForward()
	local Dir = (BaseEnt:GetGear() < 2) and Forward or -Forward
	
	local WheelSize = self.Radius or 0
	local Pos = self:GetPos()
	
	if SmokeOn and !OnRim then
		self:MakeSmoke( Scale, lcolor, Dir, Pos, WheelSize )
	end
	
	if (WheelOnGround == 0) then return end
	
	if DirtOn then
		self:MakeDirt( GripLoss, Dir, Pos, WheelSize )
	end
	
	if (Speed > 150 or DirtOn) and OnRim then
		self:MakeSparks( GripLoss, Dir, Pos, WheelSize )
	end
end

function ENT:MakeSparks( Scale, Dir, Pos, WheelSize )
	self.NextSpark = self.NextSpark or 0
	if self.NextSpark < CurTime() then
	
		self.NextSpark = CurTime() + 0.03
		local effectdata = EffectData()
			effectdata:SetOrigin( Pos - Vector(0,0,WheelSize * 0.5) )
			effectdata:SetNormal( (Dir + Vector(0,0,0.5)) * Scale * 0.5)
			util.Effect( "manhacksparks", effectdata, true, true )
	end
end

function ENT:Draw()
	return false
end

function ENT:MakeSmoke( Mul, Color, Dir, Pos, WheelSize )
	local Ran = Vector( math.Rand( -WheelSize, WheelSize ), math.Rand( -WheelSize, WheelSize ),math.Rand( -WheelSize, WheelSize ) ) * 0.3
	local OffsetPos = Pos + Ran + Vector(0,0,WheelSize * 0.2)
	
	local OffsetPos2 = OffsetPos + Ran * 0.4 + Vector(0,0,-WheelSize)

	local emitter1 = self:GetEmitter(1, OffsetPos, false )
	local emitter2 = self:GetEmitter(3, OffsetPos2, false )

	local particle1 = emitter1:Add( self.Materials[math.Round(math.Rand(1, table.Count(self.Materials) ),0)], OffsetPos )
	
	local particle2 = emitter2:Add( self.Materials[math.Round(math.Rand(1, table.Count(self.Materials) ),0)], OffsetPos2 )

	if ( particle1 ) then
		particle1:SetVelocity( Vector(0,0,-50) )
		particle1:SetDieTime( 0.5 )
		particle1:SetStartAlpha( 255 * Mul ^ 2 )
		particle1:SetStartSize( 16 * Mul )
		particle1:SetEndSize( 32 * Mul )
		particle1:SetRoll( math.Rand( -1, 1 ) )
		particle1:SetColor( Color.x * 0.9,Color.y * 0.9,Color.z * 0.9 )
		particle1:SetCollide( true )
	end
	
	if ( particle2 ) then
		particle2:SetGravity( Vector(0,0,12) + Ran * 0.2 ) 
		particle2:SetVelocity( Dir * 30 * (3 - Mul) + Vector(0,0,15) + Ran * Mul  )
		particle2:SetDieTime( math.Rand( 2, 4 ) * Mul )
		particle2:SetStartAlpha( 100 * Mul )
		particle2:SetStartSize( WheelSize * 0.7 * Mul )
		particle2:SetEndSize( math.Rand( 80, 160 ) * Mul ^ 2 )
		particle2:SetRoll( math.Rand( -1, 1 ) )
		particle2:SetColor( Color.x,Color.y,Color.z )
		particle2:SetCollide( false )
	end
end

function ENT:MakeDirt( Scale , Dir, Pos, WheelSize )
	local Ran = Vector( math.Rand( -WheelSize, WheelSize ), math.Rand( -WheelSize, WheelSize ),math.Rand( -WheelSize, WheelSize ) ) * 0.3
	local OffsetPos = Pos + Ran + Vector(0,0,WheelSize * 0.2)
	local Vel = self:GetVelocity() / 3
	
	local OffsetPos = OffsetPos + Ran * 0.4 + Vector(0,0,-WheelSize * 0.8)

	local emitter3 = self:GetEmitter(3, OffsetPos, false )

	local particle3 = emitter3:Add( self.Materials[math.Round(math.Rand(1, table.Count(self.Materials) ),0)], OffsetPos )
	
	local Mul = 0.3 + Scale * 0.05
	
	local Color = render.ComputeLighting( Pos, Vector( 0, 0, 1 ) )

	Color.x = 55 + ( math.Clamp( Color.x, 0, 1 ) ) * 200
	Color.y = 55 + ( math.Clamp( Color.y, 0, 1 ) ) * 200
	Color.z = 55 + ( math.Clamp( Color.z, 0, 1 ) ) * 200
	
	if ( particle3 ) then
		particle3:SetGravity( Vector(0,0,12) + Ran * 0.2 ) 
		particle3:SetVelocity( Dir * 10 * (3 - Mul) + Vector(0,0,15) + Ran * Mul + Vel  )
		particle3:SetDieTime( 0.5 )
		particle3:SetStartAlpha( 20 )
		particle3:SetStartSize( WheelSize * 0.7 * Mul )
		particle3:SetEndSize( math.Rand( 80, 160 ) * Mul ^ 2 )
		particle3:SetRoll( math.Rand( -1, 1 ) )
		particle3:SetColor( Color.x,Color.y,Color.z )
		particle3:SetCollide( false )
	end
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

function ENT:OnRemove()
end